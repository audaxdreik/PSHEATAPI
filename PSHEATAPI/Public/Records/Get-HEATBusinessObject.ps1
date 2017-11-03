<#
    .SYNOPSIS
    Retrieves a single HEAT business object such as an Incident, Service Request, or Task.
    .DESCRIPTION
    Retrieves a HEAT business object that is expected to have only one value. Examples would be an Employee, a specific
    Incident or ServiceRequest number, or a specific CI computer. Can find on either a field/value pair or an exact
    record ID.

    If a 'MultipleResults' response is detected a warning is printed to the screen and the -Value, -Type, and -Field
    parameters are forwarded to a call for Get-HEATMultipleBusinessObjects. This was considered more desirable behavior
    than throwing an error, however it should typically be avoided as Value/Type/Field sets expected to return multiple
    objects can be predicted by their nature and prevent an errant API call.
    .PARAMETER Value
    The value (fieldValue) to search for on a given Field (fieldName).
    .PARAMETER Type
    The HEAT business object type (boType).
    .PARAMETER Field
    The field (fieldName) that the Value (fieldValue) will search the business object Type (boType) on.
    .PARAMETER RecordID
    The exact record ID (RecId) for the business object; should be a 32-character hex string.
    .EXAMPLE
    PS C:\>Get-HEATBusinessObject -Value 'jdoe' -Type 'Employee' -Field 'NetworkUserName'

    Returns an Employee business object type where the fieldName of NetworkUserName has the fieldValue of 'jdoe'.
    .EXAMPLE
    PC C:\>Get-HEATBusinessObject -Type 'Employee' -RecordID 'F0855D03D9CB4ECD9BBE7549B94A4328'

    Returns the Employee (User) record for 'jdoe'.
    .NOTES
    FindSingleBusinessObjectByField(string sessionKey, string tenantId, string boType, string fieldName, string fieldValue)
        or
    FindBusinessObject(string sessionKey, string tenantId, string boType, string recId)
#>
function Get-HEATBusinessObject {
    [CmdletBinding(DefaultParameterSetName = 'byfield')]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline,
            Position = 0,
            ParameterSetName = 'byfield',
            HelpMessage = 'fieldValue number or name reference')]
        [string]$Value,
        [Parameter(Mandatory,
            Position = 1,
            HelpMessage = 'an exact HEAT business object type (boType)')]
        [string]$Type,
        [Parameter(Mandatory,
            Position = 2,
            ParameterSetName = 'byfield',
            HelpMessage = 'fieldName to search HEAT boType on')]
        [string]$Field,
        [Parameter(Mandatory,
            Position = 0,
            ValueFromPipeline,
            ParameterSetName = 'byrecord',
            HelpMessage = 'record ID of the business object')]
        [string]$RecordID
    )

    begin { }

    process {

        # define the API call
        switch ($PSCmdlet.ParameterSetName) {

            'byfield' {

                # providing field and value to find on
                $apiCall = {

                    $script:HEATPROXY.FindSingleBusinessObjectByField(
                        $script:HEATCONNECTION.sessionKey,
                        $script:HEATCONNECTION.tenantId,
                        $Type,
                        $Field,
                        $Value
                    )

                }

            }
            'byrecord' {

                # providing exact record ID
                $apiCall = {

                    $script:HEATPROXY.FindBusinessObject(
                        $script:HEATCONNECTION.sessionKey,
                        $script:HEATCONNECTION.tenantId,
                        $Type,
                        $RecordID
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

        switch ($response.Status) {

            'Success' {

                # convert the $response.obj.FieldValues into a PSCustomObject and drop it into the pipeline
                ConvertFrom-WebServiceObject -InputObject $response.obj -AdditionalProperties @{ boType = $Type }

            }
            'MultipleResults' {

                Write-Warning -Message 'multiple responses returned, this query should be run from Get-HEATMultipleBusinessObjects'
                Get-HEATMultipleBusinessObjects -Value $Value -Type $Type -Field $Field

            }
            default {

                throw "response Status - $($response.Status), exceptionReason - $($response.exceptionReason)"

            }

        }

    }

    end { }

}