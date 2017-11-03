<#
    .SYNOPSIS
    Retrieves an XML version of the metadata behind a business object.
    .DESCRIPTION
    Returns a string representation of the XML version of the metadata behind a business object. In the process, it
    screens out properties not appropriate for end users, such as the RecID.
    .PARAMETER Name
    The name of the business object (boType) to retrieve the schema for.
    .PARAMETER All
    Retrieves all XML metadata behind an object, including typically screened fields such as RecID.
    .EXAMPLE
    PS C:\>Get-HEATSchemaForObject -Name 'Incident#'

    Returns a string representation of the XML schema for the Incident business object type.
    .EXAMPLE
    PS C:\>Get-HEATSchemaForObject -Name 'Task#' -All

    Returns a string represenation of the XML schema for the Task business object type, including fields which are
    normally hidden from the user.
    .NOTES
    calls GetSchemaForObject(string sessionKey, string tenantId, string objectName) unless -All switch, in which
    case calls GetAllSchemaForObject(string sessionKey, string tenantId, string objectName)
#>
function Get-HEATSchemaForObject {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline,
            Position = 0,
            HelpMessage = 'the boType name')]
        [string]$Name,
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
                    $Name
                )

            }

        } else {

            $apiCall = {

                $script:HEATPROXY.GetSchemaForObject(
                    $script:HEATCONNECTION.sessionKey,
                    $script:HEATCONNECTION.tenantId,
                    $Name
                )

            }

        }

        # make the actual API call here
        try {

            $response = Invoke-Command -ScriptBlock $apiCall

        } catch [System.Web.Services.Protocols.SoapException] {

            # catch a session timeout. renew the session and try again
            Connect-HEATProxy | Out-Null

            $response = Invoke-Command -ScriptBlock $apiCall

        }

        <#
            there's not really any 'response' here as with other calls, you're either going to get a dump of the raw
            xml or 'Exception calling "GetSchemaForObject" with "3" argument(s): "Unhandled system exception:
            System.Web.Services.Protocols.SoapException: Server was unable to process request. ---> System.Exception:
            Object not found' if you provided an invalid object type (not specified in GetAllAllowedObjectNames)
        #>
        $response

    }

    end { }

}