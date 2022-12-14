@description('Location for the deployment.')
param location string = resourceGroup().location

@description('Virtual Machine Name.')
param vmName string

@description('Virtual Machine SKU.')
param vmSize string

@description('Azure Availability Zone for VM.')
param availabilityZone string

@description('Key/Value pair of tags.')
param tags object = {}

// Credentials
@description('Virtual Machine Username.')
@secure()
param username string

@description('Virtual Machine Password')
@secure()
param password string

// Networking
@description('Subnet Resource Id.')
param subnetId string

@description('Boolean flag that enables Accelerated Networking.')
param enableAcceleratedNetworking bool

resource nic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
    name: '${vmName}-nic'
    location: location
    tags: tags
    properties: {
        enableAcceleratedNetworking: enableAcceleratedNetworking
        ipConfigurations: [
            {
                name: 'IpConf'
                properties: {
                    subnet: {
                        id: subnetId
                    }
                    privateIPAllocationMethod: 'Dynamic'
                    privateIPAddressVersion: 'IPv4'
                    primary: true
                }
            }
        ]
    }
}

resource vm 'Microsoft.Compute/virtualMachines@2020-06-01' = {
    name: vmName
    location: location
    tags: tags
    zones: [
        availabilityZone
    ]
    properties: {
        hardwareProfile: {
            vmSize: vmSize
        }
        networkProfile: {
            networkInterfaces: [
                {
                    id: nic.id
                }
            ]
        }
        storageProfile: {
            imageReference: {
                publisher: 'MicrosoftWindowsServer'
                offer: 'WindowsServer'
                sku: '2019-Datacenter'
                version: 'latest'
            }
            osDisk: {
                name: '${vmName}-os'
                caching: 'ReadWrite'
                createOption: 'FromImage'
                managedDisk: {
                    storageAccountType: 'Premium_LRS'
                }
            }
            dataDisks: [
                {
                    caching: 'None'
                    name: '${vmName}-data-1'
                    diskSizeGB: 128
                    lun: 0
                    managedDisk: {
                        storageAccountType: 'Premium_LRS'
                    }
                    createOption: 'Empty'
                }
            ]
        }
        osProfile: {
            computerName: vmName
            adminUsername: username
            adminPassword: password
        }
    }
}

// Outputs
output vmName string = vm.name
output vmId string = vm.id
output nicId string = nic.id
