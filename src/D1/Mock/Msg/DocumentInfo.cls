/// document_info -- API_GetDocumentInfo's aggregate, spanning eleven blocks
/// assembled from ClaimPatient, ClaimPreAuth, ClaimChiefComplaint,
/// ClaimVisitProcedure, ClaimDiagnosis, ClaimVisit, ClaimPolicy,
/// ClaimInsurer, ClaimBilling and ClaimDischarge.
/// 
/// The widest read in the production: one call, ten tables. Every block is
/// optional in practice -- a claim still at pre-auth stage has no billing or
/// authorization yet, and %JSON.Adaptor omits what is unset.
Class D1.Mock.Msg.DocumentInfo Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

Property Hospital As D1.Mock.Msg.DocHospital(%JSONFIELDNAME = "hospital");

Property Person As D1.Mock.Msg.DocPerson(%JSONFIELDNAME = "person");

Property ComplaintInfo As D1.Mock.Msg.ComplaintInfo(%JSONFIELDNAME = "complaint_info");

Property ProcedureInfo As list Of D1.Mock.Msg.ProcedureInfo(%JSONFIELDNAME = "procedure_info");

Property DiagnosisInfo As list Of D1.Mock.Msg.DiagnosisInfo(%JSONFIELDNAME = "diagnosis_info");

Property Department As D1.Mock.Msg.DocDepartment(%JSONFIELDNAME = "department");

/// medical_license_no is left unset -- this sheet does not list it, and an
/// unset property is omitted from the JSON.
Property AttendingPhysician As D1.Mock.Msg.Physician(%JSONFIELDNAME = "attending_physician");

/// Same shape as PostPreAuth's insurer block: company fields from
/// ClaimPolicy, person fields from ClaimInsurer.
Property Insurer As D1.Mock.Msg.PreAuthInsurer(%JSONFIELDNAME = "insurer");

Property PoliciesInfo As D1.Mock.Msg.DischargePolicyInfo(%JSONFIELDNAME = "policies_info");

Property BillingInfo As D1.Mock.Msg.BillingInfo(%JSONFIELDNAME = "billing_info");

Property Authorization As D1.Mock.Msg.DocAuthorization(%JSONFIELDNAME = "authorization");

Storage Default
{
<Data name="DocumentInfoState">
<Value name="1">
<Value>Hospital</Value>
</Value>
<Value name="2">
<Value>Person</Value>
</Value>
<Value name="3">
<Value>ComplaintInfo</Value>
</Value>
<Value name="4">
<Value>ProcedureInfo</Value>
</Value>
<Value name="5">
<Value>DiagnosisInfo</Value>
</Value>
<Value name="6">
<Value>Department</Value>
</Value>
<Value name="7">
<Value>AttendingPhysician</Value>
</Value>
<Value name="8">
<Value>Insurer</Value>
</Value>
<Value name="9">
<Value>PoliciesInfo</Value>
</Value>
<Value name="10">
<Value>BillingInfo</Value>
</Value>
<Value name="11">
<Value>Authorization</Value>
</Value>
</Data>
<State>DocumentInfoState</State>
<StreamLocation>^D1.Mock.Msg.DocumentInfoS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
