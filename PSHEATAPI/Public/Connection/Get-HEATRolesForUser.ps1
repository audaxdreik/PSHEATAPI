<#
    .SYNOPSIS
    Gets a list of roles available to the current user.
    .DESCRIPTION
    Doesn't seem as if the API is capable of specifying a particular user. It will only return the roles of the user
    that was provided when the proxy connection was created.
    .EXAMPLE
    PS C:\>Get-HEATRolesForUser

    Returns 'Admin II' when run from 'SVCHeatAdministrator' context.
    .NOTES
    GetRolesForUser(string sessionKey, string tenantId)
#>
function Get-HEATRolesForUser {
    [CmdletBinding()]
    [OutputType([WebServiceProxy.NameDisplayPair])]
    param ()

    # define the API call
    $apiCall = {

        $script:HEATPROXY.GetRolesForUser(
            $script:HEATCONNECTION.sessionKey,
            $script:HEATCONNECTION.tenantId
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

        # drop the array of [WebServiceProxy.NameDisplayPair] into the pipeline
        $response.roleList

    } else {

        throw "response Status - $($response.Status), exceptionReason - $($response.exceptionReason)"

    }

}