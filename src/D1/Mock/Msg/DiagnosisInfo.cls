/// One diagnosis entry (diagnosis_info[] element), shared by GetDiagnosis and
/// the PostPreAuth/PostDischarge submissions. V1.0.3 added diagnosis_type.
Class D1.Mock.Msg.DiagnosisInfo Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

/// "PRIMARY" / "SECONDARY" -- derived from the HIS principal flag on reads
Property DiagnosisType As %String(%JSONFIELDNAME = "diagnosis_type", MAXLEN = 20);

/// The terminology name per spec sample, e.g. "ICD-10-CM"
Property Code As %String(%JSONFIELDNAME = "diagnosis_code", MAXLEN = 50);

/// "<code> - <description>", e.g. "E11 - Type 2 diabetes mellitus"
Property Name As %String(%JSONFIELDNAME = "diagnosis_name", MAXLEN = 255);

Storage Default
{
<Data name="DiagnosisInfoState">
<Value name="1">
<Value>DiagnosisType</Value>
</Value>
<Value name="2">
<Value>Code</Value>
</Value>
<Value name="3">
<Value>Name</Value>
</Value>
</Data>
<State>DiagnosisInfoState</State>
<StreamLocation>^D1.Mock.Msg.DiagnosisInfoS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
