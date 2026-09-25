/// Response message for API_D1GetPatient V1.0.3: patient is an ARRAY of
/// wrappers each holding a patient_info object -- deliberately not
/// GetPatientResponse's flat shape (V1.0.3 divergence, built as written).
Class D1.Mock.Msg.D1GetPatientResponse Extends (Ens.Response, %JSON.Adaptor)
{

Property ResponseCode As %String(%JSONFIELDNAME = "response_code", MAXLEN = 10);

Property ResponseMessage As %String(%JSONFIELDNAME = "response_message", MAXLEN = 255);

Property Patient As list Of D1.Mock.Msg.D1PatientWrapper(%JSONFIELDNAME = "patient");

Storage Default
{
<Data name="D1GetPatientResponseDefaultData">
<Subscript>"D1GetPatientResponse"</Subscript>
<Value name="1">
<Value>ResponseCode</Value>
</Value>
<Value name="2">
<Value>ResponseMessage</Value>
</Value>
<Value name="3">
<Value>Patient</Value>
</Value>
</Data>
<DefaultData>D1GetPatientResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
