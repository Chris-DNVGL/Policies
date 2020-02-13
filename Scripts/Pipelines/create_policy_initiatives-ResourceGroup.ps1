Login-AzAccount
az account set -s "26a6717f-ee24-4802-bda7-0a17b0790911"
az account show 

$initiativeDefRootFolder = "C:\Users\chrcla\OneDrive - DNV GL\Repos\Policies\initiative" #$(System.DefaultWorkingDirectory)/Policies/initiative"
$subscriptionName = "PlayGround VerIT Infrastructure Development" #"$(subscriptionName)"

class InitiativeDef {
    [string]$InitiativeName
    [string]$InitiativeRulePath
}

function Select-Initiatives {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [System.IO.DirectoryInfo[]]$InitiativeFolders
    )

    Write-Warning "Processing initiatives"
    $initiativeList = @()
    foreach ($initiativeDefinition in $InitiativeFolders) {
        $initiative = New-Object -TypeName InitiativeDef
        $initiative.InitiativeName = $initiativeDefinition.Name
        $initiative.InitiativeRulePath = $($initiativeDefinition.FullName + "\policyset.json")
        $initiativeList += $initiative
    }

    return $initiativeList
}

function Add-Initiatives {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [InitiativeDef[]]$Initiatives,
        [String]$subscriptionId
    )

    $initiativeDefList = @()
    foreach ($initiative in $Initiatives) {
        $initiativeDef = New-AzureRmPolicySetDefinition -Name $initiative.InitiativeName -PolicyDefinition $initiative.InitiativeRulePath -Metadata '{"category":"Pipeline"}'
        $initiativeDefList += $initiativeDef
    }
    return $initiativeDefList
}

$subscriptionId = (Get-AzureRmSubscription -SubscriptionName $subscriptionName).Id
Set-AzureRmContext -SubscriptionId $subscriptionId


#get list of policy folders
$initiative = Select-Initiatives -InitiativeFolders (Get-ChildItem -Path $initiativeDefRootFolder -Directory)
$initiativeDefinitions = Add-Initiatives -Initiatives $initiative -subscriptionId $subscriptionId
$initiativeDefsJson = ($initiativeDefinitions | ConvertTo-Json -Depth 10 -Compress)

Write-Host "##vso[task.setvariable variable=PolicyDefs]$initiativeDefsJson"

$Env:PolicyDefs = $initiativeDefsJson
Get-ChildItem Env: