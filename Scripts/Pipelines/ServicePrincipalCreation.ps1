# Get the reference to the resource group
$resourceGroup = Get-AzResourceGroup -Name 'chrcla-rg'
#Get assignment
$assignment = Get-AzPolicyAssignment  -Id "/subscriptions/26a6717f-ee24-4802-bda7-0a17b0790911/resourceGroups/chrcla-RG/providers/Microsoft.Authorization/policyAssignments/DNV GL - Azure Batch - Testing RG"
# Get the policy definition
$policyDef = Get-AzPolicyDefinition -Id '/subscriptions/26a6717f-ee24-4802-bda7-0a17b0790911/providers/Microsoft.Authorization/policyDefinitions/Tagging'
# Use the $policyDef to get to the roleDefinitionIds array
$roleDefinitionIds = $policyDef.Properties.policyRule.then.details.roleDefinitionIds

if ($roleDefinitionIds.Count -gt 0)
{
    $roleDefinitionIds | ForEach-Object {
        $roleDefId = $_.Split("/") | Select-Object -Last 1
        New-AzRoleAssignment -Scope $assignment.ResourceGroupName -ObjectId $assignment.Id -RoleDefinitionId $roleDefId
    }
}


