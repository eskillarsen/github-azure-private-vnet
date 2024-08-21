# github-azure-private-vnet
Use GitHub-hosted runners with an Azure private network in your organization

**Table of content:**

 - [Register resource provider on target subscription](#Register-resource-provider-on-target-subscription)
 - [Get GitHub DatabaseId](#Get-GitHub-DatabaseId)

## Register resource provider on target subscription

### Check resource provider
```bicep
Set-AzContext -Subscription 'landing-zone-demo-001'
Get-AzResourceProvider -ProviderNamespace "GitHub.Network" | Format-Table
```

```text
ProviderNamespace RegistrationState ResourceTypes             Locations                                     ZoneMappings
----------------- ----------------- -------------             ---------                                     ------------
GitHub.Network    NotRegistered     {Operations}              {global}
GitHub.Network    NotRegistered     {networkSettings}         {East US, East US 2, West US 2, West Europe…}
GitHub.Network    NotRegistered     {registeredSubscriptions} {global}
```

### Register resource provider
```bicep
Register-AzResourceProvider -ProviderNamespace 'GitHub.Network'
```

### Success
```bicep
Get-AzResourceProvider -ProviderNamespace "GitHub.Network" | Format-Table
```
```text
ProviderNamespace RegistrationState ResourceTypes             Locations                                     ZoneMappings
----------------- ----------------- -------------             ---------                                     ------------
GitHub.Network    Registered        {Operations}              {global}
GitHub.Network    Registered        {networkSettings}         {East US, East US 2, West US 2, West Europe…}
GitHub.Network    Registered        {registeredSubscriptions} {global}
```

## Get GitHub DatabaseId
```pwsh
Import-Module ./src/pwsh/Get-GithubDatabaseId.psm1
Get-GithubDatabaseId.ps1 -OrganizationName myOrgHere -BearerToken $env:GH_TOKEN
```
```text
    login       databaseId
    -----       ----------
    myOrgHere   123456789
```