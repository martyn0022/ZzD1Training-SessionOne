/// Group-2 preauth_info table (data dictionary V1.0.2) -- the "official"
/// data-dictionary record of a pre-authorization, read by D1GetPreAuthInfo.
/// Written by PostPreAuth's snapshot (alongside the full-fidelity raw archive
/// in PreAuthSubmission).
/// 
/// The dictionary lists a composite id+claim_id PK; modeled here as auto ID +
/// ClaimId indexed, matching PreAuthSubmission's existing precedent (plan
/// open item 3).
/// 
/// claim_id has NO source in the PostPreAuth request body -- IRIS generates
/// it by explicit convention (plan open item 2): auth_id when sent, else
/// "REQ-"_admission_number. claim_case_number ALSO has no source there, but
/// unlike claim_id, IRIS does not invent one -- it stays empty until
/// PatchPreAuth's own optional claim_case_number field supplies the real
/// value (see PreAuthStoreOperation.SnapshotPreAuth).
/// 
/// claim_status came from the same generated-convention (always
/// "Pre-Authorize Submitted" on insert) until V1.0.6 added auth_status
/// (Required) to the PostPreAuth request -- IRIS now stores exactly what
/// D1 sends, on both insert and update. That is the API spec's enum
/// spelling ("Submitted"); the data dictionary's sample reads "Summitted"
/// (sic), but the API contract is what D1 matches against.
Class D1.Mock.Data.ClaimPreAuth Extends %Persistent
{

/// Authorization ID, e.g. "REQ000000P1"
Property ClaimId As %String(MAXLEN = 50) [ Required ];

Index ClaimIdIdx On ClaimId [ Unique ];

Property HospitalNumber As %String(MAXLEN = 50);

Index HospitalIdx On HospitalNumber;

Property AdmissionNumber As %String(MAXLEN = 50);

Index AdmissionIdx On AdmissionNumber;

/// Case number, e.g. "PA-2026-071122"
Property ClaimCaseNumber As %String(MAXLEN = 50);

/// Set by PostPreAuth's auth_status ("Waiting for Medical" / "Pre-Accepted" /
/// "Rejected" / "Pre-Authorize Submitted") on insert or update, then kept
/// current afterwards by PostDischarge/PatchDischarge's claim_status /
/// discharge_status ("Waiting for Medical" / "Approved" / "Rejected" /
/// "Discharge Requested") -- see PostDischargeOperation.SyncPreAuthStatus.
/// The client wants this column to reflect the claim's OVERALL current
/// status, not just its pre-auth stage, so it legitimately holds either
/// enum depending on which API wrote it most recently.
Property ClaimStatus As %String(MAXLEN = 50);

/// Wire format yyyy-MM-dd HH:mm:ss, stored verbatim
Property SubmitDate As %String(MAXLEN = 30);

Property EstimatedCost As %Numeric(SCALE = 2);

Storage Default
{
<Data name="ClaimPreAuthDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ClaimId</Value>
</Value>
<Value name="3">
<Value>HospitalNumber</Value>
</Value>
<Value name="4">
<Value>AdmissionNumber</Value>
</Value>
<Value name="5">
<Value>ClaimCaseNumber</Value>
</Value>
<Value name="6">
<Value>ClaimStatus</Value>
</Value>
<Value name="7">
<Value>SubmitDate</Value>
</Value>
<Value name="8">
<Value>EstimatedCost</Value>
</Value>
</Data>
<DataLocation>^D1.Mock.Data.ClaimPreAuthD</DataLocation>
<DefaultData>ClaimPreAuthDefaultData</DefaultData>
<IdLocation>^D1.Mock.Data.ClaimPreAuthD</IdLocation>
<IndexLocation>^D1.Mock.Data.ClaimPreAuthI</IndexLocation>
<StreamLocation>^D1.Mock.Data.ClaimPreAuthS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
