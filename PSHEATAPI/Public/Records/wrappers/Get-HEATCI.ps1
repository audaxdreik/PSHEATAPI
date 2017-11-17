<#
    .SYNOPSIS
    Returns a CI (Configuration Item) business object.
    .DESCRIPTION
    A simple wrapper to return CI business objects by providing the commonly expected Name or a business object that is
    expected to have CIs associated with it.
    .PARAMETER Value
    String value for the Name or a business object that has associations with CIs, like an Employee.
    .PARAMETER SubType
    Defaults to 'Workstation', which will return a CI business object with the extended Workstation parameters. Can
    be set to other available subtypes if needed such as 'Server', 'Router', 'VirtualWorkstation', etc. Consult
    Get-HEATAllowedObjectNames for all possible 'CI#*' objects.
    .EXAMPLE
    PS C:\>Get-HEATCI -Value 'HLX00128'

    Returns the business object for the CI of the workstation named 'HLX00128'.
    .EXAMPLE
    PS C:\>Get-HEATEmployee -Value 'jdoe' | Get-HEATCI

    Returnes all the CIs where John Doe (jdoe) is listed as the owner.
    .NOTES
    The subtype assumption is specific to the client system engineers use cases and may want to be re-evaluated if
    there's wider adoption of this module.
#>
function Get-HEATCI {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline,
            Position = 0)]
        $Value,
        [Parameter(Position = 1)]
        [string]$SubType = 'Workstation'
    )

    begin { }

    process {

        $type = 'CI#' + $SubType

        if ($Value -is [string]) {

            # we assume the string -Value must be a simple request for Name
            Get-HEATBusinessObject -Value $Value -Type $type -Field 'Name'

        } else {

            # otherwise, evaluate the boType of the requesting business object and form a query based on that
            switch -regex ($Value.boType) {

                'Change#' {

                    (Find-HEATBusinessObject -SelectAll -From 'Change#' -Where @{Field = 'ChangeNumber'; Value = $Value.ChangeNumber; Condition = '='} -Link @{Relation = 'ChangeAssociatedCI'; Object = 'CI#'}).linkedQueryObjects

                }
                'Employee#' {

                    Get-HEATMultipleBusinessObjects -Value $Value.NetworkUserName -Type $type -Field 'Owner'

                }
                'Incident#' {

                    (Find-HEATBusinessObject -SelectAll -From 'Incident#' -Where @{Field = 'IncidentNumber'; Value = $Value.IncidentNumber; Condition = '='} -Link @{Relation = 'IncidentAssociatesCI'; Object = 'CI#'}).linkedQueryObjects

                }
                'Problem#' {

                    (Find-HEATBusinessObject -SelectAll -From 'Problem#' -Where @{Field = 'ProblemNumber'; Value = $Value.ProblemNumber; Condition = '='} -Link @{Relation = 'CIAssociatesProblem'; Object = 'CI#'}).linkedQueryObjects

                }
                default {

                    throw "unable to retrieve $type from provided boType: $($Value.boType)"

                }

            }

        }

    }

    end { }

}