<#
    .SYNOPSIS
    Runs a predefined integration job.
    .DESCRIPTION
    This web method adds the integration job to the integration queue, where it will be executed by the next available
    integration processor. The response object returned from this web method contains the RecID of the integration job
    that was successfully scheduled.
    .PARAMETER Name
    The name of the integration job.
    .EXAMPLE
    PS C:\>Invoke-HEATIntegrationJob -Name 'ADGroups'

    Add the 'ADGroups' integration job to the Integration Queue.
    .NOTES
    IntegrationScheduleNow(string sessionKey, string tenantId, string integrationName)
#>
function Invoke-HEATIntegrationJob {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline,
            Position = 0,
            HelpMessage = 'name of the integration job')]
        [string]$Name
    )

    begin { }

    process {

        # define the API call
        $apiCall = {

            $script:HEATPROXY.IntegrationScheduleNow(
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

            # drop the RecID of the integration queue job that was successfully scheduled into the pipeline
            return $response.integrationQueueId

        } else {

            throw "response Status - $($response.Status), exceptionReason - $($response.exceptionReason)"

        }

    }

    end { }

}