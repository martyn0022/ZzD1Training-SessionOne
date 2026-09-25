/// document_info.department -- from ClaimVisit.
Class D1.Mock.Msg.DocDepartment Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

Property DepartmentCode As %String(%JSONFIELDNAME = "department_code", MAXLEN = 50);

Property DepartmentName As %String(%JSONFIELDNAME = "department_name", MAXLEN = 100);

Storage Default
{
<Data name="DocDepartmentState">
<Value name="1">
<Value>DepartmentCode</Value>
</Value>
<Value name="2">
<Value>DepartmentName</Value>
</Value>
</Data>
<State>DocDepartmentState</State>
<StreamLocation>^D1.Mock.Msg.DocDepartmentS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
