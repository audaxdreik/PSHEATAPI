ObjectCommandData data = new ObjectCommandData();
data.ObjectType = "Profile#Employee";

List<ObjectCommandDataFieldValue> dataFields = new List<ObjectCommandDataFieldValue>();
Dictionary<string, object> fields = new Dictionary<string, object>();

fields["Status"]             = "Active";
fields["FirstName"]          = "Brian";
fields["LastName"]           = "Wilson";
fields["LoginID"]            = "BWilson";
fields["IsInternalAuth"]     = true;

// Notice when setting the password for the Employee, that the plain text
// password is specified here - it will be converted to the hashed value
// upon save of the record
fields["InternalAuthPasswd"] = "Manage1t";
fields["PrimaryEmail"]       = "BWilson@example.com";
fields["Phone1"]             = "14158665309";

// RecId for the "Admin" user, to serve as the Manager for the new Employee
fields["ManagerLink"]        = "FB884D18F7B746A0992880F2DFFE749C";

// RecId for the "GMI" Org Unit, for the OrgUnit of the new Employee
fields["OrgUnitLink"]        = "4A05123D660F408997A4FEE714DAD111";
fields["Team"]               = "IT";
fields["Department"]         = "Operations";
fields["Title"]              = "Administrator";

foreach (string key in fields.Keys) {
    dataFields.Add(new ObjectCommandDataFieldValue() {
        Name = key,
        Value = fields[key].ToString()
    });
}

data.Fields = dataFields.ToArray();
data.LinkToExistent = new LinkEntry[] {
    // First we link the new Employee to the "SelfService" and
    // "ServiceDeskAnalyst" roles by RecID
    // The internal reference name for the relationship between
    // Profile.Employee and Frs_def_role is empty, so we leave
    // the Relation attribute in the LinkEntry empty in this case
    // Link to "SelfService" role

    new LinkEntry() {
        Action            = "Link",
        Relation          = "",
        RelatedObjectType = "Frs_def_role#",
        RelatedObjectId   = "0a4724d8478b451abea3fb44d33db1b6"
    },

    // Link to "ServiceDeskAnalyst" role
    new LinkEntry() {
        Action            = "Link",
        Relation          = "",
        RelatedObjectType = "Frs_def_role#",
        RelatedObjectId   = "06d780f5d7d34119be0d1bc8fc997947"
    },

    // We then link the new Employee to the "IT" and "HR" teams
    // The internal reference name for the relationship between
    // Profile.Employee and StandardUserTeam is "Rev2", so we
    // specify this in the Relation attribute in the LinkEntry
    // Link to the "IT" team

    new LinkEntry() {
        Action = "Link",
        Relation = "Rev2",
        RelatedObjectType = "StandardUserTeam#",
        RelatedObjectId = "10F60157A4F34A4F9DDB140E2328C7A6"
    },

    // Link to the "HR" team
    new LinkEntry() {
        Action = "Link",
        Relation = "Rev2",
        RelatedObjectType = "StandardUserTeam#",
        RelatedObjectId = "1FF47B9EDA3049CC92458CE3249BA349"
    }
};

FRSHEATIntegrationCreateBOResponse result = frSvc.UpsertObject(authSessionKey, tenantId, data, new string ["LoginID" ]);

if (result.status == "Success") {
    Console.WriteLine("A new Employee record is createdor updated with recId of {0}", result.recId);
}