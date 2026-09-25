/// document_info.person -- patient identity plus the claim identifiers.
/// Assembled from ClaimPatient and ClaimPreAuth, which is why claim_id and
/// claim_case_number sit in a block otherwise about the patient.
Class D1.Mock.Msg.DocPerson Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

Property HospitalNumber As %String(%JSONFIELDNAME = "hospital_number", MAXLEN = 50);

Property ClaimId As %String(%JSONFIELDNAME = "claim_id", MAXLEN = 50);

Property ClaimCaseNumber As %String(%JSONFIELDNAME = "claim_case_number", MAXLEN = 50);

Property CitizenId As %String(%JSONFIELDNAME = "citizen_id", MAXLEN = 30);

Property PassportId As %String(%JSONFIELDNAME = "passport_id", MAXLEN = 30);

Property Title As %String(%JSONFIELDNAME = "title", MAXLEN = 20);

Property FirstName As %String(%JSONFIELDNAME = "first_name", MAXLEN = 255);

Property LastName As %String(%JSONFIELDNAME = "last_name", MAXLEN = 255);

Property Gender As %String(%JSONFIELDNAME = "gender", MAXLEN = 10);

Property BirthDate As %String(%JSONFIELDNAME = "birth_date", MAXLEN = 30);

Storage Default
{
<Data name="DocPersonState">
<Value name="1">
<Value>HospitalNumber</Value>
</Value>
<Value name="2">
<Value>ClaimId</Value>
</Value>
<Value name="3">
<Value>ClaimCaseNumber</Value>
</Value>
<Value name="4">
<Value>CitizenId</Value>
</Value>
<Value name="5">
<Value>PassportId</Value>
</Value>
<Value name="6">
<Value>Title</Value>
</Value>
<Value name="7">
<Value>FirstName</Value>
</Value>
<Value name="8">
<Value>LastName</Value>
</Value>
<Value name="9">
<Value>Gender</Value>
</Value>
<Value name="10">
<Value>BirthDate</Value>
</Value>
</Data>
<State>DocPersonState</State>
<StreamLocation>^D1.Mock.Msg.DocPersonS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
