param location string = resourceGroup().location

@description('Name of the SQL Db Server')
param serverName string

@description('Name of the Sql Database')
param sqlDatabaseName string

@description('Whether to use an existing SQL Server (true) or create new (false)')
param useExistingSqlServer bool

@description('Admin UserName for the SQL Server (required when creating new)')
param sqlServerAdminLogin string

@description('Admin Password for the SQL Server (required when creating new)')
@secure()
param sqlServerAdminPassword string

@description('Client IP Address for allow remote server connections')
param clientIPAddress string

var dbSKU = 'Basic'
var dbCapacity = 5

// Reference existing SQL Server
resource existingSqlServer 'Microsoft.Sql/servers@2024-11-01-preview' existing = if (useExistingSqlServer) {
  name: serverName
}

// Create new SQL Server
resource newSqlServer 'Microsoft.Sql/servers@2024-11-01-preview' = if (!useExistingSqlServer) {
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

// Firewall rule - Azure Services (for new server)
resource sqlServerFirewallRuleAzureServicesNew 'Microsoft.Sql/servers/firewallRules@2023-08-01-preview' = if (!useExistingSqlServer) {
  parent: newSqlServer
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// Firewall rule - Azure Services (for existing server)
resource sqlServerFirewallRuleAzureServicesExisting 'Microsoft.Sql/servers/firewallRules@2023-08-01-preview' = if (useExistingSqlServer) {
  parent: existingSqlServer
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource sqlServerFirewallRuleClientIPNew 'Microsoft.Sql/servers/firewallRules@2023-08-01-preview' = if (!useExistingSqlServer && clientIPAddress != '') {
  parent: newSqlServer
  name: 'ClientIPAddress_Home'
  properties: {
    startIpAddress: clientIPAddress
    endIpAddress: clientIPAddress
  }
}

resource sqlServerFirewallRuleClientIPExisting 'Microsoft.Sql/servers/firewallRules@2023-08-01-preview' = if (useExistingSqlServer && clientIPAddress != '') {
  parent: existingSqlServer
  name: 'ClientIPAddress_Home'
  properties: {
    startIpAddress: clientIPAddress
    endIpAddress: clientIPAddress
  }
}

// Database on new server
resource sqlDBNew 'Microsoft.Sql/servers/databases@2024-11-01-preview' = if (!useExistingSqlServer) {
  parent: newSqlServer
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

// Database on existing server (idempotent)
resource sqlDBExisting 'Microsoft.Sql/servers/databases@2024-11-01-preview' = if (useExistingSqlServer) {
  parent: existingSqlServer
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

output sqlServerName string = useExistingSqlServer ? existingSqlServer.name : newSqlServer.name
output sqlDatabaseName string = useExistingSqlServer ? sqlDBExisting.name : sqlDBNew.name
