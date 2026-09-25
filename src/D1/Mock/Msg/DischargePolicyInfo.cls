/// The policies_info object in API_PostDischarge V1.0.3 (single object in
/// this revision) -- Policy's four fields plus policy_type, which only this
/// sheet carries.
/// 
/// V1.0.3 also dropped remaining_amount from this block (it was present in
/// V1.0.2); the benefit tables remain the source of truth for balances.
Class D1.Mock.Msg.DischargePolicyInfo Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

Property PolicyId As %String(%JSONFIELDNAME = "policy_id", MAXLEN = 50);

Property PlanCode As %String(%JSONFIELDNAME = "plan_code", MAXLEN = 50);

Property PlanName As %String(%JSONFIELDNAME = "plan_name", MAXLEN = 200);

/// Unique, e.g. "AIA-TH-998821"
Property PolicyNumber As %String(%JSONFIELDNAME = "policy_number", MAXLEN = 50);

/// e.g. "Health"
Property PolicyType As %String(%JSONFIELDNAME = "policy_type", MAXLEN = 50);

Storage Default
{
<Data name="DischargePolicyInfoState">
<Value name="1">
<Value>PolicyId</Value>
</Value>
<Value name="2">
<Value>PlanCode</Value>
</Value>
<Value name="3">
<Value>PlanName</Value>
</Value>
<Value name="4">
<Value>PolicyNumber</Value>
</Value>
<Value name="5">
<Value>PolicyType</Value>
</Value>
</Data>
<State>DischargePolicyInfoState</State>
<StreamLocation>^D1.Mock.Msg.DischargePo6A23S</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
