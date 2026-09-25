/// The "person" object in API_PostPreAuth V1.0.3 (was claim_person[] in
/// V1.0.2 -- now a single object, renamed, with hospital_number and
/// visit_number added).
/// 
/// citizenId / passportId are camelCase ON PURPOSE: that is what the spec
/// sheet says, inconsistent with PostDischarge's snake_case citizen_id --
/// a flagged spec inconsistency, reproduced as written rather than silently
/// normalized (plan open item 1).
Class D1.Mock.Msg.PreAuthPerson Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

Property HospitalNumber As %String(%JSONFIELDNAME = "hospital_number", MAXLEN = 50);

/// New in V1.0.3 -- ties the pre-auth back to the visit it was built from.
Property VisitNumber As %String(%JSONFIELDNAME = "visit_number", MAXLEN = 50);

Property CitizenId As %String(%JSONFIELDNAME = "citizenId", MAXLEN = 30);

Property PassportId As %String(%JSONFIELDNAME = "passportId", MAXLEN = 30);

Property Title As %String(%JSONFIELDNAME = "title", MAXLEN = 20);

Property FirstName As %String(%JSONFIELDNAME = "first_name", MAXLEN = 100);

Property LastName As %String(%JSONFIELDNAME = "last_name", MAXLEN = 100);

/// "male" / "female"
Property Gender As %String(%JSONFIELDNAME = "gender", MAXLEN = 20);

/// Wire format yyyy-MM-dd HH:mm:ss per V1.0.3
Property Birthdate As %String(%JSONFIELDNAME = "birthdate", MAXLEN = 20);

/// Sampled unquoted (18) -- the REST layer coerces a quoted value to numeric
/// before import.
Property Age As %Integer(%JSONFIELDNAME = "age");

Storage Default
{
<Data name="PreAuthPersonState">
<Value name="1">
<Value>HospitalNumber</Value>
</Value>
<Value name="2">
<Value>VisitNumber</Value>
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
<Value>Birthdate</Value>
</Value>
<Value name="10">
<Value>Age</Value>
</Value>
</Data>
<State>PreAuthPersonState</State>
<StreamLocation>^D1.Mock.Msg.PreAuthPersonS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
