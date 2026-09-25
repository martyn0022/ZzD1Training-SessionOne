/// Group-2 policy_info table (data dictionary V1.0.2). One row per admission
/// (the natural PK per the dictionary) carrying the policy and its plan.
/// Seeded as reference data by ClaimLoader; also snapshot-updated by
/// PostDischarge's policies_info + insurer blocks.
/// 
/// company_name is new in dict V1.0.2. Note plan open item 12: PostPreAuth's
/// policies block carries no company fields, so a pre-auth-only flow leaves
/// CompanyCode/CompanyName as seeded (or empty for an unseeded admission).
Class D1.Mock.Data.ClaimPolicy Extends %Persistent
{

Property AdmissionNumber As %String(MAXLEN = 50) [ Required ];

Index AdmissionIdx On AdmissionNumber [ Unique ];

Property HospitalNumber As %String(MAXLEN = 50);

/// e.g. "AIA"
Property CompanyCode As %String(MAXLEN = 50);

/// e.g. "American International Assurance Co., Ltd"
Property CompanyName As %String(MAXLEN = 255);

Property PolicyId As %String(MAXLEN = 50);

Property PlanCode As %String(MAXLEN = 50);

Property PlanName As %String(MAXLEN = 200);

/// The unique key D1 and the insurer agree on
Property PolicyNumber As %String(MAXLEN = 50);

/// The insured person (insurer_info.insurer_id), as supplied by PostPreAuth's
/// insurer block for THIS admission.
/// 
/// Beyond data dictionary V1.0.3, which provides no link between insurer_info
/// and an admission. Storing what D1 sends is the alternative to inferring the
/// link -- GetDocumentInfo previously matched the policy holder to the patient
/// on citizen_id, which is wrong whenever someone claims under a dependant's
/// policy. IRIS should not be deciding that; D1 already knows the answer and
/// tells us.
Property InsurerId As %String(MAXLEN = 20);

Index PolicyNumberIdx On PolicyNumber;

Storage Default
{
<Data name="ClaimPolicyDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>AdmissionNumber</Value>
</Value>
<Value name="3">
<Value>HospitalNumber</Value>
</Value>
<Value name="4">
<Value>CompanyCode</Value>
</Value>
<Value name="5">
<Value>CompanyName</Value>
</Value>
<Value name="6">
<Value>PolicyId</Value>
</Value>
<Value name="7">
<Value>PlanCode</Value>
</Value>
<Value name="8">
<Value>PlanName</Value>
</Value>
<Value name="9">
<Value>PolicyNumber</Value>
</Value>
<Value name="10">
<Value>InsurerId</Value>
</Value>
</Data>
<DataLocation>^D1.Mock.Data.ClaimPolicyD</DataLocation>
<DefaultData>ClaimPolicyDefaultData</DefaultData>
<IdLocation>^D1.Mock.Data.ClaimPolicyD</IdLocation>
<IndexLocation>^D1.Mock.Data.ClaimPolicyI</IndexLocation>
<StreamLocation>^D1.Mock.Data.ClaimPolicyS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
