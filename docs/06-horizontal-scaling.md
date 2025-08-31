# 06: 수평 스케일링

## 시나리오

소셜 미디어 애플리케이션의 컨테이너화를 성공적으로 완료했습니다! 적어도 내년에는 인프라 환경이 바뀌었다고해서 야근을 할 일은 없겠습니다. 하지만 애플리케이션이 너무도 성공적이어서 사용자 수가 기하급수적으로 늘고 있습니다.

Contoso는 이제 증가하는 트래픽을 처리하기 위해 백엔드를 수평적으로 확장하고자 합니다. 단일 프론트엔드 인스턴스를 유지하면서 백엔드 서비스의 여러 인스턴스를 실행하여 로드를 분산해야 합니다.

이제 당신은 DevOps 엔지니어로서 GitHub Copilot을 사용하여 기존 컨테이너들을 활용하여 확장 가능한 시스템을 만들어야 합니다.

## 전제 조건

- 먼저 이전 단계 step 05 (컨테이너화)를 완료하세요
- 준비 사항에 대해서는 [README](../README.md) 문서를 참고하세요

## 시작하기

- [Step-05를 workshop으로 복사](#step-05를-workshop으로-복사)
- [스케일링을 위한 Docker Compose 수정](#스케일링을-위한-docker-compose-수정)
- [프론트엔드 구성 업데이트](#프론트엔드-구성-업데이트)
- [수평 스케일링 테스트](#수평-스케일링-테스트)

### Step-05를 workshop으로 복사

1. 먼저 `complete/step-05`에서 `workshop`으로 컨테이너화된 애플리케이션을 복사하세요:

   ```bash
   # 저장소 루트에서
   cp -r complete/step-05 workshop
   ```

   이는 GitHub Copilot을 사용하여 스케일링 기능으로 향상시킬 새 디렉터리 구조를 생성합니다.


### 스케일링을 위한 Docker Compose 수정

1. `workshop/docker-compose.yml` 파일을 열어 다음과 같이 수정합니다.

2. **백엔드 서비스 수정**: 여러 인스턴스를 허용하기 위해 백엔드 서비스를 다음과 같이 수정하세요:

   ```yaml
   services:
     # 백엔드 서비스 - 스케일링 가능하도록 수정
     backend:
       build:
         context: ./backend
         dockerfile: Dockerfile
       # container_name: socialapp-backend  # 👈👈 제거: 스케일링을 위해 고정 이름 제거
       environment:
         - SPRING_PROFILES_ACTIVE=docker
         - DATABASE_PATH=/app/data/sns_api.db
       # ports: 👈👈 제거, 도커 내부 접근만 허용
       #   - "8080:8080"
       volumes:
         - backend-data:/app/data
       networks:
         - appnet
       healthcheck:
         test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
         interval: 30s
         timeout: 10s
         retries: 3
   ```

3. **프론트엔드 서비스 수정**: 백엔드에 대한 의존성을 단순화합니다:

   ```yaml
     # 프론트엔드 서비스 - 단일 인스턴스 유지
     frontend:
       build:
         context: ./frontend
         dockerfile: Dockerfile
       container_name: socialapp-frontend
       ports:
         - "3000:80"  # 👈👈 외부 접근 허용
       depends_on:
         - backend
       networks:
         - appnet
   ```

### 프론트엔드 구성 업데이트

1. `workshop/frontend/nginx.conf` 파일을 열어 스케일된 백엔드 인스턴스와 작동하도록 수정합니다.

1. **API 프록시 설정 수정**: 기존 nginx 설정에서 다음 부분을 확인하고 수정합니다:

   ```nginx
   server {
      location /api/ {
            ...
            resolver 127.0.0.11 ipv6=off;
            proxy_pass http://backend:8080;
            ...
       }
   }
   ```

1. **중요한 점들**:
   - `proxy_pass http://backend:8080;`: Docker 서비스 이름 `backend`를 사용합니다
   - `resolver 127.0.0.11 ipv6=off;`: Docker 내부 DNS에서 `backend` 서비스이름을 주기적으로 리졸브합니다.

### 수평 스케일링 테스트

1. **워크숍 디렉터리로 이동**:

   ```bash
   cd workshop
   ```

1. **스케일링과 함께 서비스 시작**:

   ```bash
   # 백엔드를 3개 인스턴스로 스케일하여 시작
   docker-compose up --scale backend=3 --build -d
   ```

1. **동적 스케일링 테스트**:

   ```bash
   # 백엔드를 5개 인스턴스로 확장
   docker-compose up --scale backend=5 -d
   
   # 확인
   docker-compose ps
   
   # 2개 인스턴스로 축소
   docker-compose up --scale backend=2 -d
   
   # 확인
   docker-compose ps
   ```

1. **정리 작업**:

   ```bash
   # 모든 서비스 중지
   docker-compose down
   
   # 볼륨까지 함께 제거 (데이터 삭제 주의!)
   docker-compose down -v
   ```

---

축하합니다! 🎉 GitHub Copilot을 사용하여 컨테이너화된 소셜 미디어 애플리케이션의 수평 스케일링을 성공적으로 구현했습니다! 이제 백엔드는 여러 인스턴스를 실행하여 증가한 로드를 처리할 수 있으며, 프론트엔드는 단일 로드 밸런싱 진입점 역할을 유지합니다.

## 달성한 주요 이점

- **수평 확장성**: 만반에 따라 백엔드를 확장하거나 축소할 수 있습니다
- **로드 분산**: 여러 백엔드 인스턴스가 작업 부하를 공유합니다
- **고가용성**: 한 백엔드 인스턴스가 실패해도 다른 인스턴스가 계속 요청을 처리합니다
- **쉬운 관리**: 간단한 Docker Compose 명령으로 서비스를 스케일할 수 있습니다
- **비용 효율성**: 필요할 때만 리소스를 스케일할 수 있습니다