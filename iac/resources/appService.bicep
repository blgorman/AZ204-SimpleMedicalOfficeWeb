param web_name string
param location string
param hostingPlanId string
param applicationInsightsName string
param sa_name string
param sa_images_container_name string

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: web_name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlanId
    siteConfig: {
      netFrameworkVersion:'v10.0'
      appSettings: [
          {
            name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
            value: applicationInsights.properties.ConnectionString
          }
          {
            name: 'StorageAccount:AccountName'
            value: sa_name
          }
          {
            name: 'StorageAccount:ImagesContainerName'
            value: sa_images_container_name
          }
        ]
        connectionStrings: [
          {
            name: 'DefaultConnection'
            type: 'SQLAzure'
            connectionString: 'your-db-connection-string-here'
          }
          {
            name: 'AzureAppConfigConnection'
            type: 'Custom'
            connectionString: 'your-app-config-connection-string-here'
          }
        ]
        ftpsState: 'FtpsOnly'
        minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}
