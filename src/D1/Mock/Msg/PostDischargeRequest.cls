/// Request message for API_PostDischarge V1.0.3 (D1 Service -> IRIS) -- the
/// richest write in the spec.
/// 
/// V1.0.3 flattened claim_person / admission_info / policies_info /
/// attending_physician / billing_info from arrays to single objects, added
/// the insurer block, and added diagnosis_type to diagnosis_info[].
/// source_info[] stays URL-shaped here (unlike PostFiles' base64) -- see
/// SourceRefInfo.
/// 
/// No [ Required ] markers: validation belongs to the business process so a
/// missing field answers 400 rather than failing the message save.
Class D1.Mock.Msg.PostDischargeRequest Extends (Ens.Request, %JSON.Adaptor)
{

/// "0" - Insert, "1" - Update
Property CrudStatus As %String(%JSONFIELDNAME = "crud_status", MAXLEN = 1);

/// Authorization ID -- the discharge key, e.g. "REQ00000001"
Property ClaimId As %String(%JSONFIELDNAME = "claim_id", MAXLEN = 50);

/// Case number, e.g. "PA-2026-071122"
Property ClaimCaseNumber As %String(%JSONFIELDNAME = "claim_case_number", MAXLEN = 50);

/// V1.0.6. "Waiting for Medical" / "Approved" / "Rejected" /
/// "Discharge Requested" -- its own enum, distinct from PostPreAuth's
/// auth_status. Stored onto ClaimDischarge.DischargeStatus, which used to
/// default to "Discharge Requested" on insert only; see
/// PostDischargeOperation.StoreDischarge.
Property ClaimStatus As %String(%JSONFIELDNAME = "claim_status", MAXLEN = 50);

Property ClaimPerson As D1.Mock.Msg.DischargeClaimPerson(%JSONFIELDNAME = "claim_person");

/// Full admission detail, shared with group-1's GetAdmission response shape
Property AdmissionInfo As D1.Mock.Msg.AdmissionDetail(%JSONFIELDNAME = "admission_info");

Property Insurer As D1.Mock.Msg.InsurerInfo(%JSONFIELDNAME = "insurer");

Property PoliciesInfo As D1.Mock.Msg.DischargePolicyInfo(%JSONFIELDNAME = "policies_info");

/// Genuinely repeating -- stays an array
Property DiagnosisInfo As list Of D1.Mock.Msg.DiagnosisInfo(%JSONFIELDNAME = "diagnosis_info");

Property AttendingPhysician As D1.Mock.Msg.Physician(%JSONFIELDNAME = "attending_physician");

Property BillingInfo As D1.Mock.Msg.BillingInfo(%JSONFIELDNAME = "billing_info");

/// URL references (not base64 -- see SourceRefInfo)
Property SourceInfo As list Of D1.Mock.Msg.SourceRefInfo(%JSONFIELDNAME = "source_info");

Property Remark As %String(%JSONFIELDNAME = "remark", MAXLEN = 1000);

Storage Default
{
<Data name="PostDischargeRequestDefaultData">
<Subscript>"PostDischargeRequest"</Subscript>
<Value name="1">
<Value>CrudStatus</Value>
</Value>
<Value name="2">
<Value>ClaimId</Value>
</Value>
<Value name="3">
<Value>ClaimCaseNumber</Value>
</Value>
<Value name="4">
<Value>ClaimPerson</Value>
</Value>
<Value name="5">
<Value>AdmissionInfo</Value>
</Value>
<Value name="6">
<Value>Insurer</Value>
</Value>
<Value name="7">
<Value>PoliciesInfo</Value>
</Value>
<Value name="8">
<Value>DiagnosisInfo</Value>
</Value>
<Value name="9">
<Value>AttendingPhysician</Value>
</Value>
<Value name="10">
<Value>BillingInfo</Value>
</Value>
<Value name="11">
<Value>SourceInfo</Value>
</Value>
<Value name="12">
<Value>Remark</Value>
</Value>
<Value name="13">
<Value>ClaimStatus</Value>
</Value>
</Data>
<DefaultData>PostDischargeRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
