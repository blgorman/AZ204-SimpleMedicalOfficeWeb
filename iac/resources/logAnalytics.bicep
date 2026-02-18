param la_name string
param location string
param retentionInDays int

resource workspaces_la_name_resource 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: la_name
  location: location
  properties: {
    sku: {
      name: 'pergb2018'
    }
    retentionInDays: retentionInDays
    features: {
      legacy: 0
      searchVersion: 1
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: json('-1')
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}
