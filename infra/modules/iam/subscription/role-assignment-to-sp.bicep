

targetScope = 'subscription'

@description('Role Definition Id.')
param roleDefinitionId string

@description('Array of Service Principal Object Ids.')
param resourceSPObjectIds array = []

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for spId in resourceSPObjectIds: {
  name: guid(subscription().id, spId, roleDefinitionId)
  scope: subscription()
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: spId
    principalType: 'ServicePrincipal'
  }
}]

module roleAssignmentWait '../../util/wait-subscription.bicep' = [for (spId, idx) in resourceSPObjectIds: {
  name: '${roleAssignment[idx].name}-wait'
  scope: subscription()
  params: {
    waitNamePrefix: roleAssignment[idx].name
    loopCounter: 10
  }
}]
