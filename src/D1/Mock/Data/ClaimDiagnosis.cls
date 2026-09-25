/// Group-2 patient_diagnosis_info table (data dictionary V1.0.2). Written by
/// PostDischarge's diagnosis_info[] snapshot; one row per diagnosis per
/// admission.
Class D1.Mock.Data.ClaimDiagnosis Extends %Persistent
{

Property AdmissionNumber As %String(MAXLEN = 50) [ Required ];

Index AdmissionIdx On AdmissionNumber;

Property HospitalNumber As %String(MAXLEN = 50);

/// "PRIMARY" / "SECONDARY" (new column in dict V1.0.2)
Property DiagnosisType As %String(MAXLEN = 20);

Property DiagnosisCode As %String(MAXLEN = 50);

Property DiagnosisName As %String(MAXLEN = 255);

Storage Default
{
<Data name="ClaimDiagnosisDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>AdmissionNumber</Value>
</Value>
<Value name="3">
<Value>HospitalNumber</Value>
</Value>
<Value name="4">
<Value>DiagnosisType</Value>
</Value>
<Value name="5">
<Value>DiagnosisCode</Value>
</Value>
<Value name="6">
<Value>DiagnosisName</Value>
</Value>
</Data>
<DataLocation>^D1.Mock.Data.ClaimDiagnosisD</DataLocation>
<DefaultData>ClaimDiagnosisDefaultData</DefaultData>
<IdLocation>^D1.Mock.Data.ClaimDiagnosisD</IdLocation>
<IndexLocation>^D1.Mock.Data.ClaimDiagnosisI</IndexLocation>
<StreamLocation>^D1.Mock.Data.ClaimDiagnosisS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
