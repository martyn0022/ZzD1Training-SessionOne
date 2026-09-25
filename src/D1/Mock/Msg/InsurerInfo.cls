/// The insurer object (company code + name), new in V1.0.3 -- shared by
/// D1GetPolicy's response and PostDischarge's request.
Class D1.Mock.Msg.InsurerInfo Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

/// e.g. "AIA"
Property CompanyCode As %String(%JSONFIELDNAME = "company_code", MAXLEN = 50);

/// e.g. "American International Assurance Co., Ltd"
Property CompanyName As %String(%JSONFIELDNAME = "company_name", MAXLEN = 255);

Storage Default
{
<Data name="InsurerInfoState">
<Value name="1">
<Value>CompanyCode</Value>
</Value>
<Value name="2">
<Value>CompanyName</Value>
</Value>
</Data>
<State>InsurerInfoState</State>
<StreamLocation>^D1.Mock.Msg.InsurerInfoS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
