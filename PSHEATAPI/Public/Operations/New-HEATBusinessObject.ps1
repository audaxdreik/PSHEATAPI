<#
    .SYNOPSIS
    Creates a new HEAT business Object such as an Approval, CI, or Task.
    .DESCRIPTION
    WARNING! Submit-HEATRequestOffering should be used for most Incidents and Service Requests as the fields are
    simpler and validations are performed on the objects. This should be used only for business objects that don't have
    a request offering associated with them or when creating the object directly is strictly necessary.

    If successful, returns the business object that was created.
    .PARAMETER Type
    The type of business object (boType) to create.
    .PARAMETER Data
    A hashtable containing the Name/Value pairs for the fields you want to initialize on the specified record, i.e.
    @{Name = 'FirstName'; Value = 'John'}
    .PARAMETER Link
    An optional array of LinkEntry class or hashtables containing the Action/Relation/RelatedObjectType
    /RelatedObjectId values to link the created record with other business objects.
    .EXAMPLE
    PS C:\>New-HEATBusinessObject -Type 'CI#Workstation' -Data $data

    Creates a new CI#Workstation object with the parameters supplied by $data (for this object type, minimally,
    [string]$Name, [string]$Status, [string]$SerialNumber, and [string]$AssetTag).
    .NOTES
    FRSHEATIntegrationCreateBOResponse CreateObject(string sessionKey, string tenantId, ObjectCommandData commandData)
#>
function New-HEATBusinessObject {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory,
            Position = 0,
            HelpMessage = 'the boType of the record that will be created')]
        [ValidatePattern('.*#')]
        [string]$Type,
        [Parameter(Mandatory,
            Position = 1,
            HelpMessage = 'hash of name/value pairs for the fields/values to initially populate')]
        $Data,
        [Parameter(Position = 2,
            HelpMessage = 'optional LinkEntry to other business objects')]
        $Link
    )

    $commandData = New-Object -TypeName WebServiceProxy.ObjectCommandData

    # ObjectId (the RecId) can be ommitted in this, unique one will be assigned automatically on successful creation
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

        $script:HEATPROXY.CreateObject(
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

        # return the newly created business object data
        ConvertFrom-WebServiceObject -InputObject $response.obj -AdditionalProperties @{ boType = $Type }

    } else {

        throw "response Status - $($response.Status), exceptionReason - $($response.exceptionReason)"

    }

}