/// Request to the HIS for the patient bill rows behind one admission.
/// The HIS operation resolves the admission number to a PatientID first
/// (the real ARPatientBillAll resource has no admission-number parameter),
/// fetches GET /ARPatientBillAll?PatientID=&Hospital=, and filters the rows
/// on EpisodeID in code.
Class D1.Mock.Msg.HIS.BillingRequest Extends Ens.Request
{

/// Admission number, e.g. "VN-2569-100245"
Property AdmissionNumber As %String(MAXLEN = 50) [ Required ];

/// Hospital code filter, e.g. "RAMA9" (optional)
Property Hospital As %String(MAXLEN = 50);

Storage Default
{
<Data name="BillingRequestDefaultData">
<Subscript>"BillingRequest"</Subscript>
<Value name="1">
<Value>AdmissionNumber</Value>
</Value>
<Value name="2">
<Value>Hospital</Value>
</Value>
</Data>
<DefaultData>BillingRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
