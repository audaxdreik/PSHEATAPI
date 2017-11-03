<#
    .SYNOPSIS
    Returns a Change business object.
    .DESCRIPTION
    A simple wrapper to return Change business objects by providing the commonly expected ChangeNumber or a business
    object that is expected to have Changes associated with it.
    .PARAMETER Value
    Numeric value for the Change # or a business object that has associations with Changes, like an Employee.
    .EXAMPLE
    PS C:\>Get-HEATChange -Value '12004'

    Returns the business object for Change #12004.
    .EXAMPLE
    PS C:\>Get-HEATEmployee -Value 'jdoe' | Get-HEATChange

    Return all changes where user John Doe (jdoe) was the requestor.
    .NOTES
    General notes.
#>
function Get-HEATChange {
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

            # we assume the string -Value must be a simple request for ChangeNumber

            # remove the '#' character from -Value if the user included it
            $Value = $Value -replace '#'

            Get-HEATBusinessObject -Value $Value -Type 'Change#' -Field 'ChangeNumber'

        } else {

            # otherwise, evaluate the boType of the requesting business object and form a query based on that
            switch -regex ($Value.boType) {

                'CI#' {

                    throw 'sorry, CI# link not implemented yet'

                }
                'Employee#' {

                    Get-HEATMultipleBusinessObjects -Value $Value.RecId -Type 'Change#' -Field 'RequestorLink_RecID'

                }
                'Incident#' {

                    throw 'sorry, Incident# link not implemented yet'

                }
                'Problem#' {

                    throw 'sorry, Problem# link not implemented yet'

                }
                default {

                    throw "unable to retrieve Change# from provided boType: $($Value.boType)"

                }

            }

        }

    }

    end { }

}