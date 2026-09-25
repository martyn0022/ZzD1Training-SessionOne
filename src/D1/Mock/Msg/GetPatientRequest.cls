/// Request message for API_GetPatient V1.0.3 (D1 Service -> HIS, via IRIS).
/// Populated by the inbound Business Service from the JSON request body.
Class D1.Mock.Msg.GetPatientRequest Extends (Ens.Request, %JSON.Adaptor)
{

/// CID, PID, VN, HN, or AN
Property IdentityType As %String(%JSONFIELDNAME = "identity_type", MAXLEN = 10) [ Required ];

/// e.g. "3-1258-00558-89-8"
Property IdentityNo As %String(%JSONFIELDNAME = "identity_no", MAXLEN = 50) [ Required ];

Property HospitalCode As %String(%JSONFIELDNAME = "hospital_code", MAXLEN = 50);

Storage Default
{
<Data name="GetPatientRequestDefaultData">
<Subscript>"GetPatientRequest"</Subscript>
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
<DefaultData>GetPatientRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
