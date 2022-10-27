
targetScope = 'subscription'

/*
****** ---------- ******
****** PARAMETERS ******
****** ---------- ******
*/
@description('Organization identifier, used in creating resource names')
param org string

@description('Project identifier, used in creating resource names')
param project string

@description('application identifier, used in creating resource names')
param app string

@description('environment identifier, used in creating resource names and tags')
param env string

@description('Shortened environment identifier, used in creating resource names')
param envCode string

@description('Resource Location, defaults to deployment location')
param location string = deployment().location

@description('Resource ID of Landing Zone Subnet dedicated to Private Endpoints')
param lzPESubnetID string

@description('SQL SA account username')
param sqlUsername string

@description('SQL SA account password, SECURE STRING')
@secure()
param sqlPassword string

@description('Account Password for Azure VMs, SECURE STRING')
@secure()
param vmPassword string

@description('A parameter OBJECT with configuration settings for Virtual Machines')
param vmConfig object

@description('use Azure AD only authentication or mix of both AAD and SQL authentication')
param aadAuthenticationOnly bool

@description('Azure AD principal name, in the format of firstname last name')
param aadLoginName string = ''

@description('AAD account object id')
param aadLoginObjectID string = ''

@description('AAD account type with options User, Group, Application. Default: Group')
@allowed([
  'User'
  'Group'
  'Application'
])
param aadLoginType string = 'Group'

/*
****** --------- ******
****** VARIABLES ******
****** --------- ******
*/

var tags = {
  location: location
  Environment: env
  AppName: app
}

var workloadRGName = toUpper('${org}-${project}-${app}-${env}-RG-01')
var kvtName = toLower('${org}${project}${app}kvt1${envCode}')
var stgName = toLower('${org}${project}${app}stg1${envCode}')
var sqsName = toLower('${org}${project}${app}sqs1${envCode}')
var adfName = toLower('${org}${project}${app}adf1${envCode}')
var vmNameSeed = toLower('${org}${app}vm')

@description('Generated object used to create the AAD Admin in the SQL Server')
var aadAdministrator = {
  administratorType: 'activeDirectory'
  login: aadLoginName ?? ''
  sid: aadLoginObjectID ?? ''
  tenantId: subscription().tenantId
  azureADOnlyAuthentication: aadAuthenticationOnly
  principalType: aadLoginType
}

/*
****** --------- ******
****** RESOURCES ******
****** --------- ******
*/


resource workloadRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: workloadRGName
  location: location
  tags: tags
}

module identity 'modules/iam/user-assigned-identity.bicep' = {
  name: 'deploy-create-user-assigned-identity'
  scope: workloadRG
  params: {
    name: '${app}-managed-identity'
    location: location
  }
}

module keyvault 'modules/key-vault.bicep' = {
  scope: workloadRG
  name: 'keyvault_deployment'
  params: {
    tags: tags
    name: kvtName
    location: location
  }
}

module storage 'modules/storage-generalpurpose.bicep' = {
  scope: workloadRG
  name: 'storage_deployment'
  params: {
    tags: tags
    name: stgName
    privateEndpointSubnetId: lzPESubnetID
    location:location
  }
}

module sqlDatabase 'modules/sqldb-without-cmk.bicep' = {
  scope: workloadRG
  name: 'sql_deployment'
  params: {
    tags: tags
    aadAdministrator: aadAdministrator
    privateEndpointSubnetId: lzPESubnetID
    sqlAuthenticationPassword: sqlPassword
    sqlAuthenticationUsername: sqlUsername
    sqlServerName: sqsName
    location: location
  }
}

module azureDataFactory 'modules/adf-without-cmk.bicep' = {
  scope: workloadRG
  name: 'adf_deployment'
  params: {
    tags: tags
    name: adfName
    privateEndpointSubnetId: lzPESubnetID
    userAssignedIdentityId: identity.outputs.identityId
    location:location
  }
}

module analysisVM 'modules/vm-win2019-without-cmk.bicep' = [for i in range(0, vmConfig.vmCount): {
  scope: workloadRG
  name: 'vm_deployment_${i}'
  params: {
    tags: tags
    availabilityZone: vmConfig.availabilityZone
    enableAcceleratedNetworking: vmConfig.enableAcceleratedNetworking
    password: vmPassword
    subnetId: vmConfig.subnetID
    username: vmConfig.vmUsername
    vmName: '${vmNameSeed}${i}${envCode}'
    vmSize: vmConfig.vmSize
    location: location
  }
}]


/*
****** ------- ******
****** OUTPUTS ******
****** ------- ******
*/
