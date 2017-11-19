<#
    .SYNOPSIS
    Converts the HEAT response into a PSCustomObject.
    .DESCRIPTION
    HEAT returns [FRSHEATIntegrationFindBOResponse] with an 'obj' property of type [WebServiceBusinessObject] that
    contains FieldValues with Name, Value pairs. This does not cast easily to PSCustomObject, so this function simply
    unwraps the FieldValues and rewraps them into a dictionary which can be passed to -Property when creating a new
    PSCustomObject which is then returned in the pipeline.
    .PARAMETER InputObject
    The [WebServiceBusinessObject] from the response of a HEAT API request. Usually your $response.obj (from a
    single query) or $response.objList (from a multiple query) piped in.
    .PARAMETER AdditionalProperties
    A hashtable containing additional properties to be appended to the resultant [PSCustomObject]. Most useful for
    passing the 'boType' along with an object as this can become ambiguous during queries.
    .EXAMPLE
    PS C:\>ConvertFrom-WebServiceObject -InputObject $response.obj

    Converts the $response.obj.FieldValues of a Get-HEATBusinessObject API request into a PSCustomObject.
    .NOTES
    Is there a better way to do this? I still feel like this is slightly clumsy.
#>
function ConvertFrom-WebServiceObject {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline,
            Position = 0)]
        [WebServiceProxy.WebServiceBusinessObject]$InputObject,
        [Parameter(Position = 1)]
        [hashtable]$AdditionalProperties
    )

    begin { }

    process {

        # instantiate an empty dictionary and add -AdditionalProperties if provided
        $objectProperties = [ordered]@{} + $AdditionalProperties

        # unwrap the FieldValues and add them to the $objectProperties dictionary
        $InputObject.FieldValues |
            Sort-Object -Property Name |
            ForEach-Object -Process {$objectProperties.Add($_.Name, $_.Value)}

        # create a new PSCustomObject with the freshly wrapped properties
        $businessObject = New-Object PSCustomObject -Property $objectProperties

        # set the actual TypeName of the object so it is properly identified for our format file
        $businessObject.psobject.TypeNames.Insert(0, $businessObject.boType)

        # drop the object into the pipeline
        $businessObject

    }

    end { }

}