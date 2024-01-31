# Script to all the Invoke-Terraform command to destroy an environment
# This is required because of the way in which Docker parses the command to be run

$splat = @{
    Apply = $true
    Path = "${env:TF_FILE_LOCATION}/destroy.tfplan"
    Arguments = @("-destroy")
    Debug = $true
}

Invoke-Terraform @splat
