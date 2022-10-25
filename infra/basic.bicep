// parameters
param project string
param location string = resourceGroup().location
param stgSKU string = 'Standard_LRS'
param stgKind string = 'StorageV2'
param stgIndex string = '1'

// variables
var stgName = 'azm3d${project}stg${stgIndex}'

// resources
resource storage_demo 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: stgName
  location: location
  sku: {
    name: stgSKU
  }
  kind: stgKind
}

// outputs
output storageID string = storage_demo.id
