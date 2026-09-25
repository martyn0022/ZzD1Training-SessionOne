/// Request for API_PatchPreAuth (V1.0.5). D1 reports the insurer's
/// pre-authorization decision back to IRIS.
/// 
/// Keyed by (admission_number, company_code) -- company_code is a tenancy
/// boundary, not a lookup key. See D1.Mock.Util.ClaimCompanyResolver.
/// 
/// Every field after the key is Optional: a patch sets only what it carries,
/// so an empty value means "leave alone", never "clear".
Class D1.Mock.Msg.PatchPreAuthRequest Extends (Ens.Request, %JSON.Adaptor)
{

Property AdmissionNumber As %String(%JSONFIELDNAME = "admission_number", MAXLEN = 50) [ Required ];

Property CompanyCode As %String(%JSONFIELDNAME = "company_code", MAXLEN = 50) [ Required ];

Property ClaimCaseNumber As %String(%JSONFIELDNAME = "claim_case_number", MAXLEN = 50);

/// "Waiting for Medical" / "Pre-Accepted" / "Rejected" / "Pre-Authorize Submitted"
Property ClaimStatus As %String(%JSONFIELDNAME = "claim_status", MAXLEN = 50);

Property SubmitDate As %String(%JSONFIELDNAME = "submit_date", MAXLEN = 30);

Storage Default
{
<Data name="PatchPreAuthRequestDefaultData">
<Subscript>"PatchPreAuthRequest"</Subscript>
<Value name="1">
<Value>AdmissionNumber</Value>
</Value>
<Value name="2">
<Value>CompanyCode</Value>
</Value>
<Value name="3">
<Value>ClaimCaseNumber</Value>
</Value>
<Value name="4">
<Value>ClaimStatus</Value>
</Value>
<Value name="5">
<Value>SubmitDate</Value>
</Value>
</Data>
<DefaultData>PatchPreAuthRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
