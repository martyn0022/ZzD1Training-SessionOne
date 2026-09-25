/// Response for API_GetDocumentInfo (V1.0.5).
Class D1.Mock.Msg.GetDocumentInfoResponse Extends (Ens.Response, %JSON.Adaptor)
{

Property ResponseCode As %String(%JSONFIELDNAME = "response_code", MAXLEN = 10);

Property ResponseMessage As %String(%JSONFIELDNAME = "response_message", MAXLEN = 255);

Property DocumentInfo As D1.Mock.Msg.DocumentInfo(%JSONFIELDNAME = "document_info");

Storage Default
{
<Data name="GetDocumentInfoResponseDefaultData">
<Subscript>"GetDocumentInfoResponse"</Subscript>
<Value name="1">
<Value>ResponseCode</Value>
</Value>
<Value name="2">
<Value>ResponseMessage</Value>
</Value>
<Value name="3">
<Value>DocumentInfo</Value>
</Value>
</Data>
<DefaultData>GetDocumentInfoResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
