<#
    .SYNOPSIS
    Returns the data for a given Service Request.
    .DESCRIPTION
    It's important to note that this commandlet is different and significantly more useful than its counterpart,
    'Get-HEATServiceRequest' which will return the same object, albeit as a HEAT business object. In this form it
    contains the complete, raw data of the service request. This commandlet however will return a more sensible data
    set for what constitutes the Service Request, remember that you can access its raw parameters through the
    'lstParameters' property.
    .PARAMETER RequestNumber
    The numeric ID of the Service Request you'd like to retrieve.
    .EXAMPLE
    PS C:\>Get-HEATRequestOffering -RequestNumber '91862'

    Returns a [WebServiceProxy.FRSHEATServiceReqRequest] object with easily accessible properties such as
    'strByEmployee' ('John Doe') to show who submitted the Service Request and 'strStatus' ('Approved') to show the
    current status of the offering.
    .NOTES
    GetRequestData(string sessionKey, string tenantId, string strReqNumber)
#>
function Get-HEATRequestOffering {
    [CmdletBinding()]
    [OutputType([WebServiceProxy.FRSHEATServiceReqRequest])]
    param (
        [Parameter(Mandatory,
            Position = 0,
            ValueFromPipeline,
            HelpMessage = 'the numeric ID of the Service Request')]
        [string]$RequestNumber
    )

    begin { }

    process {

        # remove the '#' character from -RequestNumber if the user included it
        $RequestNumber = $RequestNumber -replace '#'

        # define the API call
        $apiCall = {

            $script:HEATPROXY.GetRequestData(
                $script:HEATCONNECTION.sessionKey,
                $script:HEATCONNECTION.tenantId,
                $RequestNumber
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

            # add the 'boType' property so that it can be piped into other Set/Remove commandlets
            $response.reqData | Add-Member -NotePropertyName 'boType' -NotePropertyValue 'ServiceReq#'

            # drop the request data of the response into the pipeline
            $response.reqData

        } else {

            throw "response Status - $($response.Status), exceptionReason - $($response.exceptionReason)"

        }

    }

    end { }

}