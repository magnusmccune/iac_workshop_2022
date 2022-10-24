@description('Loop Counter.')
@minValue(1)
param loopCounter int

@description('Prefix used for loop.')
@minLength(2)
@maxLength(50)
param waitNamePrefix string

@batchSize(1)
module wait 'wait-on-arm.bicep' = [for i in range(1, loopCounter): {
  name: '${waitNamePrefix}-${i}'
  params: {
    input: 'waitOnArm-${i}'
  }
}]
