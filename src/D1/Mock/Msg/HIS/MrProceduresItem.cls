/// One raw procedure row from the HIS MRProcedures list. OPERCode/OPERDesc
/// carry the same Code+Desc convention as diagnosis and department -- the
/// pinned sources for D1's procedure_code / procedure_name.
Class D1.Mock.Msg.HIS.MrProceduresItem Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

/// Ignore the ~35 clinical/coding attributes we do not model.
Parameter %JSONIGNOREINVALIDFIELD = 1;

Property PROCRowId As %String(MAXLEN = 50);

Property EpisodeID As %String(MAXLEN = 50);

/// -> D1 procedure_code
Property OPERCode As %String(MAXLEN = 20);

/// -> D1 procedure_name
Property OPERDesc As %String(MAXLEN = 255);

Property PROCDate As %String(MAXLEN = 20);

Property PROCTime As %String(MAXLEN = 20);

Storage Default
{
<Data name="MrProceduresItemState">
<Value name="1">
<Value>PROCRowId</Value>
</Value>
<Value name="2">
<Value>EpisodeID</Value>
</Value>
<Value name="3">
<Value>OPERCode</Value>
</Value>
<Value name="4">
<Value>OPERDesc</Value>
</Value>
<Value name="5">
<Value>PROCDate</Value>
</Value>
<Value name="6">
<Value>PROCTime</Value>
</Value>
</Data>
<State>MrProceduresItemState</State>
<StreamLocation>^D1.Mock.Ms9EC9.MrProcedures626S</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
