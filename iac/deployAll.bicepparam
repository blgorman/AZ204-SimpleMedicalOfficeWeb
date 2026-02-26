using 'deployAll.bicep'

param groupName = 'rg-az204-simplemedicalofficeweb-ccad21'
param location = 'centralus'

/* Database */
param serverName = 'simpleofficewebdbserver-ccad21'
param sqlDatabaseName = 'dbSimpleOfficeWeb'
param sqlServerAdminLogin = 'simpleofficewebuser'
param sqlServerAdminPassword = 'Password#12345!'
param clientIPAddress = '169.197.71.222'

/* App Config*/
param appConfigName = 'ac-az204-mow-ccad21'

/* vault*/
param keyVaultName = 'kv-az204-mow'
param keyVaultAdminObjectId = 'de2836ad-c2a2-4096-a9f8-a122b47b9833'
param enableForDeployment = true
param enableDiskEncryption = true
param enableTemplateDeployment = true
param enableSoftDelete = true

/* log analytics params */
param la_name = 'la-az204-simplemedicalofficeweb-ccad21'
param la_retentionInDays = 30

/* application insights params */
param ai_name = 'ai-az204-simplemedicalofficeweb-ccad21'

/* storage account params */
param sa_name = 'saaz204smplmdcl'
param sa_images_container_name = 'images'
param sa_documents_container_name = 'documents'

/* app service plan params */
param asp_name = 'asp-az204-simplemedicalofficeweb-ccad21'
param asp_skuName = 'P0v3'

/* app service params */
param web_name = 'app-az204-simplemedicalofficeweb-ccad21'
param staging_slot_name = 'staging'
param deployConnectionStrings = true
param deployRoleAssignments = false
