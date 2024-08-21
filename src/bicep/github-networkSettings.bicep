param parLocation string
param parNetworkSettingsName string
param parSubnetId string
param parGitHubDatabaseId string

resource githubNetworkSettings 'GitHub.Network/networkSettings@2024-04-02' = {
  name: parNetworkSettingsName
  location: parLocation
  properties: {
    subnetId: parSubnetId
    businessId: parGitHubDatabaseId
  }
}
