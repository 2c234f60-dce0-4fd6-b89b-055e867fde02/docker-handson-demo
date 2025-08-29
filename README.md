# GitHub Copilot Vibe Coding Workshop

![GitHub Copilot Vibe Coding Workshop](./images/banner.png)

Let's vibe-code with [GitHub Copilot](https://docs.github.com/copilot/about-github-copilot/what-is-github-copilot) and its newest and greatest features using JavaScript frontend and Java backend to build a social media application. Are you ready to jump in?

## Background

Contoso is a company that sells products for various outdoor activities. A marketing department of Contoso would like to launch a micro social media website to promote their products for existing and potential customers. As their first MVP, they want to quickly build the website using modern web technologies. The application consists of a React frontend built with JavaScript and a Spring Boot backend built with Java.

But here's the situation...

## Workshop Objectives

- Serve applications in docker using GitHub Copilot Agent Mode.
- Add custom instruction to GitHub Copilot so that you have more control over GitHub Copilot.
- Add various MCP servers to GitHub Copilot so that you build the applications more precisely.

### Required Tools

- [Visual Studio Code](https://code.visualstudio.com/)
- VS Code [GitHub Copilot](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot) Extension
- VS Code [GitHub Copilot Chat](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot-chat) Extension
- [git CLI](https://git-scm.com/downloads)
- [GitHub CLI](https://cli.github.com/)
- [Docker Desktop](https://docs.docker.com/get-started/introduction/get-docker-desktop/) (optional)

### JavaScript Frontend (React + Vite)

- [nvm](https://github.com/nvm-sh/nvm) or [nvm for Windows](https://github.com/coreybutler/nvm-windows)
- The latest LTS of [Node.js](https://nodejs.org/) through nvm
- npm (comes with Node.js)

### Java Backend (Spring Boot)

- [SDKMAN](https://sdkman.io/) (recommended) or manual installation
- [OpenJDK 17+](https://learn.microsoft.com/java/openjdk/download) through SDKMAN
- [Gradle Build Tool](https://docs.gradle.org/current/userguide/installation.html) through SDKMAN (or use included wrapper)
- VS Code [Extension Pack for Java](https://marketplace.visualstudio.com/items/?itemName=vscjava.vscode-java-pack) Extension
- VS Code [Spring Boot Extension Pack](https://marketplace.visualstudio.com/items/?itemName=vmware.vscode-boot-dev-pack) Extension

## Product Requirements Document

First and foremost, the place for you to start is this [PRD (Product Requirements Document)](./product-requirements.md). This document will give you a better understanding of what to do and how to do it.

## Workshop Instructions

This workshop demonstrates a complete social media application built with GitHub Copilot:

| Step                               | Link                                                    |
|------------------------------------|---------------------------------------------------------|
| 00: Development Environment        | [00-setup.md](./docs/00-setup.md)                       |
| 05: Containerization               | [05-containerization.md](./docs/05-containerization.md) |


## Read More...

- [GitHub Codespaces](https://docs.github.com/en/codespaces/about-codespaces/what-are-codespaces)
- [GitHub Copilot](https://docs.github.com/en/copilot/about-github-copilot/what-is-github-copilot)
- [GitHub Copilot: Agent Mode](https://code.visualstudio.com/blogs/2025/04/07/agentMode)
- [GitHub Copilot: MCP](https://code.visualstudio.com/blogs/2025/05/12/agent-mode-meets-mcp)
- [GitHub Copilot: Custom Instructions](https://code.visualstudio.com/docs/copilot/copilot-customization)
- [GitHub Copilot: Changing AI Models](https://docs.github.com/en/copilot/using-github-copilot/ai-models/changing-the-ai-model-for-copilot-chat?tool=vscode)
- [Curated MCP Servers](https://github.com/modelcontextprotocol/servers)
