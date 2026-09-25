/// Request to the HIS for the reason-for-encounter rows of one episode
/// (GET /MRReasonForEnc?mradm=). Same episode-scoped key as the diagnosis read.
Class D1.Mock.Msg.HIS.MrReasonForEncRequest Extends Ens.Request
{

/// Medical record admission key, e.g. "VN-2569-100245"
Property Mradm As %String(MAXLEN = 50);

Storage Default
{
<Data name="MrReasonForEncRequestDefaultData">
<Subscript>"MrReasonForEncRequest"</Subscript>
<Value name="1">
<Value>Mradm</Value>
</Value>
</Data>
<DefaultData>MrReasonForEncRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
