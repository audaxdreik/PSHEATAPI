<#
    .SYNOPSIS
    Submit a new request offering such as an Incident or Service Request.
    .DESCRIPTION
    For submitting an Incident or Service Request available in the Service Catalog. This is the proper way to create a
    new instance of those business objects as the number of required parameters is limited by the request offering.
    Attempting to create a new Incident or Service Request directly from that business object type would require
    layering the parameters of that specific request offering on top of the object.
    .PARAMETER SubscriptionID
    The subscriptionID of the request offering to submit. A list of all available can be discovered through the
    'strSubscriptionId' property of the array returned by Get-HEATRequestOfferingTemplates.
    .PARAMETER Parameters
    The a hash of key/value pairs used to create the details of the request offering. They should be validated
    against the results of the Get-HEATRequestOfferingSubscriptionData of the SubscriptionID.
    .PARAMETER User
    The username/network ID of the user that will be shown as having submitted this request offering (which is not
    necessarily the user to receive action from the request offering).
    .EXAMPLE
    PS C:\>Submit-HEATRequestOffering -SubscriptionID '1E6AD004C6254EE1B7CE229022541496' -Parameters $data

    Submits a 'SharePoint Request' offering as the default account currently connected to the proxy using the
    key/value pairs stored in $data
    .EXAMPLE
    PS C:\>Get-HEATRequestOfferingSubscriptionID -Name '* New Service Request' | Submit-HEATRequestOffering -Parameters $data -User 'jdoe'

    Gets the subscriptionId of a '* New Service Request' offering and passes it to Submit-HEATRequestOffering to
    create a new instance of that request with data and using the supplied username as the request creator.
    .NOTES
    SubmitRequest(string sessionKey, string tenantId, string subscriptionId, List<FRSHEATServiceReqParam> srparameters, string loginId)
#>
function Submit-HEATRequestOffering {
    [CmdletBinding()]
    [OutputType([WebServiceProxy.FRSHEATServiceReqRequest])]
    param (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            Position = 0,
            HelpMessage = 'subscription ID of the request offering')]
        [Alias('strSubscriptionId')]
        [string]$SubscriptionID,
        [Parameter(Mandatory,
            Position = 1,
            HelpMessage = ' list of key value parameters for submitting the service request')]
        [hashtable]$Parameters,
        [Parameter(Mandatory,
            Position = 2,
            HelpMessage = 'the network ID of the user submitting the request')]
        [string]$User = $script:HEATCREDENTIALS.UserName
    )

    <#
        do we want to run a Get-HEATRequestOfferingSubscriptionData and evaluate the mandatory fields with the provided
        -Parameters here? it would definitely be a good idea ...
    #>

    # convert our input parameters to [WebServiceProxy.FRSHEATServiceReqParam]
    [WebServiceProxy.FRSHEATServiceReqParam[]]$srParameters = foreach ($key in $Parameters.Keys) {
        New-Object -TypeName WebServiceProxy.FRSHEATServiceReqParam -Property @{
            'strName'  = $key;
            'strValue' = $Parameters[$key]
        }
    }

    # define the API call
    $apiCall = {

        $script:HEATPROXY.SubmitRequest(
            $script:HEATCONNECTION.sessionKey,
            $script:HEATCONNECTION.tenantId,
            $SubscriptionID,
            $srParameters,
            $User
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

        # drop the request data of the successfully submitted service request into the pipeline
        $response.reqData

    } else {

        throw "response Status - $($response.Status), exceptionReason - $($response.exceptionReason)"

    }

}