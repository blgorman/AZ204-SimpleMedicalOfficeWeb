using 'deployAll.bicep'

param groupName = 'rg-az204-simplemedicalofficeweb-ccad21'
param location = 'centralus'

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

/* sql server params */
param sql_server_name = 'sql-az204-smplmdcl-ccad21'
param sql_admin_login = 'sqladmin'
param sql_admin_password = 'YourSecurePassword123!' // Change this in production!
param sql_database_name = 'SimpleMedicalOfficeDB'
param sql_database_sku_name = 'Basic'
param sql_database_sku_tier = 'Basic'

/* key vault params */
param kv_name = 'kv-az204-smplmdcl-ccad21'
param shouldUpdateConnectionString = true
