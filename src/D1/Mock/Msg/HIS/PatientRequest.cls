/// Request to the HIS for one patient's demographics, by D1 identity.
/// The HIS operation resolves the identity to a PatientID internally
/// (GET /Patient?<param>= list lookup) and then fetches GET /Patient/:id.
Class D1.Mock.Msg.HIS.PatientRequest Extends Ens.Request
{

/// D1 identity type: CID, PID, VN, HN, or AN
Property IdentityType As %String(MAXLEN = 10) [ Required ];

/// The identity value, e.g. "3-1258-00558-89-8" or "VN-2569-100245"
Property IdentityNo As %String(MAXLEN = 50) [ Required ];

Storage Default
{
<Data name="PatientRequestDefaultData">
<Subscript>"PatientRequest"</Subscript>
<Value name="1">
<Value>IdentityType</Value>
</Value>
<Value name="2">
<Value>IdentityNo</Value>
</Value>
</Data>
<DefaultData>PatientRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
