/// Request to the HIS for the episode (PAAdm / Encounter) rows behind one
/// D1 identity. The HIS operation resolves the identity internally, then
/// fetches GET /PAAdm?PatientID=. Backs both GetVisit and GetAdmission --
/// TrakCare has one episode resource for both.
Class D1.Mock.Msg.HIS.PAAdmRequest Extends Ens.Request
{

/// D1 identity type: VN, AN (the group-1 visit/admission APIs), or HN/CID/PID
/// where a route still allows them.
Property IdentityType As %String(MAXLEN = 10) [ Required ];

/// The identity value, e.g. "VN-2569-100245"
Property IdentityNo As %String(MAXLEN = 50) [ Required ];

Storage Default
{
<Data name="PAAdmRequestDefaultData">
<Subscript>"PAAdmRequest"</Subscript>
<Value name="1">
<Value>IdentityType</Value>
</Value>
<Value name="2">
<Value>IdentityNo</Value>
</Value>
</Data>
<DefaultData>PAAdmRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
