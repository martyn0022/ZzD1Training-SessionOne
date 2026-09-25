/// Response message for API_PostFiles: the two-field acknowledgement envelope.
Class D1.Mock.Msg.PostFilesResponse Extends (Ens.Response, %JSON.Adaptor)
{

Property ResponseCode As %String(%JSONFIELDNAME = "response_code", MAXLEN = 10);

Property ResponseMessage As %String(%JSONFIELDNAME = "response_message", MAXLEN = 255);

Storage Default
{
<Data name="PostFilesResponseDefaultData">
<Subscript>"PostFilesResponse"</Subscript>
<Value name="1">
<Value>ResponseCode</Value>
</Value>
<Value name="2">
<Value>ResponseMessage</Value>
</Value>
</Data>
<DefaultData>PostFilesResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
