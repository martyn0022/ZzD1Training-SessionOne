/// HIS list envelope for the CTLoc read.
Class D1.Mock.Msg.HIS.CtLocResponse Extends (Ens.Response, %JSON.Adaptor)
{

/// Ignore envelope fields we do not model (e.g. "links").
Parameter %JSONIGNOREINVALIDFIELD = 1;

Property ResultsCount As %Integer(%JSONFIELDNAME = "results_count");

Property ResultsLimit As %Integer(%JSONFIELDNAME = "results_limit");

Property ResultsPage As %Integer(%JSONFIELDNAME = "results_page");

/// The raw location rows the HIS returns under "results".
Property Results As list Of D1.Mock.Msg.HIS.CtLocItem(%JSONFIELDNAME = "results");

Storage Default
{
<Data name="CtLocResponseDefaultData">
<Subscript>"CtLocResponse"</Subscript>
<Value name="1">
<Value>ResultsCount</Value>
</Value>
<Value name="2">
<Value>ResultsLimit</Value>
</Value>
<Value name="3">
<Value>ResultsPage</Value>
</Value>
<Value name="4">
<Value>Results</Value>
</Value>
</Data>
<DefaultData>CtLocResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
