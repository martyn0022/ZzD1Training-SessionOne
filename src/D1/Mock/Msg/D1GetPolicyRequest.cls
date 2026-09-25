/// Request message for API_D1GetPolicy V1.0.3 (D1 Service -> IRIS only).
Class D1.Mock.Msg.D1GetPolicyRequest Extends (Ens.Request, %JSON.Adaptor)
{

/// e.g. "AN2026080001"
Property AdmissionNumber As %String(%JSONFIELDNAME = "admission_number", MAXLEN = 50) [ Required ];

Property HospitalCode As %String(%JSONFIELDNAME = "hospital_code", MAXLEN = 50);

Storage Default
{
<Data name="D1GetPolicyRequestDefaultData">
<Subscript>"D1GetPolicyRequest"</Subscript>
<Value name="1">
<Value>AdmissionNumber</Value>
</Value>
<Value name="2">
<Value>HospitalCode</Value>
</Value>
</Data>
<DefaultData>D1GetPolicyRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
