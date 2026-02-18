@description('Name of the Resource Group')
param groupName string = 'rg-youforgotparams-ccad21'

@description('Location for deployment of the resources')
param location string = 'centralus'

/*Log analytics Params */
param la_name string = 'la-youforgotparams-ccad21'
param la_retentionInDays int = 30

/*Application Insights Params */
param ai_name string = 'ai-youforgotparams-ccad21'

/*App Service Plan Params */
param asp_name string = 'asp-youforgotparams-ccad21'
param asp_skuName string = 'F1'

/*App Service Params */
param web_name string = 'web-youforgotparams-ccad21'
param sa_name string = 'sayouforgotparms235223'
param sa_images_container_name string = 'images'

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

/* create app service plan */
module appServicePlan 'resources/appServicePlan.bicep' = {
  scope: group
  name: 'deployAppServicePlan'
  params: {
    asp_name: asp_name
    location: location
    asp_skuName: asp_skuName
  }
}

/* create app service */
module appService 'resources/appService.bicep' = {
  scope: group
  name: 'deployAppService'
  params: {
    web_name: web_name
    location: location
    hostingPlanId: appServicePlan.outputs.hostingPlanId
    applicationInsightsName: appInsights.outputs.applicationInsightsName
    sa_name: sa_name
    sa_images_container_name: sa_images_container_name
  }
}
