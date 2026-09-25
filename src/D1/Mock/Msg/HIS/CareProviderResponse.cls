/// HIS list envelope for the CTCareProv read. The practitioner lookup is a
/// list query (GET /CTCareProv?Code=), so this carries the standard list
/// envelope -- the caller reads Results.GetAt(1).
Class D1.Mock.Msg.HIS.CareProviderResponse Extends (Ens.Response, %JSON.Adaptor)
{

/// Ignore envelope fields we do not model (e.g. "links").
Parameter %JSONIGNOREINVALIDFIELD = 1;

Property ResultsCount As %Integer(%JSONFIELDNAME = "results_count");

Property ResultsLimit As %Integer(%JSONFIELDNAME = "results_limit");

Property ResultsPage As %Integer(%JSONFIELDNAME = "results_page");

/// The raw practitioner rows the HIS returns under "results".
Property Results As list Of D1.Mock.Msg.HIS.CareProviderResult(%JSONFIELDNAME = "results");

Storage Default
{
<Data name="CareProviderResponseDefaultData">
<Subscript>"CareProviderResponse"</Subscript>
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
<DefaultData>CareProviderResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
