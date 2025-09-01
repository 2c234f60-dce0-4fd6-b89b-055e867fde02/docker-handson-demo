# GitHub Copilot 바이브 코딩 워크숍

![GitHub Copilot Vibe Coding Workshop](./images/banner.png)

JavaScript 프론트엔드와 Java 백엔드를 사용하여 소셜 미디어 애플리케이션을 구축하면서 [GitHub Copilot](https://docs.github.com/copilot/about-github-copilot/what-is-github-copilot) 바이브 코딩을 사용해봅시다!

> **Take Home Message:** 
>
> 어? 깃헙 코파일럿 있으니까 할만하네?🤔
>
> 

## 배경

Contoso는 다양한 아웃도어 활동용 제품을 판매하는 회사입니다. Contoso의 마케팅 부서에서는 기존 및 잠재 고객에게 자사 제품을 홍보하기 위한 마이크로 소셜 미디어 웹사이트를 출시하고자 합니다. 첫 번째 MVP로, 그들은 현대적인 웹 기술을 사용하여 빠르게 웹사이트를 구축하고자 합니다. 애플리케이션은 JavaScript로 구축된 React 프론트엔드와 Java로 구축된 Spring Boot 백엔드로 구성됩니다.

하지만 여기서 문제가 발생했습니다...

## 워크숍 목표

- GitHub Copilot Agent 모드를 사용하여 기존 애플리케이션을 컨테이너화합니다.
- GitHub Copilot에 사용자 지침을 추가하여 GitHub Copilot을 원하는대로 제어합니다.
- GitHub Copilot에 다양한 MCP 서버를 추가하여 자유롭게 활용해봅니다.

### 필수 도구

- [Visual Studio Code](https://code.visualstudio.com/)
- VS Code [GitHub Copilot](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot) 확장 프로그램
- VS Code [GitHub Copilot Chat](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot-chat) 확장 프로그램
- [git CLI](https://git-scm.com/downloads)
- [GitHub CLI](https://cli.github.com/)
- [Docker Desktop](https://docs.docker.com/get-started/introduction/get-docker-desktop/)

### JavaScript 프론트엔드 (React + Vite)

- [nvm](https://github.com/nvm-sh/nvm) 또는 [nvm for Windows](https://github.com/coreybutler/nvm-windows)
- nvm을 통한 [Node.js](https://nodejs.org/)의 최신 LTS 버전
- npm (Node.js와 함께 제공됨)

### Java 백엔드 (Spring Boot)

- [SDKMAN](https://sdkman.io/) (권장) 또는 수동 설치
- SDKMAN을 통한 [OpenJDK 17+](https://learn.microsoft.com/java/openjdk/download)
- SDKMAN을 통한 [Gradle Build Tool](https://docs.gradle.org/current/userguide/installation.html) (또는 포함된 래퍼 사용)
- VS Code [Extension Pack for Java](https://marketplace.visualstudio.com/items/?itemName=vscjava.vscode-java-pack) 확장 프로그램
- VS Code [Spring Boot Extension Pack](https://marketplace.visualstudio.com/items/?itemName=vmware.vscode-boot-dev-pack) 확장 프로그램

## 제품 요구 사항 문서

다른 무엇보다도 이 [PRD (Product Requirements Document)](./product-requirements.md) 문서를 가장 먼저 보아야합니다. 이 문서는 무엇을, 어떻게 해야 하는지 요구사항명세가 구체적으로 작성되어 있습니다. 다만, 이번 데모에서는 이러한 PRD를 기반으로 이미 앱을 구축하였다고 가정합니다.

## 워크숍 지침

이 워크숍은 GitHub Copilot으로 구축된 완전한 소셜 미디어 애플리케이션을 시연합니다:

| 단계                               | 링크                                                    |
|------------------------------------|---------------------------------------------------------|
| 00: 개발 환경 설정        | [00-setup.md](./docs/00-setup.md)                       |
| 05: 컨테이너화               | [05-containerization.md](./docs/05-containerization.md) |
| 06: Horizontal scaling              | [06-horizontal-scaling](./06-vertical-scaling.md)  |
| 06: Cloud Deployment                | [07-azure-deploy](./07-azure-deploy.md)            |
| 06: What's next                     | [08-what's-next](./08-what's-next.md)              |

## 더 알아보기...

- [GitHub Codespaces](https://docs.github.com/en/codespaces/about-codespaces/what-are-codespaces)
- [GitHub Copilot](https://docs.github.com/en/copilot/about-github-copilot/what-is-github-copilot)
- [GitHub Copilot: Agent Mode](https://code.visualstudio.com/blogs/2025/04/07/agentMode)
- [GitHub Copilot: MCP](https://code.visualstudio.com/blogs/2025/05/12/agent-mode-meets-mcp)
- [GitHub Copilot: Custom Instructions](https://code.visualstudio.com/docs/copilot/copilot-customization)
- [GitHub Copilot: Changing AI Models](https://docs.github.com/en/copilot/using-github-copilot/ai-models/changing-the-ai-model-for-copilot-chat?tool=vscode)
- [Curated MCP Servers](https://github.com/modelcontextprotocol/servers)
