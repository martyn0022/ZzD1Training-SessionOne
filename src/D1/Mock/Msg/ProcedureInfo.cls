/// One procedure_info[] entry, new in V1.0.3 -- shared by GetVisit's response
/// and PostPreAuth's request.
Class D1.Mock.Msg.ProcedureInfo Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

/// e.g. "PROC001" -- sourced from MRProcedures.OPERCode
Property ProcedureCode As %String(%JSONFIELDNAME = "procedure_code", MAXLEN = 50);

/// e.g. "Appendectomy" -- sourced from MRProcedures.OPERDesc
Property ProcedureName As %String(%JSONFIELDNAME = "procedure_name", MAXLEN = 255);

Storage Default
{
<Data name="ProcedureInfoState">
<Value name="1">
<Value>ProcedureCode</Value>
</Value>
<Value name="2">
<Value>ProcedureName</Value>
</Value>
</Data>
<State>ProcedureInfoState</State>
<StreamLocation>^D1.Mock.Msg.ProcedureInfoS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
