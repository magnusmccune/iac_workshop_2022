

@description('Role Definition Id.')
param roleDefinitionId string

@description('Array of Service Principal Object Ids.')
param resourceSPObjectIds array = []

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for spId in resourceSPObjectIds: {
  name: guid(resourceGroup().id, spId, roleDefinitionId)
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: spId
    principalType: 'ServicePrincipal'
  }
}]

module roleAssignmentWait '../../util/wait.bicep' = [for (spId, idx) in resourceSPObjectIds: {
  name: '${roleAssignment[idx].name}-wait'
  scope: resourceGroup()
  params: {
    waitNamePrefix: roleAssignment[idx].name
    loopCounter: 10
  }
}]
