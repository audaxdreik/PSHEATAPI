<#
    .SYNOPSIS
    Return a list of request offerings from the Service Catalog.
    .DESCRIPTION
    Unless a RecId for a category is specified, it will return all templates currently in the Service Catalog.
    Returns an array with strName (the title of the offering), strDescription (the description that shows in the
    portal) and strSubscriptionId (needed when creating new requests). You should ignore the strRecId, this is the
    unique record ID of the actual object but is not useful for referencing when creating or retrieving. Empty
    categories should be expected to return a 'NotFound' response status.
    .PARAMETER RecordID
    The exact record ID (RecId) of the category you'd like to see the service offerings for. Can be found with
    Get-HEATRequestOfferingCategories.
    .PARAMETER SearchString
    A substring for determining the matching request offerings. Not sure exactly how this is implemented as it
    isn't well documented in the API, but sending a blank string returns all possible results (up to the -MaxCount)
    within the specified category, so that's nice.
    .PARAMETER MaxCount
    Maximum number of results to return. This wasn't directly documented in the API, default value is set to 100
    and shouldn't need to be adjusted unless the category offerings grow significantly.
    .EXAMPLE
    PS C:\>Get-HEATRequestOfferingTemplates

    Returns an array of everything currently being offered in the Service Catalog.
    .EXAMPLE
    PS C:\>Get-HEATRequestOfferingTemplates -RecordID '96261B20127A4E06B1FBDEBE339340E1'

    Returns all the service offering templates for the 'Application Administration' category (up to 100).
    .NOTES
    GetAllTemplates(string sessionKey, string tenantId)
        and
    GetCategoryTemplates(string sessionKey, string tenantId, string categoryid, string searchString)

    Makes more sense to go with -RecordID which has been an established convention in the API than with categoryid.
#>
function Get-HEATRequestOfferingTemplates {
    [CmdletBinding(DefaultParameterSetName = 'all')]
    [OutputType([WebServiceProxy.FRSHEATServiceReqTemplateListItem])]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 0,
            ParameterSetName = 'categorized',
            HelpMessage = 'the RecID of the category in the Service Catalog from the Get-HEATRequestOfferingCategories')]
        [Alias('strRecId')]
        [string]$RecordID,
        [Parameter(Position = 1,
            ParameterSetName = 'categorized',
            HelpMessage = 'substring for determining the matching request offerings')]
        [string]$SearchString = '',
        [Parameter(Position = 2,
            ParameterSetName = 'categorized',
            HelpMessage = 'maximum results to return')]
        [int]$MaxCount = 100
    )

    begin { }

    process {

        # define the API call based on our ParameterSetName
        switch ($PSCmdlet.ParameterSetName) {

            'all' {

                # simply retrieve all available templates
                $apiCall = {

                    $script:HEATPROXY.GetAllTemplates(
                        $script:HEATCONNECTION.sessionKey,
                        $script:HEATCONNECTION.tenantId
                    )

                }

            }
            'categorized' {

                # retrieve templates only from the specific category (up to -MaxCount)
                $apiCall = {

                    $script:HEATPROXY.GetCategoryTemplates(
                        $script:HEATCONNECTION.sessionKey,
                        $script:HEATCONNECTION.tenantId,
                        $RecordID,
                        $SearchString,
                        $MaxCount
                    )

                }

            }

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

            # returns FRSHEATServiceReqTemplateListItem[]
            return $response.srtList

        } else {

            throw "response Status - $($response.Status), exceptionReason - $($response.exceptionReason)"

        }

    }

    end { }

}