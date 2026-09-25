/// Response for API_GetRecordList (V1.0.5).
/// 
/// %JSONNULL exports unset properties as null instead of omitting them, so an
/// empty worklist answers 200 with "record_list": null rather than dropping
/// the key entirely. Requested by the customer, and it removes a foot-gun:
/// a caller writing record_list.length would otherwise get a TypeError on a
/// perfectly normal empty result.
Class D1.Mock.Msg.GetRecordListResponse Extends (Ens.Response, %JSON.Adaptor)
{

Parameter %JSONNULL = 1;

Property ResponseCode As %String(%JSONFIELDNAME = "response_code", MAXLEN = 10);

Property ResponseMessage As %String(%JSONFIELDNAME = "response_message", MAXLEN = 255);

Property RecordList As list Of D1.Mock.Msg.RecordListItem(%JSONFIELDNAME = "record_list");

Storage Default
{
<Data name="GetRecordListResponseDefaultData">
<Subscript>"GetRecordListResponse"</Subscript>
<Value name="1">
<Value>ResponseCode</Value>
</Value>
<Value name="2">
<Value>ResponseMessage</Value>
</Value>
<Value name="3">
<Value>RecordList</Value>
</Value>
</Data>
<DefaultData>GetRecordListResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
