param location string = resourceGroup().location

@description('Provide a unique datetime and initials string to make your instances unique. Use only lower case letters and numbers')
@minLength(11)
@maxLength(11)
param uniqueIdentifier string

param appConfigName string

var configStoreName = '${appConfigName}-${uniqueIdentifier}'

param storageAccountNameKVP object 
param storageAccountEndpointKVP object
param storageAccountImagesContainerNameKVP object
param storageAccountDocumentsContainerNameKVP object

param keyVaultFullName string
param connectionStringSecretName string = 'DefaultConnectionString'

resource configStore 'Microsoft.AppConfiguration/configurationStores@2025-06-01-preview' = {
  name: configStoreName
  location: location
  sku: {
    name: 'standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

//i need four kvps for the following app settings:
// - StorageAccount__AccountName
resource storageAccountName_KVP 'Microsoft.AppConfiguration/configurationStores/keyValues@2025-06-01-preview' = {
  parent: configStore
  name: storageAccountNameKVP.key 
  properties: {
    value: storageAccountNameKVP.value 
    contentType: 'text/plain'
  }
}
// - StorageAccount__ImagesContainerName
resource storageAccountImagesContainerName_KVP 'Microsoft.AppConfiguration/configurationStores/keyValues@2025-06-01-preview' = {
  parent: configStore
  name: storageAccountImagesContainerNameKVP.key 
  properties: {
    value: storageAccountImagesContainerNameKVP.value 
    contentType: 'text/plain'
  }
}
// - StorageAccount__DocumentsContainerName
resource storageAccountDocumentsContainerName_KVP 'Microsoft.AppConfiguration/configurationStores/keyValues@2025-06-01-preview' = {
  parent: configStore
  name: storageAccountDocumentsContainerNameKVP.key
  properties: {
    value: storageAccountDocumentsContainerNameKVP.value 
    contentType: 'text/plain'
  }
}
// - StorageAccount__Endpoint
resource storageAccountEndpoint_KVP 'Microsoft.AppConfiguration/configurationStores/keyValues@2025-06-01-preview' = {
  parent: configStore
  name: storageAccountEndpointKVP.key 
  properties: {
    value: storageAccountEndpointKVP.value 
    contentType: 'text/plain'
  }
}

// - ConnectionStrings__DefaultConnection (Key Vault Reference)
resource connectionString_KVP 'Microsoft.AppConfiguration/configurationStores/keyValues@2025-06-01-preview' = {
  parent: configStore
  name: 'ConnectionStrings:DefaultConnection'
  properties: {
    value: '{"uri":"https://${keyVaultFullName}.vault.azure.net/secrets/${connectionStringSecretName}"}'
    contentType: 'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
  }
}

output appConfigName string = configStore.name
output appConfigPrincipalId string = configStore.identity.principalId
