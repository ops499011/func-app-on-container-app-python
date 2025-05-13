// the scope, the deployment deploys resources to
targetScope = 'resourceGroup'

// container registry for function app images
resource azContainerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: 'crpyt001'
  location: resourceGroup().location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
    networkRuleBypassOptions: 'AzureServices'
    publicNetworkAccess: 'Enabled'
  }
}

// storage account for function app
resource azStorageAccount 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: 'saapyt001'
  location: resourceGroup().location
  kind: 'Storage'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
      supportsHttpsTrafficOnly: true
      minimumTlsVersion: 'TLS1_2'
      defaultToOAuthAuthentication: true
      allowBlobPublicAccess: false
      publicNetworkAccess: 'Enabled'
  }
}

// conatiner apps environment
resource azContainerAppEnvironment 'Microsoft.App/managedEnvironments@2025-01-01' = {
  name: 'amepyt001'
  location: resourceGroup().location
  properties: {
    workloadProfiles: [
      {
        name: 'Consumption'
        workloadProfileType: 'Consumption'
      }
    ]
  }
}

// function app targeting container app
resource azFunctionApp 'Microsoft.Web/sites@2024-04-01' = {
  name: 'wsfapyt001'
  location: resourceGroup().location
  kind: 'functionapp,linux,container,azurecontainerapps'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    managedEnvironmentId: azContainerAppEnvironment.id
    workloadProfileName: 'Consumption'
    resourceConfig: {
      cpu: 1
      memory: '2Gi'
    }
    siteConfig: {
      linuxFxVersion: 'DOCKER|mcr.microsoft.com/azure-functions/dotnet8-quickstart-demo:1.0'
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${azStorageAccount.name};EndpointSuffix=${az.environment().suffixes.storage};AccountKey=${azStorageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
      ]
    }
  }
}

// Grant AcrPull role to Function App's managed identity
resource functionAppAcrPullRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(azFunctionApp.id, azContainerRegistry.id, 'AcrPull')
  scope: azContainerRegistry
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d') // AcrPull role
    principalId: azFunctionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

@description('The login server URL for the container registry')
output acrLoginServer string = azContainerRegistry.properties.loginServer
