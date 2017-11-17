<#
    .SYNOPSIS
    Returns the allowable validation list data for the given service request parameter.
    .DESCRIPTION
    Returns an array of FRSHEATValListValue containing the strRecId, strStoredValue, and strDisplayValue of the
    allowable business objects that will validate for this parameter. The API has a hard limit of 1000 returned
    records. For larger arrays such as a list of organization users that can be expected to exceed this limit it is
    better to provide a -Substring to search against.
    .PARAMETER Name
    The name of the request offering.
    .PARAMETER Parameter
    The name of the parameter in the request offering.
    .PARAMETER DepValParName
    Parameter name that represents the dependent validation item.
    .PARAMETER DepValParValue
    Parameter value that represents the dependent validation item.
    .PARAMETER Substring
    A substring to match against the returned validation list items.
    .EXAMPLE
    PS C:\>Get-HEATRequestOfferingValidationList -Name '* New Service Request' -Parameter 'combo_1'

    Returns the first 1000 results that will validate against the 'combo_1' field (in this case, 'User to Receive
    Service Request').
    .EXAMPLE
    PS C:\>Get-HEATRequestOfferingValidationList -Name '* New Service Request' -Parameter 'combo_1' -Substring 'Travis'

    In large organizations that have more than 1000 users, names in the latter half would expected to be limited by
    the API call. In this case, providing the substring search for Travis will guarantee that any user records with
    that name will be returned. If no matching records are found, $null will be returned.
    .NOTES
    FetchServiceReqValidationListData(string sessionKey, string tenantId, string offeringName, string paramName, FRSHEATDepValItem depvalItem = null, string subStrMatch = "")
#>
function Get-HEATRequestOfferingValidationList {
    [CmdletBinding(DefaultParameterSetName = 'default')]
    [OutputType([WebServiceProxy.FRSHEATValListValue])]
    param (
        [Parameter(Mandatory,
            Position = 0,
            HelpMessage = 'name of request offering')]
        [string]$Name,
        [Parameter(Mandatory,
            Position = 1,
            HelpMessage = 'name of parameter for request offering')]
        [string]$Parameter,
        [Parameter(Mandatory,
            Position = 2,
            ParameterSetName = 'depVal',
            HelpMessage = 'dependent value parameter name')]
        [string]$DepValParName,
        [Parameter(Mandatory,
            Position = 3,
            ParameterSetName = 'depVal',
            HelpMessage = 'dependent value parameter value')]
        [string]$DepValParValue,
        [Parameter(Position = 4,
            HelpMessage = 'substring to match against the returned validation list items')]
        [string]$Substring = ''
    )

    # if dependent value was defined in parameters, set them now, otherwise leave $null
    if ($PSCmdlet.ParameterSetName -like 'depVal') {

        $dependentValueItem = [WebServiceProxy.FRSHEATDepValItem]@{strParName = $DepValParName; strParValue = $DepValParValue}

    } else {

        $dependentValueItem = $null

    }

    # define the API call
    $apiCall = {

        $script:HEATPROXY.FetchServiceReqValidationListData(
            $script:HEATCONNECTION.sessionKey,
            $script:HEATCONNECTION.tenantId,
            $Name,
            $Parameter,
            $dependentValueItem,
            $Substring
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

        # drop the validation value list into the pipeline
        $response.validationValuesList

    } else {

        throw "response Status - $($response.Status), exceptionReason - $($response.exceptionReason)"

    }

}