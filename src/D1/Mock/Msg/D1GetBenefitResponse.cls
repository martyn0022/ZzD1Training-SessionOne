/// Response message for API_D1GetBenefit V1.0.3: flat top level;
/// benefits_info stays an array (genuinely repeating), each entry carrying
/// its own nested coverage_items[].
Class D1.Mock.Msg.D1GetBenefitResponse Extends (Ens.Response, %JSON.Adaptor)
{

Property ResponseCode As %String(%JSONFIELDNAME = "response_code", MAXLEN = 10);

Property ResponseMessage As %String(%JSONFIELDNAME = "response_message", MAXLEN = 255);

Property HospitalNumber As %String(%JSONFIELDNAME = "hospital_number", MAXLEN = 50);

Property AdmissionNumber As %String(%JSONFIELDNAME = "admission_number", MAXLEN = 50);

Property BenefitsInfo As list Of D1.Mock.Msg.BenefitDetail(%JSONFIELDNAME = "benefits_info");

Storage Default
{
<Data name="D1GetBenefitResponseDefaultData">
<Subscript>"D1GetBenefitResponse"</Subscript>
<Value name="1">
<Value>ResponseCode</Value>
</Value>
<Value name="2">
<Value>ResponseMessage</Value>
</Value>
<Value name="3">
<Value>HospitalNumber</Value>
</Value>
<Value name="4">
<Value>AdmissionNumber</Value>
</Value>
<Value name="5">
<Value>BenefitsInfo</Value>
</Value>
</Data>
<DefaultData>D1GetBenefitResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
