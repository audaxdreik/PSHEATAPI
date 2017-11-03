<#
    .SYNOPSIS
    Returns a ServiceRequest business object.
    .DESCRIPTION
    A simple wrapper to return ServiceRequest business objects by providing the commonly expected ServiceReqNumber or a
    business object that is expected to have ServiceRequests associated with it.
    .PARAMETER Value
    Numeric value for the Serivce Request # or a business object that has associations with Service Requests, like
    an Employee.
    .EXAMPLE
    PS C:\>Get-HEATServiceRequest -Value '91862'

    Returns the business object for Service Request #91862.
    .EXAMPLE
    PS C:\>Get-HEATEmployee -Value 'jdoe' | Get-HEATServiceRequest

    Returns all Service Requests that need to be fulfilled for John Doe (jdoe).
    .NOTES
    General notes.
#>
function Get-HEATServiceRequest {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline,
            Position = 0)]
        $Value
    )

    begin { }

    process {

        if (($Value -is [string]) -or ($Value -is [int])) {

            # we assume the string -Value must be a simple request for ServiceReqNumber

            # remove the '#' character from -Value if the user included it
            $Value = $Value -replace '#'

            Get-HEATBusinessObject -Value $Value -Type 'ServiceReq#' -Field 'ServiceReqNumber'

        } else {

            # otherwise, evaluate the boType of the requesting business object and form a query based on that
            switch ($Value.boType) {

                'Employee#' {

                    Get-HEATMultipleBusinessObjects -Value $Value.RecId -Type 'ServiceReq#' -Field 'ProfileLink_RecID'

                }
                default {

                    throw "unable to retrieve ServiceReq# from provided boType: $($Value.boType)"

                }

            }

        }

    }

    end { }

}