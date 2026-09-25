/// One raw diagnosis row from the HIS MRDiagnos list (an element of
/// "results"). Property names match TrakCare's real field names 1:1; Mradm
/// carries the wire name "mradm" via %JSONFIELDNAME.
Class D1.Mock.Msg.HIS.DiagnosisItem Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

/// Ignore any diagnosis-row attributes we do not model.
Parameter %JSONIGNOREINVALIDFIELD = 1;

Property ID As %String(MAXLEN = 50);

Property Mradm As %String(%JSONFIELDNAME = "mradm", MAXLEN = 50);

/// Episode/admission number carried on the diagnosis row
Property PAADMADMNo As %String(MAXLEN = 50);

/// Terminology name, e.g. "ICD-10-CM" -- D1's diagnosis_code source
Property MRDIATerminologyDesc As %String(MAXLEN = 50);

/// Diagnosis code, e.g. "E11" -- half of D1's diagnosis_name
Property MRCIDCode As %String(MAXLEN = 20);

/// Diagnosis description -- other half of D1's diagnosis_name
Property MRCIDDesc As %String(MAXLEN = 255);

/// "Y" for the principal diagnosis -> D1 diagnosis_type PRIMARY
Property MRDIAPrinciple As %String(MAXLEN = 10);

Property MRDIADate As %String(MAXLEN = 20);

Storage Default
{
<Data name="DiagnosisItemState">
<Value name="1">
<Value>ID</Value>
</Value>
<Value name="2">
<Value>Mradm</Value>
</Value>
<Value name="3">
<Value>PAADMADMNo</Value>
</Value>
<Value name="4">
<Value>MRDIATerminologyDesc</Value>
</Value>
<Value name="5">
<Value>MRCIDCode</Value>
</Value>
<Value name="6">
<Value>MRCIDDesc</Value>
</Value>
<Value name="7">
<Value>MRDIAPrinciple</Value>
</Value>
<Value name="8">
<Value>MRDIADate</Value>
</Value>
</Data>
<State>DiagnosisItemState</State>
<StreamLocation>^D1.Mock.Msg.HIS.DiagnosisItemS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
