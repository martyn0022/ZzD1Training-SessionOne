/// Request for API_GetRecordList (V1.0.5): the insurer's worklist of records
/// still awaiting a decision.
Class D1.Mock.Msg.GetRecordListRequest Extends (Ens.Request, %JSON.Adaptor)
{

/// "Pre-Auth", "Discharge", or "All" (V1.0.8)
Property ListMode As %String(%JSONFIELDNAME = "list_mode", MAXLEN = 20) [ Required ];

Property CompanyCode As %String(%JSONFIELDNAME = "company_code", MAXLEN = 50) [ Required ];

Storage Default
{
<Data name="GetRecordListRequestDefaultData">
<Subscript>"GetRecordListRequest"</Subscript>
<Value name="1">
<Value>ListMode</Value>
</Value>
<Value name="2">
<Value>CompanyCode</Value>
</Value>
</Data>
<DefaultData>GetRecordListRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
