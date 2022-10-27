

@description('Location for the deployment.')
param location string = resourceGroup().location

@description('SQL Database Logical Server Name.')
param sqlServerName string

@description('Key/Value pair of tags.')
param tags object = {}

// Networking
@description('Private Endpoint Subnet Resource Id.')
param privateEndpointSubnetId string

// Credentials
@description('SQL Database Username.')
@secure()
param sqlAuthenticationUsername string

@description('SQL Database Password.')
@secure()
param sqlAuthenticationPassword string

@description('Azure AD principal to be the admin for details about it the object details, refer to the parameter file')
param aadAdministrator object

resource sqlserver 'Microsoft.Sql/servers@2021-02-01-preview' = {
  tags: tags
  location: location
  name: sqlServerName
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    administratorLogin: aadAdministrator.azureADOnlyAuthentication? json('null') : sqlAuthenticationUsername 
    administratorLoginPassword: aadAdministrator.azureADOnlyAuthentication? json('null') : sqlAuthenticationPassword
    administrators: empty(aadAdministrator.sid)? json('null') : aadAdministrator
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
  }

  resource sqlserver_audit 'auditingSettings@2020-11-01-preview' = {
    name: 'default'
    properties: {
      isAzureMonitorTargetEnabled: true
      state: 'Enabled'
    }
  }
  
  resource sqlserver_devopsAudit 'devOpsAuditingSettings@2020-11-01-preview' = {
    name: 'default'
    properties: {
      isAzureMonitorTargetEnabled: true
      state: 'Enabled'
    }
  }

  resource sqlserver_securityAlertPolicies 'securityAlertPolicies@2020-11-01-preview' = {
    name: 'Default'
    properties: {
      state: 'Enabled'
      emailAccountAdmins: false
    }
  }
}

resource sqlserver_pe 'Microsoft.Network/privateEndpoints@2020-06-01' = {
  location: location
  name: '${sqlserver.name}-endpoint'
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${sqlserver.name}-endpoint'
        properties: {
          privateLinkServiceId: sqlserver.id
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
}

// Outputs
output sqlDbFqdn string = sqlserver.properties.fullyQualifiedDomainName
