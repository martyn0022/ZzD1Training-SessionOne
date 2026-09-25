/// One benefits_info[] entry in API_D1GetBenefit's response -- the full
/// benefit detail (amounts + nested coverage items), unlike the thin
/// BenefitRef that PostPreAuth submits.
Class D1.Mock.Msg.BenefitDetail Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

/// e.g. "IPD"
Property BenefitCode As %String(%JSONFIELDNAME = "benefit_code", MAXLEN = 50);

Property BenefitName As %String(%JSONFIELDNAME = "benefit_name", MAXLEN = 100);

/// "available" - still usable / "exhausted" - policy exhausted
Property BenefitStatus As %String(%JSONFIELDNAME = "benefit_status", MAXLEN = 20);

Property MaximumAmount As %Numeric(%JSONFIELDNAME = "maximum_amount", SCALE = 2);

Property RemainingAmount As %Numeric(%JSONFIELDNAME = "remaining_amount", SCALE = 2);

Property CoverageItems As list Of D1.Mock.Msg.CoverageItemInfo(%JSONFIELDNAME = "coverage_items");

Storage Default
{
<Data name="BenefitDetailState">
<Value name="1">
<Value>BenefitCode</Value>
</Value>
<Value name="2">
<Value>BenefitName</Value>
</Value>
<Value name="3">
<Value>BenefitStatus</Value>
</Value>
<Value name="4">
<Value>MaximumAmount</Value>
</Value>
<Value name="5">
<Value>RemainingAmount</Value>
</Value>
<Value name="6">
<Value>CoverageItems</Value>
</Value>
</Data>
<State>BenefitDetailState</State>
<StreamLocation>^D1.Mock.Msg.BenefitDetailS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
