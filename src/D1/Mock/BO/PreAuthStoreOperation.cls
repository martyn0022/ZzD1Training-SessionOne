/// Persists an API_PostPreAuth payload into PreAuthSubmission (raw archive),
/// then projects it into ClaimPreAuth / ClaimAdmission / ClaimVisit /
/// ClaimVisitProcedure / ClaimBenefit -- the only write path into
/// visit_info / visit_procedure in the whole spec.
/// 
/// Generated-field conventions and the array-joining rules are documented in
/// docs/PRODUCTION_FLOWS.md.
Class D1.Mock.BO.PreAuthStoreOperation Extends Ens.BusinessOperation
{

Parameter ADAPTER;

Parameter INVOCATION = "Queue";

/// Write the whole payload into one flat row: header + person + complaint +
/// procedures + diagnoses + policy + benefits + physician + admission.
Method Store(pRequest As D1.Mock.Msg.PostPreAuthRequest, Output pResponse As D1.Mock.Msg.PostPreAuthResponse) As %Status
{
	Set pResponse = ##class(D1.Mock.Msg.PostPreAuthResponse).%New()
	Set tSC = $$$OK
	Try {
		Set tAdmissionNumber = pRequest.Admission.AdmissionNumber

		// Reuse the row this admission already has, so an update overwrites
		// in place rather than tripping the unique index.
		If ##class(D1.Mock.Data.PreAuthSubmission).AdmissionExists(tAdmissionNumber, .tId) {
			Set tSub = ##class(D1.Mock.Data.PreAuthSubmission).%OpenId(tId, , .tOpenSC)
			$$$THROWONERROR(tSC, tOpenSC)
			If '$IsObject(tSub) {
				Set tSC = $$$ERROR($$$GeneralError, "Could not open existing submission row " _ tId)
				Quit
			}
		}
		Else {
			Set tSub = ##class(D1.Mock.Data.PreAuthSubmission).%New()
		}

		Set tSub.AdmissionNumber = tAdmissionNumber
		Set tSub.AuthId = pRequest.AuthId
		Set tSub.AuthStatus = pRequest.AuthStatus
		Set tSub.HospitalCode = pRequest.HospitalCode
		Set tSub.CrudStatus = pRequest.CrudStatus
		Set tSub.SubmitDate = pRequest.SubmitDate
		Set tSub.UpdateDate = pRequest.UpdateDate
		Set tSub.ReceivedAt = $ZDateTime($Horolog, 3)

		// person -- single object per V1.0.3, plain column assignment.
		Set tSub.PersonHospitalNumber = pRequest.Person.HospitalNumber
		Set tSub.PersonVisitNumber = pRequest.Person.VisitNumber
		// Sent dashed ("3-1258-00558-89-8"); stored plain to fit varchar(13).
		Set tSub.CitizenId = $Translate(pRequest.Person.CitizenId, "-")
		Set tSub.PassportId = pRequest.Person.PassportId
		Set tSub.ClaimTitle = pRequest.Person.Title
		Set tSub.ClaimFirstName = pRequest.Person.FirstName
		Set tSub.ClaimLastName = pRequest.Person.LastName
		Set tSub.ClaimGender = pRequest.Person.Gender
		Set tSub.ClaimBirthdate = pRequest.Person.Birthdate
		Set tSub.ClaimAge = pRequest.Person.Age

		// complaint_info -- single object.
		Set tSub.ChiefComplaint = pRequest.ComplaintInfo.ChiefComplaint

		// The three genuinely repeating arrays, joined in payload order.
		Set tSub.ProcedureCodes = ..Join(pRequest.ProcedureInfo, "ProcedureCode")
		Set tSub.ProcedureNames = ..Join(pRequest.ProcedureInfo, "ProcedureName")
		Set tSub.DiagnosisTypes = ..Join(pRequest.Diagnosis, "DiagnosisType")
		Set tSub.DiagnosisCodes = ..Join(pRequest.Diagnosis, "Code")
		Set tSub.DiagnosisNames = ..Join(pRequest.Diagnosis, "Name")
		Set tSub.BenefitCodes = ..Join(pRequest.Benefits, "BenefitCode")
		Set tSub.BenefitNames = ..Join(pRequest.Benefits, "BenefitName")

		// policies -- exactly one per pre-auth in V1.0.3, scalar columns.
		Set tSub.PolicyId = pRequest.Policies.PolicyId
		Set tSub.PlanCode = pRequest.Policies.PlanCode
		Set tSub.PlanName = pRequest.Policies.PlanName
		Set tSub.PolicyNumber = pRequest.Policies.PolicyNumber

		// attending_physician -- single object.
		Set tSub.PhysicianId = pRequest.AttendingPhysician.Id
		Set tSub.PhysicianTitle = pRequest.AttendingPhysician.Title
		Set tSub.PhysicianFirstName = pRequest.AttendingPhysician.FirstName
		Set tSub.PhysicianLastName = pRequest.AttendingPhysician.LastName
		Set tSub.MedicalLicenseNo = pRequest.AttendingPhysician.LicenseNo

		// admission -- single object.
		Set tSub.WardNumber = pRequest.Admission.WardNumber
		Set tSub.WardType = pRequest.Admission.WardType
		Set tSub.RoomType = pRequest.Admission.RoomType
		Set tSub.BedNo = pRequest.Admission.BedNo
		Set tSub.EstimatedAdmissionDate = pRequest.Admission.EstimatedAdmissionDate
		Set tSub.EstimatedLengthOfStay = pRequest.Admission.EstimatedLengthOfStay
		// Quoted on the wire, and may carry thousands separators.
		Set tSub.EstimatedCost = $Select(pRequest.Admission.EstimatedCost = "": "", 1: +$Translate(pRequest.Admission.EstimatedCost, ", "))

		$$$THROWONERROR(tSC, tSub.%Save())

		// Project into the group-2 tables the local reads serve.
		$$$THROWONERROR(tSC, ..SnapshotPatient(pRequest))
		$$$THROWONERROR(tSC, ..SnapshotPreAuth(pRequest, tAdmissionNumber))
		$$$THROWONERROR(tSC, ..SnapshotAdmission(pRequest, tAdmissionNumber))
		$$$THROWONERROR(tSC, ..SnapshotVisit(pRequest))
		$$$THROWONERROR(tSC, ..SnapshotChiefComplaint(pRequest, tAdmissionNumber))
		$$$THROWONERROR(tSC, ..SnapshotPolicy(pRequest, tAdmissionNumber))
		$$$THROWONERROR(tSC, ..SnapshotInsurer(pRequest))
		$$$THROWONERROR(tSC, ..SnapshotBenefits(pRequest))

		$$$LOGINFO("Stored pre-auth submission for admission_number " _ tAdmissionNumber _ " (crud_status " _ pRequest.CrudStatus _ "): " _ pRequest.Diagnosis.Count() _ " diagnosis(es), " _ pRequest.ProcedureInfo.Count() _ " procedure(s), " _ pRequest.Benefits.Count() _ " benefit(s)")

		Set pResponse.ResponseCode = "200"
		Set pResponse.ResponseMessage = "Success"
	}
	Catch ex {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

/// patient_info snapshot, upsert by hospital number -- so D1GetPatient (and
/// any HN/CID/PID identity resolution) finds the patient right after
/// PostPreAuth, without waiting for a PostDischarge that may never come.
/// 
/// person carries no address/phone (PostDischarge's claim_person does), so
/// those are left untouched rather than blanked on an update.
ClassMethod SnapshotPatient(pRequest As D1.Mock.Msg.PostPreAuthRequest) As %Status [ Private ]
{
	Set tHospitalNumber = pRequest.Person.HospitalNumber
	Quit:tHospitalNumber="" $$$OK

	Set tId = ""
	&sql(SELECT ID INTO :tId FROM D1_Mock_Data.ClaimPatient WHERE HospitalNumber = :tHospitalNumber)
	Set tRow = $Select(SQLCODE = 0: ##class(D1.Mock.Data.ClaimPatient).%OpenId(tId), 1: "")
	If '$IsObject(tRow) {
		Set tRow = ##class(D1.Mock.Data.ClaimPatient).%New()
	}
	Set tRow.HospitalNumber = tHospitalNumber
	// Sent dashed ("3-1258-00558-89-8"); stored plain to fit varchar(13).
	Set tRow.CitizenId = $Translate(pRequest.Person.CitizenId, "-")
	Set tRow.PassportId = pRequest.Person.PassportId
	Set tRow.Title = pRequest.Person.Title
	Set tRow.FirstName = pRequest.Person.FirstName
	Set tRow.LastName = pRequest.Person.LastName
	Set tRow.Gender = pRequest.Person.Gender
	Set tRow.BirthDate = pRequest.Person.Birthdate
	Quit tRow.%Save()
}

/// patient_chiefcomplain_info snapshot (dictionary V1.0.3), upsert by
/// admission. Read by GetDocumentInfo.
/// 
/// This value is ALSO written to ClaimVisit.ChiefComplaint by SnapshotVisit.
/// Both are fed from the same request field in the same call, so they cannot
/// drift. The ClaimVisit copy is the redundant one and is the one to remove
/// once the dictionary drops chief_complaint from visit_info.
ClassMethod SnapshotChiefComplaint(pRequest As D1.Mock.Msg.PostPreAuthRequest, pAdmissionNumber As %String) As %Status [ Private ]
{
	Quit:pAdmissionNumber="" $$$OK
	Set tId = ""
	&sql(SELECT ID INTO :tId FROM D1_Mock_Data.ClaimChiefComplaint WHERE AdmissionNumber = :pAdmissionNumber)
	Set tRow = $Select(SQLCODE = 0: ##class(D1.Mock.Data.ClaimChiefComplaint).%OpenId(tId), 1: "")
	If '$IsObject(tRow) {
		Set tRow = ##class(D1.Mock.Data.ClaimChiefComplaint).%New()
	}
	Set tRow.AdmissionNumber = pAdmissionNumber
	Set tRow.HospitalNumber = pRequest.Person.HospitalNumber
	Set tRow.ChiefComplaint = pRequest.ComplaintInfo.ChiefComplaint
	Quit tRow.%Save()
}

/// policy_info snapshot, upsert by admission (the dictionary's PK).
/// 
/// LOAD-BEARING: company_code lives only on this table, and PatchPreAuth,
/// PatchDischarge, GetRecordList and GetDocumentInfo all resolve it through
/// here. Without this row the admission is invisible to every one of them.
/// PostPreAuth could not write it before V1.0.5, because the request had no
/// company_code -- that is what the new insurer block supplies.
ClassMethod SnapshotPolicy(pRequest As D1.Mock.Msg.PostPreAuthRequest, pAdmissionNumber As %String) As %Status [ Private ]
{
	Quit:pAdmissionNumber="" $$$OK
	// No insurer block means no company_code, so a policy row would be
	// unusable -- skip rather than write one that fails every tenancy check.
	Quit:pRequest.Insurer.CompanyCode="" $$$OK

	Set tId = ""
	&sql(SELECT ID INTO :tId FROM D1_Mock_Data.ClaimPolicy WHERE AdmissionNumber = :pAdmissionNumber)
	Set tRow = $Select(SQLCODE = 0: ##class(D1.Mock.Data.ClaimPolicy).%OpenId(tId), 1: "")
	If '$IsObject(tRow) {
		Set tRow = ##class(D1.Mock.Data.ClaimPolicy).%New()
	}
	Set tRow.AdmissionNumber = pAdmissionNumber
	Set tRow.HospitalNumber = pRequest.Person.HospitalNumber
	Set tRow.CompanyCode = pRequest.Insurer.CompanyCode
	Set tRow.CompanyName = pRequest.Insurer.CompanyName
	Set tRow.PolicyId = pRequest.Policies.PolicyId
	Set tRow.PlanCode = pRequest.Policies.PlanCode
	Set tRow.PlanName = pRequest.Policies.PlanName
	Set tRow.PolicyNumber = pRequest.Policies.PolicyNumber
	Set tRow.InsurerId = pRequest.Insurer.InsurerId
	Quit tRow.%Save()
}

/// insurer_info snapshot, upsert by insurer_id -- the INSURED PERSON, not
/// the company. See D1.Mock.Data.ClaimInsurer on the naming.
/// 
/// The request carries only id/title/first/last, so gender, birth_date,
/// address and phone stay empty here. The dictionary marks gender and
/// birth_date Not NULL; PostPreAuth has no way to supply them. Flagged.
ClassMethod SnapshotInsurer(pRequest As D1.Mock.Msg.PostPreAuthRequest) As %Status [ Private ]
{
	Set tInsurerId = pRequest.Insurer.InsurerId
	Quit:tInsurerId="" $$$OK

	Set tId = ""
	&sql(SELECT ID INTO :tId FROM D1_Mock_Data.ClaimInsurer WHERE InsurerId = :tInsurerId)
	Set tRow = $Select(SQLCODE = 0: ##class(D1.Mock.Data.ClaimInsurer).%OpenId(tId), 1: "")
	If '$IsObject(tRow) {
		Set tRow = ##class(D1.Mock.Data.ClaimInsurer).%New()
	}
	Set tRow.InsurerId = tInsurerId
	Set tRow.Title = pRequest.Insurer.Title
	Set tRow.FirstName = pRequest.Insurer.FirstName
	Set tRow.LastName = pRequest.Insurer.LastName
	// Seeded rows carry the rest; do not blank them on a re-submission.
	// Sent dashed ("3-1258-00558-89-8"); stored plain to fit varchar(13).
	Set:tRow.CitizenId="" tRow.CitizenId = $Translate(pRequest.Person.CitizenId, "-")
	Set:tRow.PassportId="" tRow.PassportId = pRequest.Person.PassportId
	Quit tRow.%Save()
}

/// preauth_info snapshot: upsert keyed by the generated claim id.
/// 
/// claim_id has NO source in the request body, so IRIS generates it by an
/// explicit convention: auth_id when D1 sent one, else
/// "REQ-"_admission_number.
/// 
/// claim_case_number ALSO has no source in this request -- but unlike
/// claim_id, IRIS does NOT invent one. It stays whatever it already was (or
/// empty, on a fresh insert) until PatchPreAuth's own optional
/// claim_case_number field supplies the real value. A prior "CASE-"+claim_id
/// convention here was wrong: the spec's own sample ("PA-2026-071122") is
/// nothing like that shape, confirming it is a real, externally-known case
/// number, not something to synthesize.
/// 
/// claim_status is no longer generated either: V1.0.6 added auth_status
/// (Required) to the request, so IRIS stores exactly what D1 sends, on
/// insert and update alike.
ClassMethod SnapshotPreAuth(pRequest As D1.Mock.Msg.PostPreAuthRequest, pAdmissionNumber As %String) As %Status [ Private ]
{
	Quit:pAdmissionNumber="" $$$OK
	Set tClaimId = $Select(pRequest.AuthId '= "": pRequest.AuthId, 1: "REQ-" _ pAdmissionNumber)
	Set tId = ""
	&sql(SELECT ID INTO :tId FROM D1_Mock_Data.ClaimPreAuth WHERE ClaimId = :tClaimId)
	Set tRow = $Select(SQLCODE = 0: ##class(D1.Mock.Data.ClaimPreAuth).%OpenId(tId), 1: "")
	If '$IsObject(tRow) {
		Set tRow = ##class(D1.Mock.Data.ClaimPreAuth).%New()
	}
	Set tRow.ClaimId = tClaimId
	Set tRow.HospitalNumber = pRequest.Person.HospitalNumber
	Set tRow.AdmissionNumber = pAdmissionNumber
	Set tRow.ClaimStatus = pRequest.AuthStatus
	Set tRow.SubmitDate = pRequest.SubmitDate
	Set tRow.EstimatedCost = $Select(pRequest.Admission.EstimatedCost = "": "", 1: +$Translate(pRequest.Admission.EstimatedCost, ", "))
	Quit tRow.%Save()
}

/// benefit_info snapshot, upsert by (policy_number, benefit_code) -- so
/// D1GetBenefit finds a benefit the moment a pre-auth references it, rather
/// than only whatever ClaimLoader happened to seed in advance.
/// 
/// benefits[] on this request is a thin code+name reference only -- no
/// status or amounts (those are the insurer's decision, not something the
/// hospital's pre-auth submission carries). A brand-new benefit_key is
/// therefore created with BenefitStatus/MaximumAmount/RemainingAmount left
/// empty; an existing row (e.g. one ClaimLoader seeded) keeps whatever
/// values it already has, since those columns are never touched here.
ClassMethod SnapshotBenefits(pRequest As D1.Mock.Msg.PostPreAuthRequest) As %Status [ Private ]
{
	Set tPolicyNumber = pRequest.Policies.PolicyNumber
	Quit:tPolicyNumber="" $$$OK
	For i = 1:1:pRequest.Benefits.Count() {
		Set tEntry = pRequest.Benefits.GetAt(i)
		Continue:tEntry.BenefitCode=""
		Set tKey = tPolicyNumber _ ":" _ tEntry.BenefitCode
		Set tId = ""
		&sql(SELECT ID INTO :tId FROM D1_Mock_Data.ClaimBenefit WHERE BenefitKey = :tKey)
		Set tRow = $Select(SQLCODE = 0: ##class(D1.Mock.Data.ClaimBenefit).%OpenId(tId), 1: "")
		If '$IsObject(tRow) {
			Set tRow = ##class(D1.Mock.Data.ClaimBenefit).%New()
			Set tRow.BenefitKey = tKey
		}
		Set tRow.PolicyNumber = tPolicyNumber
		Set tRow.BenefitCode = tEntry.BenefitCode
		Set tRow.BenefitName = tEntry.BenefitName
		Set tSaveSC = tRow.%Save()
		Return:$$$ISERR(tSaveSC) tSaveSC
	}
	Quit $$$OK
}

/// admission_info snapshot, upsert by admission number -- so D1GetAdmission
/// finds the admission right after PostPreAuth, without waiting for the
/// PostDischarge that populates it today (and may never come).
/// 
/// AdmissionDate is set from estimated_admission_date, the only admission
/// date PostPreAuth carries; PostDischarge overwrites it with the actual
/// date once the stay is over. ExpectedDischargeDate/ActualDischargeDate
/// are PostDischarge-only fields and are left untouched here.
ClassMethod SnapshotAdmission(pRequest As D1.Mock.Msg.PostPreAuthRequest, pAdmissionNumber As %String) As %Status [ Private ]
{
	Quit:pAdmissionNumber="" $$$OK
	Set tId = ""
	&sql(SELECT ID INTO :tId FROM D1_Mock_Data.ClaimAdmission WHERE AdmissionNumber = :pAdmissionNumber)
	Set tRow = $Select(SQLCODE = 0: ##class(D1.Mock.Data.ClaimAdmission).%OpenId(tId), 1: "")
	If '$IsObject(tRow) {
		Set tRow = ##class(D1.Mock.Data.ClaimAdmission).%New()
	}
	Set tRow.AdmissionNumber = pAdmissionNumber
	Set tRow.HospitalNumber = pRequest.Person.HospitalNumber
	Set tRow.AdmissionDate = pRequest.Admission.EstimatedAdmissionDate
	Set tRow.WardNumber = pRequest.Admission.WardNumber
	Set tRow.WardType = pRequest.Admission.WardType
	Set tRow.RoomType = pRequest.Admission.RoomType
	Set tRow.BedNo = pRequest.Admission.BedNo
	Set tRow.EstimatedLengthOfStay = pRequest.Admission.EstimatedLengthOfStay
	// Quoted on the wire, and may carry thousands separators.
	Set tRow.EstimatedCost = $Select(pRequest.Admission.EstimatedCost = "": "", 1: +$Translate(pRequest.Admission.EstimatedCost, ", "))
	Quit tRow.%Save()
}

/// visit_info + visit_procedure snapshot: upsert the visit, then replace its
/// procedure rows wholesale so a procedure dropped from a resubmission does
/// not survive.
ClassMethod SnapshotVisit(pRequest As D1.Mock.Msg.PostPreAuthRequest) As %Status [ Private ]
{
	Set tVisitNumber = pRequest.Person.VisitNumber
	Quit:tVisitNumber="" $$$OK

	Set tId = ""
	&sql(SELECT ID INTO :tId FROM D1_Mock_Data.ClaimVisit WHERE VisitNumber = :tVisitNumber)
	Set tVisit = $Select(SQLCODE = 0: ##class(D1.Mock.Data.ClaimVisit).%OpenId(tId), 1: "")
	If '$IsObject(tVisit) {
		Set tVisit = ##class(D1.Mock.Data.ClaimVisit).%New()
	}
	Set tVisit.VisitNumber = tVisitNumber
	Set tVisit.HospitalNumber = pRequest.Person.HospitalNumber
	Set tVisit.ChiefComplaint = pRequest.ComplaintInfo.ChiefComplaint
	Set tVisit.UpdateDate = pRequest.UpdateDate
	// visit_date / visit_type / department_* are not in this payload.
	Set tSC = tVisit.%Save()
	Quit:$$$ISERR(tSC) tSC

	&sql(DELETE FROM D1_Mock_Data.ClaimVisitProcedure WHERE VisitNumber = :tVisitNumber)
	If SQLCODE < 0 {
		Quit $$$ERROR($$$GeneralError, "Could not clear procedures for visit " _ tVisitNumber _ ": SQLCODE " _ SQLCODE)
	}
	For i = 1:1:pRequest.ProcedureInfo.Count() {
		Set tEntry = pRequest.ProcedureInfo.GetAt(i)
		Set tProc = ##class(D1.Mock.Data.ClaimVisitProcedure).%New()
		Set tProc.VisitNumber = tVisitNumber
		Set tProc.ProcedureCode = tEntry.ProcedureCode
		Set tProc.ProcedureName = tEntry.ProcedureName
		Set tProc.UpdateDate = pRequest.UpdateDate
		Set tSaveSC = tProc.%Save()
		Return:$$$ISERR(tSaveSC) tSaveSC
	}
	Quit $$$OK
}

/// Join one property across every entry of a payload list, in payload order,
/// using the table's delimiter. A single-entry list gives back the plain value.
ClassMethod Join(pList As %Collection.AbstractList, pProperty As %String) As %String [ Private ]
{
	Set tOut = ""
	For i = 1:1:pList.Count() {
		Set tOut = tOut _ $Select(i = 1: "", 1: ##class(D1.Mock.Data.PreAuthSubmission).#DELIMITER) _ $Property(pList.GetAt(i), pProperty)
	}
	Quit tOut
}

XData MessageMap
{
<MapItems>
  <MapItem MessageType="D1.Mock.Msg.PostPreAuthRequest">
    <Method>Store</Method>
  </MapItem>
</MapItems>
}

}
