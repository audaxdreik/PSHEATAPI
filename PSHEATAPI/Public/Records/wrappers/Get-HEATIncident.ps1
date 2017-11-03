<#
    .SYNOPSIS
    Returns an Incident business object.
    .DESCRIPTION
    A simple wrapper to return Incident business objects by providing the commonly expected IncidentNumber or a
    business object that is expected to have Incidents associated with it.
    .PARAMETER Value
    Numeric value for the Incident # or a business object that has associations with Incidents, like an Problem.
    .EXAMPLE
    PS C:\>Get-HEATIncident -Value '80337'

    Returns the business object for Incident #80337.
    .EXAMPLE
    PS C:\>Get-HEATEmployee -Value 'jdoe' | Get-HEATIncident

    Returns all the incidents where John Doe (jdoe) was the reporting user.
    .EXAMPLE
    PS C:\>Get-HEATProblem -Value '10045' | Get-HEATIncident

    Returns all the incidents associated with the "black screen" problem. All 320 of them.
    .NOTES
    General notes.
#>
function Get-HEATIncident {
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

            # we assume the string -Value must be a simple request for IncidentNumber

            # remove the '#' character from -Value if the user included it
            $Value = $Value -replace '#'

            Get-HEATBusinessObject -Value $Value -Type 'Incident#' -Field 'IncidentNumber'

        } else {

            # otherwise, evaluate the boType of the requesting business object and form a query based on that
            switch -regex ($Value.boType) {

                'Change#' {

                    throw 'sorry, Change# link not implemented yet'

                }
                'CI#' {

                    throw 'sorry, CI# link not implemented yet'

                }
                'Employee#' {

                    Get-HEATMultipleBusinessObjects -Value $Value.RecId -Type 'Incident#' -Field 'ProfileLink_RecID'

                }
                'Problem#' {

                    Get-HEATMultipleBusinessObjects -Value $Value.RecId -Type 'Incident#' -Field 'ProblemLink_RecID'

                }
                default {

                    throw "unable to retrieve Incident# from provided boType: $($Value.boType)"

                }

            }

        }

    }

    end { }

}