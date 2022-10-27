

@description('Location for the deployment.')
param location string = resourceGroup().location

@description('General Purpose Storage Account Name')
param name string

@description('Key/Value pair of tags.')
param tags object = {}

@description('Private Endpoint Subnet Id')
param privateEndpointSubnetId string

@description('Default Network Acls.  Default: deny')
param defaultNetworkAcls string = 'deny'

@description('Bypass Network Acls.  Default: AzureServices,Logging,Metrics')
param bypassNetworkAcls string = 'AzureServices,Logging,Metrics'

@description('Array of Subnet Resource Ids for Virtual Network Access')
param subnetIdForVnetAccess array = []

/* Storage Account */
resource storage 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  tags: tags
  location: location
  name: name
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'StorageV2'
  sku: {
    name: 'Standard_GRS'
  }
  properties: {
    accessTier: 'Hot'
    isHnsEnabled: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    encryption: {
      requireInfrastructureEncryption: true
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
        queue: {
          enabled: true
          keyType: 'Account'
        }
        table: {
          enabled: true
          keyType: 'Account'
        }
      }
    }
    networkAcls: {
      defaultAction: defaultNetworkAcls
      bypass: bypassNetworkAcls
      virtualNetworkRules: [for subnetId in subnetIdForVnetAccess: {
        id: subnetId
        action: 'Allow'
      }]
    }
  }
}

resource threatProtection 'Microsoft.Security/advancedThreatProtectionSettings@2019-01-01' = {
  name: 'current'
  scope: storage
  properties: {
    isEnabled: true
  }
}

/* Private Endpoints */
resource storage_blob_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  location: location
  name: '${storage.name}-blob-endpoint'
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${storage.name}-blob-endpoint'
        properties: {
          privateLinkServiceId: storage.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

resource storage_file_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  location: location
  name: '${storage.name}-file-endpoint'
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${storage.name}-file-endpoint'
        properties: {
          privateLinkServiceId: storage.id
          groupIds: [
            'file'
          ]
        }
      }
    ]
  }
}

// Outputs
output storageName string = storage.name
output storageId string = storage.id
output storagePath string = storage.properties.primaryEndpoints.blob
