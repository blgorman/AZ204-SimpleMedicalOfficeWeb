param kv_name string
param location string
param skuName string = 'standard'
param skuFamily string = 'A'
param enabledForDeployment bool = false
param enabledForTemplateDeployment bool = false
param enabledForDiskEncryption bool = false

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
