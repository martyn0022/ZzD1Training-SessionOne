/// Response message for API_GetBilling V1.0.3: billing_info is a single
/// object (flattened from V1.0.2's array).
Class D1.Mock.Msg.GetBillingResponse Extends (Ens.Response, %JSON.Adaptor)
{

Property ResponseCode As %String(%JSONFIELDNAME = "response_code", MAXLEN = 10);

Property ResponseMessage As %String(%JSONFIELDNAME = "response_message", MAXLEN = 255);

Property BillingInfo As D1.Mock.Msg.BillingInfo(%JSONFIELDNAME = "billing_info");

Storage Default
{
<Data name="GetBillingResponseDefaultData">
<Subscript>"GetBillingResponse"</Subscript>
<Value name="1">
<Value>ResponseCode</Value>
</Value>
<Value name="2">
<Value>ResponseMessage</Value>
</Value>
<Value name="3">
<Value>BillingInfo</Value>
</Value>
</Data>
<DefaultData>GetBillingResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
