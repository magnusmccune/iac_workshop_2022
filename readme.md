# IaC Workshop 2022

This is the repo that I'm using to support my 2022 IaC Workshop at Microsoft.

## Tools

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

## Future Enhancements

1. Redesign the deployed infra to describe a fully functional and integrated environment
   1. ADF using git and CICD
   2. Function Apps, Web App & Logic Apps using SiteConfigs, Connectors & KeyVault References
2. Describe the workshop delivery within the repo
3. *stretch* include powerpoint and recordings