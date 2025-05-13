$repoPath = git config --get remote.origin.url | Split-Path -Leaf
$repoPath = $repoPath -replace '\.git$', ''
$orgName = git config --get remote.origin.url | Split-Path -Parent | Split-Path -Leaf

# Get Azure subscription ID
$subscriptionId = az account show --query id -o tsv

# Create service principal with Contributor and User Access Administrator roles scoped to the resource group
$resourceGroupId = "/subscriptions/$subscriptionId/resourceGroups/rg-pyt001"
$sp = az ad sp create-for-rbac --name "sp-gh-func-app-rg" --role "Contributor" --scopes $resourceGroupId | ConvertFrom-Json
az role assignment create --assignee $sp.appId --role "User Access Administrator" --scope $resourceGroupId

# Create federated credential for GitHub Actions
$federatedCredential = @{
    name = "github-federated"
    issuer = "https://token.actions.githubusercontent.com"
    subject = "repo:$orgName/$repoPath`:environment:dev"
    audiences = @("api://AzureADTokenExchange")
} | ConvertTo-Json -Compress

az ad app federated-credential create --id $sp.appId --parameters $federatedCredential

# Create GitHub environment and set secrets
gh api --method PUT -H "Accept: application/vnd.github+json" "repos/$orgName/$repoPath/environments/dev"

gh secret set AZURE_CLIENT_ID --body $sp.appId --env dev
gh secret set AZURE_TENANT_ID --body $sp.tenant --env dev
gh secret set AZURE_SUBSCRIPTION_ID --body $subscriptionId --env dev

Write-Host "Setup completed successfully!"