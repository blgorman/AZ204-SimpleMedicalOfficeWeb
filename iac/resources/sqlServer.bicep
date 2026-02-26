param sql_server_name string
param location string
param sql_admin_login string
@secure()
param sql_admin_password string
param sql_database_name string
param sql_database_sku_name string = 'Basic'
param sql_database_sku_tier string = 'Basic'

resource sqlServer 'Microsoft.Sql/servers@2023-08-01-preview' = {
  name: sql_server_name
  location: location
  properties: {
    administratorLogin: sql_admin_login
    administratorLoginPassword: sql_admin_password
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-08-01-preview' = {
  parent: sqlServer
  name: sql_database_name
  location: location
  sku: {
    name: sql_database_sku_name
    tier: sql_database_sku_tier
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648 // 2GB
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    readScale: 'Disabled'
  }
}

// Allow Azure services to access the server
resource firewallRule 'Microsoft.Sql/servers/firewallRules@2023-08-01-preview' = {
  parent: sqlServer
  name: 'AllowAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

output sqlServerName string = sqlServer.name
output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName
output sqlDatabaseName string = sqlDatabase.name
@secure()
output connectionString string = 'Server=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=${sql_database_name};Persist Security Info=False;User ID=${sql_admin_login};Password=${sql_admin_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
