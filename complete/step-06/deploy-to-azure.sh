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
ACR_NAME="acrsocialapp$SUFFIX"

echo "📋 리소스 그룹 생성: $RESOURCE_GROUP"
az group create --name $RESOURCE_GROUP --location "$LOCATION" --output none

echo "📦 Azure Container Registry 생성: $ACR_NAME"
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic --output none
ACR_LOGIN_SERVER=$(az acr show --resource-group $RESOURCE_GROUP --name $ACR_NAME --query loginServer --output tsv)

echo "🔐 ACR 로그인"
az acr login --name $ACR_NAME

echo "🏗️  Container Apps Environment 생성: $ENVIRONMENT_NAME"
az containerapp env create --name $ENVIRONMENT_NAME --resource-group $RESOURCE_GROUP --location "$LOCATION" --output none

echo "🐳 로컬에서 Docker 이미지 빌드..."
# 백엔드 이미지 - 먼저 로컬 태그로 빌드
echo "  - 백엔드 이미지 빌드 (로컬)"
docker build -t socialapp-backend:latest ./backend

# 프론트엔드 이미지 - 먼저 로컬 태그로 빌드  
echo "  - 프론트엔드 이미지 빌드 (로컬)"
docker build -t socialapp-frontend:latest ./frontend

echo "📤 동일한 이미지를 Azure Container Registry로 푸시..."
# 백엔드 이미지를 ACR 태그로 다시 태그하고 푸시
echo "  - 백엔드 이미지 태그 및 푸시"
docker tag socialapp-backend:latest $ACR_LOGIN_SERVER/socialapp-backend:latest
docker push $ACR_LOGIN_SERVER/socialapp-backend:latest

# 프론트엔드 이미지를 ACR 태그로 다시 태그하고 푸시
echo "  - 프론트엔드 이미지 태그 및 푸시"
docker tag socialapp-frontend:latest $ACR_LOGIN_SERVER/socialapp-frontend:latest
docker push $ACR_LOGIN_SERVER/socialapp-frontend:latest

echo "✅ 로컬 빌드 완료! 동일한 이미지가 이제 Azure에서 실행됩니다."

echo "☁️  Container Apps 배포..."
# 백엔드 Container App 배포
echo "  - 백엔드 서비스 배포"
az containerapp create \
  --resource-group $RESOURCE_GROUP \
  --name socialapp-backend \
  --image $ACR_LOGIN_SERVER/socialapp-backend:latest \
  --environment $ENVIRONMENT_NAME \
  --registry-server $ACR_LOGIN_SERVER \
  --registry-identity system \
  --target-port 8080 \
  --ingress internal \
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
  --registry-identity system \
  --target-port 80 \
  --ingress external \
  --min-replicas 1 \
  --max-replicas 5 \
  --cpu 0.5 \
  --memory 1.0Gi \
  --env-vars VITE_API_URL=https://$BACKEND_FQDN \
  --output none

# 애플리케이션 URL 가져오기
FRONTEND_URL=$(az containerapp show --resource-group $RESOURCE_GROUP --name socialapp-frontend --query "properties.configuration.ingress.fqdn" --output tsv)

echo ""
echo "✅ 배포 완료!"
echo ""
echo "🌐 애플리케이션 URL: https://$FRONTEND_URL"
echo "📊 백엔드 API: https://$BACKEND_FQDN"
echo ""
echo "🔄 스케일링 설정 적용 중..."
az containerapp update \
  --resource-group $RESOURCE_GROUP \
  --name socialapp-backend \
  --scale-rule-name http-scale \
  --scale-rule-type http \
  --scale-rule-http-concurrency 100 \
  --min-replicas 2 \
  --max-replicas 20 \
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