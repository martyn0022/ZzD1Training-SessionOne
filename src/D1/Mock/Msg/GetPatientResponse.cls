/// Response message for API_GetPatient V1.0.3: flat -- "patient" is the
/// record directly, no patient_info[] wrapper.
Class D1.Mock.Msg.GetPatientResponse Extends (Ens.Response, %JSON.Adaptor)
{

Property ResponseCode As %String(%JSONFIELDNAME = "response_code", MAXLEN = 10);

Property ResponseMessage As %String(%JSONFIELDNAME = "response_message", MAXLEN = 255);

/// The patient record (single object per V1.0.3)
Property Patient As D1.Mock.Msg.PatientInfo(%JSONFIELDNAME = "patient");

Storage Default
{
<Data name="GetPatientResponseDefaultData">
<Subscript>"GetPatientResponse"</Subscript>
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
<DefaultData>GetPatientResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
