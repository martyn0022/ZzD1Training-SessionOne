/// One raw reason-for-encounter row from the HIS MRReasonForEnc list.
/// 
/// DescSnomed as the chief_complaint source is a BEST GUESS from a single
/// Postman example payload -- unverified against real data, unlike every
/// other raw mapping (see plan open item 8). Comments is the documented
/// free-text fallback.
Class D1.Mock.Msg.HIS.MrReasonForEncItem Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

/// Ignore the reason-for-encounter attributes we do not model.
Parameter %JSONIGNOREINVALIDFIELD = 1;

Property ID As %String(MAXLEN = 50);

Property Mradm As %String(%JSONFIELDNAME = "mradm", MAXLEN = 50);

/// Best-guess D1 chief_complaint source, e.g. "Fever"
Property DescSnomed As %String(MAXLEN = 255);

/// Free-text fallback source
Property Comments As %String(MAXLEN = 500);

Property ConceptID As %String(MAXLEN = 50);

Storage Default
{
<Data name="MrReasonForEncItemState">
<Value name="1">
<Value>ID</Value>
</Value>
<Value name="2">
<Value>Mradm</Value>
</Value>
<Value name="3">
<Value>DescSnomed</Value>
</Value>
<Value name="4">
<Value>Comments</Value>
</Value>
<Value name="5">
<Value>ConceptID</Value>
</Value>
</Data>
<State>MrReasonForEncItemState</State>
<StreamLocation>^D1.Mock.Ms9EC9.MrReasonForE476S</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
