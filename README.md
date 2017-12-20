# Ivanti HEAT PowerShell API

An implementation of the Ivanti HEAT API with a strict focus on PowerShell conventions. The core API functionality has been translated into the standard Get/Set/New/Remove commandlets allowing you to easily retrieve and modify business object records.

## Getting Started

### Documentation

[HEAT Admin Help](https://<YOUR_TENANT_ID>/help/admin/index.html)

[API](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/Web%20Service.htm)

[WSDL](https://<YOUR_TENANT_ID>/ServiceAPI/FRSHEATIntegration.asmx?wsdl)

[Community](https://community.ivanti.com/community/heat-software/ivanti-service-manager-formerly-heat-service-management/heat-api-ivanti-service-manager)

### Configuring for Your Environment

To install the module, simply copy the **PSHEATAPI** directory into your `$env:PSModulePath` or directory of choice.

In order to allow the module to automatically connect to your HEAT instance when imported it's recommended that you cache your credentials in the PSHEATAPI\data directory by running the `Set-CachedCredentials.ps1` script. If caching the credentials of a service account, please remember that these credentials will only work for the user that created the cached credentials, from the machine where they were originally cached. You'll also need to set the *defaultRole* for the cached credentials and *tenantId* of your HEAT instance in the config.json.sample file and rename it to config.json.

If you do not set these files beforehand, you will receive a warning when importing the module stating that it was unable to automatically connect. You will need to manually run Connect-HEATProxy and enter the appropriate parameters in order to establish a connection before running any module commandlets.

### Customizing

Additionally you may want to implement custom format files and wrapper functions. A set of examples have been included in this repository but no guarantees can be made that they will work in your environment.

If you are running Windows 10 Anniversary Update (1607) or above you may wish to copy PSHEATAPI\data\PSHEATAPI.format.ps1xml.ANSI to PSHEATAPI\PSHEATAPI.format.ps1xml for ANSI coloration on certain elements,

![alt-text](https://github.com/audaxdreik/PSHEATAPI/raw/master/media/ANSI_formatting.png "example ANSI coloration")

## Implementation

* Establishing the Connection and Selecting a Role
  * [Connect](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/Connect.htm#Using_the_Connect_WebMethod) , `Connect-HEATProxy`
  * [GetRolesForUser](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/Connect.htm#Using_the_Connect_WebMethod) , `Get-HEATRolesForUser`
  * [IntegrationScheduleNow](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/IntegrationScheduleNow.htm) , `Invoke-HEATIntegrationJob`
* Searching for Records
  * [FindBusinessObject](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/FindBusinessObject.htm#_Toc357184303) , `Get-HEATBusinessObject [-Type] <String> [-RecordID] <String>`
  * [FindSingleBusinessObjectByField](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/FindSingleBusinessObjectByField.htm#_Toc357184304) , `Get-HEATBusinessObject [-Value] <String> [-Type] <String> [-Field] <String>`
  * [FindMultipleBusinessObjectsByField](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/FindMultipleBusinessObjectsByField.htm#_Toc357184305) , `Get-HEATMultipleBusinessObjects`
  * [Search](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/Search.htm#_Toc357184306) , `Find-HEATBusinessObject`
* Record Operations
  * [CreateObject](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/CreateObject.htm#Using_the_CreateObject_Web_Method) , `New-HEATBusinessObject`
  * [UpdateObject](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/UpdateObject.htm#Using_the_UpdateObject_Web_Method) , `Set-HEATBusinessObject`
  * [DeleteObject](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/DeleteObject.htm#Using_the_DeleteObject_Web_Method) , `Remove-HEATBusinessObject`
  * [UpsertObject](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/UpsertObject.htm#Using_the_UpsertObject_Web_Method) , `Merge-HEATBusinessObject`
* Attachment Web Methods
  * [AddAttachment](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/AddAttachment.htm#_Toc357184316) , `Set-HEATAttachmentData`
  * [ReadAttachment](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/ReadAttachment.htm#_Toc357184317) , `Get-HEATAttachmentData`
* Metadata Access
  * [GetSchemaForObject](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/GetSchemaForObject.htm#_Toc357184319) , `Get-HEATSchemaForObject`
  * [GetAllSchemaForObject](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/GetAllSchemaForObject.htm#_Toc357184320) , `Get-HEATSchemaForObject -All`
  * [GetAllAllowedObjectNames](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/GetAllAllowedObjectNames.htm#_Toc357184321) , `Get-HEATAllowedObjectNames`
* Working with Request Offerings and Service Requests
  * [GetCategories](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/GetCategories.htm#Using_the_GetCategories_Web_Method) , `Get-HEATRequestOfferingCategories`
  * [GetCategoryTemplates](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/GetCategoryTemplates.htm#Using_the_GetCategoryTemplates_Web_Method) , `Get-HEATRequestOfferingTemplates [-RecordID] <String> [[-SearchString] <String>] [[-MaxCount] <Int32>]`
  * [GetAllTemplates](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/GetAllTemplates.htm#Using_the_GetAllTemplatesWebMethod) , `Get-HEATRequestOfferingTemplates`
  * [GetSubscriptionId](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/GetSubscriptionId.htm#Using_the_GetSubscriptionId_Web_Method), `Get-HEATRequestOfferingSubscriptionID`
  * [GetPackageData](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/GetPackageData.htm#Using_the_GetPackageDataWeb_Method) , `Get-HEATRequestOfferingSubscriptionData`
  * [UserCanAccessRequestOffering](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/UserCanAccessRequestOffering.htm#Using_the_UserCanAccessRequestOffering_Web_Method) , `Confirm-HEATRequestOfferingAccess`
  * [SubmitRequest](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/SubmitRequest.htm#Using_the_SubmitRequestWeb_Method) , `Submit-HEATRequestOffering`
  * [GetRequestData](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/GetRequestData.htm#Using_the_GetRequestData_Web_Method) , `Get-HEATRequestOffering`
  * [FetchServiceReqValidationListData](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/FetchServiceReqValidtionListData.htm#Using_the_FetchServiceReqValidationListData_Web_Method) , `Get-HEATRequestOfferingValidationList`

## Explanation

### Connection and Initialization

`Connect-HEATProxy` is run when the module is imported. Credentials are pulled from the locally cached credentials (will print a warning if it's unsuccessful for any reason at which point you'll have to manually rerun the command and supply the -Credential parameter yourself) and stored in `$script:HEATCREDENTIALS`. This is responsible for creating the proxy framework in `$script:HEATPROXY` and connecting to the actual API with `$script:HEATCONNECTION`. The connection variable holds a _sessionKey_ and the _tenantId_ which need to be referenced on all API calls. The session will timeout after an unspecified amount of time but in the event this happens the error is caught and `Connect-HEATProxy` is automatically rerun with the same criteria before attempting to make the API call again.

### Working with Records (Get/Set/New/Remove)

The module revolves around accessing records in HEAT, called business objects. Following PowerShell conventions you may use the Get/Set/New/Remove verbs to modify them. `Get-HEATBusinessObject` returns a single [PSCustomObject] representation of the business object when provided with either an exact record ID or a field/value pair to search on. `Get-HEATMultipleBusinessObjects` will return a [PSCustomObject] or [PSCustomObjects[]] when given a value and field to search on. The API is unclear on what benefits using `Get-HEATBusinessObject` to return single records has since `Get-HEATMultipleBusinessObjects` will operate off the same criteria or return a single result when criteria expecting multiple results in fact only returns a single record. Running `Get-HEATBusinessObject` will return a 'MultipleResults' error when provided with such criteria. The script will print a warning and rerun the query as `Get-HEATMultipleBusinessObjects`.

Using `New-HEATBusinessObject` is as simple as specifying the boType (business object type) and sending it a dictionary of Name/Value pairs for the properties you would like to populate. This does require some awareness of the properties required to create an object of that type. If the operation is successful, the newly created business object is returned in whole as a [PSCustomObject].

The same applies to `Set-HEATBusinessObject`; it's easiest to retrieve the record first with `Get-HEATBusinessObject` and pipe it into the commandlet with the dictionary of Name/Value pairs you'd like to create or update. If the operation is successful, the modified business object is returned as a [PSCustomObject] with the updated fields.

`Remove-HEATBusinessObject` is the simplest, there is no variation. Giving it the exact record ID or piping it any sort of business object results in the complete removal of that record.

### Wrappers

**WARNING!** The Get/Set/New wrappers should be considered example implementations to help instruct you to create your own set as they are dependent on your specific implementation of HEAT. Changing the fields related to any of the business objects or the way they are queried could potentially break the wrapper. The Get command wrappers help make querying more obvious and intuitive with piping. The Set/New wrappers aren't fully implemented yet but will attempt to make it more obvious how certain name/value pairs should be handled for each object.

### Business Objects vs. Request Offerings

Request Offerings apply to anything that is available through the self service 'Service Catalog'. Underneath they are still ServiceReq# business objects, but it abstracts the data to a more sensible level for you. While you can create a new Service Request directly with `New-HEATBusinessObject -Type 'ServiceReq#' -Data $data` it's not the recommended method.

You can pull all the current available offerings with `Get-HEATRequestOfferingTemplates`. For a particular offering, use `Get-HEATRequestOfferingSubscriptionID` and pipe it into `Get-HEATRequestOfferingSubscriptionData` to see which fields that particular offering has and which are required. To simply get the record, use `Get-HEATRequestOffering`. When creating a new Service Request, use `Submit-HEATRequestOffering`. See the below examples for more details.

### Important Notes on the API

  * Ensure your [DateTime]'s are formatted in 'yyyy-MM-dd hh:mm' or 'yyyy-MM-ddThh:mm' (`Get-Date -Format 'yyyy-MM-dd hh:mm'`)
  * Most HEAT business object names are postfixed with the '#' character, this should not be interpreted literally as 'number'. Objects that inherit are split with this character, i.e. CI#Workstation inherits from the CI# business object. You can see all available business objects with `Get-HEATAllowedObjectNames`

## Examples

### Retrieving Records

``` powershell
# explicit
Get-HEATBusinessObject -Value '20000' -Type 'Incident#' -Field 'IncidentNumber'

# from search
Find-HEATBusinessObject -SelectAll -From 'Incident#' -Where @{Field = 'IncidentNumber'; Value = '20000'; Condition = '='; Join = 'AND')

# wrapper
Get-HEATIncident -Value '20000'
```
Retrieve Incident #20000 with all fields; all should return exactly the same results.

``` powershell
# explicit
$tasks = (Get-HEATBusinessObject -Value '91327' -Type 'ServiceReq#' -Field 'ServiceReqNumber').RecID | Get-HEATMultipleBusinessObjects -Type 'Task' -Field 'ParentLink_RecID'

# wrapper
$tasks = Get-HEATServiceRequest -Value '91327' | Get-HEATTask
```
Retrieve all tasks for Service Request #91327. Both should return exactly the same results.

``` powershell
# a more detailed search query
$incidents = Find-HEATBusinessObject -Select @{Name = 'IncidentNumber'; Type = 'Text'} -From 'Incident#' -Where @(@{Field = 'Status'; Value = 'Active'; Condition = '='}, @{Field = 'IncidentNumber'; Value = '100000'; Condition = '>='; Join = 'AND'}) -OrderBy @{Name = 'IncidentNumber'; Direction = 'ASC'}
```
Returns just the IncidentNumber for all Incidents which are currently Active and have an IncidentNumber greater than or equal to 100000, sorted in ascending order.

``` powershell
# find all business objects of a given type
$where = [WebServiceProxy.RuleClass]::New()
$where.ConditionType = 'ByText'
$where.Condtion      = '='
$where.Value         = '' # empty string is important, do not leave $null
$departments = Find-HEATBusinessObject -SelectAll -From 'Department#' -Where $where
```
A somewhat hack-ish way to use searching 'ByText' instead of the default 'ByField' in order to return all business objects of a given type. May try to implement this more directly in the future.

``` powershell
# find all business objects associated to a parent object through links
$problem = Find-HEATBusinessObject -SelectAll -From 'Problem#' -Where @{Field = 'ProblemNumber'; Value = '10075'; Condition = '='} -Link @{Relation = 'ProblemAssociatesChange'; Object = 'Change#'}
```
Returns all the Change# business objects associated with the parent Problem# business object. If broader criteria where applied in the -Where parameter, multiple Problem# business objects would be returned, each with all their associated Change# business objects nested.

![alt-text](https://github.com/audaxdreik/PSHEATAPI/raw/master/media/bo_relationships.png "finding a link relationship")

### Updating Records

``` powershell
$data = @(
    @{Name = 'Status';           Value = 'Fulfilled'}
    @{Name = 'Resolution';       Value = 'Service Request has been completed.'}
    @{Name = 'ResolvedDateTime'; Value = Get-Date -Format 'yyyy-MM-dd hh:mm'}
    @{Name = 'ResolvedBy';       Value = 'jdoe'}
    @{Name = 'ClosedBy';         Value = 'jdoe'}
    @{Name = 'OwnerTeam';        Value = 'IT Helpdesk'}
    @{Name = 'Owner';            Value = 'John Doe'}
    @{Name = 'OwnerEmail';       Value = 'john.doe@company.com'}
)

Get-HEATServiceRequest -Value '92066' | Set-HEATBusinessObject -Data $data
```
Sets the mandatory fields for closing a Service Request on an existing record.

``` powershell
# results in the 'Floor' field being set to '', an empty string
Get-HEATEmployee -Value 'jdoe' | Set-HEATBusinessObject -Data @{Name = 'Floor'; Value = $null}

# results in the 'Floor' field being truly unset
Get-HEATEmployee -Value 'jdoe' | Set-HEATBusinessObject -Data @{Name = 'Floor'; BinaryData = $null}
```
Anything passed as a Name/Value pair is cast to a string as part of the WSDL specifications. Passing a Name/BinaryData pair where the binary data is $null will result in wiping the field out and setting it to NULL.

### Creating New Records

``` powershell
$data = @(
    @{Name = 'Name';         Value = 'HXA10051'}
    @{Name = 'Status';       Value = 'Deployment in Progress'}
    @{Name = 'SerialNumber'; Value = 'FF0088F'}
    @{Name = 'AssetTag';     Value = 'A10051'}
)

New-HEATBusinessObject -Type 'CI#Workstation' -Data $data
```
Creates a new workstation CI (configuration item) with the specified data. Will return the business object record into the pipeline if it was successful or throw an error if it was not.

## Contributing

Due to the highly customizable nature of HEAT instances, it is asked that all contributors please keep the core code as generic as possible. Please fork the code if you need to create your own customized wrappers and adjustments.

## Versioning

[SemVer](http://semver.org/) style versioning will be applied to help ensure this code can be used in production with reasonable guarantees against breaking changes.

## Authors

* Audax Dreik - *Initial work, 1.0 release*

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
