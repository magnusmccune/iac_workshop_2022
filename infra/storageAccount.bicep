// Parameters

param envCode string = 'd'
param project string = 'project1'
param app string = 'app1'
param org string = 'm3d'

@description('Please select a location for the resources deployment.')
@allowed([
  'canadacentral'
  'canadaeast'
])
param location string

@allowed([
  'Standard_LRS'
  'Premium_LRS'
])
param stgSku string


@allowed([
  'StorageV2'
  'FileStorage'
])
param stgKind string

// Variables

var stgName = '${org}${project}${app}stg1${envCode}'

// Resources
resource myStorageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: stgName
  location: location
  sku: {
    name: stgSku
  }
  kind: stgKind
}

// Outputs

output stgID string = myStorageAccount.id
