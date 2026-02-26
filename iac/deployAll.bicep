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
param sa_documents_container_name string = 'documents'
param staging_slot_name string = 'staging'
param deployConnectionStrings bool = false
param deployRoleAssignments bool = false

/*SQL Server Params */
param sql_server_name string = 'sql-youforgotparams-ccad21'
param sql_admin_login string = 'sqladmin'
@secure()
param sql_admin_password string
param sql_database_name string = 'SimpleMedicalOfficeDB'
param sql_database_sku_name string = 'Basic'
param sql_database_sku_tier string = 'Basic'

/*Key Vault Params */
param kv_name string = 'kv-youforgotparams-ccad21'
param shouldUpdateConnectionString bool = false

var uniqueString = '20261231blg'

var sa_name_normalized = toLower('${take(sa_name, 24 - length(uniqueString))}${uniqueString}') // truncate base only, uniqueString always preserved

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

/* create sql server and database */
module sqlServer 'resources/sqlServer.bicep' = {
  scope: group
  name: 'deploySqlServer'
  params: {
    sql_server_name: sql_server_name
    location: location
    sql_admin_login: sql_admin_login
    sql_admin_password: sql_admin_password
    sql_database_name: sql_database_name
    sql_database_sku_name: sql_database_sku_name
    sql_database_sku_tier: sql_database_sku_tier
  }
}

/* create key vault with database connection string secret */
module keyVault 'resources/keyVault.bicep' = {
  scope: group
  name: 'deployKeyVault'
  params: {
    kv_name: kv_name
    location: location
    shouldUpdateConnectionString: shouldUpdateConnectionString
    databaseConnectionString: sqlServer.outputs.connectionString
  }
}

output keyVaultName string = keyVault.outputs.keyVaultName
output keyVaultUri string = keyVault.outputs.keyVaultUri
output sqlServerFqdn string = sqlServer.outputs.sqlServerFqdn
output sqlDatabaseName string = sqlServer.outputs.sqlDatabaseName
