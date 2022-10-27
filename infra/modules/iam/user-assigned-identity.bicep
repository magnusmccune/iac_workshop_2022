

@description('Location for the deployment.')
param location string = resourceGroup().location

@description('User Assigned Managed Identity Name.')
param name string

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: name
  location: location
}

// Outputs
output identityId string = identity.id
output identityPrincipalId string = identity.properties.principalId
output identityClientId string = identity.properties.clientId
