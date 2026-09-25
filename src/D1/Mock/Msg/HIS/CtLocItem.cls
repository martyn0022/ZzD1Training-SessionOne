/// One raw location/department row from the HIS CTLoc list -- the pinned
/// source for D1's department_code / department_name.
Class D1.Mock.Msg.HIS.CtLocItem Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

/// Ignore the location attributes we do not model.
Parameter %JSONIGNOREINVALIDFIELD = 1;

/// -> D1 department_code
Property CTLOCCode As %String(MAXLEN = 50);

/// -> D1 department_name
Property CTLOCDesc As %String(MAXLEN = 100);

Property Hospital As %String(MAXLEN = 50);

Storage Default
{
<Data name="CtLocItemState">
<Value name="1">
<Value>CTLOCCode</Value>
</Value>
<Value name="2">
<Value>CTLOCDesc</Value>
</Value>
<Value name="3">
<Value>Hospital</Value>
</Value>
</Data>
<State>CtLocItemState</State>
<StreamLocation>^D1.Mock.Msg.HIS.CtLocItemS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
