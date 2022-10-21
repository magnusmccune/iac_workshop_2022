# IaC Workshop 2022

This is the repo that I'm using to support my 2022 IaC Workshop at Microsoft.

# Tools

### Install & Update using WinGet

Check winget is installed and working  
`winget --version`

Install all the applications listed in winget.json  
`winget import ./winget.json`

### Install Extensions

``` powershell
code --install-extension ms-azure-devops.azure-pipelines
code --install-extension ms-azuretools.azure-dev
code --install-extension ms-azuretools.vscode-azureterraform
code --install-extension ms-azuretools.vscode-bicep
code --install-extension ms-vscode.azure-account
code --install-extension ms-vscode.azurecli
code --install-extension msazurermtools.azurerm-vscode-tools
code --install-extension vscode-icons-team.vscode-icons
```