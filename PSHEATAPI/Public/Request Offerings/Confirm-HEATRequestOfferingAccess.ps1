<#
    .SYNOPSIS
    Checks if the supplied user is entitled to access the given request offering.
    .DESCRIPTION
    Returns a boolean indicating whether or not a specific user has access to see and submit a specific request
    offering in the Service Catalog.
    .PARAMETER User
    The login ID (network user name) of the user to check access for.
    .PARAMETER Name
    The name of the request offering to check access to.
    .EXAMPLE
    PS C:\>Confirm-HEATRequestOfferingAccess -User 'jdoe' -Name '* New Service Request'

    Returns True if the user 'jdoe' has access to the '* New Service Request' offering.
    .NOTES
    UserCanAccessRequestOffering(string sessionKey, string tenantId, string loginId, string reqOfferingName)
#>
function Confirm-HEATRequestOfferingAccess {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory,
            Position = 0,
            HelpMessage = 'login ID of the user')]
        [string]$User,
        [Parameter(Mandatory,
            Position = 1,
            HelpMessage = 'name of request offering')]
        [string]$Name
    )

    # define the API call
    $apiCall = {

        $script:HEATPROXY.UserCanAccessRequestOffering(
            $script:HEATCONNECTION.sessionKey,
            $script:HEATCONNECTION.tenantId,
            $User,
            $Name
        )

    }

    # make the actual API call here
    try {

        $response = Invoke-Command -ScriptBlock $apiCall

    } catch [System.Web.Services.Protocols.SoapException] {

        # catch a session timeout. renew the session and try again
        Connect-HEATProxy | Out-Null

        $response = Invoke-Command -ScriptBlock $apiCall

    }

    if ($response.Status -like 'Success') {

        # drop it into the pipeline
        $response.canAccess

    } else {

        throw "response Status - $($response.Status), exceptionReason - $($response.exceptionReason)"

    }

}