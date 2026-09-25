/// The visit_info object in API_GetVisit's V1.0.3 response (single object,
/// not an array). JSON field names match the spec exactly.
Class D1.Mock.Msg.VisitInfo Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

Property VisitNumber As %String(%JSONFIELDNAME = "visit_number", MAXLEN = 50);

/// Visit date, wire format yyyy-MM-dd HH:mm:ss
Property VisitDate As %String(%JSONFIELDNAME = "visit_date", MAXLEN = 20);

/// Visit type, e.g. "IPD"/"OPD" -- from the episode's PAADMType
Property VisitType As %String(%JSONFIELDNAME = "visit_type", MAXLEN = 30);

/// Nullable -- only available via the CTLoc lookup; sparse on real sites
Property DepartmentCode As %String(%JSONFIELDNAME = "department_code", MAXLEN = 50);

Property DepartmentName As %String(%JSONFIELDNAME = "department_name", MAXLEN = 100);

Storage Default
{
<Data name="VisitInfoState">
<Value name="1">
<Value>VisitNumber</Value>
</Value>
<Value name="2">
<Value>VisitDate</Value>
</Value>
<Value name="3">
<Value>VisitType</Value>
</Value>
<Value name="4">
<Value>DepartmentCode</Value>
</Value>
<Value name="5">
<Value>DepartmentName</Value>
</Value>
</Data>
<State>VisitInfoState</State>
<StreamLocation>^D1.Mock.Msg.VisitInfoS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
