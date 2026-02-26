param kv_name string
param location string
param skuName string = 'standard'
param skuFamily string = 'A'
param enabledForDeployment bool = false
param enabledForTemplateDeployment bool = false
param enabledForDiskEncryption bool = false
@description('Flag to determine if the connection string secret should be updated')
param shouldUpdateConnectionString bool = false
@description('SQL Server FQDN for connection string')
param sqlServerFqdn string = ''
@description('SQL Database name for connection string')
param sqlDatabaseName string = ''
@description('SQL admin login for connection string')
param sqlAdminLogin string = ''
@secure()
@description('SQL admin password for connection string')
param sqlAdminPassword string = ''

resource keyVault 'Microsoft.KeyVault/vaults@2025-05-01' = {
  name: kv_name
  location: location
  properties: {
    enabledForDeployment: enabledForDeployment
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    tenantId: tenant().tenantId
    accessPolicies: []
    sku: {
      name: skuName
      family: skuFamily
    }
  }
}

resource databaseConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2025-05-01' = if (shouldUpdateConnectionString && !empty(sqlServerFqdn)) {
  parent: keyVault
  name: 'DatabaseConnectionString'
  properties: {
    value: 'Server=tcp:${sqlServerFqdn},1433;Initial Catalog=${sqlDatabaseName};Persist Security Info=False;User ID=${sqlAdminLogin};Password=${sqlAdminPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
  }
}

output keyVaultName string = keyVault.name
output keyVaultUri string = keyVault.properties.vaultUri
