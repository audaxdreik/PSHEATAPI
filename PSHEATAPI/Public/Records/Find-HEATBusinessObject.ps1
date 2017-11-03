<#
    .SYNOPSIS
    Retrieves one or more business objects satisfying the search criteria.
    .DESCRIPTION
    Performs search as a Microsoft SQL-style query. Compared to the other search web methods, this is a general
    purpose web method that can be used to express arbitrarily complex queries.
    .PARAMETER Query
    Querty string that follows the structure of a Microsoft SQL SELECT request and captures most of the possible
    parameters in SELECT queries, including TOP, WHERE, JOIN, ORDER BY clauses.
    .EXAMPLE
    PS C:\>Find-HEATBusinessObject -Query $query

    Gonna be honest, don't know how to use this one myself quite yet.
    .NOTES
    Search(string sessionKey, string tenantId, ObjectQueryDefinition query)

    The verb 'Find' was chosen over 'Search' as it follows the PowerShell naming conventions closer.

    Be warned that currently the boType is not attached to found objects the same way as with the Get commands
    which can be expected to break piping. Looking for a way to fix this in future releases.
#>
function Find-HEATBusinessObject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline,
            Position = 0,
            HelpMessage = 'SQL query of search criteria'
        )]
        [string]$Query
    )

    begin { }

    process {

        # define the API call
        $apiCall = {

            $script:HEATPROXY.Search(
                $script:HEATCONNECTION.sessionKey,
                $script:HEATCONNECTION.tenantId,
                $Query
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

                #ConvertFrom-WebServiceObject -InputObject $_ -AdditionalProperties @{ boType = $Type }
                ConvertFrom-WebServiceObject -InputObject $_

            }

        } else {

            throw "response Status - $($response.Status), exceptionReason - $($response.exceptionReason)"

        }

    }

    end { }

}