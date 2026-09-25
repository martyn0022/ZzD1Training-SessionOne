/// PostPreAuth's "insurer" block, new in V1.0.5.
/// 
/// It carries TWO different concepts in one object, and they persist to two
/// different tables:
///   company_code / company_name -> policy_info  (the insurance COMPANY)
///   insurer_id / title / first_name / last_name -> insurer_info
///                                                 (the INSURED PERSON)
/// 
/// The company half is what makes this block load-bearing: it is the only
/// way PostPreAuth can create a policy_info row, and without that row the
/// admission is invisible to PatchPreAuth, PatchDischarge, GetRecordList and
/// GetDocumentInfo -- all of which resolve company_code through policy_info.
/// V1.0.5 adding this block is what makes that join viable.
/// 
/// Distinct from D1.Mock.Msg.InsurerInfo (company fields only, used by
/// D1GetPolicy and PostDischarge).
Class D1.Mock.Msg.PreAuthInsurer Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

Property CompanyCode As %String(%JSONFIELDNAME = "company_code", MAXLEN = 50);

Property CompanyName As %String(%JSONFIELDNAME = "company_name", MAXLEN = 255);

/// Insured person's id, e.g. "INS00001" -- insurer_info's PK
Property InsurerId As %String(%JSONFIELDNAME = "insurer_id", MAXLEN = 20);

Property Title As %String(%JSONFIELDNAME = "title", MAXLEN = 20);

Property FirstName As %String(%JSONFIELDNAME = "first_name", MAXLEN = 255);

Property LastName As %String(%JSONFIELDNAME = "last_name", MAXLEN = 255);

Storage Default
{
<Data name="PreAuthInsurerState">
<Value name="1">
<Value>CompanyCode</Value>
</Value>
<Value name="2">
<Value>CompanyName</Value>
</Value>
<Value name="3">
<Value>InsurerId</Value>
</Value>
<Value name="4">
<Value>Title</Value>
</Value>
<Value name="5">
<Value>FirstName</Value>
</Value>
<Value name="6">
<Value>LastName</Value>
</Value>
</Data>
<State>PreAuthInsurerState</State>
<StreamLocation>^D1.Mock.Msg.PreAuthInsurerS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
