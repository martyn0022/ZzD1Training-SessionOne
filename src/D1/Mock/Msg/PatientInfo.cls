/// The patient record inside API_GetPatient's V1.0.3 response -- the "patient"
/// object is this record directly (the V1.0.2 patient_info[] wrapper is gone).
/// JSON field names match the D1-Claim spec V1.0.3 exactly.
/// 
/// title and last_name have no TrakCare source (no title field exists; only a
/// composite name) -- they stay empty on live HIS reads, per the documented gaps.
Class D1.Mock.Msg.PatientInfo Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

Property HospitalNumber As %String(%JSONFIELDNAME = "hospital_number", MAXLEN = 50);

Property CitizenId As %String(%JSONFIELDNAME = "citizen_id", MAXLEN = 30);

Property PassportId As %String(%JSONFIELDNAME = "passport_id", MAXLEN = 30);

/// No TrakCare source -- always empty from live HIS reads.
Property Title As %String(%JSONFIELDNAME = "title", MAXLEN = 20);

/// Carries the whole composite PAPERName -- TrakCare has no split name.
Property FirstName As %String(%JSONFIELDNAME = "first_name", MAXLEN = 200);

/// No TrakCare source -- always empty from live HIS reads.
Property LastName As %String(%JSONFIELDNAME = "last_name", MAXLEN = 100);

/// "male" / "female" (lower-cased from the HIS description)
Property Gender As %String(%JSONFIELDNAME = "gender", MAXLEN = 20);

/// Date of birth, wire format yyyy-MM-dd HH:mm:ss
Property BirthDate As %String(%JSONFIELDNAME = "birth_date", MAXLEN = 20);

Property Address As %String(%JSONFIELDNAME = "address", MAXLEN = 255);

Property PhoneNumber As %String(%JSONFIELDNAME = "phone_number", MAXLEN = 30);

Storage Default
{
<Data name="PatientInfoState">
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
<State>PatientInfoState</State>
<StreamLocation>^D1.Mock.Msg.PatientInfoS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
