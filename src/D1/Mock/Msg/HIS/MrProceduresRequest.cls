/// Request to the HIS for the procedures of one episode
/// (GET /MRProcedures?EpisodeID=). The episode id comes from the PAAdm read.
Class D1.Mock.Msg.HIS.MrProceduresRequest Extends Ens.Request
{

/// Episode id, e.g. "VN-2569-100245"
Property EpisodeID As %String(MAXLEN = 50);

Storage Default
{
<Data name="MrProceduresRequestDefaultData">
<Subscript>"MrProceduresRequest"</Subscript>
<Value name="1">
<Value>EpisodeID</Value>
</Value>
</Data>
<DefaultData>MrProceduresRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
