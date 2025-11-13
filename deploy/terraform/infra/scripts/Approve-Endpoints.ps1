
[CmdletBinding()]
param (
    [string]
    # Client ID of the Service Principal
    $ClientID,

    [string]
    # Client Secret of the service principal
    $ClientSecret = $env:ARM_CLIENT_SECRET,

    [string]
    # Tenant ID of the SP
    $TenantId,

    [string]
    # JSON list of endpoint IDs to approve
    $EndpointIds
)

# Connect to Azure
# - Created the credentials object to use with the Connect-AzAccount cmdlet
$secureStringPassword = ConvertTo-SecureString -String $ClientSecret -AsPlainText -Force
$psCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ClientID, $secureStringPassword

# - Create the splat of parameters to pass to the cmdlet
$splatParams = @{
    ServicePrincipal = $true
    Credential       = $psCredential
    Tenant           = $TenantId
}

Write-Host "Connecting to Azure..."
Connect-AzAccount @splatParams

# convert the json string to a pscustomobject
$data = $EndpointIds -replace "'", "" | ConvertFrom-Json

# Iterate around the IDs that have been passed and approve them
foreach ($item in $data.PsObject.Properties) {
    Write-Host ("Checking endpoint: {0} [{1}]" -f $item.Name, $item.Value)

    # Get the list of endpoints that need to be approved
    # These are the ones that are in a provisioning state
    $pendingPrivateEndpoints = Get-AzPrivateEndpointConnection -PrivateLinkResourceId $item.Value | Where-Object { $_.PrivateLinkServiceConnectionState.Status -eq "Pending" }
    foreach ($ep in $pendingPrivateEndpoints) {
        Write-Host ("`tApproving endpoint: {0}" -f $ep.id)

        Approve-AzPrivateEndpointConnection -ResourceId $ep.id -Description "Approved by Terraform"
    }
    
}