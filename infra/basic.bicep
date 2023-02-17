param project string
param location string = resourceGroup().location
param stgSKU string
param stgKind string
param stgIndex string

var stgName = 'm3d${project}stg${stgIndex}'

resource stg 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: stgName
  location: location
  sku: {
    name: stgSKU
  }
  kind: stgKind
}

output storageID string = stg.id
