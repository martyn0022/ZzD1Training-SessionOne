/// The claim_person object in API_PostDischarge V1.0.3 (single object in this
/// revision; was an array in V1.0.2).
/// 
/// Uses snake_case citizen_id / passport_id -- inconsistent with
/// PostPreAuth's camelCase citizenId / passportId for the same concept.
/// A flagged spec inconsistency, reproduced as written rather than silently
/// normalized (plan open item 1). Also carries address / phone_number, which
/// PostPreAuth's person block does not.
Class D1.Mock.Msg.DischargeClaimPerson Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

Property HospitalNumber As %String(%JSONFIELDNAME = "hospital_number", MAXLEN = 50);

Property CitizenId As %String(%JSONFIELDNAME = "citizen_id", MAXLEN = 30);

Property PassportId As %String(%JSONFIELDNAME = "passport_id", MAXLEN = 30);

Property Title As %String(%JSONFIELDNAME = "title", MAXLEN = 20);

Property FirstName As %String(%JSONFIELDNAME = "first_name", MAXLEN = 255);

Property LastName As %String(%JSONFIELDNAME = "last_name", MAXLEN = 255);

/// "male" / "female"
Property Gender As %String(%JSONFIELDNAME = "gender", MAXLEN = 20);

/// Wire format yyyy-MM-dd HH:mm:ss
Property BirthDate As %String(%JSONFIELDNAME = "birth_date", MAXLEN = 20);

Property Address As %String(%JSONFIELDNAME = "address", MAXLEN = 255);

Property PhoneNumber As %String(%JSONFIELDNAME = "phone_number", MAXLEN = 30);

Storage Default
{
<Data name="DischargeClaimPersonState">
<Value name="1">
<Value>HospitalNumber</Value>
</Value>
<Value name="2">
<Value>CitizenId</Value>
</Value>
<Value name="3">
<Value>PassportId</Value>
</Value>
<Value name="4">
<Value>Title</Value>
</Value>
<Value name="5">
<Value>FirstName</Value>
</Value>
<Value name="6">
<Value>LastName</Value>
</Value>
<Value name="7">
<Value>Gender</Value>
</Value>
<Value name="8">
<Value>BirthDate</Value>
</Value>
<Value name="9">
<Value>Address</Value>
</Value>
<Value name="10">
<Value>PhoneNumber</Value>
</Value>
</Data>
<State>DischargeClaimPersonState</State>
<StreamLocation>^D1.Mock.Msg.DischargeCl8536S</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
