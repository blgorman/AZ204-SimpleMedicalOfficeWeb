param web_name string
param location string
param hostingPlanId string
param applicationInsightsName string
param sa_name string
param sa_images_container_name string
param sa_documents_container_name string
param staging_slot_name string
param deployConnectionStrings bool

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

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
]

var commonConnectionStrings = [
  {
    name: 'DefaultConnection'
    type: 'SQLAzure'
    connectionString: 'your-db-connection-string-here'
    deploymentSlotSetting: true
  }
  {
    name: 'AzureAppConfigConnection'
    type: 'Custom'
    connectionString: 'your-app-config-connection-string-here'
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
      appSettings: commonAppSettings
      connectionStrings: commonConnectionStrings
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    } : {
      linuxFxVersion: 'DOTNETCORE|10.0'
      appSettings: commonAppSettings
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
      appSettings: commonAppSettings
      connectionStrings: commonConnectionStrings
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    } : {
      linuxFxVersion: 'DOTNETCORE|10.0'
      appSettings: commonAppSettings
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}
