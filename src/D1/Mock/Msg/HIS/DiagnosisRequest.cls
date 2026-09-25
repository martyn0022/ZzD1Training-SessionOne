/// Request to the HIS for the diagnoses of one episode, by mradm -- the
/// episode-scoped key (PatientID alone would return diagnoses across all
/// episodes). The caller obtains mradm from the PAAdm read first.
Class D1.Mock.Msg.HIS.DiagnosisRequest Extends Ens.Request
{

/// Medical record admission key, e.g. "VN-2569-100245"
Property Mradm As %String(MAXLEN = 50);

Storage Default
{
<Data name="DiagnosisRequestDefaultData">
<Subscript>"DiagnosisRequest"</Subscript>
<Value name="1">
<Value>Mradm</Value>
</Value>
</Data>
<DefaultData>DiagnosisRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
