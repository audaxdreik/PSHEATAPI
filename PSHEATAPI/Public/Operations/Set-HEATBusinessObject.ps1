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
    A hashtable containing the Name/Value pairs for the fields you want to update on the specified record, i.e.
    @{Name = 'FirstName'; Value = 'John'}
    .PARAMETER Link
    An optional array of LinkEntry class or hashtables containing the Action/Relation/RelatedObjectType
    /RelatedObjectId values to link the updated record with other business objects.
    .EXAMPLE
    PS C:\>Set-HEATBusinessObject -RecordID '41590365066449B18BE6A0DC5A44EC9A' -Type 'Incident#' -Data $data

    Updates/appends the values defined in $data to the Incident business object with the provided record ID.
    .EXAMPLE
    PS C:\>Get-HEATEmployee -Value 'jdoe' | Set-HEATBusinessObject -Data @{Name = 'Floor'; Value = '19'}

    Retrieves the Employee# business object for user 'jdoe' and sets the Floor field value to '19'.
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
        [ValidatePattern('.*#')]
        [string]$Type,
        [Parameter(Mandatory,
            Position = 2,
            HelpMessage = 'hash of name/value pairs for the fields/values being updated')]
        $Data,
        [Parameter(Position = 3,
            HelpMessage = 'optional LinkEntry to other business objects')]
        $Link
    )

    begin { }

    process {

        $commandData = New-Object -TypeName WebServiceProxy.ObjectCommandData

        # point the commandData at the object we want to update
        $commandData.ObjectType = $Type
        $commandData.ObjectId   = $RecordID

        # attach the field data we want to update to the commandData
        try {

            $commandData.Fields = [WebServiceProxy.ObjectCommandDataFieldValue[]]$Data

        } catch {

            throw $_

        }

        # append optional links to other business objects if defined in -Link parameter
        if ($Link) {

            try {

                $commandData.LinkToExistent = [WebServiceProxy.LinkEntry[]]$Link

            } catch {

                throw $_

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