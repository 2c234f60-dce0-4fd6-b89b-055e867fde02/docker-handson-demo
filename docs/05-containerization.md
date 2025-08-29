# 05: Containerization

## Scenario

Contoso is a company that sells products for various outdoor activities. A marketing department of Contoso would like to launch a micro social media website to promote their products for existing and potential customers.

They now have both Java-based backend app and React-based frontend app. They want to make them containerized so that they can be deployed on any platform.

Now, as a DevOps engineer, you should containerize both apps using GitHub Copilot by copying the complete/step-00 directory to workshop and adding containerization.

## Prerequisites

Refer to the [README](../README.md) doc for preparation.

## Getting Started

- [Copy Base Application to Step-05](#copy-base-application-to-step-05)
- [Check GitHub Copilot Agent Mode](#check-github-copilot-agent-mode)
- [Prepare Custom Instructions](#prepare-custom-instructions)
- [Containerize Java Backend Application](#containerize-java-backend-application)
- [Containerize React Frontend Application](#containerize-react-frontend-application)
- [Orchestrate Containers](#orchestrate-containers)

### Copy Base Application to Step-05

1. First, copy the base application from `complete/step-00` to `workshop`:

   ```bash
   # From repository root
   cp -r complete/step-00 workshop
   ```

   This creates a new directory structure that you will enhance with containerization using GitHub Copilot.

### Check GitHub Copilot Agent Mode

1. Click the GitHub Copilot icon on the top of GitHub Codespace or VS Code and open GitHub Copilot window.

   ![Open GitHub Copilot Chat](./images/setup-02.png)

1. If you're asked to login or sign up, do it. It's free of charge.
1. Make sure you're using GitHub Copilot Agent Mode.

   ![GitHub Copilot Agent Mode](./images/setup-03.png)

1. Select model to either `GPT-4.1` or `Claude Sonnet 4`.
1. Make sure that you've configured [MCP Servers](./00-setup.md#set-up-mcp-servers).

### Prepare Custom Instructions

1. Set the environment variable of `$REPOSITORY_ROOT`.

   ```bash
   # bash/zsh
   REPOSITORY_ROOT=$(git rev-parse --show-toplevel)
   ```

   ```powershell
   # PowerShell
   $REPOSITORY_ROOT = git rev-parse --show-toplevel
   ```

1. Copy custom instructions.

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

### Containerize Java Backend Application

1. Make sure that you're using GitHub Copilot Agent Mode with the model of `Claude Sonnet 4` or `GPT-4.1`.
1. Use prompt like below to build a container image for the Java backend app.

    ```text
    I'd like to build a container image of a Java Spring Boot app. Follow the instructions below.

    - Identify all the steps first, which you're going to do.
    - The Java app is located at `workshop/backend`.
    - Your working directory is the repository root.
    - Create a Dockerfile in the `workshop/backend` directory.
    - Use Amazon Corretto JDK 17 Alpine for the build stage.
    - Use Amazon Corretto JRE 17 Alpine for the runtime stage.
    - Use multi-stage build approach.
    - Use the target port number of `8080` for the container image.
    - Create an SQLite database file, `sns_api.db`, in the container image. DO NOT copy the file from the host.
    - Add health check using the Spring Boot Actuator endpoint.
    - Run as non-root user for security.
    ```

1. Click the ![the keep button image](https://img.shields.io/badge/keep-blue) button of GitHub Copilot to take the changes.

1. Once `Dockerfile` is created, build the container image with the following prompt.

    ```text
    Use the Dockerfile in `workshop/backend` and build a container image.

    - Use `socialapp-backend` as the container image name.
    - Use `latest` as the container image tag.
    - Verify if the container image is built properly.
    - If the build fails, analyze the issues and fix them.
    ```

1. Click the ![the keep button image](https://img.shields.io/badge/keep-blue) button of GitHub Copilot to take the changes.

1. Once the build succeeds, run the container image with the following prompt.

    ```text
    Use the container image just built, run a container and verify if the app is running properly.
    
    - Use the host port of `8080` and map it to container port `8080`.
    - Verify the health endpoint is accessible.
    ```

### Containerize React Frontend Application

1. Make sure that you're using GitHub Copilot Agent Mode with the model of `Claude Sonnet 4` or `GPT-4.1`.
2. Use the following prompt to build a container image for the React frontend app:

    ```text
    I'd like to build a container image of a React frontend app. Follow the instructions below.

    - Identify all the steps first, which you're going to do.
    - The frontend app is located at `workshop/frontend`.
    - Your working directory is the repository root.
    - Create a Dockerfile named `Dockerfile` in the `workshop/frontend` directory.
    - Use Node.js 18-alpine for the build stage.
    - Use nginx:1.25-alpine for the production stage.
    - Use multi-stage build approach.
    - Build the app using `npm ci` and `npm run build`.
    - Serve the built files with Nginx.
    - Expose port `80` for the container image.
    - Copy and use the custom `nginx.conf` for routing and API proxy.
    - Run as non-root user for security.
    - Add health check endpoint.
    ```

3. Click the ![the keep button image](https://img.shields.io/badge/keep-blue) button of GitHub Copilot to take the changes.

4. Once `Dockerfile` is created, build the container image with the following prompt:

    ```text
    Use the Dockerfile in `workshop/frontend` and build a container image.

    - Use `socialapp-frontend` as the container image name.
    - Use `latest` as the container image tag.
    - Verify if the container image is built properly.
    - If the build fails, analyze the issues and fix them.
    ```

5. Click the ![the keep button image](https://img.shields.io/badge/keep-blue) button of GitHub Copilot to take the changes.

6. Once the build succeeds, run the container image with the following prompt:

    ```text
    Use the container image just built, run a container and verify if the app is running properly.
    
    - Use the host port of `3000` and map it to container port `80`.
    - Ensure the Nginx config proxies `/api` requests to the backend.
    ```

7. Make sure that both frontend and backend apps are NOT communicating with each other because they don't know each other yet. Run the prompt like below:

    ```text
    Remove both backend and frontend containers and their respective container images.
    ```

### Orchestrate Containers

1. Make sure that you're using GitHub Copilot Agent Mode with the model of `Claude Sonnet 4` or `GPT-4.1`.
1. Use prompt like below to build a Docker Compose file.

    ```text
    I'd like to create a Docker Compose file. Follow the instructions below.
    
    - Identify all the steps first, which you're going to do.
    - Your working directory is the repository root.
    - Create `docker-compose.yml` in the `workshop` directory.
    - Use the Dockerfile in `./backend` for the backend service.
    - Use the Dockerfile in `./frontend` for the frontend service.
    - Use `socialapp-network` as the network name.
    - Use `socialapp-backend` as the container name of the Java app. Its target port is 8080, and host port is 8080.
    - Use `socialapp-frontend` as the container name of the React app. Its target port is 80, and host port is 3000.
    - Add environment variable `SPRING_PROFILES_ACTIVE=docker` to the backend container.
    - Add health checks for both services.
    - Add dependency so frontend waits for backend to be healthy.
    - Create a volume for backend data persistence.
    ```

1. Click the ![the keep button image](https://img.shields.io/badge/keep-blue) button of GitHub Copilot to take the changes.

1. Once the `docker-compose.yml` file is created, run it and verify if both apps are running properly.

    ```text
    Run the Docker compose file and verify if all the apps are running properly.
    
    - Navigate to the `workshop` directory.
    - Use `docker-compose up --build -d` to start the services.
    - Check the logs to ensure both services start successfully.
    - Verify both services are healthy.
    ```

1. Open a web browser and navigate to `http://localhost:3000`, and verify if the apps are up and running properly and can communicate with each other.

---

Congratulations! 🎉 You've successfully containerized both the Java backend and React frontend applications using GitHub Copilot! The applications are now ready for deployment on any platform that supports Docker containers.
