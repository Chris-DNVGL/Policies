#$pscredential = Get-Credential
# connect-AzAccount -ServicePrincipal -Tenant "adf10e2b-b6e9-41d6-be2f-c12bb566019c"

# Get the reference to the resource group
$resourceGroup = Get-AzResourceGroup -Name 'chrcla-rg'
#Get assignment
$assignment = Get-AzPolicyAssignment  -Id "/subscriptions/26a6717f-ee24-4802-bda7-0a17b0790911/resourceGroups/chrcla-RG/providers/Microsoft.Authorization/policyAssignments/Tagging"
# Get the policy definition
$policyDef = Get-AzPolicyDefinition -Id '/subscriptions/26a6717f-ee24-4802-bda7-0a17b0790911/providers/Microsoft.Authorization/policyDefinitions/Tagging'
# Use the $policyDef to get to the roleDefinitionIds array
$roleDefinitionIds = $policyDef.Properties.policyRule.then.details.roleDefinitionIds

if ($roleDefinitionIds.Count -gt 0)
{
    $roleDefinitionIds | ForEach-Object {
        $roleDefId = $_.Split("/") | Select-Object -Last 1
        New-AzRoleAssignment -Scope $assignment.Properties.Scope -ObjectId $assignment.Identity.principalId -RoleDefinitionId $roleDefId
    }
}



