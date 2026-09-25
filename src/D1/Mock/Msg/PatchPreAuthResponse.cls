/// Acknowledgement response for API_PatchPreAuth (V1.0.5).
Class D1.Mock.Msg.PatchPreAuthResponse Extends (Ens.Response, %JSON.Adaptor)
{

Property ResponseCode As %String(%JSONFIELDNAME = "response_code", MAXLEN = 10);

Property ResponseMessage As %String(%JSONFIELDNAME = "response_message", MAXLEN = 255);

Storage Default
{
<Data name="PatchPreAuthResponseDefaultData">
<Subscript>"PatchPreAuthResponse"</Subscript>
<Value name="1">
<Value>ResponseCode</Value>
</Value>
<Value name="2">
<Value>ResponseMessage</Value>
</Value>
</Data>
<DefaultData>PatchPreAuthResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
