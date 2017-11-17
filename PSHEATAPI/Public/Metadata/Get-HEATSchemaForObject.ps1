<#
    .SYNOPSIS
    Retrieves an XML version of the metadata behind a business object.
    .DESCRIPTION
    Returns the XML repesentation of the metadata behind a business object. In the process, it screens out properties
    not appropriate for end users, such as the RecID.
    .PARAMETER Type
    The name of the business object (boType) to retrieve the schema for.
    .PARAMETER All
    Retrieves all XML metadata behind an object, including typically screened fields such as RecID.
    .EXAMPLE
    PS C:\>Get-HEATSchemaForObject -Type 'Incident#'

    Returns a string representation of the XML schema for the Incident business object type.
    .EXAMPLE
    PS C:\>Get-HEATSchemaForObject -Type 'Task#' -All

    Returns a string represenation of the XML schema for the Task business object type, including fields which are
    normally hidden from the user.
    .NOTES
    calls GetSchemaForObject(string sessionKey, string tenantId, string objectName) unless -All switch, in which
    case calls GetAllSchemaForObject(string sessionKey, string tenantId, string objectName)
#>
function Get-HEATSchemaForObject {
    [CmdletBinding()]
    [OutputType([xml])]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline,
            Position = 0,
            HelpMessage = 'the name of the boType')]
        [ValidatePattern('.*#')]
        [string]$Type,
        [switch]$All
    )

    begin { }

    process {

        # define the API call
        if ($All) {

            $apiCall = {

                $script:HEATPROXY.GetAllSchemaForObject(
                    $script:HEATCONNECTION.sessionKey,
                    $script:HEATCONNECTION.tenantId,
                    $Type
                )

            }

        } else {

            $apiCall = {

                $script:HEATPROXY.GetSchemaForObject(
                    $script:HEATCONNECTION.sessionKey,
                    $script:HEATCONNECTION.tenantId,
                    $Type
                )

            }

        }

        # make the actual API call here
        try {

            <#
                there's not really any 'response' here as with other calls, you're either going to get a dump of the
                raw xml or 'Exception calling "GetSchemaForObject" with "3" argument(s): "Unhandled system exception:
                System.Web.Services.Protocols.SoapException: Server was unable to process request. --->
                System.Exception: Object not found' if you provided an invalid object type (not specified in
                GetAllAllowedObjectNames)
            #>
            [xml](Invoke-Command -ScriptBlock $apiCall)

        }
        catch [System.Web.Services.Protocols.SoapException] {

            # catch a session timeout. renew the session and try again
            Connect-HEATProxy | Out-Null

            [xml](Invoke-Command -ScriptBlock $apiCall)

        }

    }

    end { }

}