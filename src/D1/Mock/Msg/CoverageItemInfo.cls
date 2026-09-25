/// One coverage_items[] entry inside a benefit, in API_D1GetBenefit's
/// response. Distinct from D1.Mock.Data.CoverageItem (the table class) --
/// this is the wire shape.
Class D1.Mock.Msg.CoverageItemInfo Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

/// e.g. "1.1"
Property CoverageItem As %String(%JSONFIELDNAME = "coverage_item", MAXLEN = 20);

Property CoverageCode As %String(%JSONFIELDNAME = "coverage_code", MAXLEN = 50);

Property CoverageName As %String(%JSONFIELDNAME = "coverage_name", MAXLEN = 100);

/// e.g. "PerDay"
Property CoverageType As %String(%JSONFIELDNAME = "coverage_type", MAXLEN = 50);

Property LimitAmount As %Numeric(%JSONFIELDNAME = "limit_amount", SCALE = 2);

/// e.g. "THB"
Property LimitUnit As %String(%JSONFIELDNAME = "limit_unit", MAXLEN = 20);

Property Remark As %String(%JSONFIELDNAME = "remark", MAXLEN = 255);

Storage Default
{
<Data name="CoverageItemInfoState">
<Value name="1">
<Value>CoverageItem</Value>
</Value>
<Value name="2">
<Value>CoverageCode</Value>
</Value>
<Value name="3">
<Value>CoverageName</Value>
</Value>
<Value name="4">
<Value>CoverageType</Value>
</Value>
<Value name="5">
<Value>LimitAmount</Value>
</Value>
<Value name="6">
<Value>LimitUnit</Value>
</Value>
<Value name="7">
<Value>Remark</Value>
</Value>
</Data>
<State>CoverageItemInfoState</State>
<StreamLocation>^D1.Mock.Msg.CoverageItemInfoS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
