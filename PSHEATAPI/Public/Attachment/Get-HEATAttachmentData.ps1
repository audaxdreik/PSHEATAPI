<#
    .SYNOPSIS
    Reads the data of a specific attachment record.
    .DESCRIPTION
    Given a RecordID it will return the byte[] for the attachment data. Given a RecordID and Type (boType) it will
    attempt to read all the attachments associated with that record.

    If you are only looking to retrieve the business object record, please use Get-HEATAttachment instead.
    .PARAMETER RecordID
    The RecID of a specific attachment, or when paired with Type, a business object containing a(n) attachment(s).
    .PARAMETER Type
    The optional boType of a parent record containing one or more attachments.
    .EXAMPLE
    PS C:\>Get-HEATAttachmentData -RecordID 'C0E5538846364E04944F587B9523C0B7'

    Returns a byte[] for the attachment with RecID 'C0E5538846364E04944F587B9523C0B7'.
    .EXAMPLE
    PS C:\>Get-HEATServiceRequest -Value '91862' | Get-HEATAttachmentData

    Return all the attachments associated with Service Request #91862.
    .NOTES
    ReadAttachment(string sessionKey, string tenantId, ObjectAttachmentCommandData commandData)

    Writing bytes to file,
    [System.IO.File]::WriteAllBytes("C:\TEMP\$($attachment.name)", $attachment.content)
#>
function Get-HEATAttachmentData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            Position = 0,
            HelpMessage = 'the exact recordId of attachment to retrieve')]
        [Alias('RecId', 'strRequestRecId')]
        [string]$RecordID,
        [Parameter(ValueFromPipelineByPropertyName,
            Position = 1,
            HelpMessage = 'the boType of the record that will be updated')]
        [Alias('boType')]
        [string]$Type
    )

    begin { }

    process {

        if ($Type) {

            <#
                $Type is not actually consumed in any meaningful way, it just indicates that another business object
                was piped in or that the user is specifying any type other than 'Attachment#' for a parent
            #>
            $records = Get-HEATMultipleBusinessObjects -Value $RecordID -Type 'Attachment#' -Field 'ParentLink_RecID'

        } else {

            $records = Get-HEATBusinessObject -Type 'Attachment#' -RecordID $RecordID

        }

        $attachments = foreach ($record in $records) {

            # wrap the requested record id in an [ObjectAttachmentCommandData] object
            $commandData = New-Object -TypeName WebServiceProxy.ObjectAttachmentCommandData

            $commandData.ObjectId = $record.RecId

            # define the API call
            $apiCall = {

                $script:HEATPROXY.ReadAttachment(
                    $script:HEATCONNECTION.sessionKey,
                    $script:HEATCONNECTION.tenantId,
                    $commandData
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

                # drop attachment data of this particular record into the pipeline to be collected in $attachments
                New-Object -TypeName PSCustomObject -Property @{
                    name    = $record.ATTACHNAME;
                    RecID   = $record.RecId;
                    content = $response.attachmentData
                }

            } else {

                throw "response Status - $($response.Status), exceptionReason - $($response.exceptionReason)"

            }

        }

        # drop all the retrieved attachments into the pipeline
        $attachments

    }

    end { }

}