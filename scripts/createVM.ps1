Write-Host "Set Variables..."

$RGNAME='M3DEMOS-IACWSHP-RG-01'
$LOCATION='canadacentral'
$VMNAME='m3diacwshputl1'

Write-Host "Creating Resource Group..."

New-AzResourceGroup -Name $RGNAME -Location $VMNAME

Write-Host "Creating Virtual Machine, standby to provide username and password..."

New-AzVm `
    -ResourceGroupName $RGNAME `
    -Name $VMNAME `
    -Location $LOCATION `
    -VirtualNetworkName 'myVnet' `
    -SubnetName 'mySubnet' `
    -SecurityGroupName 'myNetworkSecurityGroup' `
    -PublicIpAddressName 'myPublicIpAddress' `
    -OpenPorts 80,3389