<#
    .SYNOPSIS
    Update a business object if it exists, otherwise create it.
    .DESCRIPTION
    This commandlet implements a SQL Merge or Upsert functionality, not to be confused with merging two business
    objects into a single record.

    It will attempt to find an existing business object using the provided field(s) to uniquely identify a record. If
    the business object is found, it updates it similar to a Set-HEATBusinessObject. If it does not find the business
    object it will create a new one similar to New-HEATBusinessObject.

    If your field criteria is not specific enough and applies to multiple valid records, the operation will update only
    one. The evaluation criteria is arbitrary but repeatable (meaning that which object is chosen is determined by an
    unknown internal mechanism, but will always choose the same object given the same set of objects). Obviously this
    is to be avoided as it can result in unexpected/unintended record changes.
    .PARAMETER Type
    The business object type (boType) for the data you are trying to upsert.
    .PARAMETER Data
    A hashtable containing the Name/Value pairs for the fields you want to upsert on the specified record, i.e.
    @{Name = 'FirstName'; Value = 'John'}
    .PARAMETER Field
    An array of fields for the given business object type that would uniquely match with your Data and identify a
    currently existing record. For example, if you are attempting to update an Employee# record, the 'LoginID'
    field could be provided. If a record matching the LoginID specified in Data was found, it would update that
    record. Otherwise it would create a new one. Your -Data must contain a definition for any/all -Fields provided.
    .PARAMETER Link
    An optional array of LinkEntry class or hashtables containing the Action/Relation/RelatedObjectType
    /RelatedObjectId values to link the updated/created record with other business objects.
    .EXAMPLE
    PS C:\>Merge-HEATBusinessObject -Type 'CI#Workstation' -Data @(@{Name = 'Name'; Value = 'HXA10051'}, @{Name = 'SerialNumber'; Value = 'FF0088C'}) -Field 'Name'

    Searches for a CI#Workstation business object where the Name is 'HXA10051' and, if found, sets the SerialNumber to
    'FF0088C'. Otherwise a new CI#Workstation record is created where the SerialNumber is 'HXA10051'. Notice how the
    -Data parameter contains a Name/Value pair for the -Field that is being specified.
    .NOTES
    Merge was chosen as the appropriate verb since it mirrors the intent of the SQL MERGE. Set is more appropriate
    for an update operation and Update is not really appropriate by PowerShell naming conventions. Topic is open
    for discussion but changes will be breaking after a 1.0 release.

    UpsertObject(string sessionKey, string tenantId, ObjectCommandData commandData, string[] searchFields)
#>
function Merge-HEATBusinessObject {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory,
            Position = 0,
            HelpMessage = 'the boType of the record that will be upserted')]
        [ValidatePattern('.*#')]
        [string]$Type,
        [Parameter(Mandatory,
            Position = 1,
            HelpMessage = 'hash of name/value pairs for the fields/values being updated')]
        $Data,
        [Parameter(Mandatory,
            Position = 2,
            HelpMessage = 'field names to uniquely identify the business object')]
        [string[]]$Field,
        [Parameter(Position = 3,
            HelpMessage = 'optional LinkEntry to other business objects')]
        $Link
    )

    $commandData = New-Object -TypeName WebServiceProxy.ObjectCommandData

    $commandData.ObjectType = $Type

    # attach the field data we want to initialize to the commandData
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

        $script:HEATPROXY.UpsertObject(
            $script:HEATCONNECTION.sessionKey,
            $script:HEATCONNECTION.tenantId,
            $commandData,
            $Field
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

        # return the created or updated business object data
        ConvertFrom-WebServiceObject -InputObject $response.obj -AdditionalProperties @{ boType = $Type }

    } else {

        throw "response Status - $($response.Status), exceptionReason - $($response.exceptionReason)"

    }

}