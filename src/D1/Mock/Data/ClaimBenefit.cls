/// Group-2 benefit_info table (data dictionary V1.0.2). Pure insurer
/// REFERENCE data: nothing in the API spec ever writes maximum_amount /
/// remaining_amount / coverage items -- ClaimLoader seeds them, the
/// D1GetBenefit read serves them.
/// 
/// coverage_items is normalized into the D1.Mock.Data.CoverageItem child
/// table (FK-by-string BenefitKey) rather than the dictionary's
/// semi-structured text column -- keeps it queryable in the Portal.
Class D1.Mock.Data.ClaimBenefit Extends %Persistent
{

/// Business key linking CoverageItem rows to this benefit, e.g. "AIA-TH-998821:IPD-ROOM"
Property BenefitKey As %String(MAXLEN = 100) [ Required ];

Index BenefitKeyIdx On BenefitKey [ Unique ];

Property PolicyNumber As %String(MAXLEN = 50) [ Required ];

Index PolicyNumberIdx On PolicyNumber;

/// e.g. "IPD"
Property BenefitCode As %String(MAXLEN = 50);

/// e.g. "Room and Board"
Property BenefitName As %String(MAXLEN = 100);

/// "available" / "exhausted"
Property BenefitStatus As %String(MAXLEN = 20);

Property MaximumAmount As %Numeric(SCALE = 2);

Property RemainingAmount As %Numeric(SCALE = 2);

Storage Default
{
<Data name="ClaimBenefitDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>BenefitKey</Value>
</Value>
<Value name="3">
<Value>PolicyNumber</Value>
</Value>
<Value name="4">
<Value>BenefitCode</Value>
</Value>
<Value name="5">
<Value>BenefitName</Value>
</Value>
<Value name="6">
<Value>BenefitStatus</Value>
</Value>
<Value name="7">
<Value>MaximumAmount</Value>
</Value>
<Value name="8">
<Value>RemainingAmount</Value>
</Value>
</Data>
<DataLocation>^D1.Mock.Data.ClaimBenefitD</DataLocation>
<DefaultData>ClaimBenefitDefaultData</DefaultData>
<IdLocation>^D1.Mock.Data.ClaimBenefitD</IdLocation>
<IndexLocation>^D1.Mock.Data.ClaimBenefitI</IndexLocation>
<StreamLocation>^D1.Mock.Data.ClaimBenefitS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
