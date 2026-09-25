/// Mock HIS patient row, mirroring TrakCare's Patient resource (PA_Person).
/// Lives in MOCKDATA (via the D1.Mock.Data.* global mapping); the mock HIS
/// service reads it to answer both the /Patient list (identity lookups) and
/// /Patient/:id (demographics fetch).
/// 
/// Column names are TrakCare's REAL raw field names (PAPER* = PA_Person,
/// CT*Desc = code-table description) so the mock's wire contract matches a
/// real deployment 1:1. The D1-clean renames happen only in the DTL layer.
/// 
/// Documented gap: PAPERResidentNumber is a BEST GUESS for the citizen ID;
/// PAPERForeignId is the documented fallback for non-Thai patients.
Class D1.Mock.Data.Patient Extends %Persistent
{

/// Internal patient registry row id (the /Patient/:id path segment), e.g. "1001"
Property PatientID As %String(MAXLEN = 50) [ Required ];

Index PatientIDIdx On PatientID [ Unique ];

/// Hospital / medical record number. Exact literal TrakCare field name.
Property RegistrationNumber As %String(MAXLEN = 50);

Index RegistrationIdx On RegistrationNumber;

/// Best-guess citizen ID column -- no confirmed TrakCare field exists.
Property PAPERResidentNumber As %String(MAXLEN = 30);

Property PAPERPassportNumber As %String(MAXLEN = 30);

/// Surname (TrakCare's own param description for this field).
Property PAPERName As %String(MAXLEN = 100);

/// Given name.
Property PAPERName2 As %String(MAXLEN = 100);

/// Title description, e.g. "Mr."
Property TTLDesc As %String(MAXLEN = 20);

/// Sex description, e.g. "Male"
Property CTSEXDesc As %String(MAXLEN = 20);

/// Date of birth, HIS display format DD/MM/YYYY
Property PAPERDob As %String(MAXLEN = 10);

/// Street name / address line
Property PAPERStName As %String(MAXLEN = 255);

/// City description
Property CTCITDesc As %String(MAXLEN = 100);

/// Mobile phone number
Property PAPERMobPhone As %String(MAXLEN = 30);

Storage Default
{
<Data name="PatientDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>PatientID</Value>
</Value>
<Value name="3">
<Value>RegistrationNumber</Value>
</Value>
<Value name="4">
<Value>PAPERResidentNumber</Value>
</Value>
<Value name="5">
<Value>PAPERPassportNumber</Value>
</Value>
<Value name="6">
<Value>PAPERName</Value>
</Value>
<Value name="7">
<Value>PAPERName2</Value>
</Value>
<Value name="8">
<Value>TTLDesc</Value>
</Value>
<Value name="9">
<Value>CTSEXDesc</Value>
</Value>
<Value name="10">
<Value>PAPERDob</Value>
</Value>
<Value name="11">
<Value>PAPERStName</Value>
</Value>
<Value name="12">
<Value>CTCITDesc</Value>
</Value>
<Value name="13">
<Value>PAPERMobPhone</Value>
</Value>
</Data>
<DataLocation>^D1.Mock.Data.PatientD</DataLocation>
<DefaultData>PatientDefaultData</DefaultData>
<IdLocation>^D1.Mock.Data.PatientD</IdLocation>
<IndexLocation>^D1.Mock.Data.PatientI</IndexLocation>
<StreamLocation>^D1.Mock.Data.PatientS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
