/// Request to the HIS for a location/department row, by description
/// (GET /CTLoc?Description=&Hospital=). The description comes from the
/// episode's DEPDesc; the answer supplies the pinned department code/name.
Class D1.Mock.Msg.HIS.CtLocRequest Extends Ens.Request
{

/// Location description to look up, e.g. "Internal Medicine"
Property Description As %String(MAXLEN = 100);

/// Hospital code filter, e.g. "RAMA9" (optional)
Property Hospital As %String(MAXLEN = 50);

Storage Default
{
<Data name="CtLocRequestDefaultData">
<Subscript>"CtLocRequest"</Subscript>
<Value name="1">
<Value>Description</Value>
</Value>
<Value name="2">
<Value>Hospital</Value>
</Value>
</Data>
<DefaultData>CtLocRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
