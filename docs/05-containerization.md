# 05: 컨테이너화

## 시나리오

Contoso는 다양한 아웃도어 활동용 제품을 판매하는 회사입니다. Contoso의 마케팅 부서에서는 기존 및 잠재 고객에게 자사 제품을 홍보하기 위한 마이크로 소셜 미디어 웹사이트를 출시하고자 합니다.

장기간 프로젝트를 수행하여 Java 기반 백엔드 앱과 React 기반 프론트엔드 앱을 모두 보유하고 있습니다. 그러나 앱을 서빙하기 직전 업체가 탈주했고, 회사는 내부 이슈로 내년도에 인프라 환경 전면 교체를 계획하고 있습니다. 이 기회에 당신은 어떤 환경에서도 동일하게 앱을 서빙할 수 있도록 컨테이너화 기술을 도입하고자 합니다.

이제 당신은 DevOps 엔지니어로서 GitHub Copilot을 사용해 두 앱을 모두 컨테이너화해야 합니다.

## 전제 조건

준비 사항에 대해서는 [README](../README.md) 문서를 참고하세요.

## 시작하기

- [기본 애플리케이션을 workshop으로 복사](#기본-애플리케이션을-workshop으로-복사)
- [GitHub Copilot Agent 모드 확인](#github-copilot-agent-모드-확인)
- [사용자 지정 지침 준비](#사용자-지정-지침-준비)
- [Java 백엔드 애플리케이션 컨테이너화](#java-백엔드-애플리케이션-컨테이너화)
- [React 프론트엔드 애플리케이션 컨테이너화](#react-프론트엔드-애플리케이션-컨테이너화)
- [컨테이너 오케스트레이션](#컨테이너-오케스트레이션)

### 기본 애플리케이션을 workshop으로 복사

1. 먼저 `complete/step-00`에서 `workshop`으로 기본 애플리케이션을 복사하세요:

   ```bash
   # 저장소 루트에서
   rm -rf workshop/*
   cp -r complete/step-00/* workshop
   cd workshop
   ```

   이는 GitHub Copilot을 사용하여 컨테이너화로 향상시킬 새 디렉터리 구조를 생성합니다.

### GitHub Copilot Agent 모드 확인

1. VS Code 상단에 있는 GitHub Copilot 아이콘을 클릭하여 GitHub Copilot 창을 열어주세요.

   ![Open GitHub Copilot Chat](./images/setup-02.png)

1. 로그인이나 가입을 요구받으면 진행하세요. 무료입니다.
1. GitHub Copilot Agent 모드를 사용하고 있는지 확인하세요.

   ![GitHub Copilot Agent Mode](./images/setup-03.png)

1. 모델을 `GPT-4.1` 또는 `Claude Sonnet 4` 중 하나로 선택하세요.
1. [MCP 서버](./00-setup.md#mcp-서버-설정하기)를 구성했는지 확인하세요.

### 사용자 지정 지침 준비

1. `$REPOSITORY_ROOT` 환경 변수를 설정하세요.

   ```bash
   # bash/zsh
   REPOSITORY_ROOT=$(git rev-parse --show-toplevel)
   ```

   ```powershell
   # PowerShell
   $REPOSITORY_ROOT = git rev-parse --show-toplevel
   ```

1. 사용자 지침을 복사하세요.

    ```bash
    # bash/zsh
    cp -r $REPOSITORY_ROOT/docs/custom-instructions/containerization/. \
          $REPOSITORY_ROOT/.github/
    ```

    ```powershell
    # PowerShell
    Copy-Item -Path $REPOSITORY_ROOT/docs/custom-instructions/containerization/* `
              -Destination $REPOSITORY_ROOT/.github/ -Recurse -Force
    ```

### Java 백엔드 애플리케이션 컨테이너화

1. `Claude Sonnet 4` 또는 `GPT-4.1` 모델로 GitHub Copilot Agent 모드를 사용하고 있는지 확인하세요.
1. Java 백엔드 앱의 컨테이너 이미지를 빌드하기 위해 아래와 같은 프롬프트를 사용하세요.

    ```text
    Java Spring Boot 앱의 컨테이너 이미지를 빌드하고 싶습니다. 아래 지시사항을 따라주세요.

    - 먼저 수행할 모든 단계를 식별하세요.
    - Java 앱은 `workshop/backend`에 위치해 있습니다.
    - 작업 디렉터리는 저장소 루트입니다.
    - `workshop/backend` 디렉터리에 Dockerfile을 생성하세요.
    - Amazon Corretto JDK 17 Alpine를 사용합니다.
    - 백엔드 서비스포트를 호스트로 연결해주세요.
    - 백엔드 디렉토리 안에 sqlite `sns_api.db` 파일이 있습니다. 호스트에서 해당 파일을 복사하지 말고 컨테이너 내부에서 새로 만드세요.
    - 보안을 고려해서 사용자 설정 등을 구성하세요.
    ```

1. 변경 사항을 반영하려면 GitHub Copilot의 ![the keep button image](https://img.shields.io/badge/keep-blue) 버튼을 클릭하세요.

1. `Dockerfile`이 생성되면 다음 프롬프트로 컨테이너 이미지를 빌드하세요.

    ```text
    `workshop/backend`에 있는 Dockerfile을 사용하여 컨테이너 이미지를 빌드하세요.

    - 컨테이너 이미지 이름으로 `socialapp-backend`를 사용하세요.
    - 컨테이너 이미지 태그로 `latest`를 사용하세요.
    - 컨테이너 이미지가 제대로 빌드되었는지 확인하세요.
    - 빌드가 실패하면 문제를 분석하고 수정하세요.
    ```

1. 변경 사항을 반영하려면 GitHub Copilot의 ![the keep button image](https://img.shields.io/badge/keep-blue) 버튼을 클릭하세요.

1. 빌드가 성공하면 다음 프롬프트로 컨테이너 이미지를 실행하세요.

    ```text
    방금 빌드한 컨테이너 이미지를 사용하여 컨테이너를 실행하고 앱이 제대로 실행되고 있는지 확인하세요.
    
    - 백엔드 서비스 포트와 동일한 것으로 호스트/컨테이너 포트를 연결합니다.
    - 상태 엔드포인트에 접근 가능한지 확인하세요.
    ```

### React 프론트엔드 애플리케이션 컨테이너화

1. `Claude Sonnet 4` 또는 `GPT-4.1` 모델로 GitHub Copilot Agent 모드를 사용하고 있는지 확인하세요.
2. React 프론트엔드 앱의 컨테이너 이미지를 빌드하기 위해 다음 프롬프트를 사용하세요:

    ```text
    React 프론트엔드 앱의 컨테이너 이미지를 빌드하고 싶습니다. 아래 지시사항을 따라주세요.

    - 먼저 수행할 모든 단계를 식별하세요.
    - 프론트엔드 앱은 `workshop/frontend`에 위치해 있습니다.
    - 작업 디렉터리는 저장소 루트입니다.
    - `workshop/frontend` 디렉터리에 `Dockerfile`이라는 이름의 Dockerfile을 생성하세요.
    - 빌드 단계에서는 Node.js 18-alpine을 사용하세요.
    - 프로덕션 단계에서는 nginx:1.25-alpine을 사용하세요.
    - 다단계 빌드 접근 방식을 사용하세요.
    - `npm ci`와 `npm run build`를 사용하여 앱을 빌드하세요.
    - Nginx로 빌드된 파일을 서브하세요.
    - 컨테이너 이미지에 포트 `80`을 노출하세요.
    - 라우팅과 API 프록시를 위해 사용자 지정 `nginx.conf`를 복사하고 사용하세요.
    - 보안을 위해 비root 사용자로 실행하세요.
    - 상태 확인 엔드포인트를 추가하세요.
    ```

3. 변경 사항을 반영하려면 GitHub Copilot의 ![the keep button image](https://img.shields.io/badge/keep-blue) 버튼을 클릭하세요.

4. `Dockerfile`이 생성되면 다음 프롬프트로 컨테이너 이미지를 빌드하세요:

    ```text
    `workshop/frontend`에 있는 Dockerfile을 사용하여 컨테이너 이미지를 빌드하세요.

    - 컨테이너 이미지 이름으로 `socialapp-frontend`를 사용하세요.
    - 컨테이너 이미지 태그로 `latest`를 사용하세요.
    - 컨테이너 이미지가 제대로 빌드되었는지 확인하세요.
    - 빌드가 실패하면 문제를 분석하고 수정하세요.
    ```

5. 변경 사항을 반영하려면 GitHub Copilot의 ![the keep button image](https://img.shields.io/badge/keep-blue) 버튼을 클릭하세요.

6. 빌드가 성공하면 다음 프롬프트로 컨테이너 이미지를 실행하세요:

    ```text
    방금 빌드한 컨테이너 이미지를 사용하여 컨테이너를 실행하고 앱이 제대로 실행되고 있는지 확인하세요.
    
    - 호스트 포트 `3000`을 사용하여 컨테이너 포트 `80`에 매핑하세요.
    - Nginx 설정이 `/api` 요청을 백엔드로 프록시하는지 확인하세요.
    ```

7. 프론트엔드와 백엔드 앱이 아직 서로를 모르기 때문에 서로 통신하지 않는지 확인하세요. 다음과 같은 프롬프트를 실행하세요:

    ```text
    백엔드와 프론트엔드 컨테이너와 각각의 컨테이너 이미지를 모두 제거하세요.
    ```

### 컨테이너 오케스트레이션

1. `Claude Sonnet 4` 또는 `GPT-4.1` 모델로 GitHub Copilot Agent 모드를 사용하고 있는지 확인하세요.
1. Docker Compose 파일을 빌드하기 위해 아래와 같은 프롬프트를 사용하세요.

    ```text
    Docker Compose 파일을 만들고 싶습니다. 아래 지시사항을 따라주세요.
    
    - 먼저 수행할 모든 단계를 식별하세요.
    - 작업 디렉터리는 저장소 루트입니다.
    - `workshop` 디렉터리에 `docker-compose.yml`을 생성하세요.
    - 백엔드 서비스에는 `./backend`에 있는 Dockerfile을 사용하세요.
    - 프론트엔드 서비스에는 `./frontend`에 있는 Dockerfile을 사용하세요.
    - 네트워크 이름으로 `socialapp-network`를 사용하세요.
    - Java 앱의 컨테이너 이름으로 `socialapp-backend`를 사용하세요. 대상 포트는 8080이고 호스트 포트는 8080입니다.
    - React 앱의 컨테이너 이름으로 `socialapp-frontend`를 사용하세요. 대상 포트는 80이고 호스트 포트는 3000입니다.
    - 백엔드 컨테이너에 환경 변수 `SPRING_PROFILES_ACTIVE=docker`를 추가하세요.
    - 두 서비스 모두에 상태 확인을 추가하세요.
    - 프론트엔드가 백엔드가 정상 상태가 될 때까지 기다리도록 의존성을 추가하세요.
    - 백엔드 데이터 지속성을 위한 볼륨을 생성하세요.
    ```

1. 변경 사항을 반영하려면 GitHub Copilot의 ![the keep button image](https://img.shields.io/badge/keep-blue) 버튼을 클릭하세요.

1. `docker-compose.yml` 파일이 생성되면 실행하고 두 앱 모두 제대로 실행되는지 확인하세요.

    ```text
    Docker compose 파일을 실행하고 모든 앱이 제대로 실행되는지 확인하세요.
    
    - `workshop` 디렉터리로 이동하세요.
    - `docker-compose up --build -d`를 사용하여 서비스를 시작하세요.
    - 두 서비스가 성공적으로 시작되는지 로그를 확인하세요.
    - 두 서비스가 정상 상태인지 확인하세요.
    ```

1. 웹 브라우저를 열고 `http://localhost:3000`으로 이동하여 앱이 정상적으로 실행되고 서로 통신할 수 있는지 확인하세요.

---

축하합니다! 🎉 GitHub Copilot을 사용하여 Java 백엔드와 React 프론트엔드 애플리케이션을 모두 성공적으로 컨테이너화했습니다! 이제 애플리케이션이 Docker 컨테이너를 지원하는 모든 플랫폼에 배포할 준비가 되었습니다.
