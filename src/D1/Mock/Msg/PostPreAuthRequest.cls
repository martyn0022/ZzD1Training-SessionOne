/// Request message for API_PostPreAuth V1.0.3 (D1 Service -> IRIS).
/// 
/// Loaded straight off the wire in the REST dispatch class, so every
/// %JSONFIELDNAME matches the spec exactly -- including the camelCase
/// citizenId/passportId inside person (a flagged spec inconsistency,
/// reproduced as written).
/// 
/// V1.0.3 shape changes from the previously-built V1.0.1 form:
///   claim_person[] -> person (single object, + hospital_number/visit_number)
///   NEW complaint_info + procedure_info[] (echoed back from GetVisit)
///   diagnosis_info[] -> diagnosis[] (+ diagnosis_type)
///   policies_info[] (decision shape) -> policies (single object, plan shape)
///   NEW benefits[]
///   attending_physician[] -> attending_physician (single object)
///   admission_info[] -> admission (single object, more fields)
///   submitDate -> submit_date, NEW update_date, NEW top-level auth_id
/// 
/// Deliberately NO [ Required ] anywhere: a missing field must come back to
/// D1 as a 400 envelope from the business process, not as an Ensemble
/// message-save failure. Validation lives in PreAuthStoreProcess.Validate().
Class D1.Mock.Msg.PostPreAuthRequest Extends (Ens.Request, %JSON.Adaptor)
{

/// "0" - Insert, "1" - Update
Property CrudStatus As %String(%JSONFIELDNAME = "crud_status", MAXLEN = 1);

/// Authorization ID (case number) -- spec samples NULL on insert
Property AuthId As %String(%JSONFIELDNAME = "auth_id", MAXLEN = 50);

/// V1.0.6. "Waiting for Medical" / "Pre-Accepted" / "Rejected" /
/// "Pre-Authorize Submitted" -- IRIS used to generate this (always
/// "Pre-Authorize Submitted" on insert, untouched on update); D1 now sends
/// it directly on every request. See PreAuthStoreOperation.SnapshotPreAuth.
Property AuthStatus As %String(%JSONFIELDNAME = "auth_status", MAXLEN = 50);

Property HospitalCode As %String(%JSONFIELDNAME = "hospital_code", MAXLEN = 50);

/// person -- the patient the claim is for (single object)
Property Person As D1.Mock.Msg.PreAuthPerson(%JSONFIELDNAME = "person");

/// complaint_info -- chief complaint echoed from GetVisit
Property ComplaintInfo As D1.Mock.Msg.ComplaintInfo(%JSONFIELDNAME = "complaint_info");

/// procedure_info[] -- procedures echoed from GetVisit
Property ProcedureInfo As list Of D1.Mock.Msg.ProcedureInfo(%JSONFIELDNAME = "procedure_info");

/// diagnosis[] -- one entry per diagnosis, with type
Property Diagnosis As list Of D1.Mock.Msg.DiagnosisInfo(%JSONFIELDNAME = "diagnosis");

/// policies -- exactly ONE policy per pre-auth in V1.0.3 (single object)
/// V1.0.5. Splits two ways on write: the company half creates the
/// policy_info row every V1.0.5 API resolves company_code through; the
/// person half populates insurer_info. See D1.Mock.Msg.PreAuthInsurer.
Property Insurer As D1.Mock.Msg.PreAuthInsurer(%JSONFIELDNAME = "insurer");

Property Policies As D1.Mock.Msg.Policy(%JSONFIELDNAME = "policies");

/// benefits[] -- thin code+name references
Property Benefits As list Of D1.Mock.Msg.BenefitRef(%JSONFIELDNAME = "benefits");

/// attending_physician -- single object
Property AttendingPhysician As D1.Mock.Msg.Physician(%JSONFIELDNAME = "attending_physician");

/// admission -- room/ward/dates/cost estimate (single object)
Property Admission As D1.Mock.Msg.AdmissionInfo(%JSONFIELDNAME = "admission");

/// e.g. "2026-07-09 10:00:15"
Property SubmitDate As %String(%JSONFIELDNAME = "submit_date", MAXLEN = 30);

/// e.g. "2026-07-09 10:00:15"
Property UpdateDate As %String(%JSONFIELDNAME = "update_date", MAXLEN = 30);

Storage Default
{
<Data name="PostPreAuthRequestDefaultData">
<Subscript>"PostPreAuthRequest"</Subscript>
<Value name="1">
<Value>CrudStatus</Value>
</Value>
<Value name="2">
<Value>AuthId</Value>
</Value>
<Value name="3">
<Value>HospitalCode</Value>
</Value>
<Value name="4">
<Value>Person</Value>
</Value>
<Value name="5">
<Value>ComplaintInfo</Value>
</Value>
<Value name="6">
<Value>ProcedureInfo</Value>
</Value>
<Value name="7">
<Value>Diagnosis</Value>
</Value>
<Value name="8">
<Value>Insurer</Value>
</Value>
<Value name="9">
<Value>Policies</Value>
</Value>
<Value name="10">
<Value>Benefits</Value>
</Value>
<Value name="11">
<Value>AttendingPhysician</Value>
</Value>
<Value name="12">
<Value>Admission</Value>
</Value>
<Value name="13">
<Value>SubmitDate</Value>
</Value>
<Value name="14">
<Value>UpdateDate</Value>
</Value>
<Value name="15">
<Value>AuthStatus</Value>
</Value>
</Data>
<DefaultData>PostPreAuthRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
