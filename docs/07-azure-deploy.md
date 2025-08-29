# 07: Azure Deployment

## Scenario

After successfully containerizing and scaling the social media application, Contoso wants to deploy their application to Azure for production use. They will use Azure Container Registry to store their Docker images and Azure Container Apps for hosting the scalable application.

As a DevOps engineer, you will use Azure Developer CLI (`azd`) to streamline the deployment process to Azure.

## Prerequisites

- Completed steps 05 (Containerization) and 06 (Vertical Scaling)
- Azure subscription (free tier available)
- Docker Desktop installed and running
- Azure Developer CLI (`azd`) installed
- Azure CLI (`az`) installed
- Refer to the [README](../README.md) doc for preparation

## Getting Started

- [Install Required Tools](#install-required-tools)
- [Prepare Azure Configuration](#prepare-azure-configuration)
- [Create Azure Resources](#create-azure-resources)
- [Build and Push Container Images](#build-and-push-container-images)
- [Deploy to Azure Container Apps](#deploy-to-azure-container-apps)
- [Configure Scaling and Monitoring](#configure-scaling-and-monitoring)

### Install Required Tools

1. First, ensure you have the required tools installed:

   ```bash
   # Install Azure Developer CLI (azd)
   # On macOS
   brew tap azure/azd && brew install azd
   
   # On Windows (PowerShell as Administrator)
   powershell -ex AllSigned -c "Invoke-RestMethod 'https://aka.ms/install-azd.ps1' | Invoke-Expression"
   
   # On Linux
   curl -fsSL https://aka.ms/install-azd.sh | bash
   ```

   ```bash
   # Install Azure CLI (az)
   # On macOS
   brew install azure-cli
   
   # On Windows
   winget install Microsoft.AzureCLI
   
   # On Linux (Ubuntu/Debian)
   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
   ```

2. Login to Azure:

   ```bash
   # Login to Azure
   az login
   
   # Set your subscription (if you have multiple)
   az account set --subscription "your-subscription-id"
   ```

### Prepare Azure Configuration

1. Initialize Azure Developer environment in the repository root:

   ```bash
   # From repository root
   azd init
   ```

   When prompted:
   - Select "Use code in the current directory"
   - Enter project name: `socialapp`
   - Choose your preferred Azure region (e.g., `eastus`, `westus2`)

2. This creates several files:
   - `azure.yaml` - Azure Developer configuration
   - `.azure/` directory - Azure environment settings
   - `infra/` directory - Infrastructure as Code templates

### Create Azure Resources

1. Create the required Azure infrastructure:

   ```bash
   # Provision Azure resources
   azd provision
   ```

   This command will:
   - Create a Resource Group
   - Create an Azure Container Registry (ACR)
   - Create Azure Container Apps Environment
   - Set up networking and security configurations
   - Configure managed identity for secure access

2. Verify the resources were created:

   ```bash
   # List created resources
   az resource list --resource-group rg-socialapp --output table
   ```

### Build and Push Container Images

1. Build and tag your container images for Azure Container Registry:

   ```bash
   # Navigate to your containerized application
   cd complete/step-06
   
   # Get your ACR login server
   ACR_NAME=$(az acr list --resource-group rg-socialapp --query "[0].name" --output tsv)
   ACR_LOGIN_SERVER=$(az acr list --resource-group rg-socialapp --query "[0].loginServer" --output tsv)
   
   echo "ACR Name: $ACR_NAME"
   echo "ACR Login Server: $ACR_LOGIN_SERVER"
   ```

2. Login to Azure Container Registry:

   ```bash
   # Login to your ACR
   az acr login --name $ACR_NAME
   ```

3. Build and push the backend image:

   ```bash
   # Build backend image with ACR tag
   docker build -t $ACR_LOGIN_SERVER/socialapp-backend:latest ./backend
   
   # Push backend image to ACR
   docker push $ACR_LOGIN_SERVER/socialapp-backend:latest
   ```

4. Build and push the frontend image:

   ```bash
   # Build frontend image with ACR tag
   docker build -t $ACR_LOGIN_SERVER/socialapp-frontend:latest ./frontend
   
   # Push frontend image to ACR
   docker push $ACR_LOGIN_SERVER/socialapp-frontend:latest
   ```

5. Verify images in ACR:

   ```bash
   # List images in ACR
   az acr repository list --name $ACR_NAME --output table
   az acr repository show-tags --name $ACR_NAME --repository socialapp-backend --output table
   az acr repository show-tags --name $ACR_NAME --repository socialapp-frontend --output table
   ```

### Deploy to Azure Container Apps

1. Create the backend container app:

   ```bash
   # Create backend container app
   az containerapp create \
     --resource-group rg-socialapp \
     --name socialapp-backend \
     --image $ACR_LOGIN_SERVER/socialapp-backend:latest \
     --environment-name cae-socialapp \
     --registry-server $ACR_LOGIN_SERVER \
     --registry-identity system \
     --target-port 8080 \
     --ingress internal \
     --min-replicas 1 \
     --max-replicas 10 \
     --cpu 1.0 \
     --memory 2.0Gi \
     --env-vars SPRING_PROFILES_ACTIVE=docker
   ```

2. Create the frontend container app:

   ```bash
   # Get backend FQDN
   BACKEND_FQDN=$(az containerapp show --resource-group rg-socialapp --name socialapp-backend --query "properties.configuration.ingress.fqdn" --output tsv)
   
   # Create frontend container app
   az containerapp create \
     --resource-group rg-socialapp \
     --name socialapp-frontend \
     --image $ACR_LOGIN_SERVER/socialapp-frontend:latest \
     --environment-name cae-socialapp \
     --registry-server $ACR_LOGIN_SERVER \
     --registry-identity system \
     --target-port 80 \
     --ingress external \
     --min-replicas 1 \
     --max-replicas 5 \
     --cpu 0.5 \
     --memory 1.0Gi
   ```

3. Get the application URL:

   ```bash
   # Get frontend URL
   FRONTEND_URL=$(az containerapp show --resource-group rg-socialapp --name socialapp-frontend --query "properties.configuration.ingress.fqdn" --output tsv)
   echo "Application URL: https://$FRONTEND_URL"
   ```

### Configure Scaling and Monitoring

1. Configure horizontal scaling rules:

   ```bash
   # Configure backend scaling based on HTTP requests
   az containerapp update \
     --resource-group rg-socialapp \
     --name socialapp-backend \
     --scale-rule-name http-scale \
     --scale-rule-type http \
     --scale-rule-http-concurrency 100 \
     --min-replicas 2 \
     --max-replicas 20
   ```

2. Configure monitoring and logging:

   ```bash
   # Enable Container Insights
   az containerapp logs show \
     --resource-group rg-socialapp \
     --name socialapp-backend \
     --follow
   ```

3. Set up health probes:

   ```bash
   # Update backend with health probes
   az containerapp update \
     --resource-group rg-socialapp \
     --name socialapp-backend \
     --health-probe-type liveness \
     --health-probe-path /actuator/health \
     --health-probe-interval 30 \
     --health-probe-timeout 10 \
     --health-probe-threshold 3
   ```

### Test the Deployed Application

1. Test the application functionality:

   ```bash
   # Open the application in your browser
   echo "Opening application at: https://$FRONTEND_URL"
   
   # On macOS
   open "https://$FRONTEND_URL"
   
   # On Windows
   start "https://$FRONTEND_URL"
   
   # On Linux
   xdg-open "https://$FRONTEND_URL"
   ```

2. Monitor application performance:

   ```bash
   # View application logs
   az containerapp logs show --resource-group rg-socialapp --name socialapp-backend --follow
   
   # Check scaling status
   az containerapp replica list --resource-group rg-socialapp --name socialapp-backend --output table
   ```

### Update and Redeploy

1. For future updates, use the Azure Developer CLI:

   ```bash
   # Deploy updates to Azure
   azd deploy
   ```

2. Or manually update container apps:

   ```bash
   # Update backend with new image
   az containerapp update \
     --resource-group rg-socialapp \
     --name socialapp-backend \
     --image $ACR_LOGIN_SERVER/socialapp-backend:v2
   
   # Update frontend with new image
   az containerapp update \
     --resource-group rg-socialapp \
     --name socialapp-frontend \
     --image $ACR_LOGIN_SERVER/socialapp-frontend:v2
   ```

### Clean Up Resources

When you're done testing, clean up Azure resources to avoid charges:

```bash
# Delete all resources
azd down --force --purge

# Or manually delete the resource group
az group delete --name rg-socialapp --yes --no-wait
```

---

Congratulations! <‰ You've successfully deployed your containerized and scalable social media application to Azure using Azure Container Registry and Azure Container Apps with the Azure Developer CLI!

## Key Benefits Achieved

- **Cloud-Native Deployment**: Application runs on managed Azure services
- **Auto-Scaling**: Container Apps automatically scale based on demand
- **Secure Image Storage**: Container images stored in Azure Container Registry
- **Production Ready**: Health checks, monitoring, and logging configured
- **Easy Updates**: Simple redeployment process with `azd deploy`
- **Cost Efficient**: Pay only for resources used, with automatic scaling
- **High Availability**: Built-in redundancy and failover capabilities

## Next Steps

- Set up CI/CD pipelines with GitHub Actions
- Configure custom domains and SSL certificates
- Implement Azure Application Insights for advanced monitoring
- Set up Azure Key Vault for secrets management
- Configure Azure Front Door for global load balancing