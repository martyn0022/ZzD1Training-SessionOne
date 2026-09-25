/// Request message for API_GetDiagnosis V1.0.3.
Class D1.Mock.Msg.GetDiagnosisRequest Extends (Ens.Request, %JSON.Adaptor)
{

/// VN or AN
Property IdentityType As %String(%JSONFIELDNAME = "identity_type", MAXLEN = 10) [ Required ];

/// e.g. "VN-2569-100245"
Property IdentityNo As %String(%JSONFIELDNAME = "identity_no", MAXLEN = 50) [ Required ];

Property HospitalCode As %String(%JSONFIELDNAME = "hospital_code", MAXLEN = 50);

Storage Default
{
<Data name="GetDiagnosisRequestDefaultData">
<Subscript>"GetDiagnosisRequest"</Subscript>
<Value name="1">
<Value>IdentityType</Value>
</Value>
<Value name="2">
<Value>IdentityNo</Value>
</Value>
<Value name="3">
<Value>HospitalCode</Value>
</Value>
</Data>
<DefaultData>GetDiagnosisRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
