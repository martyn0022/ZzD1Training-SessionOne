/// Request message for API_D1GetBenefit V1.0.3 (D1 Service -> IRIS only).
Class D1.Mock.Msg.D1GetBenefitRequest Extends (Ens.Request, %JSON.Adaptor)
{

/// e.g. "AIA-TH-998821"
Property PolicyNumber As %String(%JSONFIELDNAME = "policy_number", MAXLEN = 50) [ Required ];

/// e.g. "AIA"
Property CompanyCode As %String(%JSONFIELDNAME = "company_code", MAXLEN = 50) [ Required ];

Storage Default
{
<Data name="D1GetBenefitRequestDefaultData">
<Subscript>"D1GetBenefitRequest"</Subscript>
<Value name="1">
<Value>PolicyNumber</Value>
</Value>
<Value name="2">
<Value>CompanyCode</Value>
</Value>
</Data>
<DefaultData>D1GetBenefitRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
