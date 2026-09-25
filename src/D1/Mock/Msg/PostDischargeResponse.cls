/// Response message for API_PostDischarge: the two-field acknowledgement envelope.
Class D1.Mock.Msg.PostDischargeResponse Extends (Ens.Response, %JSON.Adaptor)
{

Property ResponseCode As %String(%JSONFIELDNAME = "response_code", MAXLEN = 10);

Property ResponseMessage As %String(%JSONFIELDNAME = "response_message", MAXLEN = 255);

Storage Default
{
<Data name="PostDischargeResponseDefaultData">
<Subscript>"PostDischargeResponse"</Subscript>
<Value name="1">
<Value>ResponseCode</Value>
</Value>
<Value name="2">
<Value>ResponseMessage</Value>
</Value>
</Data>
<DefaultData>PostDischargeResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
