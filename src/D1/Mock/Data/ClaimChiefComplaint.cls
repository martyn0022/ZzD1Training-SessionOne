/// Group-2 patient_chiefcomplain_info table, new in data dictionary V1.0.3.
/// Written by PostPreAuth; read by GetDocumentInfo.
/// 
/// DUPLICATE WRITE, deliberate for now: ClaimVisit.ChiefComplaint holds the
/// same value, written by the same PostPreAuth call. The dictionary still
/// lists chief_complaint on visit_info, so both are kept to stay faithful.
/// The ClaimVisit copy is the one to retire once the dictionary drops it --
/// this table is keyed by admission, which is how GetDocumentInfo reads it.
Class D1.Mock.Data.ClaimChiefComplaint Extends %Persistent
{

Property AdmissionNumber As %String(MAXLEN = 50) [ Required ];

/// Unique: one chief complaint per admission, so PostPreAuth upserts on it.
Index AdmissionIdx On AdmissionNumber [ Unique ];

Property HospitalNumber As %String(MAXLEN = 50);

Index HospitalIdx On HospitalNumber;

Property ChiefComplaint As %String(MAXLEN = 255);

Storage Default
{
<Data name="ClaimChiefComplaintDefaultData">
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
<Value>ChiefComplaint</Value>
</Value>
</Data>
<DataLocation>^D1.Mock.Data.ClaimChiefC835DD</DataLocation>
<DefaultData>ClaimChiefComplaintDefaultData</DefaultData>
<IdLocation>^D1.Mock.Data.ClaimChiefC835DD</IdLocation>
<IndexLocation>^D1.Mock.Data.ClaimChiefC835DI</IndexLocation>
<StreamLocation>^D1.Mock.Data.ClaimChiefC835DS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
