/// Request for API_GetDocumentInfo (V1.0.5).
Class D1.Mock.Msg.GetDocumentInfoRequest Extends (Ens.Request, %JSON.Adaptor)
{

Property AdmissionNumber As %String(%JSONFIELDNAME = "admission_number", MAXLEN = 50) [ Required ];

Property CompanyCode As %String(%JSONFIELDNAME = "company_code", MAXLEN = 50) [ Required ];

Storage Default
{
<Data name="GetDocumentInfoRequestDefaultData">
<Subscript>"GetDocumentInfoRequest"</Subscript>
<Value name="1">
<Value>AdmissionNumber</Value>
</Value>
<Value name="2">
<Value>CompanyCode</Value>
</Value>
</Data>
<DefaultData>GetDocumentInfoRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
