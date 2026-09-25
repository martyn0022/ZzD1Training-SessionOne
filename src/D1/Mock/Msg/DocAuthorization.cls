/// document_info.authorization -- the insurer's decision, sourced from
/// ClaimDischarge and populated by API_PatchDischarge.
/// 
/// Empty until the insurer replies. Nothing here is synthesised: IRIS used to
/// generate a placeholder gl_number, which V1.0.5 made obsolete.
Class D1.Mock.Msg.DocAuthorization Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

Property AuthorizationTitle As %String(%JSONFIELDNAME = "authorization_title", MAXLEN = 20);

Property AuthorizationFirstName As %String(%JSONFIELDNAME = "authorization_firstname", MAXLEN = 255);

Property AuthorizationLastName As %String(%JSONFIELDNAME = "authorization_lastName", MAXLEN = 255);

Property AuthorizationDate As %String(%JSONFIELDNAME = "authorization_date", MAXLEN = 30);

Property AuthorizationAmount As %Numeric(%JSONFIELDNAME = "authorization_amount", SCALE = 2);

/// ClaimDischarge.GlNumber. D1GetDischargeInfo serves the same value as
/// gl_number; this sheet names it discharge_gl_number.
Property DischargeGlNumber As %String(%JSONFIELDNAME = "discharge_gl_number", MAXLEN = 50);

Property DischargeGlDate As %String(%JSONFIELDNAME = "discharge_gl_date", MAXLEN = 30);

Storage Default
{
<Data name="DocAuthorizationState">
<Value name="1">
<Value>AuthorizationTitle</Value>
</Value>
<Value name="2">
<Value>AuthorizationFirstName</Value>
</Value>
<Value name="3">
<Value>AuthorizationLastName</Value>
</Value>
<Value name="4">
<Value>AuthorizationDate</Value>
</Value>
<Value name="5">
<Value>AuthorizationAmount</Value>
</Value>
<Value name="6">
<Value>DischargeGlNumber</Value>
</Value>
<Value name="7">
<Value>DischargeGlDate</Value>
</Value>
</Data>
<State>DocAuthorizationState</State>
<StreamLocation>^D1.Mock.Msg.DocAuthorizationS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
