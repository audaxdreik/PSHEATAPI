<#
    .SYNOPSIS
    Removes a HEAT business object record.
    .DESCRIPTION
    Completely deletes a HEAT business object record from the service instance. Returns $true if successful, otherwise
    throws an error.
    .PARAMETER RecordID
    The record ID (RecID) of the business object being removed.
    .PARAMETER Type
    The business object type (boType) of the record to be removed.
    .EXAMPLE
    PS C:\>Remove-HEATBusinessObject -RecordID '88D652EB6D7E4B10B305F7FE1C19B330' -Type 'ServiceReq#'

    Removes the Service Request business object with a record ID (RecId) of '88D652EB6D7E4B10B305F7FE1C19B330'.
    .EXAMPLE
    PS C:\>Get-HEATServiceRequest -Value '91862' | Remove-HEATBusinessObject

    Retrieves the business object data for Service Request #91862, then passes it to Remove-HEATBusinessObject for
    deletion.
    .NOTES
    DeleteObject(string sessionKey, string tenantId, ObjectCommandData commandData)

    In this case, the commandData only needs the boType and RecId for the object to be removed.
#>
function Remove-HEATBusinessObject {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            Position = 0,
            HelpMessage = 'the exact recordId of the business object to update')]
        [Alias('RecId', 'strRequestRecId')]
        [string]$RecordID,
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            Position = 1,
            HelpMessage = 'the boType of the record that will be updated')]
        [Alias('boType')]
        [string]$Type
    )

    begin { }

    process {

        $commandData = New-Object -TypeName WebServiceProxy.ObjectCommandData

        $commandData.ObjectType = $Type
        $commandData.ObjectId   = $RecordID

        # define the API call
        $apiCall = {

            $script:HEATPROXY.DeleteObject(
                $script:HEATCONNECTION.sessionKey,
                $script:HEATCONNECTION.tenantId,
                $commandData
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

            # object was successfully removed
            return $true

        } else {

            throw "response Status - $($response.Status), exceptionReason - $($response.exceptionReason)"

        }

    }

    end { }

}