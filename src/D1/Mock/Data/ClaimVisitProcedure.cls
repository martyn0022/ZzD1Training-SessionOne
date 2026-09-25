/// Group-2 visit_procedure table (NEW in data dictionary V1.0.2). Written by
/// PostPreAuth's snapshot (procedure_info[]); one row per procedure per visit.
/// No read API exists for it yet (plan open item 11).
Class D1.Mock.Data.ClaimVisitProcedure Extends %Persistent
{

Property VisitNumber As %String(MAXLEN = 50) [ Required ];

Index VisitIdx On VisitNumber;

Property ProcedureCode As %String(MAXLEN = 50);

Property ProcedureName As %String(MAXLEN = 255);

Property UpdateDate As %String(MAXLEN = 30);

Storage Default
{
<Data name="ClaimVisitProcedureDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>VisitNumber</Value>
</Value>
<Value name="3">
<Value>ProcedureCode</Value>
</Value>
<Value name="4">
<Value>ProcedureName</Value>
</Value>
<Value name="5">
<Value>UpdateDate</Value>
</Value>
</Data>
<DataLocation>^D1.Mock.Data.ClaimVisitP3EE0D</DataLocation>
<DefaultData>ClaimVisitProcedureDefaultData</DefaultData>
<IdLocation>^D1.Mock.Data.ClaimVisitP3EE0D</IdLocation>
<IndexLocation>^D1.Mock.Data.ClaimVisitP3EE0I</IndexLocation>
<StreamLocation>^D1.Mock.Data.ClaimVisitP3EE0S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
