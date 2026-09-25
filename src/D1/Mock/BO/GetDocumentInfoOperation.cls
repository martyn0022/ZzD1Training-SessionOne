/// Business Operation for API_GetDocumentInfo (V1.0.5): one call assembling
/// the whole claim document from ten of IRIS's own tables.
/// 
/// The widest read in the production. Every block is filled independently, so
/// a claim still at pre-auth stage returns what exists and omits the rest --
/// %JSON.Adaptor drops unset properties, so absent blocks simply do not
/// appear rather than arriving empty.
/// 
/// Nothing here is synthesised. The authorization block stays empty until
/// API_PatchDischarge supplies the insurer's decision.
Class D1.Mock.BO.GetDocumentInfoOperation Extends Ens.BusinessOperation
{

Parameter ADAPTER;

Parameter INVOCATION = "Queue";

Method GetDocumentInfo(pRequest As D1.Mock.Msg.GetDocumentInfoRequest, Output pResponse As D1.Mock.Msg.GetDocumentInfoResponse) As %Status
{
	Set pResponse = ##class(D1.Mock.Msg.GetDocumentInfoResponse).%New()
	Set tSC = $$$OK
	Try {
		Set tCode = ##class(D1.Mock.Util.ClaimCompanyResolver).Check(pRequest.AdmissionNumber, pRequest.CompanyCode, .tMsg)
		If tCode '= "200" {
			Set pResponse.ResponseCode = tCode, pResponse.ResponseMessage = tMsg
			Quit
		}

		Set tAdm = pRequest.AdmissionNumber
		Set tDoc = pResponse.DocumentInfo

		// Every host variable is initialised before its SELECT: an &sql that
		// finds nothing leaves its INTO targets untouched, so a later read of
		// one would be <UNDEFINED> rather than empty.
		Set tHospitalNumber = "", tCid = "", tVisitNo = ""

		// --- policy + insurer company (the row the tenancy check just passed)
		Set tInsurerId = ""
		&sql(SELECT HospitalNumber, CompanyCode, CompanyName, PolicyId, PlanCode, PlanName, PolicyNumber, InsurerId
			 INTO :tHospitalNumber, :tCompCode, :tCompName, :tPolicyId, :tPlanCode, :tPlanName, :tPolicyNo, :tInsurerId
			 FROM D1_Mock_Data.ClaimPolicy WHERE AdmissionNumber = :tAdm)
		If SQLCODE = 0 {
			Set tDoc.Insurer.CompanyCode = tCompCode, tDoc.Insurer.CompanyName = tCompName
			Set tDoc.PoliciesInfo.PolicyId = tPolicyId, tDoc.PoliciesInfo.PlanCode = tPlanCode
			Set tDoc.PoliciesInfo.PlanName = tPlanName, tDoc.PoliciesInfo.PolicyNumber = tPolicyNo
		}

		// --- patient identity
		If tHospitalNumber '= "" {
			Set tDoc.Person.HospitalNumber = tHospitalNumber
			&sql(SELECT CitizenId, PassportId, Title, FirstName, LastName, Gender, BirthDate
				 INTO :tCid, :tPid, :tTitle, :tFirst, :tLast, :tGender, :tDob
				 FROM D1_Mock_Data.ClaimPatient WHERE HospitalNumber = :tHospitalNumber)
			Set:SQLCODE'=0 tCid = ""
			If SQLCODE = 0 {
				Set tDoc.Person.CitizenId = tCid, tDoc.Person.PassportId = tPid
				Set tDoc.Person.Title = tTitle, tDoc.Person.FirstName = tFirst
				Set tDoc.Person.LastName = tLast, tDoc.Person.Gender = tGender
				Set tDoc.Person.BirthDate = tDob
			}
		}

		// --- claim identifiers live on preauth_info, not on the patient
		&sql(SELECT ClaimId, ClaimCaseNumber INTO :tClaimId, :tCaseNo
			 FROM D1_Mock_Data.ClaimPreAuth WHERE AdmissionNumber = :tAdm)
		If SQLCODE = 0 {
			Set tDoc.Person.ClaimId = tClaimId, tDoc.Person.ClaimCaseNumber = tCaseNo
		}

		// --- insured PERSON (insurer_info), by the insurer_id D1 supplied with
		// the pre-auth. Not inferred: the dictionary provides no link between
		// insurer_info and an admission, and guessing one (matching the policy
		// holder to the patient on citizen_id) is wrong for a dependant's
		// policy. D1 knows the answer and sends it; IRIS stores and returns it.
		If tInsurerId '= "" {
			Set tDoc.Insurer.InsurerId = tInsurerId
			&sql(SELECT Title, FirstName, LastName INTO :tInsTitle, :tInsFirst, :tInsLast
				 FROM D1_Mock_Data.ClaimInsurer WHERE InsurerId = :tInsurerId)
			If SQLCODE = 0 {
				Set tDoc.Insurer.Title = tInsTitle
				Set tDoc.Insurer.FirstName = tInsFirst, tDoc.Insurer.LastName = tInsLast
			}
		}

		// --- chief complaint: the V1.0.3 table, keyed by admission
		&sql(SELECT ChiefComplaint INTO :tComplaint FROM D1_Mock_Data.ClaimChiefComplaint WHERE AdmissionNumber = :tAdm)
		Set:SQLCODE=0 tDoc.ComplaintInfo.ChiefComplaint = tComplaint

		// --- visit supplies hospital code and department
		&sql(SELECT VisitNumber, DepartmentCode, DepartmentName INTO :tVisitNo, :tDepCode, :tDepName
			 FROM D1_Mock_Data.ClaimVisit WHERE HospitalNumber = :tHospitalNumber)
		Set:SQLCODE'=0 tVisitNo = ""
		If SQLCODE = 0 {
			Set tDoc.Department.DepartmentCode = tDepCode, tDoc.Department.DepartmentName = tDepName
		}

		$$$THROWONERROR(tSC, ..FillProcedures(tVisitNo, tDoc))
		$$$THROWONERROR(tSC, ..FillDiagnoses(tAdm, tDoc))

		// --- billing + the insurer's decision, both keyed by discharge
		&sql(SELECT Currency, TotalCharge, DiscountAmount, NetCharge, PatientPayable, InsurancePayable
			 INTO :tCur, :tTotal, :tDisc, :tNet, :tPatPay, :tInsPay
			 FROM D1_Mock_Data.ClaimBilling WHERE AdmissionNumber = :tAdm)
		If SQLCODE = 0 {
			Set tDoc.BillingInfo.Currency = tCur, tDoc.BillingInfo.TotalCharge = tTotal
			Set tDoc.BillingInfo.DiscountAmount = tDisc, tDoc.BillingInfo.NetCharge = tNet
			Set tDoc.BillingInfo.PatientPayable = tPatPay, tDoc.BillingInfo.InsurancePayable = tInsPay
		}

		// Most recent, for the same reason PatchDischarge does: an admission can
		// hold several discharge rows and this call is keyed on the admission.
		&sql(SELECT TOP 1 GlNumber, DischargeGlDate, AuthorizationDate, AuthorizationAmount,
					AuthorizationTitle, AuthorizationFirstName, AuthorizationLastName
			 INTO :tGl, :tGlDate, :tAuthDate, :tAuthAmt, :tAuthTitle, :tAuthFirst, :tAuthLast
			 FROM D1_Mock_Data.ClaimDischarge WHERE AdmissionNumber = :tAdm ORDER BY ID DESC)
		If SQLCODE = 0 {
			Set tDoc.Authorization.DischargeGlNumber = tGl, tDoc.Authorization.DischargeGlDate = tGlDate
			Set tDoc.Authorization.AuthorizationDate = tAuthDate
			Set tDoc.Authorization.AuthorizationAmount = tAuthAmt
			Set tDoc.Authorization.AuthorizationTitle = tAuthTitle
			Set tDoc.Authorization.AuthorizationFirstName = tAuthFirst
			Set tDoc.Authorization.AuthorizationLastName = tAuthLast
		}

		Set pResponse.ResponseCode = "200"
		Set pResponse.ResponseMessage = "Success"
	}
	Catch ex {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

/// procedure_info[] from visit_procedure, keyed by visit.
ClassMethod FillProcedures(pVisitNumber As %String, pDoc As D1.Mock.Msg.DocumentInfo) As %Status [ Private ]
{
	Quit:pVisitNumber="" $$$OK
	Set tStmt = ##class(%SQL.Statement).%New()
	Set tSC = tStmt.%Prepare("SELECT ProcedureCode, ProcedureName FROM D1_Mock_Data.ClaimVisitProcedure WHERE VisitNumber = ?")
	Quit:$$$ISERR(tSC) tSC
	Set tRs = tStmt.%Execute(pVisitNumber)
	While tRs.%Next() {
		Set tItem = ##class(D1.Mock.Msg.ProcedureInfo).%New()
		Set tItem.ProcedureCode = tRs.%Get("ProcedureCode")
		Set tItem.ProcedureName = tRs.%Get("ProcedureName")
		Do pDoc.ProcedureInfo.Insert(tItem)
	}
	Quit $$$OK
}

/// diagnosis_info[] from patient_diagnosis_info, keyed by admission.
ClassMethod FillDiagnoses(pAdmissionNumber As %String, pDoc As D1.Mock.Msg.DocumentInfo) As %Status [ Private ]
{
	Set tStmt = ##class(%SQL.Statement).%New()
	Set tSC = tStmt.%Prepare("SELECT DiagnosisType, DiagnosisCode, DiagnosisName FROM D1_Mock_Data.ClaimDiagnosis WHERE AdmissionNumber = ?")
	Quit:$$$ISERR(tSC) tSC
	Set tRs = tStmt.%Execute(pAdmissionNumber)
	While tRs.%Next() {
		Set tItem = ##class(D1.Mock.Msg.DiagnosisInfo).%New()
		Set tItem.DiagnosisType = tRs.%Get("DiagnosisType")
		Set tItem.Code = tRs.%Get("DiagnosisCode")
		Set tItem.Name = tRs.%Get("DiagnosisName")
		Do pDoc.DiagnosisInfo.Insert(tItem)
	}
	Quit $$$OK
}

XData MessageMap
{
<MapItems>
  <MapItem MessageType="D1.Mock.Msg.GetDocumentInfoRequest">
    <Method>GetDocumentInfo</Method>
  </MapItem>
</MapItems>
}

}
