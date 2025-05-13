# Azure Function App on Container Apps (Python)

This repository demonstrates how to deploy a Python-based Azure Function App to Azure Container Apps using Infrastructure as Code (Bicep) and GitHub Actions for CI/CD.

## Architecture

The solution deploys the following Azure resources:
- Azure Container Registry (ACR) for storing function container images
- Azure Storage Account for function app requirements
- Azure Container Apps Environment
- Azure Function App running on Container Apps
- Managed Identity and RBAC roles for secure access

## Prerequisites

- Azure Subscription
- GitHub Account
- Azure CLI
- Docker
- Visual Studio Code with Azure Functions extension
- Python 3.12+

## Project Structure

```
├── .github/workflows/
│   └── deploy.yml         # GitHub Actions workflow for deployment
├── infra/
│   ├── main.bicep        # Infrastructure as Code (Bicep) template
│   └── setup-gh.ps1      # PowerShell script to set up GitHub authentication
├── src/
│   ├── Dockerfile        # Container image definition
│   ├── function_app.py   # Sample HTTP-triggered function
│   ├── host.json         # Function host configuration
│   └── requirements.txt  # Python dependencies
```

## Getting Started

1. Clone this repository
2. Run the setup script to configure GitHub authentication:
   ```powershell
   ./infra/setup-gh.ps1
   ```
   This will:
   - Create a service principal with necessary permissions
   - Set up GitHub Actions environment and secrets
   - Configure federated credentials for passwordless authentication

3. The deployment will create resources in the following environment:
   - Resource Group: `rg-pyt001`
   - Region: South Africa North
   - Python Version: 3.12

## Deployment

The solution uses GitHub Actions for automated deployment. The workflow:
1. Authenticates with Azure using OIDC
2. Creates resource group if not exists
3. Deploys infrastructure using Bicep
4. Builds and pushes the container image to ACR
5. Updates the Function App with the latest container image

To deploy:
1. Navigate to the Actions tab in your repository
2. Select the "Deploy Function App to Container App" workflow
3. Click "Run workflow"

## Local Development

1. Install dependencies:
   ```bash
   pip install -r src/requirements.txt
   ```

2. Run the function locally:
   ```bash
   cd src
   func start
   ```

## Sample Function

The repository includes a sample HTTP-triggered function that accepts a `name` parameter either through query string or request body and returns a personalized greeting.

Test the function:
```bash
curl "http://localhost:7071/api/HttpExample?name=YourName"
```

## Security Features

- HTTPS-only access to storage
- TLS 1.2 enforcement
- OAuth authentication for storage
- System-assigned managed identity
- RBAC for ACR access
- Application Insights monitoring

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
