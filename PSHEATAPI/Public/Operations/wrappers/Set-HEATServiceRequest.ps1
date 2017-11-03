function Set-HEATServiceRequest {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 0)]
        [Alias('RecID')]
        [string]$RecordID,
        [Parameter(Mandatory,
            Position = 1)]
        [hashtable]$Data
    )

    Set-HEATBusinessObject -RecordID $RecordID -Type 'ServiceReq#' -Data $Data

}