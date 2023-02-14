Write-Host "Set Variables..."

$RGNAME='M3DEMOS-SBX-ALZ-WKSP-RG-02'
$LOCATION='canadacentral'
$VMNAME='m3dwksputl1s'

Write-Host "Creating Resource Group..."

New-AzResourceGroup -Name $RGNAME -Location $LOCATION

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