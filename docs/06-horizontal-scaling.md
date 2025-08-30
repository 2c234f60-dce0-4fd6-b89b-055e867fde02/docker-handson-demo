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
       # container_name: socialapp-backend  # 제거: 스케일링을 위해 고정 이름 제거
       environment:
         - SPRING_PROFILES_ACTIVE=docker
         - DATABASE_PATH=/app/data/sns_api.db  # 데이터베이스 경로 환경변수
       # ports: # 제거: 내부 통신만 허용
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
         - "3000:80"  # 외부 접근 허용
       depends_on:
         - backend  # 상태 확인 조건 제거, 단순 의존성만 유지
       networks:
         - appnet
   ```

4. **네트워크 설정 업데이트**: 네트워크 이름을 변경하고 주석을 추가합니다:

   ```yaml
   # 볼륨 설정
   volumes:
     backend-data:
       driver: local
   
   # 네트워크 설정
   networks:
     appnet:  # socialapp-network에서 appnet으로 변경
       driver: bridge
   ```

5. **스케일링 가이드 주석 추가**: 파일 상단에 다음 주석을 추가합니다:

   ```yaml
   # 수평 스케일링 가이드:
   # 백엔드 서비스를 3개 인스턴스로 스케일: docker-compose up --scale backend=3 -d
   # 백엔드 서비스를 5개 인스턴스로 스케일: docker-compose up --scale backend=5 -d
   # 현재 실행 중인 서비스 확인: docker-compose ps
   # 특정 서비스 로그 확인: docker-compose logs -f backend
   
   version: '3.8'
   ```

### 프론트엔드 구성 업데이트

1. `workshop/frontend/nginx.conf` 파일을 열어 스케일된 백엔드 인스턴스와 작동하도록 수정합니다.

2. **API 프록시 설정 수정**: 기존 nginx 설정에서 다음 부분을 확인하고 수정합니다:

   ```nginx
   server {
       listen 80;
       server_name localhost;
       
       # 정적 파일 서빙
       location / {
           root /usr/share/nginx/html;
           index index.html index.htm;
           try_files $uri $uri/ /index.html;
       }
       
       # API 프록시 - 백엔드 서비스로 전달
       location /api/ {
           # Docker 서비스 이름 사용 (Docker가 자동으로 로드 밸런싱 수행)
           proxy_pass http://backend:8080;
           
           # 로드 밸런싱을 위한 프록시 헤더 설정
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
           
           # 컨테이너 네트워킹 최적화
           proxy_connect_timeout 30s;
           proxy_send_timeout 30s;
           proxy_read_timeout 30s;
           
           # 연결 재사용으로 성능 향상
           proxy_http_version 1.1;
           proxy_set_header Connection "";
       }
   }
   ```

3. **중요한 점들**:
   - `proxy_pass http://backend:8080;`: Docker 서비스 이름 `backend`를 사용합니다
   - Docker Compose가 여러 백엔드 인스턴스 간의 로드 밸런싱을 자동으로 처리합니다
   - 프록시 헤더들이 올바른 클라이언트 정보를 백엔드로 전달합니다

### 수평 스케일링 테스트

1. **워크숍 디렉터리로 이동**:

   ```bash
   cd workshop
   ```

2. **스케일링과 함께 서비스 시작**:

   ```bash
   # 백엔드를 3개 인스턴스로 스케일하여 시작
   docker-compose up --scale backend=3 --build -d
   ```

3. **실행 중인 서비스 확인**:

   ```bash
   # 실행 중인 컨테이너 확인
   docker-compose ps
   ```

   출력 예시:
   ```
        Name                     Command               State           Ports
   -----------------------------------------------------------------------------
   workshop_backend_1     java -jar /app/app.jar      Up      8080/tcp
   workshop_backend_2     java -jar /app/app.jar      Up      8080/tcp  
   workshop_backend_3     java -jar /app/app.jar      Up      8080/tcp
   workshop_frontend_1    nginx -g daemon off;         Up      0.0.0.0:3000->80/tcp
   ```

4. **백엔드 로그 모니터링**:

   ```bash
   # 모든 백엔드 인스턴스의 로그를 실시간으로 확인
   docker-compose logs -f backend
   ```

5. **애플리케이션 기능 테스트**:

   - 웹 브라우저를 열고 `http://localhost:3000`으로 접속
   - 여러 게시물을 생성하여 백엔드 로드 분산 테스트
   - 로그에서 다른 백엔드 인스턴스들이 요청을 처리하는 것을 확인

6. **동적 스케일링 테스트**:

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

7. **개별 인스턴스 관리**:

   ```bash
   # 특정 백엔드 인스턴스의 로그만 확인
   docker-compose logs -f backend_1
   
   # 특정 인스턴스 재시작 (다른 인스턴스는 계속 실행)
   docker-compose restart backend_1
   
   # 실시간 리소스 사용량 확인
   docker stats
   ```

### 고급 스케일링 작업

1. **로드 밸런싱 이해하기**:
   
   Docker Compose는 동일한 서비스의 여러 인스턴스 간에 자동으로 로드 밸런싱을 수행합니다:
   - DNS 라운드 로빈 방식 사용
   - 각 요청이 다른 백엔드 인스턴스로 순환 분배
   - 인스턴스가 다운되면 자동으로 트래픽 재분배

2. **실시간 모니터링**:

   ```bash
   # 모든 컨테이너의 실시간 리소스 사용량
   docker stats
   
   # 특정 서비스의 상세 정보
   docker-compose ps backend
   
   # 서비스별 로그를 분리해서 보기
   docker-compose logs --tail=50 backend_1 &
   docker-compose logs --tail=50 backend_2 &
   docker-compose logs --tail=50 backend_3 &
   ```

3. **부하 테스트**:

   ```bash
   # curl을 사용한 간단한 부하 테스트
   for i in {1..20}; do
     curl -X GET http://localhost:3000/api/posts
     echo "Request $i completed"
     sleep 0.5
   done
   ```

4. **장애 복구 테스트**:

   ```bash
   # 특정 백엔드 인스턴스 중지
   docker-compose kill backend_1
   
   # 애플리케이션이 여전히 작동하는지 확인
   curl http://localhost:3000/api/posts
   
   # 중지된 인스턴스 다시 시작
   docker-compose up -d backend
   ```

5. **정리 작업**:

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