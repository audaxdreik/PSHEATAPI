ObjectQueryDefinition query = new ObjectQueryDefinition();

query.Select = new SelectClass();
// Retrieve just the IncidentNumber field value from the Incident,
// when invoking the search
FieldClass[] incidentFieldObjects = new FieldClass[] {
    new FieldClass() {
        Name = "IncidentNumber",
        Type = "Text"
    }
};

query.Select.Fields = incidentFieldObjects;

query.From          = new FromClass();
query.From.Object   = "Incident";
 
query.Where = new RuleClass[] {
    new RuleClass() {
        Join      = "AND",
        Condition = "=",
        Field     = "Priority",
        Value     = "1"
    },
    new RuleClass() {
        Join      = "AND",
        Condition = "=",
        Field     = "Status",
        Value     = "Active"
    }
};

// make the API call here
FRSHEATIntegrationSearchResponse searchResponse = frSvc.Search(authSessionKey, tenantId, query);

if (searchResponse.status == "Success") {

    WebServiceBusinessObject[][] incidentList = searchResponse.objList;

    foreach (WebServiceBusinessObject[] incidentOuterList in incidentList) {

        foreach (WebServiceBusinessObject incident in incidentOuterList) {

            // Since we are just retrieving one field in the selection criteria
            // (i.e. IncidentNumber), this corresponds to
            // incident.FieldValues[0].Value when retrieving the results
            Console.WriteLine("Incident {0} matches the selection criteria", incident.FieldValues[0].Value);

        }

    }

}