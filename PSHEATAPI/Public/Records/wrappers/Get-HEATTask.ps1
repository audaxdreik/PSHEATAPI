<#
    .SYNOPSIS
    Returns a Task business object.
    .DESCRIPTION
    A simple wrapper to return Task business objects by providing the commonly expected AssignmentID (Task #).
    .PARAMETER Value
    Either a numeric value for the specific Task # you'd like to receive or a business object that is expected to
    have one or more tasks associated with it.
    .EXAMPLE
    PS C:\>Get-HEATTask -Value '54426'

    Returns the business object for Task #54426.
    .EXAMPLE
    PS C:\>Get-HEATServiceRequest -Value 91327 | Get-HEATTask

    Returns all the tasks associated with Service Request #91327
    .NOTES
    General notes.
#>
function Get-HEATTask {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 0)]
        [Alias('RecId', 'strRequestRecId')]
        [string]$Value
    )

    begin { }

    process {

        if($Value -match '[0-9A-F]{32}'){

            # if a record ID was provided, we're looking for multiple possible tasks attached to some other object
            Get-HEATMultipleBusinessObjects -Value $Value -Type 'Task#' -Field 'ParentLink_RecID'

        } else {

            # otherwise we're probably just searching for a single task, go with the parameters as set

            # remove the '#' character from -Value if the user included it
            $Value = $Value -replace '#'

            Get-HEATBusinessObject -Value $Value -Type 'Task#' -Field 'AssignmentID'

        }

    }

    end { }

}