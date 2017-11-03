<#
    .SYNOPSIS
    Adds a file attachment to a business object.
    .DESCRIPTION
    Adds a file attachment to a business object. Returns $true if it's successful, otherwise it will throw an error
    message. Not all file types are supported as attachments. Please read error messages carefully to determine why it
    may have failed.
    .PARAMETER RecordID
    The specific recordId (RecId) of the business object you wish to attach a file to.
    .PARAMETER Type
    The corresponding business object type (boType) of the record you are trying to update.
    .PARAMETER Path
    The path to the file you are trying to attach.
    .EXAMPLE
    PS C:\>Set-HEATAttachmentData -RecordID 'B2B31CB6AD6848EFA927EF6F0C1D8C2C' -Type 'ServiceReq#' -Path C:\TEMP\test.txt

    Add the 'test.txt' file as an attachment to the specified business object.
    .EXAMPLE
    PS C:\> Get-HEATRequestOffering -RequestNumber '91862' | Set-HEATAttachmentData -Path C:\TEMP\test.txt

    Retrieve the business object for Service Request #91862 and attach the file at C:\TEMP\test.txt
    .NOTES
    AddAttachment(string sessionKey, string tenantId, ObjectAttachmentCommandData commandData)
#>
function Set-HEATAttachmentData {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            Position = 0,
            HelpMessage = 'the exact recordId of the business object to update')]
        [Alias('RecId', 'strRequestRecId')]
        [string]$RecordID,
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            Position = 1,
            HelpMessage = 'the boType of the record that will be updated')]
        [Alias('boType')]
        [string]$Type,
        [Parameter(Mandatory,
            Position = 2,
            HelpMessage = 'path to file for attaching')]
        [ValidateScript({ (Get-Item -Path $_) -is [System.IO.FileInfo] })]
        [string]$Path
    )

    begin { }

    process {

        $file = Get-Item -Path $Path

        # wrap the information for the attachment in an [ObjectAttachmentCommandData] object
        $commandData = New-Object -TypeName WebServiceProxy.ObjectAttachmentCommandData

        $commandData.ObjectType = $Type
        $commandData.ObjectId   = $RecordID
        $commandData.fileName   = $file.Name
        $commandData.fileData   = [System.IO.File]::ReadAllBytes($Path)

        # define the API call
        $apiCall = {

            $script:HEATPROXY.AddAttachment(
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

            return $true

        } else {

            throw "response Status - $($response.Status), exceptionReason - $($response.exceptionReason)"

        }

    }

    end { }

}