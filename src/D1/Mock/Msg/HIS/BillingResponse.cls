/// HIS list envelope for the ARPatientBillAll read. The BO filters
/// Results on EpisodeID after import to isolate one admission's bill.
Class D1.Mock.Msg.HIS.BillingResponse Extends (Ens.Response, %JSON.Adaptor)
{

/// Ignore envelope fields we do not model (e.g. "links").
Parameter %JSONIGNOREINVALIDFIELD = 1;

Property ResultsCount As %Integer(%JSONFIELDNAME = "results_count");

Property ResultsLimit As %Integer(%JSONFIELDNAME = "results_limit");

Property ResultsPage As %Integer(%JSONFIELDNAME = "results_page");

/// The raw bill rows the HIS returns under "results".
Property Results As list Of D1.Mock.Msg.HIS.BillingItem(%JSONFIELDNAME = "results");

Storage Default
{
<Data name="BillingResponseDefaultData">
<Subscript>"BillingResponse"</Subscript>
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
<DefaultData>BillingResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
