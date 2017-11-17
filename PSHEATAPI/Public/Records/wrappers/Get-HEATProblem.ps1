<#
    .SYNOPSIS
    Returns an Problem business object.
    .DESCRIPTION
    A simple wrapper to return Problem business objects by providing the commonly expected ProblemNumber or a business
    object that is expected to have Problems associated with it.
    .PARAMETER Value
    Numeric value for the Problem # or a business object that has associations with Problems, like an Change.
    .EXAMPLE
    PS C:\>Get-HEATProblem -Value '10045'

    Returns the business object for Problem #10045, the infamous 'black screen' incident.
    .NOTES
    General notes.
#>
function Get-HEATProblem {
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

            # we assume the string -Value must be a simple request for ProblemNumber

            # remove the '#' character from -Value if the user included it
            $Value = $Value -replace '#'

            Get-HEATBusinessObject -Value $Value -Type 'Problem#' -Field 'ProblemNumber'

        } else {

            # otherwise, evaluate the boType of the requesting business object and form a query based on that
            switch -regex ($Value.boType) {

                'Change#' {

                    (Find-HEATBusinessObject -SelectAll -From 'Change#' -Where @{Field = 'ChangeNumber'; Value = $Value.ChangeNumber; Condition = '='} -Link @{Relation = 'ProblemAssociatesChange'; Object = 'Problem#'}).linkedQueryObjects

                }
                'CI#' {

                    (Find-HEATBusinessObject -SelectAll -From 'CI#' -Where @{Field = 'Name'; Value = $Value.Name; Condition = '='} -Link @{Relation = 'CIAssociatesProblem'; Object = 'Problem#'}).linkedQueryObjects

                }
                default {

                    throw "unable to retrieve Problem# from provided boType: $($Value.boType)"

                }

            }

        }

    }

    end { }

}