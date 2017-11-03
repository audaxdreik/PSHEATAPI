<#
    .SYNOPSIS
    Returns the subscriptionId for a specific request offering.
    .DESCRIPTION
    SubscriptionID is the appropriate property to use whenever manipulating Request Offerings, as opposed to the usual
    RecId parameter.
    .PARAMETER Name
    The user friendly name for the request offering.
    .EXAMPLE
    PS C:\>Get-HEATRequestOfferingSubscriptionID -Name '* New Issue'

    Returns the subscriptionId for the '* New Issue' offering, '36C932BB2AD945CE92287AD100265206'.
    .NOTES
    GetSubscriptionId(string sessionKey, string tenantId, string name)
#>
function Get-HEATRequestOfferingSubscriptionID {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory,
            Position = 0,
            HelpMessage = 'the name of the offering as it appears in Service Catalog')]
        [string]$Name
    )

    # define the API call
    $apiCall = {

        $script:HEATPROXY.GetSubscriptionId(
            $script:HEATCONNECTION.sessionKey,
            $script:HEATCONNECTION.tenantId,
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

        # return just the subscriptionId string
        $response.subscriptionId

    } else {

        throw "response Status - $($response.Status), exceptionReason - $($response.exceptionReason)"

    }

}