param kv_name string
param location string
param skuName string = 'standard'
param skuFamily string = 'A'
param enabledForDeployment bool = false
param enabledForTemplateDeployment bool = false
param enabledForDiskEncryption bool = false
@description('Flag to determine if the connection string secret should be updated')
param shouldUpdateConnectionString bool = false
@secure()
@description('SQL Server connection string value to store in Key Vault')
param databaseConnectionString string = ''

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

resource databaseConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2025-05-01' = if (shouldUpdateConnectionString && !empty(databaseConnectionString)) {
  parent: keyVault
  name: 'DatabaseConnectionString'
  properties: {
    value: databaseConnectionString
  }
}

output keyVaultName string = keyVault.name
output keyVaultUri string = keyVault.properties.vaultUri
