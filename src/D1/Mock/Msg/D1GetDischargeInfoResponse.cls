/// Response message for API_D1GetDischargeInfo V1.0.4.
/// 
/// V1.0.4 changed the shape: "discharge" went from a single object to an
/// array, and hospital_number / admission_number moved off the top level into
/// each row's insurer_info block. A date-range query returning one row was
/// the V1.0.3 inconsistency against D1GetPreAuthInfo; it is now resolved, and
/// every match in range is returned, most recent first.
Class D1.Mock.Msg.D1GetDischargeInfoResponse Extends (Ens.Response, %JSON.Adaptor)
{

Property ResponseCode As %String(%JSONFIELDNAME = "response_code", MAXLEN = 10);

Property ResponseMessage As %String(%JSONFIELDNAME = "response_message", MAXLEN = 255);

Property Discharge As list Of D1.Mock.Msg.D1DischargeEntry(%JSONFIELDNAME = "discharge");

Storage Default
{
<Data name="D1GetDischargeInfoResponseDefaultData">
<Subscript>"D1GetDischargeInfoResponse"</Subscript>
<Value name="1">
<Value>ResponseCode</Value>
</Value>
<Value name="2">
<Value>ResponseMessage</Value>
</Value>
<Value name="3">
<Value>Discharge</Value>
</Value>
</Data>
<DefaultData>D1GetDischargeInfoResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
