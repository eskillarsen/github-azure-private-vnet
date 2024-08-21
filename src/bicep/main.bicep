targetScope = 'subscription'

param parLocation string
param parResourceGroup string = 'rg-github-nics-001'

param parNetworkSecurityGroupName string = 'nsg-github-nics-001'

param parVnetName string = 'vnet-github-nics-001'
param parVnetAddressPrefix string = '10.0.0.0/23'

param parSubnetNameGithub string = 'snet-github-nics-001'
param parSubnetAddressGithub string = '10.0.0.0/24'
param parSubnetStorageServiceEndpointGitHub bool = false

param parGithubNetworkSettingsName string = 'github-network-settings-001'
param parGitHubDatabaseId string

param parUamiName string = 'id-github-nics-001'

@description('Storage account info, used during testing of private access over service endpoint')
param parTestVnetServiceEndpoint typStorageAccountContainer?

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
        serviceEndpoints: parSubnetStorageServiceEndpointGitHub ? [{ service: 'Microsoft.Storage' }] : []
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

module uami 'br/public:avm/res/managed-identity/user-assigned-identity:0.3.0' = {
  scope: rg
  name: '${uniqueString(deployment().name, parLocation)}-uami'
  params: {
    name: parUamiName
    federatedIdentityCredentials: [
      {
        name: 'eskillarsen/github-azure-private-vnet/main'
        audiences: ['api://AzureADTokenExchange']
        issuer: 'https://token.actions.githubusercontent.com'
        subject: 'repo:eskillarsen/github-azure-private-vnet:ref:refs/heads/main'
      }
    ]
  }
}

module storage 'br/public:avm/res/storage/storage-account:0.9.1' = if (parTestVnetServiceEndpoint != null) {
  scope: rg
  name: '${uniqueString(deployment().name, parLocation)}-storage-account'
  params: {
    name: parTestVnetServiceEndpoint.?storageAccountName!
    skuName: 'Standard_LRS'
    blobServices: {
      containers: [
        { name: parTestVnetServiceEndpoint.?containerName }
      ]
    }
    roleAssignments: [
      {
        principalId: uami.outputs.principalId
        roleDefinitionIdOrName: 'Storage Blob Data Owner'
      }
    ]
    networkAcls: {
      defaultAction: 'Deny'
      virtualNetworkRules: [
        {
          id: first(vnet.outputs.subnetResourceIds)
          action: 'Allow'
        }
      ]
    }
  }
}

type typStorageAccountContainer = {
  storageAccountName: string
  containerName: string
}
