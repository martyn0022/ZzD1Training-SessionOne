/// Request message for API_GetVisit V1.0.3. Identity types narrowed to VN/AN
/// in this spec revision (validated at the REST layer; the resolver itself
/// still supports the full set for the routes that allow it).
Class D1.Mock.Msg.GetVisitRequest Extends (Ens.Request, %JSON.Adaptor)
{

/// VN or AN
Property IdentityType As %String(%JSONFIELDNAME = "identity_type", MAXLEN = 10) [ Required ];

/// e.g. "VN-2569-100245"
Property IdentityNo As %String(%JSONFIELDNAME = "identity_no", MAXLEN = 50) [ Required ];

Property HospitalCode As %String(%JSONFIELDNAME = "hospital_code", MAXLEN = 50);

Storage Default
{
<Data name="GetVisitRequestDefaultData">
<Subscript>"GetVisitRequest"</Subscript>
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
<DefaultData>GetVisitRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
