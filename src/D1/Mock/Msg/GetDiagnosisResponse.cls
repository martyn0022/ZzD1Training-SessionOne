/// Response message for API_GetDiagnosis V1.0.3: hospital_number /
/// visit_number / admission_number top-level, diagnosis_info[] the one array.
/// attending_physician was REMOVED from this response in V1.0.3 --
/// deliberately absent here; its return would be a spec regression.
Class D1.Mock.Msg.GetDiagnosisResponse Extends (Ens.Response, %JSON.Adaptor)
{

Property ResponseCode As %String(%JSONFIELDNAME = "response_code", MAXLEN = 10);

Property ResponseMessage As %String(%JSONFIELDNAME = "response_message", MAXLEN = 255);

Property HospitalNumber As %String(%JSONFIELDNAME = "hospital_number", MAXLEN = 50);

Property VisitNumber As %String(%JSONFIELDNAME = "visit_number", MAXLEN = 50);

Property AdmissionNumber As %String(%JSONFIELDNAME = "admission_number", MAXLEN = 50);

Property DiagnosisInfo As list Of D1.Mock.Msg.DiagnosisInfo(%JSONFIELDNAME = "diagnosis_info");

Storage Default
{
<Data name="GetDiagnosisResponseDefaultData">
<Subscript>"GetDiagnosisResponse"</Subscript>
<Value name="1">
<Value>ResponseCode</Value>
</Value>
<Value name="2">
<Value>ResponseMessage</Value>
</Value>
<Value name="3">
<Value>HospitalNumber</Value>
</Value>
<Value name="4">
<Value>VisitNumber</Value>
</Value>
<Value name="5">
<Value>AdmissionNumber</Value>
</Value>
<Value name="6">
<Value>DiagnosisInfo</Value>
</Value>
</Data>
<DefaultData>GetDiagnosisResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
