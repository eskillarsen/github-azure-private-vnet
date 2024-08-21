function Get-GithubDatabaseId {
    <#
    .EXAMPLE
    Get-GithubDatabaseId -OrganizationName myOrgHere -BearerToken $env:GH_TOKEN123
    
    login       databaseId
    -----       ----------
    myOrgHere   123456789
    #>

    param (
        [string]$OrganizationName,
        [string]$BearerToken
    )

    $splat = @{
        Uri = 'https://api.github.com/graphql'
        Method = 'POST'
        Authentication = 'OAuth'
        Token = ConvertTo-SecureString -AsPlainText -Force -String $BearerToken
        Body = @{
            "query" = 'query($login: String!) { organization (login: $login) { login databaseId } }'
            "variables" = @{ "login" = $OrganizationName }
        } | ConvertTo-Json
    }
    return (Invoke-RestMethod @splat).data.organization
}
