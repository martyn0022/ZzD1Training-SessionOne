/// One record_list[] entry.
/// 
/// Both statuses are returned on every row regardless of list_mode, so the
/// caller can see the whole state of an admission from one call. Neither is
/// a new stored value: claim_status IS ClaimPreAuth.ClaimStatus (same field
/// name D1GetPreAuthInfo uses) and discharge_status IS
/// ClaimDischarge.DischargeStatus. No schema change.
/// 
/// A row can legitimately carry only one: an admission with a pre-auth but
/// no discharge yet has no discharge_status, and vice versa.
Class D1.Mock.Msg.RecordListItem Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

Property AdmissionNumber As %String(%JSONFIELDNAME = "admission_number", MAXLEN = 50);

/// Pre-authorization status. Renamed from auth_status (V1.0.5) to
/// claim_status to match D1GetPreAuthInfo's field name for the same value.
Property ClaimStatus As %String(%JSONFIELDNAME = "claim_status", MAXLEN = 50);

Property DischargeStatus As %String(%JSONFIELDNAME = "discharge_status", MAXLEN = 50);

Storage Default
{
<Data name="RecordListItemState">
<Value name="1">
<Value>AdmissionNumber</Value>
</Value>
<Value name="2">
<Value>ClaimStatus</Value>
</Value>
<Value name="3">
<Value>DischargeStatus</Value>
</Value>
</Data>
<State>RecordListItemState</State>
<StreamLocation>^D1.Mock.Msg.RecordListItemS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
