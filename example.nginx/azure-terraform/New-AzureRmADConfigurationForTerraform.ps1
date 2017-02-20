<#
.SYNOPSIS
Create new Azure AD elements for use with Terraform AzureRM provisioner
.DESCRIPTION
Terraform needs an AD application and service principal to use with its AzureRM provisioner.
#>
function New-AzureRmADConfigurationForTerraform
{
    [CmdletBinding()]
    [OutputType([Boolean])]
    Param
    (
        # Name of the AzureAD Application
        [string] $AzureRmADApplicationDisplayName = "TriDis-NginxOverview",

        # Password for the AzureAD Application
        [string] $AzureRmADApplicationPassword = "",

        # Path to save the AzureRM profile access token.
        [string] $AzureRmProfilePath = "..\\azure-secrets\\AzureRmProfile.json"
    )
    Begin
    {
        $ErrorActionPreference = "Stop"

        $UseDebugOrVerboseOutput = $true
        if ($PSBoundParameters.ContainsKey("Debug") -or $PSBoundParameters.ContainsKey("Verbose") -or ($DebugPreference -ne "SilentlyContinue") -or ($VerbosePreference -ne "SilentlyContinue"))
        {
            $UseDebugOrVerboseOutput = $true
        }

        [Environment]::CurrentDirectory = get-location

        if ($AzureRmADApplicationPassword -eq "")
        {
            Add-Type -AssemblyName System.Web
            $AzureRmADApplicationPassword = [System.Web.Security.Membership]::GeneratePassword(24,3)
        }
    }
    Process
    {
        $AzureRmAccount = Add-AzureRmAccount

        $AzureRMSubscriptionId = $AzureRmAccount.Context.Subscription.SubscriptionId

        $AzureRMTenantId = $AzureRmAccount.Context.Subscription.TenantId

        $AzureRmADApplication = New-AzureRmADApplication -DisplayName $AzureRmADApplicationDisplayName -HomePage "https://$AzureRmADApplicationDisplayName" -IdentifierUris "https://$AzureRmADApplicationDisplayName" -Password $AzureRmADApplicationPassword

        New-AzureRmADServicePrincipal -ApplicationId $AzureRmADApplication.ApplicationId

        Start-Sleep -s 15

        New-AzureRmRoleAssignment -RoleDefinitionName "Owner" -ServicePrincipalName $AzureRmADApplication.ApplicationId.Guid

        Save-AzureRmProfile -Path $AzureRmProfilePath

        $AzureRmADApplicationApplicationId = $AzureRmADApplication.ApplicationId

        Write-Output ""
        Write-Output "Use the following in your terraform.tfvars"
        Write-Output ""
        Write-Output "azure_client_id       = `"$AzureRmADApplicationApplicationId`""
        Write-Output "azure_client_secret   = `"$AzureRmADApplicationPassword`""
        Write-Output "azure_subscription_id = `"$AzureRMSubscriptionId`""
        Write-Output "azure_tenant_id       = `"$AzureRMTenantId`""
        Write-Output ""
    }
}