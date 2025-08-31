#!/bin/bash

# Azure 배포 자동화 스크립트
# Docker 컨테이너를 Azure Container Apps에 배포

set -e

# 사용법 출력 함수
usage() {
    echo "사용법: $0 [4자리 숫자]"
    echo "예제: $0 1234"
    echo "       $0        # 랜덤 4자리 숫자 사용"
    exit 1
}

# 4자리 숫자 검증 함수
validate_suffix() {
    if [[ ! $1 =~ ^[0-9]{4}$ ]]; then
        echo "❌ 오류: 4자리 숫자만 입력 가능합니다 (예: 1234)"
        usage
    fi
}

# 명령줄 인수 처리
if [ $# -eq 0 ]; then
    # 인수가 없으면 랜덤 4자리 숫자 생성 (크로스 플랫폼 호환)
    SUFFIX=$(printf "%04d" $((RANDOM % 9000 + 1000)))
    echo "📋 랜덤 접미사 생성: $SUFFIX"
elif [ $# -eq 1 ]; then
    # 인수가 하나면 검증 후 사용
    validate_suffix $1
    SUFFIX=$1
    echo "📋 사용자 지정 접미사: $SUFFIX"
else
    echo "❌ 오류: 인수가 너무 많습니다"
    usage
fi

echo "🚀 Azure Container Apps 배포 시작..."

# 변수 설정
RESOURCE_GROUP="rg-socialapp-$SUFFIX"
LOCATION="Korea Central"
ENVIRONMENT_NAME="cae-socialapp-$SUFFIX"
# ACR 이름은 전역적으로 고유해야 하므로 타임스탬프 추가
TIMESTAMP=$(date +%Y%m%d%H%M)
ACR_NAME="acrsocial${SUFFIX}${TIMESTAMP}"

echo "📋 리소스 그룹 생성: $RESOURCE_GROUP"
az group create --name $RESOURCE_GROUP --location "$LOCATION" --output none

echo "📦 Azure Container Registry 생성: $ACR_NAME"
# ACR 생성 시도
if ! az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic --output none; then
    echo "❌ ACR 생성 실패. 다른 이름으로 시도합니다."
    # 더 고유한 이름으로 재시도
    ACR_NAME="acrsocial${RANDOM}${SUFFIX}"
    echo "📦 다른 이름으로 ACR 재생성: $ACR_NAME"
    az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic --output none
fi

# ACR 로그인 서버 확인
ACR_LOGIN_SERVER=$(az acr show --resource-group $RESOURCE_GROUP --name $ACR_NAME --query loginServer --output tsv)
echo "✅ ACR 생성 완료: $ACR_LOGIN_SERVER"

echo "🔐 ACR 로그인"
if ! az acr login --name $ACR_NAME; then
    echo "❌ ACR 로그인 실패!"
    exit 1
fi

echo "🔑 ACR 관리자 계정 활성화"
az acr update --name $ACR_NAME --admin-enabled true --output none

# ACR이 정상적으로 작동하는지 확인
echo "🔍 ACR 상태 확인"
az acr show --name $ACR_NAME --query "provisioningState" --output tsv

echo "🏗️  Container Apps Environment 생성: $ENVIRONMENT_NAME"
az containerapp env create --name $ENVIRONMENT_NAME --resource-group $RESOURCE_GROUP --location "$LOCATION" --output none

echo "🐳 로컬에서 Docker 이미지 빌드 (AMD64 아키텍처)..."
# 백엔드 이미지 - AMD64 플랫폼으로 빌드 (Azure 호환)
echo "  - 백엔드 이미지 빌드 (AMD64)"
docker build --platform linux/amd64 -t socialapp-backend:latest ./backend

# 프론트엔드 이미지 - AMD64 플랫폼으로 빌드 (Azure 호환)
echo "  - 프론트엔드 이미지 빌드 (AMD64)"
docker build --platform linux/amd64 -t socialapp-frontend:latest ./frontend

echo "📤 동일한 이미지를 Azure Container Registry로 푸시..."
# 백엔드 이미지를 ACR 태그로 다시 태그하고 푸시
echo "  - 백엔드 이미지 태그 및 푸시"
docker tag socialapp-backend:latest $ACR_LOGIN_SERVER/socialapp-backend:latest
if ! docker push $ACR_LOGIN_SERVER/socialapp-backend:latest; then
    echo "❌ 백엔드 이미지 푸시 실패!"
    exit 1
fi

# 프론트엔드 이미지를 ACR 태그로 다시 태그하고 푸시
echo "  - 프론트엔드 이미지 태그 및 푸시"
docker tag socialapp-frontend:latest $ACR_LOGIN_SERVER/socialapp-frontend:latest
if ! docker push $ACR_LOGIN_SERVER/socialapp-frontend:latest; then
    echo "❌ 프론트엔드 이미지 푸시 실패!"
    exit 1
fi

# 푸시된 이미지 확인
echo "✅ 이미지 푸시 완료. ACR에서 확인 중..."
az acr repository list --name $ACR_NAME --output table

echo "✅ 로컬 빌드 완료! 동일한 이미지가 이제 Azure에서 실행됩니다."

echo "🔑 ACR 자격 증명 가져오기"
ACR_USERNAME=$(az acr credential show --resource-group $RESOURCE_GROUP --name $ACR_NAME --query username --output tsv)
ACR_PASSWORD=$(az acr credential show --resource-group $RESOURCE_GROUP --name $ACR_NAME --query passwords[0].value --output tsv)

echo "☁️  Container Apps 배포..."
# 백엔드 Container App 배포
echo "  - 백엔드 서비스 배포"
az containerapp create \
  --resource-group $RESOURCE_GROUP \
  --name socialapp-backend \
  --image $ACR_LOGIN_SERVER/socialapp-backend:latest \
  --environment $ENVIRONMENT_NAME \
  --registry-server $ACR_LOGIN_SERVER \
  --registry-username $ACR_USERNAME \
  --registry-password $ACR_PASSWORD \
  --target-port 8080 \
  --ingress external \
  --min-replicas 1 \
  --max-replicas 10 \
  --cpu 1.0 \
  --memory 2.0Gi \
  --env-vars SPRING_PROFILES_ACTIVE=docker \
  --output none

# 백엔드 FQDN 가져오기
BACKEND_FQDN=$(az containerapp show --resource-group $RESOURCE_GROUP --name socialapp-backend --query "properties.configuration.ingress.fqdn" --output tsv)

# 프론트엔드 Container App 배포
echo "  - 프론트엔드 서비스 배포"
az containerapp create \
  --resource-group $RESOURCE_GROUP \
  --name socialapp-frontend \
  --image $ACR_LOGIN_SERVER/socialapp-frontend:latest \
  --environment $ENVIRONMENT_NAME \
  --registry-server $ACR_LOGIN_SERVER \
  --registry-username $ACR_USERNAME \
  --registry-password $ACR_PASSWORD \
  --target-port 8080 \
  --ingress external \
  --min-replicas 1 \
  --max-replicas 5 \
  --cpu 0.5 \
  --memory 1.0Gi \
  --env-vars VITE_API_URL=http://$BACKEND_FQDN:8080 \
  --output none

# 애플리케이션 URL 가져오기
FRONTEND_URL=$(az containerapp show --resource-group $RESOURCE_GROUP --name socialapp-frontend --query "properties.configuration.ingress.fqdn" --output tsv)

echo ""
echo "✅ 배포 완료!"
echo ""
echo "🌐 애플리케이션 URL: https://$FRONTEND_URL"
echo "📊 백엔드 API: http://$BACKEND_FQDN:8080"
echo ""
echo "🔄 스케일링 설정 적용 중..."
az containerapp update \
  --resource-group $RESOURCE_GROUP \
  --name socialapp-backend \
  --scale-rule-name http-scale \
  --scale-rule-type http \
  --scale-rule-http-concurrency 2 \
  --min-replicas 2 \
  --max-replicas 4 \
  --output none

echo ""
echo "🎉 소셜 미디어 앱이 Azure에 성공적으로 배포되었습니다!"
echo "   로컬에서 실행하던 동일한 컨테이너가 이제 클라우드에서 실행됩니다."
echo ""
echo "📋 배포된 리소스:"
echo "   - 리소스 그룹: $RESOURCE_GROUP"
echo "   - Container Registry: $ACR_NAME"
echo "   - Container Apps Environment: $ENVIRONMENT_NAME"
echo ""
echo "🧹 정리하려면: az group delete --name $RESOURCE_GROUP --yes --no-wait"