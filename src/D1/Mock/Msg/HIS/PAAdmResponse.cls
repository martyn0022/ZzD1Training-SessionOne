/// HIS list envelope for the PAAdm (episode) read:
///   { "results_count":N, "results_limit":N, "results_page":N,
///     "links":{...}, "results":[ {...}, ... ] }
/// The BO loads the raw HTTP body straight into this with %JSONImport.
Class D1.Mock.Msg.HIS.PAAdmResponse Extends (Ens.Response, %JSON.Adaptor)
{

/// Ignore envelope fields we do not model (e.g. "links").
Parameter %JSONIGNOREINVALIDFIELD = 1;

Property ResultsCount As %Integer(%JSONFIELDNAME = "results_count");

Property ResultsLimit As %Integer(%JSONFIELDNAME = "results_limit");

Property ResultsPage As %Integer(%JSONFIELDNAME = "results_page");

/// The raw episode rows the HIS returns under "results".
Property Results As list Of D1.Mock.Msg.HIS.PAAdmItem(%JSONFIELDNAME = "results");

Storage Default
{
<Data name="PAAdmResponseDefaultData">
<Subscript>"PAAdmResponse"</Subscript>
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
<DefaultData>PAAdmResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
