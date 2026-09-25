/// Group-2 patient_info table (D1-Claim data dictionary V1.0.2). IRIS's OWN
/// claim-workflow store -- D1-spec field names directly, never raw Trak names,
/// and never touched by any group-1 (live HIS) flow.
/// 
/// Populated by group 2's own POSTs: PostDischarge snapshots the claim_person
/// block here; ClaimLoader lightly seeds one demo row for cold-start smoke
/// tests. Dates are stored verbatim as sent (wire strings), matching the
/// codebase convention.
Class D1.Mock.Data.ClaimPatient Extends %Persistent
{

/// Hospital number (MRN) -- the natural PK per the data dictionary
Property HospitalNumber As %String(MAXLEN = 50) [ Required ];

Index HospitalIdx On HospitalNumber [ Unique ];

Property CitizenId As %String(MAXLEN = 13);

Index CitizenIdx On CitizenId;

Property PassportId As %String(MAXLEN = 30);

Index PassportIdx On PassportId;

Property Title As %String(MAXLEN = 20);

Property FirstName As %String(MAXLEN = 255);

Property LastName As %String(MAXLEN = 255);

/// "male" / "female" wire values (the dictionary's 1-char M/F is projected
/// out at the API layer; the wire enum is what D1 sends and reads back)
Property Gender As %String(MAXLEN = 20);

/// Wire format yyyy-MM-dd HH:mm:ss (datetime per data dict V1.0.2)
Property BirthDate As %String(MAXLEN = 20);

Property Address As %String(MAXLEN = 255);

Property PhoneNumber As %String(MAXLEN = 30);

Storage Default
{
<Data name="ClaimPatientDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>HospitalNumber</Value>
</Value>
<Value name="3">
<Value>CitizenId</Value>
</Value>
<Value name="4">
<Value>PassportId</Value>
</Value>
<Value name="5">
<Value>Title</Value>
</Value>
<Value name="6">
<Value>FirstName</Value>
</Value>
<Value name="7">
<Value>LastName</Value>
</Value>
<Value name="8">
<Value>Gender</Value>
</Value>
<Value name="9">
<Value>BirthDate</Value>
</Value>
<Value name="10">
<Value>Address</Value>
</Value>
<Value name="11">
<Value>PhoneNumber</Value>
</Value>
</Data>
<DataLocation>^D1.Mock.Data.ClaimPatientD</DataLocation>
<DefaultData>ClaimPatientDefaultData</DefaultData>
<IdLocation>^D1.Mock.Data.ClaimPatientD</IdLocation>
<IndexLocation>^D1.Mock.Data.ClaimPatientI</IndexLocation>
<StreamLocation>^D1.Mock.Data.ClaimPatientS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
