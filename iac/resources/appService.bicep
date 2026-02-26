param web_name string
param location string
param hostingPlanId string
param applicationInsightsName string
param sa_name string
param sa_endpoint string
param sa_images_container_name string
param sa_documents_container_name string
param staging_slot_name string
param deployConnectionStrings bool

param keyVaultName string
param defaultConnectionStringName string
param appConfigConnectionStringName string


resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

resource existingVault 'Microsoft.KeyVault/vaults@2025-05-01' existing = {
  name: keyVaultName
}

var defaultConnectionString = '@Microsoft.KeyVault(VaultName=${existingVault.name};SecretName=${defaultConnectionStringName})'
var appConfigConnectionString = '@Microsoft.KeyVault(VaultName=${existingVault.name};SecretName=${appConfigConnectionStringName})'
var authenticationSecret = '@Microsoft.KeyVault(VaultName=${existingVault.name};SecretName=MICROSOFT-PROVIDER-AUTHENTICATION-SECRET)'
var authenticationSecretStaging = '@Microsoft.KeyVault(VaultName=${existingVault.name};SecretName=MICROSOFT-PROVIDER-AUTHENTICATION-SECRET-STAGING)'
var allowedTenantsForAuthSecret = '@Microsoft.KeyVault(VaultName=${existingVault.name};SecretName=WEBSITE-AUTH-AAD-ALLOWED-TENANTS)'

var commonAppSettings = [
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: applicationInsights.properties.ConnectionString
    deploymentSlotSetting: true
  }
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: applicationInsights.properties.InstrumentationKey
    deploymentSlotSetting: true
  }
  {
    name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
    value: '~3'
    deploymentSlotSetting: true
  }
  {
    name: 'XDT_MicrosoftApplicationInsights_Mode'
    value: 'recommended'
    deploymentSlotSetting: true
  }
  {
    name: 'StorageAccount__AccountName'
    value: sa_name
    deploymentSlotSetting: true
  }
  {
    name: 'StorageAccount__ImagesContainerName'
    value: sa_images_container_name
    deploymentSlotSetting: true
  }
  {
    name: 'StorageAccount__DocumentsContainerName'
    value: sa_documents_container_name
    deploymentSlotSetting: true
  }
  {
    name: 'StorageAccount__Endpoint'
    value: sa_endpoint
    deploymentSlotSetting: true
  }
  {
    name: 'WEBSITE_AUTH_AAD_ALLOWED_TENANTS'
    value: allowedTenantsForAuthSecret
    deploymentSlotSetting: true
  }
]

var productionAppSettings = concat(commonAppSettings, [
  {
    name: 'MICROSOFT_PROVIDER_AUTHENTICATION_SECRET'
    value: authenticationSecret
    deploymentSlotSetting: true
  }
])

var stagingAppSettings = concat(commonAppSettings, [
  {
    name: 'MICROSOFT_PROVIDER_AUTHENTICATION_SECRET'
    value: authenticationSecretStaging
    deploymentSlotSetting: true
  }
])

var commonConnectionStrings = [
  {
    name: 'DefaultConnection'
    type: 'SQLAzure'
    connectionString: defaultConnectionString
    deploymentSlotSetting: true
  }
  {
    name: 'AzureAppConfigConnection'
    type: 'Custom'
    connectionString: appConfigConnectionString
    deploymentSlotSetting: true
  }
]

resource webApp 'Microsoft.Web/sites@2025-03-01' = {
  name: web_name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlanId
    siteConfig: deployConnectionStrings ? {
      linuxFxVersion: 'DOTNETCORE|10.0'
      appSettings: productionAppSettings
      connectionStrings: commonConnectionStrings
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    } : {
      linuxFxVersion: 'DOTNETCORE|10.0'
      appSettings: productionAppSettings
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}

resource stagingSlot 'Microsoft.Web/sites/slots@2025-03-01' = {
  parent: webApp
  name: staging_slot_name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlanId
    siteConfig: deployConnectionStrings ? {
      linuxFxVersion: 'DOTNETCORE|10.0'
      appSettings: stagingAppSettings
      connectionStrings: commonConnectionStrings
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    } : {
      linuxFxVersion: 'DOTNETCORE|10.0'
      appSettings: stagingAppSettings
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}


//both slot identities need to be set as Key Vault Secrets Officer on the vault:

// Key Vault Secrets Officer role definition ID
var keyVaultSecretsOfficerRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7')

// Grant Key Vault Secrets Officer role to the web app
resource webAppKvRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(existingVault.id, webApp.id, keyVaultSecretsOfficerRoleId)
  scope: existingVault
  properties: {
    roleDefinitionId: keyVaultSecretsOfficerRoleId
    principalId: webApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Grant Key Vault Secrets Officer role to the staging slot
resource stagingSlotKvRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(existingVault.id, stagingSlot.id, keyVaultSecretsOfficerRoleId)
  scope: existingVault
  properties: {
    roleDefinitionId: keyVaultSecretsOfficerRoleId
    principalId: stagingSlot.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

output webAppPrincipalId string = webApp.identity.principalId
output stagingSlotPrincipalId string = stagingSlot.identity.principalId
