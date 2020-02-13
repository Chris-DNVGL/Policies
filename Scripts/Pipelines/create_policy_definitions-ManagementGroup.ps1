Set-PSDebug -Trace 0
Login-AzAccount
az account set -s "26a6717f-ee24-4802-bda7-0a17b0790911"
az account show #>

$policyDefRootFolder = "C:\Users\chrcla\OneDrive - DNV GL\Repos\Policies\Policy"  #"$(System.DefaultWorkingDirectory)/Policies"
$Managementgroupname = "68bcf241-a9a9-4d13-a40f-20486631c688" #$(managementgroupName)"

class PolicyDef {
    [string]$PolicyName
    [string]$PolicyRulePath
    [string]$PolicyParamPath
    [string]$ResourceId
}

function Select-Policies {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [System.IO.DirectoryInfo[]]$PolicyFolders
    )

    Write-Verbose "Processing policies"
    $policyList = @()
    foreach ($policyDefinition in $PolicyFolders) {
        $policy = New-Object -TypeName PolicyDef
        $policy.PolicyName = $policyDefinition.Name
        $policy.PolicyRulePath = $($policyDefinition.FullName + "\policydef.json")
        $policy.PolicyParamPath = $($policyDefinition.FullName + "\policydef.params.json")
        $policyList += $policy
    }

    return $policyList
}

function Add-Policies {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true)]
        [PolicyDef[]]$Policies
        # [String]$ManagementgroupID
    )

    Write-Verbose "Creating policy definitions"
    $policyDefList = @()
    foreach ($policy in $Policies) {
        $policyDef = New-AzureRmPolicyDefinition -ManagementGroupName $ManagementgroupID -Name $policy.PolicyName -Policy $policy.PolicyRulePath -Parameter $policy.PolicyParamPath -Metadata '{"category":"Pipeline"}'
        $policyDefList += $policyDef
    }
    return $policyDefList
}

$ManagementgroupID = (Get-AzureRmManagementGroup -GroupName $Managementgroupname).Name
#Set-AzureRmContext -SubscriptionId $ManagementgroupID
Write-Verbose $policyDefRootFolder
Write-Verbose $ManagementgroupID

#get list of policy folders
$policies = Select-Policies -PolicyFolders (Get-ChildItem -Path $policyDefRootFolder -Directory)
$policyDefinitions = Add-Policies -Policies $policies #-ManagementgroupID $ManagementgroupID
$policyDefsJson = ($policyDefinitions | ConvertTo-Json -Depth 10 -Compress)

Write-Host "##vso[task.setvariable variable=PolicyDefs]$policyDefsJson"