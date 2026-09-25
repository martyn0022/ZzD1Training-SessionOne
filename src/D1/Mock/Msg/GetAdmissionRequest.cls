/// Request message for API_GetAdmission V1.0.3. Only identity_type is
/// Required per spec; identity_no and hospital_code are Optional.
Class D1.Mock.Msg.GetAdmissionRequest Extends (Ens.Request, %JSON.Adaptor)
{

/// VN or AN
Property IdentityType As %String(%JSONFIELDNAME = "identity_type", MAXLEN = 10) [ Required ];

Property IdentityNo As %String(%JSONFIELDNAME = "identity_no", MAXLEN = 50);

Property HospitalCode As %String(%JSONFIELDNAME = "hospital_code", MAXLEN = 50);

Storage Default
{
<Data name="GetAdmissionRequestDefaultData">
<Subscript>"GetAdmissionRequest"</Subscript>
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
<DefaultData>GetAdmissionRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
