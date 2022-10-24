@description('Azure Key Vault Name.')
param akvName string

@description('RSA Key Name.')
param keyName string

resource akvKey 'Microsoft.KeyVault/vaults/keys@2020-04-01-preview' = {
  name: '${akvName}/${keyName}'
  properties: {
    kty: 'RSA'
    keySize: 2048
    attributes: {
      enabled: true
    }
  }  
}

// Outputs
output keyName string = keyName
output keyId string = akvKey.id
output keyVersion string = last(split(akvKey.properties.keyUriWithVersion, '/'))
output keyUri string = akvKey.properties.keyUri
output keyUriWithVersion string = akvKey.properties.keyUriWithVersion
