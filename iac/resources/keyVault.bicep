param location string = resourceGroup().location

param keyVaultFullName string

@description('Provide the object id of the admin user/group that will have access to the key vault')
param keyVaultAdminObjectId string

@description('Whether to enable the key vault for deployment scenarios (e.g. to allow ARM templates to retrieve secrets during deployment)')
param enableForDeployment bool
@description('Whether to enable the key vault for disk encryption scenarios (e.g. to allow Azure Disk Encryption to retrieve secrets)')
param enableDiskEncryption bool
@description('Whether to enable the key vault for template deployment scenarios (e.g. to allow ARM templates to retrieve secrets after deployment)')
param enableTemplateDeployment bool
@description('Whether to enable soft delete on the key vault (recommended to prevent accidental deletion)')
param enableSoftDelete bool

@description('Name of the App configuration')
param appConfigName string

@description('Principal ID of the App Configuration managed identity')
param appConfigPrincipalId string

@description('Name of the SQL Db Server')
param sqlServerName string

@description('Name of the Sql Database')
param sqlDatabaseName string

@description('Admin UserName for the SQL Server')
param sqlAdminUsername string

@description('Admin Password for the SQL Server')
@secure()
param sqlAdminPassword string

@description('Deploy the Authentication secrets to Key Vault set to false after first deploy to avoid overwriting existing secrets')
param deployAuthenticationSecrets bool

var skuName = 'standard'
var softDeleteRetentionInDays = 7
var keyVaultAdminRoleId = '00482a5a-887f-4fb3-b363-3b7fe8e74483' // Key Vault Administrator role ID
var keyVaultSecretsUserRoleId = '4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User role ID

resource appConfig 'Microsoft.AppConfiguration/configurationStores@2025-06-01-preview' existing = {
  name: appConfigName
}

resource sqlServer 'Microsoft.Sql/servers@2024-11-01-preview' existing = {
  name: sqlServerName
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2024-11-01-preview' existing = {
  parent: sqlServer
  name: sqlDatabaseName
}

var sqlConnectionString = 'Server=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=${sqlDatabase.name};Persist Security Info=False;User ID=${sqlAdminUsername};Password=${sqlAdminPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultFullName
  location: location
  properties: {
    enabledForDeployment: enableForDeployment
    enabledForDiskEncryption: enableDiskEncryption
    enabledForTemplateDeployment: enableTemplateDeployment
    tenantId: subscription().tenantId
    enableSoftDelete: enableSoftDelete
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enableRbacAuthorization: true
    sku: {
      name: skuName
      family: 'A'
    }
    accessPolicies: []
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

// Assign Key Vault Administrator role to the specified admin object ID

resource keyVaultAdminRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, keyVaultAdminObjectId, keyVaultAdminRoleId)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', keyVaultAdminRoleId)
    principalId: keyVaultAdminObjectId
    principalType: 'Group'
  }
}

// Assign Key Vault Secrets User role to App Configuration managed identity
resource appConfigSecretsUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, appConfigPrincipalId, keyVaultSecretsUserRoleId)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', keyVaultSecretsUserRoleId)
    principalId: appConfigPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource KeyVault_Secret_AppConfigConnection 'Microsoft.KeyVault/vaults/secrets@2025-05-01' = {
  parent: keyVault
  name: 'AppConfigConnection'
  properties: {
    contentType: 'string'
    attributes: {
      enabled: true
    }
    value: appConfig.listKeys().value[0].connectionString
  }
}

resource KeyVault_Secret_DbConnectionString 'Microsoft.KeyVault/vaults/secrets@2025-05-01' = {
  parent: keyVault
  name: 'DefaultConnectionString'
  properties: {
    contentType: 'string'
    attributes: {
      enabled: true
    }
    value: sqlConnectionString
  }
}

resource KeyVault_Secret_AuthorizedTenants 'Microsoft.KeyVault/vaults/secrets@2025-05-01' = {
  parent: keyVault
  name: 'WEBSITE-AUTH-AAD-ALLOWED-TENANTS'
  properties: {
    contentType: 'string'
    attributes: {
      enabled: true
    }
    value: tenant().tenantId
  }
}

resource KeyVault_Secret_AuthenticationSecret 'Microsoft.KeyVault/vaults/secrets@2025-05-01' = if (deployAuthenticationSecrets) {
  parent: keyVault
  name: 'MICROSOFT-PROVIDER-AUTHENTICATION-SECRET'
  properties: {
    contentType: 'string'
    attributes: {
      enabled: true
    }
    value: 'you-must-manually-update-this'
  }
}

resource KeyVault_Secret_AuthenticationSecret_Staging 'Microsoft.KeyVault/vaults/secrets@2025-05-01' = if (deployAuthenticationSecrets) {
  parent: keyVault
  name: 'MICROSOFT-PROVIDER-AUTHENTICATION-SECRET-STAGING'
  properties: {
    contentType: 'string'
    attributes: {
      enabled: true
    }
    value: 'you-must-manually-update-this'
  }
}

output keyVaultName string = keyVault.name  
output DefaultConnectionStringName string = KeyVault_Secret_DbConnectionString.name
output AppConfigConnectionStringName string = KeyVault_Secret_AppConfigConnection.name
