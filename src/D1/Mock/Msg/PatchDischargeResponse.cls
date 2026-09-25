/// Acknowledgement response for API_PatchDischarge (V1.0.5).
Class D1.Mock.Msg.PatchDischargeResponse Extends (Ens.Response, %JSON.Adaptor)
{

Property ResponseCode As %String(%JSONFIELDNAME = "response_code", MAXLEN = 10);

Property ResponseMessage As %String(%JSONFIELDNAME = "response_message", MAXLEN = 255);

Storage Default
{
<Data name="PatchDischargeResponseDefaultData">
<Subscript>"PatchDischargeResponse"</Subscript>
<Value name="1">
<Value>ResponseCode</Value>
</Value>
<Value name="2">
<Value>ResponseMessage</Value>
</Value>
</Data>
<DefaultData>PatchDischargeResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
