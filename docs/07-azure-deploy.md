# 07: 클라우드 배포 - 어디서나 동일한 환경

## 🎯 핵심 메시지

> **"로컬에서 실행하던 동일한 Docker 컨테이너가 클라우드에서도 똑같이 실행됩니다"**  
> 컨테이너의 진정한 힘 - Write Once, Run Anywhere

## 시나리오

지금까지 개발한 소셜 미디어 앱을 Azure 클라우드에 배포해봅시다.
로컬 Docker Compose와 동일한 컨테이너를 클라우드에서 실행하여 **완전히 동일한 환경**을 보장합니다.

## 🚀 원클릭 배포

### 전제 조건
- Azure 구독 (무료 계정 가능)
- Azure CLI 설치 및 로그인 완료

```bash
# Azure 로그인 확인
az account show
```

### 자동화된 배포 실행

```bash
# Step-06 디렉터리 복사
rm -rf workshop/*
cp -r complete/step-06/* workshop/
cd workshop

# 원클릭 배포 스크립트 실행
./deploy-to-azure.sh
```

**이게 전부입니다!** 스크립트가 자동으로:
- ☁️ Azure Container Registry 생성
- 🐳 Docker 이미지 빌드 및 업로드
- 🚀 Container Apps 배포
- ⚡ 자동 스케일링 설정
- 🌐 공개 URL 제공

## 🎬 데모 진행 순서

### 1. 로컬 환경 확인
```bash
# 로컬에서 실행 중인 컨테이너 확인
docker-compose ps
```

### 2. 배포 시작
```bash
# 자동화 스크립트 실행
./deploy-to-azure.sh
```

### 3. 결과 확인
- 📱 **로컬**: `http://localhost:3000`
- ☁️ **Azure**: `https://your-app.azurecontainerapps.io`
- ✨ **동일한 애플리케이션이 클라우드에서 실행!**

## 🔄 배포 과정 (스크립트 내부)

스크립트는 다음 단계를 자동 실행합니다:

1. **인프라 생성** - Azure 리소스 그룹, Container Registry
2. **이미지 배포** - 로컬과 동일한 Docker 이미지를 클라우드로
3. **서비스 실행** - Container Apps에서 컨테이너 실행
4. **자동 스케일링** - 트래픽에 따른 자동 확장/축소

## 💡 핵심 장점

| 특징 | 로컬 개발 | Azure 프로덕션 |
|-----|----------|----------------|
| **환경** | Docker 컨테이너 | 동일한 Docker 컨테이너 |
| **코드** | 동일 | 동일 |
| **설정** | docker-compose.yml | Container Apps |
| **스케일링** | 수동 | 자동 (1-20 인스턴스) |
| **가용성** | 단일 머신 | 고가용성 클러스터 |

## 🧪 배포 테스트

배포가 완료되면 다음을 확인해보세요:

```bash
# 애플리케이션 상태 확인
az containerapp show --resource-group rg-socialapp --name socialapp-frontend --query "properties.provisioningState"

# 실행 중인 인스턴스 수 확인
az containerapp replica list --resource-group rg-socialapp --name socialapp-backend --output table

# 애플리케이션 로그 확인
az containerapp logs show --resource-group rg-socialapp --name socialapp-backend --follow
```

## 🧹 정리

```bash
# 리소스 정리 (Azure 요금 절약)
az group delete --name rg-socialapp --yes --no-wait
```

---

## ✨ 달성한 것

🎯 **Write Once, Run Anywhere**: 동일한 컨테이너가 로컬과 클라우드에서 실행  
🚀 **원클릭 배포**: 복잡한 클라우드 인프라를 한 번의 명령으로 구성  
⚡ **자동 스케일링**: 트래픽에 따라 자동으로 서버 확장/축소  
🛡️ **프로덕션 준비**: 로드 밸런서, SSL, 모니터링 자동 구성

**이것이 바로 컨테이너 기술의 진정한 가치입니다!**

## 🎥 데모 포인트

1. **환경 일관성**: 로컬과 클라우드에서 동일한 Docker 이미지 실행
2. **배포 단순성**: 한 번의 스크립트 실행으로 전체 인프라 구성
3. **자동 스케일링**: 실시간 트래픽 증가에 따른 인스턴스 자동 확장
4. **운영 효율성**: 코드 변경 없이 어떤 클라우드든 배포 가능

이 데모를 통해 컨테이너가 어떻게 **개발과 운영의 간극을 해결**하고, **진정한 DevOps**를 가능하게 하는지 보여줄 수 있습니다.