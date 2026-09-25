/// Request message for API_GetBilling V1.0.3 -- keyed by admission_number
/// directly, not identity_type.
Class D1.Mock.Msg.GetBillingRequest Extends (Ens.Request, %JSON.Adaptor)
{

/// e.g. "VN-2569-100245"
Property AdmissionNumber As %String(%JSONFIELDNAME = "admission_number", MAXLEN = 50) [ Required ];

Property HospitalCode As %String(%JSONFIELDNAME = "hospital_code", MAXLEN = 50);

Storage Default
{
<Data name="GetBillingRequestDefaultData">
<Subscript>"GetBillingRequest"</Subscript>
<Value name="1">
<Value>AdmissionNumber</Value>
</Value>
<Value name="2">
<Value>HospitalCode</Value>
</Value>
</Data>
<DefaultData>GetBillingRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
