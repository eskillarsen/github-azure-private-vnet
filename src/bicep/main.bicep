targetScope = 'subscription'

param parLocation string
param parResourceGroup string = 'rg-github-nics-001'

param parNetworkSecurityGroupName string = 'nsg-github-nics-001'

param parVnetName string = 'vnet-github-nics-001'
param parVnetAddressPrefix string = '10.0.0.0/23'

param parSubnetNameGithub string = 'snet-github-nics-001'
param parSubnetAddressGithub string = '10.0.0.0/24'
param parSubnetDelegationStorageGitHub bool = false

param parGithubNetworkSettingsName string = 'github-network-settings-001'
param parGitHubDatabaseId string

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: parResourceGroup
  location: parLocation
}

module vnet 'br/public:avm/res/network/virtual-network:0.2.0' = {
  scope: rg
  name: '${uniqueString(deployment().name, parLocation)}-vnet'
  params: {
    name: parVnetName
    addressPrefixes: [parVnetAddressPrefix]
    subnets: [
      {
        name: parSubnetNameGithub
        addressPrefix: parSubnetAddressGithub
        networkSecurityGroupResourceId: nsg.outputs.nsgId
        delegations: [
          {
            name: 'GitHub.Network.networkSettings'
            properties: {
              serviceName: 'GitHub.Network/networkSettings'
            }
          }
        ]
        serviceEndpoints: parSubnetDelegationStorageGitHub ? [{ service: 'Microsoft.Storage' }] : []
      }
    ]
  }
}

module nsg './nsg.bicep' = {
  scope: rg
  name: '${uniqueString(deployment().name, parLocation)}-nsg'
  params: {
    location: parLocation
    nsgName: parNetworkSecurityGroupName
  }
}

module githubNetworkSettings './github-networkSettings.bicep' = {
  scope: rg
  name: '${uniqueString(deployment().name, parLocation)}-github-network-settings'
  params: {
    parLocation: parLocation
    parNetworkSettingsName: parGithubNetworkSettingsName
    parSubnetId: first(vnet.outputs.subnetResourceIds)
    parGitHubDatabaseId: parGitHubDatabaseId
  }
}
