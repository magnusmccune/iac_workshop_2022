

targetScope = 'subscription'

@description('Role Definition Id.')
param roleDefinitionId string

@description('Array of Security Group Object Ids.')
param groupObjectIds array = []

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for groupId in groupObjectIds: {
  name: guid(subscription().id, groupId, roleDefinitionId)
  scope: subscription()
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: groupId
    principalType: 'Group'
  }
}]
