<#
    .SYNOPSIS
    Returns information for a service offering template.
    .DESCRIPTION
    Not to be confused with Get-HEATRequestOffering which gives information regarding a specific request offering
    already submitted, this will provide information regarding the template for a service offering. Important
    information can be found under the 'lstParameters' property for each one of the parameters including whether or not
    it is required and how it is validated.
    .PARAMETER SubscriptionID
    The subscription ID for the service offering.
    .EXAMPLE
    PS C:\>Get-HEATRequestOfferingSubscriptionData -SubscriptionID '1E6AD004C6254EE1B7CE229022541496'

    Gets the package data for 'SharePoint Request' offering in the Service Catalog.
    .EXAMPLE
    PS C:\>Get-HEATRequestOfferingSubscriptionID -Name '* New Service Request' | Get-HEATRequestOfferingSubscriptionData

    Gets the subscription ID for a '* New Service Request' offering in the Service Catalog and feeds it directly into
    the Get-HEATRequestOfferingSubscriptionData.
    .NOTES
    GetPackageData(string sessionKey, string tenantId, string strSubscrRecId)
#>
function Get-HEATRequestOfferingSubscriptionData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            HelpMessage = 'subscription ID of the request offering')]
        [Alias('strSubscriptionId')]
        [string]$SubscriptionID
    )

    begin { }

    process {

        # define the API call
        $apiCall = {

            $script:HEATPROXY.GetPackageData(
                $script:HEATCONNECTION.sessionKey,
                $script:HEATCONNECTION.tenantId,
                $SubscriptionID
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

            # drop the response into the pipeline
            $response.srSubscription

        } else {

            throw "response Status - $($response.Status), exceptionReason - $($response.exceptionReason)"

        }

    }

    end { }

}