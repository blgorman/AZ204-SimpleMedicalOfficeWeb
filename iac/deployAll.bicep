@description('Name of the Resource Group')
param groupName string = 'rg-youforgotparams-ccad21'

@description('Location for deployment of the resources')
param location string = 'centralus'

targetScope = 'subscription'

/* create resource group */
resource group 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: groupName
  location: location
}

