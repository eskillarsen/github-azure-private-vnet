using './main.bicep'

param parLocation = 'norwayeast'
param parResourceGroup = 'rg-github-nics-001'
param parNetworkSecurityGroupName = 'nsg-github-nics-001'
param parVnetName = 'vnet-github-nics-001'
param parVnetAddressPrefix = '10.0.0.0/23'
param parSubnetNameGithub = 'snet-github-nics-001'
param parSubnetAddressGithub = '10.0.0.0/24'
param parSubnetStorageServiceEndpointGitHub = true
param parGithubNetworkSettingsName = 'github-network-settings-001'
param parGitHubDatabaseId = sys.readEnvironmentVariable('GITHUB_DATABASE_ID')
param parUamiName = 'id-github-nics-001'
param parTestVnetServiceEndpoint = {
  containerName: 'test-container'
  storageAccountName: 'st4githubazvnet'
}
