/// Request for API_PatchDischarge (V1.0.5). D1 reports the insurer's
/// discharge decision back to IRIS.
/// 
/// This is the API that made the synthetic gl_number obsolete: before V1.0.5
/// no request in the spec carried gl_number, discharge_status or the
/// authorization fields, so IRIS generated placeholders. They arrive here now.
/// 
/// Note the field is discharge_gl_number, while the response of
/// API_D1GetDischargeInfo calls the same value gl_number. Built as specified.
Class D1.Mock.Msg.PatchDischargeRequest Extends (Ens.Request, %JSON.Adaptor)
{

Property AdmissionNumber As %String(%JSONFIELDNAME = "admission_number", MAXLEN = 50) [ Required ];

Property CompanyCode As %String(%JSONFIELDNAME = "company_code", MAXLEN = 50) [ Required ];

/// Stored as ClaimDischarge.GlNumber -- the read side calls it gl_number.
Property DischargeGlNumber As %String(%JSONFIELDNAME = "discharge_gl_number", MAXLEN = 50);

/// "Waiting for Medical" / "Approved" / "Rejected" / "Discharge Requested"
Property DischargeStatus As %String(%JSONFIELDNAME = "discharge_status", MAXLEN = 50);

Property AuthorizationTitle As %String(%JSONFIELDNAME = "authorization_title", MAXLEN = 20);

Property AuthorizationFirstName As %String(%JSONFIELDNAME = "authorization_firstname", MAXLEN = 255);

Property AuthorizationLastName As %String(%JSONFIELDNAME = "authorization_lastName", MAXLEN = 255);

Property AuthorizationDate As %String(%JSONFIELDNAME = "authorization_date", MAXLEN = 30);

Property AuthorizationAmount As %Numeric(%JSONFIELDNAME = "authorization_amount", SCALE = 2);

Property DischargeGlDate As %String(%JSONFIELDNAME = "discharge_gl_date", MAXLEN = 30);

Storage Default
{
<Data name="PatchDischargeRequestDefaultData">
<Subscript>"PatchDischargeRequest"</Subscript>
<Value name="1">
<Value>AdmissionNumber</Value>
</Value>
<Value name="2">
<Value>CompanyCode</Value>
</Value>
<Value name="3">
<Value>DischargeGlNumber</Value>
</Value>
<Value name="4">
<Value>DischargeStatus</Value>
</Value>
<Value name="5">
<Value>AuthorizationTitle</Value>
</Value>
<Value name="6">
<Value>AuthorizationFirstName</Value>
</Value>
<Value name="7">
<Value>AuthorizationLastName</Value>
</Value>
<Value name="8">
<Value>AuthorizationDate</Value>
</Value>
<Value name="9">
<Value>AuthorizationAmount</Value>
</Value>
<Value name="10">
<Value>DischargeGlDate</Value>
</Value>
</Data>
<DefaultData>PatchDischargeRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
