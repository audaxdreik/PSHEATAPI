<#
    .SYNOPSIS
    Retrieves a list of all business object types.
    .DESCRIPTION
    Retrieves a list of all possible business object types in your HEAT implementation.
    .EXAMPLE
    PS C:\>Get-HEATAllowedObjectNames

    Returns an array of [string] for all the allowed object type names of this instance of HEAT.
    .NOTES
    GetAllAllowedObjectNames(string sessionKey, string tenantId)
#>
function Get-HEATAllowedObjectNames {
    [CmdletBinding()]
    [OutputType([string])]
    param ()

    # define the API call
    $apiCall = {

        $script:HEATPROXY.GetAllAllowedObjectNames(
            $script:HEATCONNECTION.sessionKey,
            $script:HEATCONNECTION.tenantId
        )

    }

    # make the actual API call here
    try {

        # drop [string[]] response directly into pipeline
        Invoke-Command -ScriptBlock $apiCall

    } catch [System.Web.Services.Protocols.SoapException] {

        # catch a session timeout. renew the session and try again
        Connect-HEATProxy | Out-Null

        Invoke-Command -ScriptBlock $apiCall

    }

}