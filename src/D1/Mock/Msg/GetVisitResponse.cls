/// Response message for API_GetVisit V1.0.3: flat top level (hospital_number
/// directly on the response), visit_info / complaint_info / attending_physician
/// as single objects, procedure_info as the one genuinely-repeating array.
Class D1.Mock.Msg.GetVisitResponse Extends (Ens.Response, %JSON.Adaptor)
{

Property ResponseCode As %String(%JSONFIELDNAME = "response_code", MAXLEN = 10);

Property ResponseMessage As %String(%JSONFIELDNAME = "response_message", MAXLEN = 255);

Property HospitalNumber As %String(%JSONFIELDNAME = "hospital_number", MAXLEN = 50);

Property VisitInfo As D1.Mock.Msg.VisitInfo(%JSONFIELDNAME = "visit_info");

Property ComplaintInfo As D1.Mock.Msg.ComplaintInfo(%JSONFIELDNAME = "complaint_info");

Property ProcedureInfo As list Of D1.Mock.Msg.ProcedureInfo(%JSONFIELDNAME = "procedure_info");

Property AttendingPhysician As D1.Mock.Msg.Physician(%JSONFIELDNAME = "attending_physician");

Storage Default
{
<Data name="GetVisitResponseDefaultData">
<Subscript>"GetVisitResponse"</Subscript>
<Value name="1">
<Value>ResponseCode</Value>
</Value>
<Value name="2">
<Value>ResponseMessage</Value>
</Value>
<Value name="3">
<Value>HospitalNumber</Value>
</Value>
<Value name="4">
<Value>VisitInfo</Value>
</Value>
<Value name="5">
<Value>ComplaintInfo</Value>
</Value>
<Value name="6">
<Value>ProcedureInfo</Value>
</Value>
<Value name="7">
<Value>AttendingPhysician</Value>
</Value>
</Data>
<DefaultData>GetVisitResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
