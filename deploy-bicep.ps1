#Requires -Modules @{ ModuleName="Az.Resources"; ModuleVersion="7.2.0" }

param (
    [string]$Subscription = 'landing-zone-demo-001',
    [string]$TemplateFile = './src/bicep/main.bicep',
    [string]$TemplateParameterFile = './src/bicep/main.bicepparam',
    [string]$Location = 'norwayeast'
)


$splat = @{
    Name                  = -join ('github-nics-{0}' -f (Get-Date -Format 'yyyyMMddTHHMMssffffZ'))[0..63]
    Location              = $Location
    TemplateFile          = $TemplateFile
    TemplateParameterFile = $TemplateParameterFile
    Verbose               = $true
}

Select-AzSubscription -Subscription $Subscription
New-AzSubscriptionDeployment @splat
