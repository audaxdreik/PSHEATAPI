<#
    .SYNOPSIS
    Wrapper to create a new [WebServiceProxy.RuleClass]
    .DESCRIPTION
    Wrapper to assist creation of a new [WebServiceProxy.RuleClass] that can be passed to the Find-HEATBusinessObject
    function or nested within other [WebServiceProxy.RuleClass] for more complex queries.
    .PARAMETER Field
    The field on which you'll be searching the business objects.
    .PARAMETER Value
    The value of the field on which you'll be searching.
    .PARAMETER Condition
    The logical condition for matching on the field, i.e. '=', '!=', '>', '<', '>=', or '<='. Defaults to '='.
    .PARAMETER Join
    How the rule will be joined to other rules in the query, i.e. 'AND' or 'OR'. Defaults to 'AND'.
    .PARAMETER RuleClass
    Optional nested dependant [WebServiceProxy.RuleClass].
    .EXAMPLE
    PS C:\>New-HEATRuleClass -Field 'Status' -Value 'Active'

    Helpful for passing to a Find-HEATBusinessObject regarding Incidents. Defines a rule where the 'Status' field
    must be '=' (default) to 'Active'. Joined to any other RuleClasses passed to the Find-HEATBusinessObject
    commandlet by 'AND' (default).
    .EXAMPLE
    PS C:\>New-HEATRuleClass -Field 'IncidentNumber' -Value '20000' -Condition '>=' -Join 'OR'

    Defines a RuleClass for finding Incidents where the IncidentNumber is greater than or equal to 20000 (joined to
    previous clauses by 'OR').
    .NOTES
    Basically wraps [WebServiceProxy.RuleClass]::New(), I'm not sure how useful this will be.
#>
function New-HEATRuleClass {
    [CmdletBinding(DefaultParameterSetName = 'byField')]
    [OutputType([WebServiceProxy.RuleClass])]
    param (
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            Position = 0,
            ParameterSetName = 'byField',
            HelpMessage = 'field to search on')]
        [string]$Field,
        [Parameter(Position = 0,
            ParameterSetName = 'byText',
            HelpMessage = 'full text catalog search')]
        [switch]$ByText,
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName,
            Position = 1,
            HelpMessage = 'value to search field on')]
        [string]$Value,
        [Parameter(Position = 2,
            HelpMessage = 'condition to match field/value on ')]
        [ValidateSet('=', '!=', '>', '<', '>=', '<=')]
        [string]$Condition = '=',
        [Parameter(Position = 3,
            HelpMessage = 'join criteria, AND/OR')]
        [ValidateSet('AND', 'OR')]
        [string]$Join = 'AND',
        [Parameter(Position = 4,
            HelpMessage = 'nested RuleClass')]
        [WebServiceProxy.RuleClass]$RuleClass
    )

    begin { }

    process {

        switch ($PSCmdlet.ParameterSetName) {

            'byField' {

                # create a new Field/Value query object and drop it into the pipeline
                New-Object -TypeName WebServiceProxy.RuleClass -Property @{
                    Join      = $Join;
                    Condition = $Condition;
                    Field     = $Field;
                    Value     = $Value;
                    Rules     = $RuleClass
                }

            }
            'byText' {

                # create a new full text search query object and drop it into the pipeline
                New-Object -TypeName WebServiceProxy.RuleClass -Property @{
                    Join          = $Join;
                    Condition     = $Condition;
                    ConditionType = [WebServiceProxy.SearchConditionType]::ByText
                    Value         = $Value;
                    Rules         = $RuleClass
                }

            }

        }

    }

    end { }

}