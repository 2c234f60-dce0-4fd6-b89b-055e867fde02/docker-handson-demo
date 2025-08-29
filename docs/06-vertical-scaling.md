# 06: Vertical Scaling

## Scenario

After successfully containerizing the social media application, Contoso now wants to handle increased traffic by scaling their backend horizontally. They need to run multiple instances of the backend service to distribute the load while keeping a single frontend instance.

As a DevOps engineer, you will use GitHub Copilot to modify the existing containerized application from step-05 to create a scalable version in step-06.

## Prerequisites

- Complete step 05 (Containerization) first
- Refer to the [README](../README.md) doc for preparation

## Getting Started

- [Copy Step-05 to Step-06](#copy-step-05-to-step-06)
- [Check GitHub Copilot Agent Mode](#check-github-copilot-agent-mode)
- [Modify Docker Compose for Scaling](#modify-docker-compose-for-scaling)
- [Update Frontend Configuration](#update-frontend-configuration)
- [Test Horizontal Scaling](#test-horizontal-scaling)

### Copy Step-05 to Step-06

1. First, copy the containerized application from `complete/step-05` to `workshop`:

   ```bash
   # From repository root
   cp -r complete/step-05 workshop
   ```

   This creates a new directory structure that you will enhance with scaling capabilities using GitHub Copilot.

### Check GitHub Copilot Agent Mode

1. Click the GitHub Copilot icon on the top of GitHub Codespace or VS Code and open GitHub Copilot window.

   ![Open GitHub Copilot Chat](./images/setup-02.png)

1. If you're asked to login or sign up, do it. It's free of charge.
1. Make sure you're using GitHub Copilot Agent Mode.

   ![GitHub Copilot Agent Mode](./images/setup-03.png)

1. Select model to either `GPT-4.1` or `Claude Sonnet 4`.

### Modify Docker Compose for Scaling

1. Make sure that you're using GitHub Copilot Agent Mode with the model of `Claude Sonnet 4` or `GPT-4.1`.
2. Use the following prompt to modify the Docker Compose file for horizontal scaling:

    ```text
    I'd like to modify the Docker Compose file to support horizontal scaling of the backend. Follow the instructions below.

    - Identify all the steps first, which you're going to do.
    - The Docker Compose file is located at `workshop/docker-compose.yml`.
    - Your working directory is the repository root.
    - Remove the `container_name` from the backend service to allow multiple instances.
    - Remove the explicit `ports` mapping from the backend service so it's only accessible internally.
    - Keep the frontend service as a single instance with ports exposed.
    - Update the network configuration to use `appnet` as the network name.
    - Add comments explaining how to scale the backend service.
    - Ensure the backend uses environment variables for database configuration.
    - Update the frontend dependencies to just depend on `backend` service without health check conditions.
    ```

3. Click the ![the keep button image](https://img.shields.io/badge/keep-blue) button of GitHub Copilot to take the changes.

### Update Frontend Configuration

1. Use the following prompt to ensure the frontend can connect to scaled backend instances:

    ```text
    I need to update the frontend nginx configuration to work with scaled backend instances. Follow the instructions below.

    - Identify all the steps first, which you're going to do.
    - The nginx configuration is at `workshop/frontend/nginx.conf`.
    - Your working directory is the repository root.
    - Ensure the `/api` proxy pass uses the Docker service name `backend` (Docker will load balance automatically).
    - Make sure the proxy configuration can handle multiple backend instances.
    - Add appropriate proxy headers for load balancing.
    - Ensure the configuration is optimized for container networking.
    ```

2. Click the ![the keep button image](https://img.shields.io/badge/keep-blue) button of GitHub Copilot to take the changes.

### Test Horizontal Scaling

1. Use the following prompt to test the scaled application:

    ```text
    I want to test the horizontally scaled application. Follow the instructions below.

    - Identify all the steps first, which you're going to do.
    - Navigate to the `workshop` directory.
    - Build and start the services with scaling using Docker Compose.
    - Scale the backend service to 3 instances.
    - Verify that multiple backend instances are running.
    - Check the logs of all backend instances.
    - Test the application functionality through the frontend.
    - Show how to scale up and scale down the backend instances.
    ```

2. Click the ![the keep button image](https://img.shields.io/badge/keep-blue) button of GitHub Copilot to take the changes.

3. Once the scaling is working, test the application with the following prompt:

    ```text
    Test the scaled application to ensure it works properly.

    - Open a web browser and navigate to `http://localhost:80`.
    - Create several posts to test backend load distribution.
    - Check the logs of different backend instances to see load distribution.
    - Verify that the application remains responsive with multiple backend instances.
    ```

### Advanced Scaling Operations

1. Use the following prompt to learn about advanced scaling operations:

    ```text
    Show me advanced scaling operations for the containerized application.

    - Demonstrate how to scale the backend to 5 instances.
    - Show how to scale down to 2 instances.
    - Explain how Docker Compose handles load balancing between instances.
    - Show how to view real-time logs from all scaled instances.
    - Demonstrate how to restart individual instances without affecting others.
    ```

---

Congratulations! <� You've successfully implemented horizontal scaling for your containerized social media application using GitHub Copilot! The backend can now handle increased load by running multiple instances while the frontend remains as a single load-balancing entry point.

## Key Benefits Achieved

- **Horizontal Scalability**: Backend can be scaled up or down based on demand
- **Load Distribution**: Multiple backend instances share the workload
- **High Availability**: If one backend instance fails, others continue serving requests
- **Easy Management**: Simple Docker Compose commands to scale services
- **Cost Efficiency**: Scale resources only when needed