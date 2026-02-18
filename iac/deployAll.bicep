@description('Name of the Resource Group')
param groupName string = 'rg-youforgotparams-ccad21'

@description('Location for deployment of the resources')
param location string = 'centralus'

/*Log analytics Params */
param la_name string = 'la-youforgotparams-ccad21'
param la_retentionInDays int = 30

/*Application Insights Params */
param ai_name string = 'ai-youforgotparams-ccad21'

targetScope = 'subscription'

/* create resource group */
resource group 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: groupName
  location: location
}

/* create log analytics workspace */
module logAnalytics 'resources/logAnalytics.bicep' = {
  scope: group
  name: 'deployLogAnalytics'
  params: {
    la_name: la_name
    location: location
    retentionInDays: la_retentionInDays
  }
}

/* create application insights */
module appInsights 'resources/appInsights.bicep' = {
  scope: group
  name: 'deployAppInsights'
  params: {
    ai_name: ai_name
    location: location
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId
  }
}
