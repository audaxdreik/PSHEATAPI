<#
    .SYNOPSIS
    Retrieve one or more business objects from an arbitrarily complex SQL-style query.
    .DESCRIPTION
    This web method retrieves one or more business objects satisfying the search criteria. This is a Microsoft
    SQL-style query. Compared to the other search web methods, this is a general purpose web method that can be used to
    express arbitrarily complex queries. Please be aware that as with Get-HEATMultipleBusinessObjects, pulling all
    fields for a large number of business objects will take some time to return.
    .PARAMETER Select
    The fields to return for the selected business object. Should take an array of preformed
    [WebServiceProxy.FieldClass] or an array of Name/Type pairs, i.e. @{Name = 'IncidentNumber'; Type = 'Text'}.
    .PARAMETER SelectAll
    This switch can be specified in place of providing an explicit -Select parameter in order to retrieve all fields
    for the requested business object.
    .PARAMETER From
    The table from which the fields are being pulled, in this case the business object type (boType). Please be
    sure to include the '#' character such as in 'Incident#' or 'CI#Workstation'.
    .PARAMETER Link
    The [WebServiceProxy.FromLinkClass] defining what additional linked business objects to query in addition to
    the parent object query. Also accepts Relation/Object pairs indicating the relationship name and business
    object type. For example @{Relation = 'ProblemAssociatesChange'; Object = 'Change#'} could be used to retrieve
    the associated Change# business objects from a parent Problem# business object query.

    If linked records are found, they will be accessible through the 'linkedQueryObjects' property of the returned
    parent object.
    .PARAMETER Where
    The [WebServiceProxy.RuleClass] defining a SQL-like WHERE clause. Please see the Get-Help of New-HEATRuleClass
    for more details on how to define one or more [WebServiceProxy.RuleClass] objects. An array of Field/Value/
    Condition/(Optional)Join sets may also be defined, i.e. @{Field = 'Status'; Value = 'Active'; Condition = '='}.
    Join may be either 'AND' or 'OR' (default is 'AND' unless otherwise specified).
    .PARAMETER OrderBy
    The [WebServiceProxy.OrderByClass] defining a SQL-like ORDER BY clause. Also accepts Name/Direction pairs
    indicating what field and in which direction ('ASC' or 'DESC') it should be sorted, i.e.
    @{Name = 'DisplayName'; Direction = 'ASC'}.
    .PARAMETER Top
    Limit the returned results to just the n top results.
    .PARAMETER Distinct
    Limit returned results to only distinct entries.
    .EXAMPLE
    PS C:\>Find-HEATBusinessObject -Select @{Name = 'IncidentNumber'; Type = 'Text'} -From 'Incident#' -Where @{Field = 'Status'; Value = 'Active'; Condition = '='}

    Return just the IncidentNumber field from the Incident# business object where the 'Status' field is equal to
    'Active'.
    .EXAMPLE
    PS C:\>Find-HEATBusinessObject -SelectAll -From 'ServiceReq#' -Where @{Field = 'Status'; Value = 'Approved'; Condition = '='}

    Return all the fields for any ServiceReq# business object where the 'Status' field is equal to 'Approved'.
    .EXAMPLE
    PS C:\>Find-HEATBusinessObject -SelectAll -From 'Problem#' -Where @{Field = 'ProblemNumber'; Value = '10075'; Condition = '='} -Link @{Relation = 'ProblemAssociatesChange'; Object = 'Change#'}

    Return all the fields for Problem #10075 as well as any Change# business objects that are associated with it.
    .NOTES
    Search(string sessionKey, string tenantId, ObjectQueryDefinition query)
#>
function Find-HEATBusinessObject {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory,
            Position = 0,
            ParameterSetName = 'granularSelect',
            HelpMessage = 'fields to select, or All')]
        [ValidateNotNullOrEmpty()]
        $Select,
        [Parameter(Position = 0,
            ParameterSetName = 'selectAll')]
        [switch]$SelectAll,
        [Parameter(Mandatory,
            Position = 1,
            HelpMessage = 'business object or link class')]
        [ValidatePattern('.*#')]
        [string]$From,
        [Parameter(Position = 2,
            HelpMessage = 'optional relationship search')]
        $Link,
        [Parameter(Mandatory,
            Position = 3,
            HelpMessage = 'RuleClass for search criteria')]
        [ValidateNotNullOrEmpty()]
        $Where,
        [Parameter(Position = 4,
            HelpMessage = 'hash containing field and ASC or DESC')]
        [ValidateNotNullOrEmpty()]
        $OrderBy,
        [Parameter(Position = 5,
            HelpMessage = 'number of top results to return')]
        [int]$Top,
        [switch]$Distinct
    )

    <#
        NOTE: for the -Select, -Link, -Where, and -OrderBy parameters, each accepts a generic Object. the object is
        expected to be [WebServiceProxy.<CLASS>], [WebServiceProxy.<CLASS>[]], an implicit Object or Object[]
        containing [WebServiceProxy.<CLASS>], or a [hashtable] or [hashtable[]] of appropriate key/value pairs. all of
        these should cast properly to the correct [WebServiceProxy.<CLASS>[]] before being attached to the query
        object. all other possibilities should get thrown to the catch block and generate a readable error message.

        if the object is completely wrong, we get a standard:
            Cannot convert the <VALUE> value of type <TYPE> to type "WebServiceProxy.<CLASS>"

        if the hash contains invalid properties, you get a very descriptive error telling you what properties were
        invalid and which ones the class needs/contains

        if the hash or [WebServiceProxy.<CLASS>] contains an improper property value, the API call is made but you will
        receive an Error response status informing you that the query wasn't valid and for what reason
    #>

    # define the primary query object, containing all query data
    $query = New-Object -TypeName WebServiceProxy.ObjectQueryDefinition

    # attach a SELECT clause to the query
    $query.Select = New-Object -TypeName WebServiceProxy.SelectClass

    switch ($PSCmdlet.ParameterSetName) {

        'selectAll' {

            # if -SelectAll, set the [bool] value to true to return all fields
            $query.Select.All = $true

        }
        'granularSelect' {

            # otherwise cast into a FieldClass and attach
            try {

                # see above note about casting
                $query.Select.Fields = [WebServiceProxy.FieldClass[]]$Select

            } catch {

                throw $_

            }

        }

    }

    # attach a FROM clause to the query
    $query.From = New-Object -TypeName WebServiceProxy.FromClass -Property @{
        Object = $From
    }

    if ($Link) {

        try {

            # see above note about casting
            $query.From.Links = [WebServiceProxy.FromLinkClass[]]$Link

        } catch {

            throw $_

        }

    }

    # attach a WHERE clause to the query
    try {

        # see above note about casting
        $query.Where = [WebServiceProxy.RuleClass[]]$Where

    } catch {

        throw $_

    }

    # attach an ORDERBY clause, if one was specified
    if ($OrderBy) {

        try {

            # see above note about casting
            $query.OrderBy = [WebServiceProxy.OrderByClass[]]$OrderBy

        } catch {

            throw $_

        }

    }

    # define the API call
    $apiCall = {

        $script:HEATPROXY.Search(
            $script:HEATCONNECTION.sessionKey,
            $script:HEATCONNECTION.tenantId,
            $Query
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

        <#
            $response.objList will always be of type [WebServiceProxy.WebServiceBusinessObject[][]] even if only one
            object is returned. for each object, WebServiceBusinessObject[][0] is the parent object and
            WebServiceBusinessObject[][1] through WebServiceBusinessObject[][n] are the linked business objects when
            -Link parameter is defined
        #>
        $response.objList | ForEach-Object -Process {

            # convert each element of the sub-array into a [PSCustomObject]
            $processedObjects = $_ | Foreach-Object -Process {

                ConvertFrom-WebServiceObject -InputObject $_ -AdditionalProperties @{ boType = $_.TableRef}

            }

            # set the parent object as the first object in the process array
            $parentObject = $processedObjects[0]

            # add all the remaining process objects under the 'linkedQueryObjects' property
            $parentObject | Add-Member -NotePropertyName 'linkedQueryObjects' -NotePropertyValue ($processedObjects[1..($processedObjects.Length - 1)])

            # drop the fully processed parent object into the pipeline
            $parentObject

        }

    } else {

        throw "response Status - $($response.Status), exceptionReason - $($response.exceptionReason)"

    }

}