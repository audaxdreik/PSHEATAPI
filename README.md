# Introduction
[HEAT Admin Help](https://<YOUR_TENANT_ID>/help/admin/index.html)

[API](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/Web%20Service.htm)

[WSDL](https://<YOUR_TENANT_ID>/ServiceAPI/FRSHEATIntegration.asmx?wsdl)

[Community](https://community.ivanti.com/community/heat-software/ivanti-service-manager-formerly-heat-service-management/heat-api-ivanti-service-manager)

# Module Structure

## Connection and Initialization

It's recommended that you store the credentials of a service account in the \data\cachedCredentials file (use `Set-CachedCredentials.ps1`). It's also recommended that you set your tenant ID and the default role of the service account in the \data\config.json file (rename config.json.sample).

`Connect-HEATProxy` is run when the module is imported. Credentials are pulled from the locally cached credentials (will print a warning if it's unsuccessful for any reason at which point you'll have to manually rerun the command and supply the -Credential parameter yourself) and stored in `$script:HEATCREDENTIALS`. This is responsible for creating the proxy framework in `$script:HEATPROXY` and connecting to the actual API with `$script:HEATCONNECTION`. The connection variable holds a _sessionKey_ and the _tenantId_ which need to be referenced on all API calls. The session will timeout after an unspecified amount of time but in the event this happens the error is caught and `Connect-HEATProxy` is automatically rerun with the same criteria. It will then attempt to make the API call again.

## Working with Records (Get/Set/New/Remove)

The module revolves around accessing records in HEAT, called business objects. Following PowerShell conventions you may use the Get/Set/New/Remove verbs to modify them. `Get-HEATBusinessObject` returns a single [PSCustomObject] representation of the business object when provided with either an exact record ID or a field/value pair to search on. `Get-HEATMultipleBusinessObjects` will return a [PSCustomObject] or [PSCustomObjects[]] when given a value and field to search on. The API is unclear on what benefits using Get-HEATBusinessObject to return single records has since Get-HEATMultipleBusinessObjects will operate off the same criteria or return a single result when criteria expecting multiple results in fact only returns a single record. Running Get-HEATBusinessObject will return a 'MultipleResults' error when provided with such criteria. The script will print a warning and rerun the query as Get-HEATMultipleBusinessObjects.

Using `New-HEATBusinessObject` is as simple as specifying the boType (business object type) and sending it a dictionary of Name/Value pairs for the properties you would like to populate. This does require some awareness of the properties required to create an object of that type. If the operation is successful, the newly created business object is returned in whole.

The same applies to `Set-HEATBusinessObject`, it's easiest to retrieve the record first with Get-HEATBusinessObject and pipe it into the commandlet with the dictionary of Name/Value pairs you'd like to create or update. If the operation is successful, the modified business object is returned with the updated fields.

`Remove-HEATBusinessObject` is the simplest, there is no variation. Giving it the exact record ID or piping it any sort of business object results in the complete removal of that record.

## Wrappers

**WARNING!** The Get/Set/New wrappers should be considered more unstable than the rest of the API as they are dependent on your specific implementation of HEAT. Changing the fields related to any of the business objects or the way they are queried could potentially break the wrapper. The Get command wrappers help make querying more obvious and intuitive with piping. The Set/New wrappers aren't fully implemented yet but will attempt to make it more obvious how certain name/value pairs should be handled for each object.

## Business Objects vs. Request Offerings

Request Offerings apply to anything that is available through the self service 'Service Catalog'. Underneath they are still Service Requests, but it abstracts the data to a more sensible level for you. While you can create a new Service Request directly with `New-HEATBusinessObject -Type 'ServiceReq#' -Data $data` it's not the recommended method.

You can pull all the current available offerings with `Get-HEATRequestOfferingTemplates`. For a particular offering, use `Get-HEATRequestOfferingSubscriptionID` and pipe it into `Get-HEATRequestOfferingSubscriptionData` to see which fields that particular offering has and which are required. To simply get the record, use `Get-HEATRequestOffering`. When creating a new Service Request, use `Submit-HEATRequestOffering`. See the below examples for more details.

## Important Notes on the API

  * Ensure your [DateTime]'s are formatted in 'yyyy-MM-dd hh:mm' or 'yyyy-MM-ddThh:mm' (`Get-Date -Format 'yyyy-MM-dd hh:mm'`)
  * It's a good idea to cache a set of credentials in the \data folder. Run the `Set-CachedCredentials.ps1` script located in the folder and enter your current organization credentials. Do not prefix the domain, simply 'jdoe' and your current network password.
  * Most HEAT business object names are postfixed with the '#' character, this should not be interpreted literally as 'number'. Objects that inherit are split with this character, i.e. CI#Workstation inherits from the CI# business object. You can see all available business objects with `Get-HEATAllowedObjectNames`

# Progress

## Main API

* Establishing the Connection and Selecting a Role
  * [Connect](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/Connect.htm#Using_the_Connect_WebMethod) , `Connect-HEATProxy`
  * [GetRolesForUser](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/Connect.htm#Using_the_Connect_WebMethod) , `Get-HEATRolesForUser`
  * [IntegrationScheduleNow](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/IntegrationScheduleNow.htm) , `Invoke-HEATIntegrationJob` __(not well tested)__ , I don't understand what this does
* Searching for Records
  * [FindBusinessObject](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/FindBusinessObject.htm#_Toc357184303) , `Get-HEATBusinessObject [-Type] <String> [-RecordID] <String>`
  * [FindSingleBusinessObjectByField](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/FindSingleBusinessObjectByField.htm#_Toc357184304) , `Get-HEATBusinessObject [-Value] <String> [-Type] <String> [-Field] <String>`
  * [FindMultipleBusinessObjectsByField](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/FindMultipleBusinessObjectsByField.htm#_Toc357184305) , `Get-HEATMultipleBusinessObjects`
  * [Search](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/Search.htm#_Toc357184306) , `Find-HEATBusinessObject` , this is completely broken right now, __DO NOT USE!__
* Record Operations
  * [CreateObject](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/CreateObject.htm#Using_the_CreateObject_Web_Method) , `New-HEATBusinessObject`
  * [UpdateObject](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/UpdateObject.htm#Using_the_UpdateObject_Web_Method) , `Set-HEATBusinessObject`
  * [DeleteObject](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/DeleteObject.htm#Using_the_DeleteObject_Web_Method) , `Remove-HEATBusinessObject`
  * [UpsertObject](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/UpsertObject.htm#Using_the_UpsertObject_Web_Method) , planned for **2.0** release, expands functionality forward without breaking backwards compatibility of code
* Attachment Web Methods
  * [AddAttachment](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/AddAttachment.htm#_Toc357184316) , `Set-HEATAttachmentData`
  * [ReadAttachment](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/ReadAttachment.htm#_Toc357184317) , `Get-HEATAttachmentData` , I don't like the way this works right now ...
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
  * [FetchServiceReqValidationListData](https://help.ivanti.com/ht/help/en_US/ISM/2017/Content/Configure/Develop/FetchServiceReqValidtionListData.htm#Using_the_FetchServiceReqValidationListData_Web_Method) , not sure what this is, will attempt to implement later

# Examples

## Retrieving Records

``` powershell
# explicit
Get-HEATBusinessObject -Value '20000' -Type 'Incident#' -Field 'IncidentNumber'

# wrapper
Get-HEATIncident -Value '20000'
```
Retrieve Incident #20000, both should return exactly the same results.

``` powershell
# explicit
$tasks = (Get-HEATBusinessObject -Value '91327' -Type 'ServiceReq#' -Field 'ServiceReqNumber').RecID | Get-HEATMultipleBusinessObjects -Type 'Task' -Field 'ParentLink_RecID'

# wrapper
$tasks = Get-HEATServiceRequest -Value '91327' | Get-HEATTask
```
Retrieve all tasks for Service Request #91327. Both should return exactly the same results.

## Updating Records

``` powershell
$data = @{
    'Status'           = 'Fulfilled';
    'Resolution'       = 'Service Request has been completed.';
    'ResolvedDateTime' = Get-Date -Format 'yyyy-MM-dd hh:mm';
    'ResolvedBy'       = 'jdoe';
    'ClosedBy'         = 'jdoe';
    'OwnerTeam'        = 'IT Helpdesk';
    'Owner'            = 'John Doe';
    'OwnerEmail'       = 'john.doe@company.com'
}

Get-HEATServiceRequest -Value '92066' | Set-HEATBusinessObject -Data $data
```
Sets the mandatory fields for closing a Service Request on an existing record.

## Creating New Records

``` powershell
$data = @{Name = 'HXA10051'; Status = 'Deployment in Progress'; SerialNumber = 'FF0088F'; AssetTag = 'A10051'}

New-HEATBusinessObject -Type 'CI#Workstation' -Data $data
```
Creates a new workstation CI (configuration item) with the specified data. Will return the business object record into the pipeline if it was successful or throw an error if it was not.
