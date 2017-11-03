<#
    .SYNOPSIS
    Returns the list of available categories for the Service Catalog.
    .DESCRIPTION
    Returns an array with strRecID (the record ID), strName (the title of the category), and strDescription (a
    brief description of the category).
    .EXAMPLE
    PS C:\>Get-HEATRequestOfferingCategories

    Return all service request categories in your instance of HEAT.
    .NOTES
    GetCategories(string sessionKey, string tenantId)
#>
function Get-HEATRequestOfferingCategories {
    [CmdletBinding()]
    [OutputType([WebServiceProxy.FRSHEATServiceReqCategory])]
    param ()

    # define the API call
    $apiCall = {

        $script:HEATPROXY.GetCategories(
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

        # returns FRSHEATServiceReqCategory[]
        return $response.srCategories

    } else {

        throw "response Status - $($response.Status), exceptionReason - $($response.exceptionReason)"

    }

}