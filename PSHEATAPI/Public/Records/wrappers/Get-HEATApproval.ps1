<#
    .SYNOPSIS
    Returns an Approval business object.
    .DESCRIPTION
    Retrieves all approvals (FRS_Approval#) attached to a provided record ID. It will also automatically find any votes
    (FRS_ApprovalVoteTracking#) attached to the business object and append them under the 'FRS_ApprovalVoteTracking'
    property for easy access.
    .PARAMETER Value
    The record ID (RecId) of the object you'd like to retrieve approvals attached to. Also accepts business objects
    that are expected to have approvals attached to them such as Change and ServiceRequest/RequestOffering.
    .EXAMPLE
    PS C:\>Get-HEATApproval -Value '1AFFC174C7EA4AB79CCA6B15EB67006D'

    Returns any approvals attached to the specified business object record.
    .EXAMPLE
    PS C:\>Get-HEATChange -Value '18745' | Get-HEATApproval

    Returns any approvals attached to the Change business object #18745.
    .NOTES
    Implement a way to pull all FRS_ApprovalVoteTracking# objects for a certain Employee. Currently it doesn't
    appear that the Owner property is populating with NetworkUserName properly (has email instead?) and the
    OwnerRecId is blank, even for Service Request submitted directly through the self service (Service Catalog)
    portal which should run all validation rules. Something might be a bit wonky.
#>
function Get-HEATApproval {
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

        # retrieve the actual approval objects (typically there's only one, but there could be more)
        $approvalObjects = Get-HEATMultipleBusinessObjects -Value $Value -Type 'FRS_Approval#' -Field 'ParentLink_RecID'

        foreach ($approvalObject in $approvalObjects) {

            try{

                # attempt to retrieve any connected vote tracking objects
                $approvalVotes = Get-HEATMultipleBusinessObjects -Value $approvalObject.RecId -Type 'FRS_ApprovalVoteTracking#' -Field 'ParentLink_RecID'

                # append the vote tracking objects to the approval object
                $approvalObject | Add-Member -NotePropertyName 'FRS_ApprovalVoteTracking' -NotePropertyValue $approvalVotes

            } catch {

                # most likely due to no votes being present
                Write-Verbose -Message "unable to retrieve FRS_ApprovalVoteTracking# attached to record: $($approvalObject.RecId)"

            }

        }

        # drop the approval objects into the pipeline
        $approvalObjects

    }

    end { }

}