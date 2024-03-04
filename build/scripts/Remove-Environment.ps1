
function Remove-Environment() {
    <#

    .SYNOPSIS
    Remove-Environment removes a resource group and associated Terraform state from Azure

    .DESCRIPTION
    There is an issue with destroying a databricks deployment in that the tokens and other secrets
    cannot be removed using Terraform. A bug for this is logged as an issue - https://github.com/databricks/terraform-provider-databricks/issues/3137

    #>

    [CmdletBinding()]
    param (

        [Alias("rgname", "group")]
        [string]
        # Name of the resource group to remove
        $ResourceGroupName,

        [string]
        # Group that has the specific network
        $NetworkResourceGroupName,

        [string]
        # Name of the virtual network which has the subnets
        $VirtualNetworkName,

        [string]
        # Terraform state storage account
        $TerraformStorageAccount,

        [string]
        # terraform container name
        $TerraformContainerName = "tfstate",

        [string]
        # Terraform state key
        $TerraformStateKey,

        [string]
        # Terraform workspace
        $TerraformWorkspace = "",

        [string]
        # Stiorage account key
        $SAKey = $env:SAKey,

        [string[]]
        # List of subnets to remove
        $subnets = $env:subnets,

        [string]
        # Path to the terraform files
        $TF_FILE_LOCATION = $env:TF_FILE_LOCATION,

        [switch]
        # Specifdy DryRun to see what would happen
        $dryrun
    )

    # Diable the saving of credentials
    Disable-AzContextAutosave | Out-Null

    # Connect to Azure using the credentials in the environment variables
    $secure_password = $env:ARM_CLIENT_SECRET | ConvertTo-SecureString -AsPlainText -Force
    $creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $env:ARM_CLIENT_ID, $secure_password
    $azsub = Connect-AzAccount -ServicePrincipal -Credential $creds -Tenant $env:ARM_TENANT_ID

    # Remove the subnets from the appropriate network
    $subnets = $subnets -split ","
    foreach ($subnet in $subnets) {

        # get the virtual network from which the subnet will be removed
        $_vnet = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $NetworkResourceGroupName
        $_subnet = Get-AzVirtualNetworkSubnetConfig -Name $subnet -VirtualNetwork $_vnet

        Write-Host ("Removing Subnet: {0}" -f $_subnet.Name)

        if ($_subnet -and !$dryRun) {
            Remove-AzVirtualNetworkSubnetConfig -Name $_subnet.Name -VirtualNetwork $_vnet | Set-AzVirtualNetwork -ErrorAction Continue
        }
    }

    # Remove the state from Terraform-State

    # Determine the name of the state key
    if (![String]::IsNullOrEmpty($TerraformWorkspace)) {
        $TerraformWorkspace = "env:{0}" -f $TerraformWorkspace
    }
    $state_key = "{0}{1}" -f $TerraformStateKey, $TerraformWorkspace

    $ctx = New-AzStorageContext -StorageAccountName $TerraformStorageAccount -StorageAccountKey $SAKey

    #if ($ctx) {
        $container = Get-AzStorageContainer -Name $TerraformContainerName -Context $ctx

        if ($container) {
            Write-Host ("State Key: {0}, Container: {1}" -f $state_key, $container.Name)

            if (!$dryRun) {
                Remove-AzStorageBlob -Blob $state_key -Container $container.Name -Context $ctx -Confirm:$false
            }
        }
    #}


    # Run command to delete the resource group
    Write-Host  ("Removing resource group: {0}" -f $ResourceGroupName)
    if (!$dryRun) {
        Remove-AzResourceGroup -Name $ResourceGroupName -Force
    }
}

# Use Terraform to get the name of the resource group to delete
Write-Host "Getting resource group to remove"

if (![String]::IsNullOrEmpty($TF_FILE_LOCATION)) {
    Push-Location -Path $TF_FILE_LOCATION
}

# Get the resource gropup to be deleted
if (!(Test-Path -Path env:\resource_group_name)) {
    $tf_data = Invoke-Expression -Command "terraform output -json" | ConvertFrom-Json
    $rg_name = $tf_data.resource_group_name
} else {
    $rg_name = $env:resource_group_name
}

if (![String]::IsNullOrEmpty($TF_FILE_LOCATION)) {
    Pop-Location 
}

$splat = @{
    NetworkResourceGroupName = $env:vnet_resource_group_name
    VirtualNetworkName = $env:vnet_name
    TerraformStorageAccount = $env:tf_state_storage
    TerraformStateKey = $env:tf_state_key
    TerraformWorkspace = $env:ENV_NAME
    ResourceGroupName = $rg_name
    subnets = $env:subnets
}

Remove-Environment @splat
