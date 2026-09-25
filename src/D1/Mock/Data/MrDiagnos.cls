/// Mock HIS diagnosis row, mirroring TrakCare's MRDiagnos resource
/// (alias /Condition). Lives in MOCKDATA. Filtered by mradm -- the
/// episode-scoped key; filtering by PatientID alone would return diagnoses
/// across ALL episodes, which is why mradm is the pinned filter.
/// 
/// Field conventions carried from the real resource (see the field-mapping doc):
///   MRDIATerminologyDesc -> D1 diagnosis_code  (yes, the terminology NAME,
///                           e.g. "ICD-10-CM" -- matches the spec's own sample)
///   MRCIDCode + MRCIDDesc -> D1 diagnosis_name ("E11 - Type 2 diabetes mellitus")
///   MRDIAPrinciple (Y/N)  -> D1 diagnosis_type ("PRIMARY"/"SECONDARY" -- a
///                           best-guess enum derivation, the spec only ever
///                           samples "PRIMARY")
Class D1.Mock.Data.MrDiagnos Extends %Persistent
{

/// Diagnosis row id
Property DiagID As %String(MAXLEN = 50) [ Required ];

Index DiagIDIdx On DiagID [ Unique ];

/// Medical record admission key (-> PAAdm.mradm)
Property Mradm As %String(MAXLEN = 50) [ SqlFieldName = mradm ];

Index MradmIdx On Mradm;

/// Episode/admission number carried on the diagnosis row itself
Property PAADMADMNo As %String(MAXLEN = 50);

/// Terminology name, e.g. "ICD-10-CM" -- the pinned diagnosis_code source
Property MRDIATerminologyDesc As %String(MAXLEN = 50);

/// Diagnosis code within the terminology, e.g. "E11"
Property MRCIDCode As %String(MAXLEN = 20);

/// Diagnosis code description, e.g. "Type 2 diabetes mellitus"
Property MRCIDDesc As %String(MAXLEN = 255);

/// "Y" when this is the principal diagnosis for the episode
Property MRDIAPrinciple As %String(MAXLEN = 10);

/// Diagnosis date, HIS display format DD/MM/YYYY
Property MRDIADate As %String(MAXLEN = 20);

Storage Default
{
<Data name="MrDiagnosDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>DiagID</Value>
</Value>
<Value name="3">
<Value>Mradm</Value>
</Value>
<Value name="4">
<Value>PAADMADMNo</Value>
</Value>
<Value name="5">
<Value>MRDIATerminologyDesc</Value>
</Value>
<Value name="6">
<Value>MRCIDCode</Value>
</Value>
<Value name="7">
<Value>MRCIDDesc</Value>
</Value>
<Value name="8">
<Value>MRDIAPrinciple</Value>
</Value>
<Value name="9">
<Value>MRDIADate</Value>
</Value>
</Data>
<DataLocation>^D1.Mock.Data.MrDiagnosD</DataLocation>
<DefaultData>MrDiagnosDefaultData</DefaultData>
<IdLocation>^D1.Mock.Data.MrDiagnosD</IdLocation>
<IndexLocation>^D1.Mock.Data.MrDiagnosI</IndexLocation>
<StreamLocation>^D1.Mock.Data.MrDiagnosS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
