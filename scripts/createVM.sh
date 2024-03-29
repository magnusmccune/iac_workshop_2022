# Set Variables

echo 'Setting Variables...'
export RGNAME='M3DEMOS-SBX-ALZ-WKSP-RG-02'
export LOCATION='canadacentral'
export VMNAME='m3dwksputl1s'

# Create Resource Group

echo 'Creating Resource Group...'
az group create --name $RGNAME --location $LOCATION

# Create VM

echo 'Creating VM, standby to enter admin password...'
az vm create \
  --resource-group $RGNAME \
  --name $VMNAME \
  --image Win2022AzureEditionCore \
  --public-ip-sku Standard \
  --admin-username azadmin