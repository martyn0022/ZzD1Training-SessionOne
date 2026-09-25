/// Response message for API_D1GetPolicy V1.0.3: flat top level, a new
/// insurer object, and policies as a SINGLE object (V1.0.2's policies_info[]
/// array was flattened).
Class D1.Mock.Msg.D1GetPolicyResponse Extends (Ens.Response, %JSON.Adaptor)
{

Property ResponseCode As %String(%JSONFIELDNAME = "response_code", MAXLEN = 10);

Property ResponseMessage As %String(%JSONFIELDNAME = "response_message", MAXLEN = 255);

Property HospitalNumber As %String(%JSONFIELDNAME = "hospital_number", MAXLEN = 50);

Property AdmissionNumber As %String(%JSONFIELDNAME = "admission_number", MAXLEN = 50);

Property Insurer As D1.Mock.Msg.InsurerInfo(%JSONFIELDNAME = "insurer");

Property Policies As D1.Mock.Msg.Policy(%JSONFIELDNAME = "policies");

Storage Default
{
<Data name="D1GetPolicyResponseDefaultData">
<Subscript>"D1GetPolicyResponse"</Subscript>
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
<Value>Insurer</Value>
</Value>
<Value name="6">
<Value>Policies</Value>
</Value>
</Data>
<DefaultData>D1GetPolicyResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
