ObjectCommandData data = new ObjectCommandData();
data.ObjectType = "Change#";

List<ObjectCommandDataFieldValue> dataFields = new List<ObjectCommandDataFieldValue>();
Dictionary<string, object> fields            = new Dictionary<string, object>();

fields["RequestorLink"]             = "FB884D18F7B746A0992880F2DFFE749C";
fields["Subject"]                   = "Need to swap out the hard disk";
fields["Description"]               = "The hard drive just crashed - need to replace with a new drive from the vendor";
fields["Status"]                    = "Logged";
fields["TypeOfChange"]              = "Major";
fields["OwnerTeam"]                 = "Operations";
fields["Owner"]                     = "Admin";
fields["Impact"]                    = "Medium";
fields["Urgency"]                   = "Medium";
fields["CABVoteExpirationDateTime"] = "2013-03-26 18:38:30";

foreach (string key in fields.Keys) {
    dataFields.Add(new ObjectCommandDataFieldValue() {
        Name = key,
        Value = fields[key].ToString()
    });
}

data.Fields = dataFields.ToArray();

// Here we will identify a CI.Computer record, to link to the
// new Change record

// For this example, we will attempt to locate the CI.Computer record
// with the name of "APAC-DEPOT-SERV01", and retrieve its RecId
ObjectQueryDefinition ciQuery = new ObjectQueryDefinition();

// Just retrieve only the RecId field for the CI.Computer record
FieldClass[] ciFieldObjects = new FieldClass[] {
    new FieldClass() {
        Name = "RecId",
        Type = "Text"
    }
};

ciQuery.Select        = new SelectClass();
ciQuery.Select.Fields = ciFieldObjects;
ciQuery.From          = new FromClass();
// Search for the record against the CI.Computer member object
ciQuery.From.Object   = "CI.Computer";

ciQuery.Where = new RuleClass[] {
    // Provide the criteria to search for the CI.Computer
    // Here, we will search for the CI.Computer by its Name
    new RuleClass() {
        Condition = "=",
        Field     = "Name",
        Value     = "APAC-DEPOT-SERV01"
    }
};

// Pass in the ObjectQueryDefinition for the query
FRSHEATIntegrationSearchResponse searchResponse = frSvc.Search(authSessionKey, tenantId, ciQuery);
WebServiceBusinessObject[][] cilist             = searchResponse.objList;

// Assuming that the CI record is uniquely identified by its Name, and
// because the above query does not join with other tables, we should be
// able to locate the CI record, by accessing cilist[0][0], in the
// list of list of WebServiceBusinessObjects

WebServiceBusinessObject ci = cilist[0][0];
string ciRecId              = ci.RecID;

// Define the LinkEntry record, to link the new Change record to the CI
// record, by means of the RecId of the Change (i.e. ciRecId), as
// determined above
data.LinkToExistent = new LinkEntry[] {
    new LinkEntry() {
        Action            = "Link",
        Relation          = "",
        RelatedObjectType = "CI#",
        RelatedObjectId   = ciRecId
    }
};

// If the record creation succeeds, the result variable will store the
// RecId of the new Change record, otherwise it will be null
FRSHEATIntegrationCreateBOResponse result = frSvc.CreateObject(authSessionKey, tenantId, data);

if (result.status == "Success") {
    Console.WriteLine("A new Change record is created with RecId of {0}", result.recId);
}
// The next example creates a new Profile.Employee record and links the
// user to the respective roles and teams. Notice that the password value
// is specified in plain text; it is automatically converted to the
// internal hashed value when you save the record.
ObjectCommandData data = new ObjectCommandData();
data.ObjectType        = "Profile#Employee";

List<ObjectCommandDataFieldValue> dataFields = new List<ObjectCommandDataFieldValue>();
Dictionary<string, object> fields            = new Dictionary<string, object>();

fields["Status"]         = "Active";
fields["FirstName"]      = "Brian";
fields["LastName"]       = "Wilson";
fields["LoginID"]        = "BWilson";
fields["IsInternalAuth"] = true;

// Notice when setting the password for the Employee, that the plain text
// password is specified here - it will be converted to the hashed value
// upon save of the record
fields["InternalAuthPasswd"] = "Manage1t";
fields["PrimaryEmail"]       = "BWilson@example.com";
fields["Phone1"]             = "14158665309";

// RecId for the "Admin" user, to serve as the Manager for the new Employee
fields["ManagerLink"] = "FB884D18F7B746A0992880F2DFFE749C";
// RecId for the "GMI" Org Unit, for the OrgUnit of the new Employee
fields["OrgUnitLink"] = "4A05123D660F408997A4FEE714DAD111";
fields["Team"]        = "IT";
fields["Department"]  = "Operations";
fields["Title"]       = "Administrator";

foreach (string key in fields.Keys) {
    dataFields.Add(new ObjectCommandDataFieldValue() {
        Name  = key,
        Value = fields[key].ToString()
    });
}

data.Fields = dataFields.ToArray();

data.LinkToExistent = new LinkEntry[]
{
// First we link the new Employee to the "SelfService" and
// "ServiceDeskAnalyst" roles by RecID
 
// The internal reference name for the relationship between
// Profile.Employee and Frs_def_role is empty, so we leave
// the Relation attribute in the LinkEntry empty in this case
 
// Link to "SelfService" role
new LinkEntry()
       {
Action = "Link",
              Relation = "",
              RelatedObjectType = "Frs_def_role#",                   
              RelatedObjectId = "0a4724d8478b451abea3fb44d33db1b6"
},
// Link to "ServiceDeskAnalyst" role
new LinkEntry()
       {
Action = "Link",
              Relation = "",
              RelatedObjectType = "Frs_def_role#",
              RelatedObjectId = "06d780f5d7d34119be0d1bc8fc997947"
},
// We then link the new Employee to the "IT" and "HR" teams
 
// The internal reference name for the relationship between
// Profile.Employee and StandardUserTeam is "Rev2", so we
// specify this in the Relation attribute in the LinkEntry
 
// Link to the "IT" team
new LinkEntry()
       {
Action = "Link",
              Relation = "Rev2",
              RelatedObjectType = "StandardUserTeam#",
              RelatedObjectId = "10F60157A4F34A4F9DDB140E2328C7A6"
},
// Link to the "HR" team
new LinkEntry()
       {
Action = "Link",
              Relation = "Rev2",
              RelatedObjectType = "StandardUserTeam#",
              RelatedObjectId = "1FF47B9EDA3049CC92458CE3249BA349"
}
};
 
FRSHEATIntegrationCreateBOResponse result = frSvc.CreateObject(authSessionKey, tenantId, data);
 
if (result.status == "Success")
{
Console.WriteLine("A new Employee record is created with recId of {0}", result.recId);
}