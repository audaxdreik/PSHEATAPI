// Fetch the matching validation list records for requester, in the
// "Domain Password Reset" request offering

// Since the requester is constrained by the "RequesterDeparment" parameter,
// this needs to be specified as an input parameter to the web method

string offeringName = "Domain Password Reset";
string paramName    = "Requester";

FRSHEATDepValItem depValItem = newFRSHEATDepValItem() {
    strParName  = "RequesterDepartment",
    strParValue = "IT"
};

FRSHEATFetchSRValListDataResponse validationValuesResponse = frSvc.FetchServiceReqValidationListData(authSessionKey, tenantId, offeringName, paramName, depValItem, subStrQuery);
FRSHEATValListValue[] valListValues;

if (validationValuesResponse.status == "Success") {

    valListValues = validationValuesResponse.validationValuesList;

    Console.WriteLine("Here are the matching validation list records:\n");

    foreach (FRSHEATValListValue valListItem in valListValues) {
        Console.WriteLine("Stored Value: \"{0}\"\t\tDisplay Value: \"{1}\"", valListItem.strStoredValue, valListItem.strDisplayValue);
    }

}