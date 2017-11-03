<#
    .SYNOPSIS
    Updates a HEAT business objects such as an Incident, Service Request, or Task.
    .DESCRIPTION
    Updates a single object by changing its field values, and may also establish or break relationships with other
    objects. The auto-fill, calculated, save, and business rules run during the update and may trigger additional field
    changes. Validation rules are also executed and they might block the update operation if the resulting object field
    values do not pass the validation.
    .PARAMETER RecordID
    The specific recordId (RecId) of the business object you are trying to update.
    .PARAMETER Type
    The corresponding business object type (boType) of the record you are trying to update.
    .PARAMETER Data
    A hashtable containing the fieldName/fieldValue pairs you want to update on the specified record.
    .EXAMPLE
    PS C:\>Set-HEATBusinessObject -RecordID '41590365066449B18BE6A0DC5A44EC9A' -Type 'Incident#' -Data $data

    Updates/appends the values defined in $data to the Incident business object with the provided record ID.
    .EXAMPLE
    PS C:\>Get-HEATRequestOffering -RequestNumber '91862' | Set-HEATBusinessObject -Data $data

    Retrieves the appropriate record ID to reference Service Request #91862 and then updates/appends the values defined
    in the $data variable. It's important to note that in this example the result of this operation will return the new
    state of the object as a [PSCustomObject] even though Get-HEATRequestOffering passed in [FRSHEATServiceReqRequest].
    .NOTES
    UpdateObject(string sessionKey, string tenantId, ObjectCommandData commandData)

    Even though the web service method is UpdateObject, PowerShell approved verbs and naming conventions indicate
    that Set is a more appropriate verb than Update for this commandlet.
#>
function Set-HEATBusinessObject {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
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
        [string]$Type,
        [Parameter(Mandatory,
            Position = 2,
            HelpMessage = 'hash of name/value pairs for the fields/values being updated')]
        [hashtable]$Data
    )

    begin { }

    process {

        $commandData = New-Object -TypeName WebServiceProxy.ObjectCommandData

        $commandData.ObjectType = $Type
        $commandData.ObjectId   = $RecordID
        $commandData.Fields     = foreach ($key in $Data.Keys) {
            New-Object -TypeName WebServiceProxy.ObjectCommandDataFieldValue -Property @{
                'Name'  = $key;
                'Value' = $Data[$key]
            }
        }

        # define the API call
        $apiCall = {

            $script:HEATPROXY.UpdateObject(
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

            # return the updated business object data
            ConvertFrom-WebServiceObject -InputObject $response.obj -AdditionalProperties @{ boType = $Type }

        } else {

            throw "response Status - $($response.Status), exceptionReason - $($response.exceptionReason)"

        }

    }

    end { }

}