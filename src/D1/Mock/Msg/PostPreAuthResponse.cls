/// Response message for API_PostPreAuth: the two-field acknowledgement envelope
/// ("200"/"Success"), written back to D1 as JSON by D1.Mock.API.D1API.
Class D1.Mock.Msg.PostPreAuthResponse Extends (Ens.Response, %JSON.Adaptor)
{

Property ResponseCode As %String(%JSONFIELDNAME = "response_code", MAXLEN = 10);

Property ResponseMessage As %String(%JSONFIELDNAME = "response_message", MAXLEN = 255);

Storage Default
{
<Data name="PostPreAuthResponseDefaultData">
<Subscript>"PostPreAuthResponse"</Subscript>
<Value name="1">
<Value>ResponseCode</Value>
</Value>
<Value name="2">
<Value>ResponseMessage</Value>
</Value>
</Data>
<DefaultData>PostPreAuthResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
