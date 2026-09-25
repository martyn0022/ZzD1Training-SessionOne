/// The "discharge" object in API_D1GetDischargeInfo's V1.0.3 response.
/// 
/// A SINGLE object despite the request being a date range -- the spec sheet
/// says so, unlike the structurally identical D1GetPreAuthInfo which became
/// an array in the same revision. Flagged as a probable spec inconsistency
/// (plan open item 10); built as written, with the operation returning the
/// most recent match in range.
Class D1.Mock.Msg.DischargeDetail Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

/// Discharge ID, e.g. "REQ000000D1"
Property DischargeId As %String(%JSONFIELDNAME = "discharge_id", MAXLEN = 50);

/// Guarantee letter number, e.g. "GCL-12345"
Property GlNumber As %String(%JSONFIELDNAME = "gl_number", MAXLEN = 50);

/// "Waiting for Medical" / "Approved" / "Rejected" / "Discharge Requested"
Property DischargeStatus As %String(%JSONFIELDNAME = "discharge_status", MAXLEN = 50);

/// Wire format yyyy-MM-dd HH:mm:ss
Property AuthorizationDate As %String(%JSONFIELDNAME = "authorization_date", MAXLEN = 30);

Property AuthorizationAmount As %Numeric(%JSONFIELDNAME = "authorization_amount", SCALE = 2);

/// Guarantee letter issue date
Property DischargeGlDate As %String(%JSONFIELDNAME = "discharge_gl_date", MAXLEN = 30);

Storage Default
{
<Data name="DischargeDetailState">
<Value name="1">
<Value>DischargeId</Value>
</Value>
<Value name="2">
<Value>GlNumber</Value>
</Value>
<Value name="3">
<Value>DischargeStatus</Value>
</Value>
<Value name="4">
<Value>AuthorizationDate</Value>
</Value>
<Value name="5">
<Value>AuthorizationAmount</Value>
</Value>
<Value name="6">
<Value>DischargeGlDate</Value>
</Value>
</Data>
<State>DischargeDetailState</State>
<StreamLocation>^D1.Mock.Msg.DischargeDetailS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
