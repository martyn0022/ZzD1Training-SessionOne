/// One benefits[] entry in API_PostPreAuth V1.0.3 -- a thin code+name
/// reference, not the full benefit detail the group-2 read APIs serve.
Class D1.Mock.Msg.BenefitRef Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

/// e.g. "IPD"
Property BenefitCode As %String(%JSONFIELDNAME = "benefit_code", MAXLEN = 50);

/// e.g. "Inpatient"
Property BenefitName As %String(%JSONFIELDNAME = "benefit_name", MAXLEN = 100);

Storage Default
{
<Data name="BenefitRefState">
<Value name="1">
<Value>BenefitCode</Value>
</Value>
<Value name="2">
<Value>BenefitName</Value>
</Value>
</Data>
<State>BenefitRefState</State>
<StreamLocation>^D1.Mock.Msg.BenefitRefS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
