/// HIS patient response envelope: { "results": { ...raw flat fields... } }.
/// The BO loads the raw GET /Patient/:id body straight into this with %JSONImport.
Class D1.Mock.Msg.HIS.PatientResponse Extends (Ens.Response, %JSON.Adaptor)
{

/// Ignore any top-level envelope fields we do not model.
Parameter %JSONIGNOREINVALIDFIELD = 1;

/// The single raw patient record the HIS returns under "results".
Property Results As D1.Mock.Msg.HIS.PatientResult(%JSONFIELDNAME = "results");

Storage Default
{
<Data name="PatientResponseDefaultData">
<Subscript>"PatientResponse"</Subscript>
<Value name="1">
<Value>Results</Value>
</Value>
</Data>
<DefaultData>PatientResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
