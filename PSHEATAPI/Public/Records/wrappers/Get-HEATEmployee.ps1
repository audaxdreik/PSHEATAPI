<#
    .SYNOPSIS
    Returns an Employee (User) business object.
    .DESCRIPTION
    A simple wrapper to return Employee business objects by providing the commonly expected NetworkUserName.
    .PARAMETER Value
    String value for the NetworkUserName (SamAccountName).
    .EXAMPLE
    PS C:\>Get-HEATEmployee -Value 'jdoe'

    Returns the business object for Employee 'jdoe' (John Doe).
    .NOTES
    Get-HEATBusinessObject -Value $Value -Type 'Employee#' -Field $Field
#>
function Get-HEATEmployee {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline,
            Position = 0)]
        [string]$Value,
        [Parameter(Position = 1)]
        [string]$Field = 'NetworkUserName'
    )

    begin { }

    process {

        Get-HEATBusinessObject -Value $Value -Type 'Employee#' -Field 'NetworkUserName'

    }

    end { }

}