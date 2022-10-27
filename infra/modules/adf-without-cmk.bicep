

@description('Location for the deployment.')
param location string = resourceGroup().location

@description('Azure Data Factory Name.')
param name string

@description('Key/Value pair of tags.')
param tags object = {}

// Private Endpoints
@description('Private Endpoint Subnet Resource Id.')
param privateEndpointSubnetId string

// User Assigned Identity
@description('User Assigned Managed Identity Resource Id.')
param userAssignedIdentityId string

// Deploy Azure Data Factory with Managed Virtual Network & Managed Integration Runtime
resource adf 'Microsoft.DataFactory/factories@2018-06-01' = {
  location: location
  name: name
  tags: tags
  identity: {
    type: 'SystemAssigned,UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
    }
  }
  properties: {
    publicNetworkAccess: 'Disabled'
  }

  resource managedVnet 'managedVirtualNetworks@2018-06-01' = {
    name: 'default'
    properties: {}
  }

  resource autoResolveIR 'integrationRuntimes@2018-06-01' = {
    name: 'AutoResolveIntegrationRuntime'
    properties: {
      type: 'Managed'
      managedVirtualNetwork: {
        type: 'ManagedVirtualNetworkReference'
        referenceName: managedVnet.name
      }
      typeProperties: {
        computeProperties: {
          location: 'AutoResolve'
        }
      }
    }
  }
}

// Create Private Endpoints and register their IPs with Private DNS Zone
resource adf_datafactory_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  location: location
  name: '${adf.name}-df-endpoint'
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${adf.name}-df-endpoint'
        properties: {
          privateLinkServiceId: adf.id
          groupIds: [
            'dataFactory'
          ]
        }
      }
    ]
  }
}
