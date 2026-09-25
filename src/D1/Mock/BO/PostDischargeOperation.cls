/// Persists an API_PostDischarge payload: writes ClaimDischarge + ClaimBilling
/// and snapshots ClaimPatient / ClaimAdmission / ClaimPolicy / ClaimDiagnosis,
/// without which the local read APIs would 404 for a claim IRIS just stored.
/// Also overwrites ClaimPreAuth.ClaimStatus with this same claim_status (see
/// SyncPreAuthStatus) -- the client wants that column to track the claim's
/// overall current status, not just its pre-auth stage.
/// 
/// source_info[] is URL-shaped here (not base64 like PostFiles), so those
/// references are logged rather than forced through the content-shaped
/// ClaimFile. See docs/PRODUCTION_FLOWS.md.
Class D1.Mock.BO.PostDischargeOperation Extends Ens.BusinessOperation
{

Parameter ADAPTER;

Parameter INVOCATION = "Queue";

Method Store(pRequest As D1.Mock.Msg.PostDischargeRequest, Output pResponse As D1.Mock.Msg.PostDischargeResponse) As %Status
{
	Set pResponse = ##class(D1.Mock.Msg.PostDischargeResponse).%New()
	Set tSC = $$$OK
	Try {
		Set tAdmissionNumber = pRequest.AdmissionInfo.AdmissionNumber
		Set tHospitalNumber = pRequest.ClaimPerson.HospitalNumber

		$$$THROWONERROR(tSC, ..StoreDischarge(pRequest, tHospitalNumber, tAdmissionNumber))
		$$$THROWONERROR(tSC, ..SyncPreAuthStatus(pRequest.ClaimStatus, tAdmissionNumber))
		$$$THROWONERROR(tSC, ..StoreBilling(pRequest, tHospitalNumber, tAdmissionNumber))
		$$$THROWONERROR(tSC, ..SnapshotPatient(pRequest, tHospitalNumber))
		$$$THROWONERROR(tSC, ..SnapshotAdmission(pRequest, tHospitalNumber, tAdmissionNumber))
		$$$THROWONERROR(tSC, ..SnapshotPolicy(pRequest, tHospitalNumber, tAdmissionNumber))
		$$$THROWONERROR(tSC, ..SnapshotDiagnoses(pRequest, tHospitalNumber, tAdmissionNumber))

		If pRequest.SourceInfo.Count() > 0 {
			$$$LOGINFO("Discharge " _ pRequest.ClaimId _ " carried " _ pRequest.SourceInfo.Count() _ " source_info URL reference(s); file CONTENT is stored via POST /d1/files instead")
		}

		$$$LOGINFO("Stored discharge " _ pRequest.ClaimId _ " for admission_number " _ tAdmissionNumber _ " (crud_status " _ pRequest.CrudStatus _ ")")
		Set pResponse.ResponseCode = "200"
		Set pResponse.ResponseMessage = "Success"
	}
	Catch ex {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

/// discharge_info: upsert keyed by the request's claim_id.
ClassMethod StoreDischarge(pRequest As D1.Mock.Msg.PostDischargeRequest, pHospitalNumber As %String, pAdmissionNumber As %String) As %Status [ Private ]
{
	Set tClaimId = pRequest.ClaimId, tId = ""
	&sql(SELECT ID INTO :tId FROM D1_Mock_Data.ClaimDischarge WHERE DischargeId = :tClaimId)
	Set tRow = $Select(SQLCODE = 0: ##class(D1.Mock.Data.ClaimDischarge).%OpenId(tId), 1: "")
	If '$IsObject(tRow) {
		Set tRow = ##class(D1.Mock.Data.ClaimDischarge).%New()
	}
	Set tRow.DischargeId = tClaimId
	Set tRow.HospitalNumber = pHospitalNumber
	Set tRow.AdmissionNumber = pAdmissionNumber

	// NOTHING on this row is derived. Every authorization_* field, the
	// guarantee letter and its date are the INSURER's decision and arrive via
	// API_PatchDischarge. IRIS used to fill them in -- authorization_amount
	// copied from insurance_payable, authorization_date copied from the
	// discharge date, then falling back to "now" -- which quietly published
	// figures D1 never sent. A discharge posted before the insurer replies
	// legitimately has all of them empty.
	//
	// discharge_status used to be generated ("Discharge Requested", the
	// spec's own enum for a posted, undecided claim) since PostDischarge had
	// no status field of its own. V1.0.6 added claim_status (Required) to
	// the request, so IRIS now stores exactly what D1 sends here too --
	// PatchDischarge still overwrites it later with the insurer's decision.
	Set tRow.DischargeStatus = pRequest.ClaimStatus
	Set tRow.DischargeDate = pRequest.AdmissionInfo.ActualDischargeDate
	Quit tRow.%Save()
}

/// The client wants ClaimPreAuth.ClaimStatus to track the claim's overall
/// current status, not just its pre-auth stage -- so once a discharge status
/// arrives, it overwrites the pre-auth row too. Not Private: PatchDischarge-
/// Operation calls this too, on the same rule. Find-only, not upsert: a
/// discharge with no preceding pre-auth row leaves ClaimPreAuth untouched
/// rather than fabricating one from fields PostDischarge doesn't carry.
ClassMethod SyncPreAuthStatus(pClaimStatus As %String, pAdmissionNumber As %String) As %Status
{
	Set tId = ""
	&sql(SELECT TOP 1 ID INTO :tId FROM D1_Mock_Data.ClaimPreAuth WHERE AdmissionNumber = :pAdmissionNumber ORDER BY ID DESC)
	Quit:SQLCODE'=0 $$$OK
	Set tRow = ##class(D1.Mock.Data.ClaimPreAuth).%OpenId(tId)
	Quit:'$IsObject(tRow) $$$OK
	Set tRow.ClaimStatus = pClaimStatus
	Quit tRow.%Save()
}

/// billing_info: upsert keyed by the same discharge id.
ClassMethod StoreBilling(pRequest As D1.Mock.Msg.PostDischargeRequest, pHospitalNumber As %String, pAdmissionNumber As %String) As %Status [ Private ]
{
	Set tClaimId = pRequest.ClaimId, tId = ""
	&sql(SELECT ID INTO :tId FROM D1_Mock_Data.ClaimBilling WHERE DischargeId = :tClaimId)
	Set tRow = $Select(SQLCODE = 0: ##class(D1.Mock.Data.ClaimBilling).%OpenId(tId), 1: "")
	If '$IsObject(tRow) {
		Set tRow = ##class(D1.Mock.Data.ClaimBilling).%New()
	}
	Set tRow.DischargeId = tClaimId
	Set tRow.HospitalNumber = pHospitalNumber
	Set tRow.AdmissionNumber = pAdmissionNumber
	Set tRow.Currency = pRequest.BillingInfo.Currency
	Set tRow.TotalCharge = pRequest.BillingInfo.TotalCharge
	Set tRow.DiscountAmount = pRequest.BillingInfo.DiscountAmount
	Set tRow.NetCharge = pRequest.BillingInfo.NetCharge
	Set tRow.PatientPayable = pRequest.BillingInfo.PatientPayable
	Set tRow.InsurancePayable = pRequest.BillingInfo.InsurancePayable
	Quit tRow.%Save()
}

/// patient_info snapshot: upsert keyed by hospital number.
ClassMethod SnapshotPatient(pRequest As D1.Mock.Msg.PostDischargeRequest, pHospitalNumber As %String) As %Status [ Private ]
{
	Quit:pHospitalNumber="" $$$OK
	Set tId = ""
	&sql(SELECT ID INTO :tId FROM D1_Mock_Data.ClaimPatient WHERE HospitalNumber = :pHospitalNumber)
	Set tRow = $Select(SQLCODE = 0: ##class(D1.Mock.Data.ClaimPatient).%OpenId(tId), 1: "")
	If '$IsObject(tRow) {
		Set tRow = ##class(D1.Mock.Data.ClaimPatient).%New()
	}
	Set tRow.HospitalNumber = pHospitalNumber
	// Sent dashed ("3-1258-00558-89-8"); stored plain to fit varchar(13).
	Set tRow.CitizenId = $Translate(pRequest.ClaimPerson.CitizenId, "-")
	Set tRow.PassportId = pRequest.ClaimPerson.PassportId
	Set tRow.Title = pRequest.ClaimPerson.Title
	Set tRow.FirstName = pRequest.ClaimPerson.FirstName
	Set tRow.LastName = pRequest.ClaimPerson.LastName
	Set tRow.Gender = pRequest.ClaimPerson.Gender
	Set tRow.BirthDate = pRequest.ClaimPerson.BirthDate
	Set tRow.Address = pRequest.ClaimPerson.Address
	Set tRow.PhoneNumber = pRequest.ClaimPerson.PhoneNumber
	Quit tRow.%Save()
}

/// admission_info snapshot: upsert keyed by admission number.
ClassMethod SnapshotAdmission(pRequest As D1.Mock.Msg.PostDischargeRequest, pHospitalNumber As %String, pAdmissionNumber As %String) As %Status [ Private ]
{
	Quit:pAdmissionNumber="" $$$OK
	Set tId = ""
	&sql(SELECT ID INTO :tId FROM D1_Mock_Data.ClaimAdmission WHERE AdmissionNumber = :pAdmissionNumber)
	Set tRow = $Select(SQLCODE = 0: ##class(D1.Mock.Data.ClaimAdmission).%OpenId(tId), 1: "")
	If '$IsObject(tRow) {
		Set tRow = ##class(D1.Mock.Data.ClaimAdmission).%New()
	}
	Set tRow.AdmissionNumber = pAdmissionNumber
	Set tRow.HospitalNumber = pHospitalNumber
	Set tRow.AdmissionDate = pRequest.AdmissionInfo.AdmissionDate
	Set tRow.WardNumber = pRequest.AdmissionInfo.WardNumber
	Set tRow.WardType = pRequest.AdmissionInfo.WardType
	Set tRow.RoomType = pRequest.AdmissionInfo.RoomType
	Set tRow.BedNo = pRequest.AdmissionInfo.BedNo
	Set tRow.ExpectedDischargeDate = pRequest.AdmissionInfo.ExpectedDischargeDate
	Set tRow.ActualDischargeDate = pRequest.AdmissionInfo.ActualDischargeDate
	Quit tRow.%Save()
}

/// policy_info snapshot: upsert keyed by admission number, including the
/// insurer block V1.0.3 added.
ClassMethod SnapshotPolicy(pRequest As D1.Mock.Msg.PostDischargeRequest, pHospitalNumber As %String, pAdmissionNumber As %String) As %Status [ Private ]
{
	Quit:pAdmissionNumber="" $$$OK
	Set tId = ""
	&sql(SELECT ID INTO :tId FROM D1_Mock_Data.ClaimPolicy WHERE AdmissionNumber = :pAdmissionNumber)
	Set tRow = $Select(SQLCODE = 0: ##class(D1.Mock.Data.ClaimPolicy).%OpenId(tId), 1: "")
	If '$IsObject(tRow) {
		Set tRow = ##class(D1.Mock.Data.ClaimPolicy).%New()
	}
	Set tRow.AdmissionNumber = pAdmissionNumber
	Set tRow.HospitalNumber = pHospitalNumber
	Set tRow.CompanyCode = pRequest.Insurer.CompanyCode
	Set tRow.CompanyName = pRequest.Insurer.CompanyName
	Set tRow.PolicyId = pRequest.PoliciesInfo.PolicyId
	Set tRow.PlanCode = pRequest.PoliciesInfo.PlanCode
	Set tRow.PlanName = pRequest.PoliciesInfo.PlanName
	Set tRow.PolicyNumber = pRequest.PoliciesInfo.PolicyNumber
	Quit tRow.%Save()
}

/// patient_diagnosis_info snapshot: replace this admission's rows wholesale,
/// so a diagnosis dropped from a resubmission does not survive.
ClassMethod SnapshotDiagnoses(pRequest As D1.Mock.Msg.PostDischargeRequest, pHospitalNumber As %String, pAdmissionNumber As %String) As %Status [ Private ]
{
	Quit:pAdmissionNumber="" $$$OK
	&sql(DELETE FROM D1_Mock_Data.ClaimDiagnosis WHERE AdmissionNumber = :pAdmissionNumber)
	If (SQLCODE < 0) {
		Quit $$$ERROR($$$GeneralError, "Could not clear diagnoses for " _ pAdmissionNumber _ ": SQLCODE " _ SQLCODE)
	}
	For i = 1:1:pRequest.DiagnosisInfo.Count() {
		Set tEntry = pRequest.DiagnosisInfo.GetAt(i)
		Set tRow = ##class(D1.Mock.Data.ClaimDiagnosis).%New()
		Set tRow.AdmissionNumber = pAdmissionNumber
		Set tRow.HospitalNumber = pHospitalNumber
		Set tRow.DiagnosisType = tEntry.DiagnosisType
		Set tRow.DiagnosisCode = tEntry.Code
		Set tRow.DiagnosisName = tEntry.Name
		Set tSaveSC = tRow.%Save()
		Return:$$$ISERR(tSaveSC) tSaveSC
	}
	Quit $$$OK
}

XData MessageMap
{
<MapItems>
  <MapItem MessageType="D1.Mock.Msg.PostDischargeRequest">
    <Method>Store</Method>
  </MapItem>
</MapItems>
}

}
