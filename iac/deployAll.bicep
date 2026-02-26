@description('Name of the Resource Group')
param groupName string 

@description('Location for deployment of the resources')
param location string 

/* Database */
@description('Name of the SQL Db Server')
param serverName string  
@description('Name of the Sql Database')
param sqlDatabaseName string 

@description('Admin UserName for the SQL Server')
param sqlServerAdminLogin string 

@description('Admin Password for the SQL Server')
@secure()
param sqlServerAdminPassword string

@description('Client IP Address for allow remote server connections')
param clientIPAddress string 

/*Log analytics Params */
param la_name string 
param la_retentionInDays int = 30

/*Application Insights Params */
param ai_name string

/*App Service Plan Params */
param asp_name string 
param asp_skuName string = 'F1'

/*App Service Params */
param web_name string 
param sa_name string 
param sa_images_container_name string = 'images'
param sa_documents_container_name string = 'documents'
param staging_slot_name string = 'staging'
param deployConnectionStrings bool = false
param deployRoleAssignments bool = false

var uniqueString = '20261231blg'

var sa_name_normalized = toLower('${take(sa_name, 24 - length(uniqueString))}${uniqueString}') // truncate base only, uniqueString always preserved

targetScope = 'subscription'

/* create resource group */
resource group 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: groupName
  location: location
}

/* create storage account with images and documents containers */
module storageAccount 'resources/storageAccount.bicep' = {
  scope: group
  name: 'deployStorageAccount'
  params: {
    sa_name: sa_name_normalized
    location: location
    containerNames: [sa_images_container_name, sa_documents_container_name]
  }
}

/* database*/
module database 'resources/sqlServer.bicep' = {
  name: 'database'
  scope: group
  params: {
    location: location
    serverName: serverName
    sqlDatabaseName: sqlDatabaseName
    sqlServerAdminLogin: sqlServerAdminLogin
    sqlServerAdminPassword: sqlServerAdminPassword
    clientIPAddress: clientIPAddress
  }
}

/* vault */


/* app config */


/* assign Storage Blob Data Contributor to the web app and staging slot identities */
module storageRoleAssignmentWebApp 'resources/storageRoleAssignment.bicep' = if (deployRoleAssignments) {
  scope: group
  name: 'deployStorageRoleAssignment-webApp'
  params: {
    storageAccountName: storageAccount.outputs.storageAccountName
    principalId: appService.outputs.webAppPrincipalId
  }
}

module storageRoleAssignmentStagingSlot 'resources/storageRoleAssignment.bicep' = if (deployRoleAssignments) {
  scope: group
  name: 'deployStorageRoleAssignment-stagingSlot'
  params: {
    storageAccountName: storageAccount.outputs.storageAccountName
    principalId: appService.outputs.stagingSlotPrincipalId
  }
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
    sa_name: sa_name_normalized
    sa_images_container_name: sa_images_container_name
    sa_documents_container_name: sa_documents_container_name
    sa_endpoint: storageAccount.outputs.storageAccountEndpoint
    staging_slot_name: staging_slot_name
    deployConnectionStrings: deployConnectionStrings
  }
}
