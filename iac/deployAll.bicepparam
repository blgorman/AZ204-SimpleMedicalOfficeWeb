using 'deployAll.bicep'

param groupName = 'rg-az204-simplemedicalofficeweb-ccad21'
param location = 'centralus'

/* log analytics params */
param la_name = 'la-az204-simplemedicalofficeweb-ccad21'
param la_retentionInDays = 30

/* application insights params */
param ai_name = 'ai-az204-simplemedicalofficeweb-ccad21'

/* app service plan params */
param asp_name = 'asp-az204-simplemedicalofficeweb-ccad21'
param asp_skuName = 'P0v3'

/* app service params */
param web_name = 'app-az204-simplemedicalofficeweb-ccad21'
param sa_name = 'saaz204smplmdclccad21'
param sa_images_container_name = 'images'
param staging_slot_name = 'staging'
