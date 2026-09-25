/// Response message for API_GetAdmission V1.0.3: hospital_number and
/// visit_number top-level, admission_info a single object.
Class D1.Mock.Msg.GetAdmissionResponse Extends (Ens.Response, %JSON.Adaptor)
{

Property ResponseCode As %String(%JSONFIELDNAME = "response_code", MAXLEN = 10);

Property ResponseMessage As %String(%JSONFIELDNAME = "response_message", MAXLEN = 255);

Property HospitalNumber As %String(%JSONFIELDNAME = "hospital_number", MAXLEN = 50);

Property VisitNumber As %String(%JSONFIELDNAME = "visit_number", MAXLEN = 50);

Property AdmissionInfo As D1.Mock.Msg.AdmissionDetail(%JSONFIELDNAME = "admission_info");

Storage Default
{
<Data name="GetAdmissionResponseDefaultData">
<Subscript>"GetAdmissionResponse"</Subscript>
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
<Value>AdmissionInfo</Value>
</Value>
</Data>
<DefaultData>GetAdmissionResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
