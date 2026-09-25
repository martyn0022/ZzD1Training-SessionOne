/// Response message for API_D1GetPreAuthInfo V1.0.4: preauth is an ARRAY of
/// self-contained rows (each carrying its own hospital/admission numbers), so
/// a date range spanning several admissions answers correctly.
/// 
/// V1.0.4 renumbered the response block to 3.1-3.7, putting estimated_cost
/// inside each row. It previously sat here on the root, where a multi-row
/// result could only ever report one figure -- see PreAuthDetail.
Class D1.Mock.Msg.D1GetPreAuthInfoResponse Extends (Ens.Response, %JSON.Adaptor)
{

Property ResponseCode As %String(%JSONFIELDNAME = "response_code", MAXLEN = 10);

Property ResponseMessage As %String(%JSONFIELDNAME = "response_message", MAXLEN = 255);

Property PreAuth As list Of D1.Mock.Msg.PreAuthDetail(%JSONFIELDNAME = "preauth");

Storage Default
{
<Data name="D1GetPreAuthInfoResponseDefaultData">
<Subscript>"D1GetPreAuthInfoResponse"</Subscript>
<Value name="1">
<Value>ResponseCode</Value>
</Value>
<Value name="2">
<Value>ResponseMessage</Value>
</Value>
<Value name="3">
<Value>PreAuth</Value>
</Value>
</Data>
<DefaultData>D1GetPreAuthInfoResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
