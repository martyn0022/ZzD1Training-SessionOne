/// Response message for API_D1GetAdmission V1.0.3.
/// 
/// Distinct from group-1's GetAdmissionResponse: this one nests under
/// "admission" (not "admission_info") and adds estimated_lengthofstay /
/// estimated_cost, which the local table carries but the live HIS read does
/// not expose. The request shape is shared with group 1
/// (GetAdmissionRequest) -- but note this sheet kept the WIDER identity set
/// (VN/HN/AN) while group-1's GetAdmission narrowed to VN/AN.
Class D1.Mock.Msg.D1GetAdmissionResponse Extends (Ens.Response, %JSON.Adaptor)
{

Property ResponseCode As %String(%JSONFIELDNAME = "response_code", MAXLEN = 10);

Property ResponseMessage As %String(%JSONFIELDNAME = "response_message", MAXLEN = 255);

Property HospitalNumber As %String(%JSONFIELDNAME = "hospital_number", MAXLEN = 50);

Property AdmissionNumber As %String(%JSONFIELDNAME = "admission_number", MAXLEN = 50);

Property Admission As D1.Mock.Msg.D1AdmissionDetail(%JSONFIELDNAME = "admission");

Storage Default
{
<Data name="D1GetAdmissionResponseDefaultData">
<Subscript>"D1GetAdmissionResponse"</Subscript>
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
<Value>AdmissionNumber</Value>
</Value>
<Value name="5">
<Value>Admission</Value>
</Value>
</Data>
<DefaultData>D1GetAdmissionResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
