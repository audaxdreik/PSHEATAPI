<#
    .SYNOPSIS
    Retrieves multiple HEAT business objects such as Incidents, Service Requests, or Tasks.
    .DESCRIPTION
    WARNING! Because this is pulling multiple entries this commandlet can take some time to complete! It will return
    multiple business objects on queries that are expected to have multiple entries such as 'all active incidents' or
    'all tasks associated with an incident'. Can also be used to return queries expected to have only one result,
    though Get-HEATBusinessObject is preferred.
    .PARAMETER Value
    The value (fieldValue) to search for on a given Field (fieldName).
    .PARAMETER Type
    The HEAT business object type (boType).
    .PARAMETER Field
    The field (fieldName) that the Value (fieldValue) will search the business object Type (boType) on.
    .EXAMPLE
    PS C:\>Get-HEATMultipleBusinessObjects -Value 'Active' -Type 'Incident' -Field 'Status'

    Return all the 'Incident' business objects that currently have their 'Status' fieldValue set to 'Active'.
    .NOTES
    FindMultipleBusinessObjectsByField(string sessionKey, string tenantId, string boType, string fieldName, string fieldValue)
#>
function Get-HEATMultipleBusinessObjects {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline,
            Position = 0,
            HelpMessage = 'fieldValue for the fieldName (Field)')]
        [string]$Value,
        [Parameter(Mandatory,
            Position = 1,
            HelpMessage = 'an exact HEAT boType')]
        [ValidatePattern('.*#')]
        [string]$Type,
        [Parameter(Mandatory,
            Position = 2,
            HelpMessage = 'fieldName to search HEAT boType on')]
        [string]$Field
    )

    begin { }

    process {

        # define the API call
        $apiCall = {

            $script:HEATPROXY.FindMultipleBusinessObjectsByField(
                $script:HEATCONNECTION.sessionKey,
                $script:HEATCONNECTION.tenantId,
                $Type,
                $Field,
                $Value
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

            # convert the $response.obj.FieldValues into a PSCustomObject and drop it into the pipeline
            $response.objList | ForEach-Object -Process {
                <#
                    each element of objList is actually [WebServiceProxy.WebServiceBusinessObject[]] due to the
                    possibility of nested joins that aren't entirely clear to me that would result in this particular
                    API call. for this reason $_[0] is passed instead of just $_ though this may cause unintended
                    results that may need to be addressed in the future
                #>
                ConvertFrom-WebServiceObject -InputObject $_[0] -AdditionalProperties @{ boType = $Type }
            }

        } else {

            throw "response Status - $($response.Status), exceptionReason - $($response.exceptionReason)"

        }

    }

    end { }

}