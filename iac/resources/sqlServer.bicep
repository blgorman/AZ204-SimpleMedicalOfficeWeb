param location string = resourceGroup().location

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

var dbSKU = 'Basic'
var dbCapacity = 5

// SQL Server
resource sqlServer 'Microsoft.Sql/servers@2024-11-01-preview' = {
  name: serverName
  location: location
  properties: {
    administratorLogin: sqlServerAdminLogin
    administratorLoginPassword: sqlServerAdminPassword
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    restrictOutboundNetworkAccess: 'Disabled'
  }
}

// Firewall rule - Azure Services
resource sqlServerFirewallRuleAzureServices 'Microsoft.Sql/servers/firewallRules@2023-08-01-preview' = {
  parent: sqlServer
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource sqlServerFirewallRuleClientIP 'Microsoft.Sql/servers/firewallRules@2023-08-01-preview' = if (clientIPAddress != '') {
  parent: sqlServer
  name: 'ClientIPAddress_Home'
  properties: {
    startIpAddress: clientIPAddress
    endIpAddress: clientIPAddress
  }
}

// Database
resource sqlDB 'Microsoft.Sql/servers/databases@2024-11-01-preview' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  sku: {
    name: dbSKU
    capacity: dbCapacity
  }
  properties: {
    requestedBackupStorageRedundancy: 'local'
  }
}

output sqlServerName string = sqlServer.name
output sqlDatabaseName string = sqlDB.name
