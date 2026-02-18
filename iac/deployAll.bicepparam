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
