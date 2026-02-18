param asp_name string
param location string
param asp_skuName string

resource hostingPlan 'Microsoft.Web/serverfarms@2025-03-01' = {
  name: asp_name
  location: location
  sku: {
    name: asp_skuName
  }
  properties: {
    reserved: true
  }
}

output hostingPlanId string = hostingPlan.id
