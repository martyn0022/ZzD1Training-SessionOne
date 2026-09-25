/// One policy and its plan -- the "policies" object in API_PostPreAuth's
/// request (exactly one per pre-auth in V1.0.3) and in API_D1GetPolicy's
/// response.
/// 
/// Four fields, exactly as the spec sheets list them. policy_number is the
/// unique key D1 and the insurer agree on; policy_id is the insurer's own row
/// identifier. PostDischarge uses D1.Mock.Msg.DischargePolicyInfo instead --
/// same four fields plus policy_type, which only that sheet carries.
Class D1.Mock.Msg.Policy Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

/// Policy ID, e.g. "POL000001"
Property PolicyId As %String(%JSONFIELDNAME = "policy_id", MAXLEN = 50);

/// Plan Code (แผนประกัน), e.g. "AIA001"
Property PlanCode As %String(%JSONFIELDNAME = "plan_code", MAXLEN = 50);

/// Plan Name (แผนประกัน), e.g. "AIA Health Gold"
Property PlanName As %String(%JSONFIELDNAME = "plan_name", MAXLEN = 200);

/// Policy Number (กรมธรรม์) -- unique, e.g. "AIA-TH-998821"
Property PolicyNumber As %String(%JSONFIELDNAME = "policy_number", MAXLEN = 50);

Storage Default
{
<Data name="PolicyState">
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
</Data>
<State>PolicyState</State>
<StreamLocation>^D1.Mock.Msg.PolicyS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
