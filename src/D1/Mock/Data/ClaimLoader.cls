/// Wipes (and optionally reseeds) the group-2 claim tables. Run:
///   Do ##class(D1.Mock.Data.ClaimLoader).Reset()
/// or  CALL D1_Mock_Data.ClaimLoader_Reset()
/// or over HTTP: POST /d1/reset {"reseed": "1"}
/// 
/// pReseed defaults to true for the direct/SQL entry points above, so
/// existing callers (including the test suite's Setup) keep getting a
/// reseeded demo dataset. The HTTP route defaults reseed to "0" instead --
/// see D1.Mock.API.D1API.Reset.
/// 
/// Two kinds of seed, both skipped when pReseed is false:
///   reference data (ClaimPolicy / ClaimBenefit / CoverageItem) -- no API in
///     the spec ever writes it, so without this D1GetBenefit cannot answer
///   one demo claim thread (HN000001 / AN2026080001 / VN2026080001), taken
///     from the data dictionary's first sample row per table
/// 
/// ClaimFile is not seeded: it fills via POST /files.
Class D1.Mock.Data.ClaimLoader
{

ClassMethod Reset(pReseed As %Boolean = 1) As %Status [ SqlProc ]
{
	Set tSC = $$$OK
	Try {
		Do ##class(D1.Mock.Data.ClaimPatient).%KillExtent()
		Do ##class(D1.Mock.Data.ClaimDiagnosis).%KillExtent()
		Do ##class(D1.Mock.Data.ClaimVisit).%KillExtent()
		Do ##class(D1.Mock.Data.ClaimVisitProcedure).%KillExtent()
		Do ##class(D1.Mock.Data.ClaimPolicy).%KillExtent()
		Do ##class(D1.Mock.Data.ClaimBenefit).%KillExtent()
		Do ##class(D1.Mock.Data.CoverageItem).%KillExtent()
		Do ##class(D1.Mock.Data.ClaimAdmission).%KillExtent()
		Do ##class(D1.Mock.Data.ClaimPreAuth).%KillExtent()
		Do ##class(D1.Mock.Data.ClaimDischarge).%KillExtent()
		Do ##class(D1.Mock.Data.ClaimBilling).%KillExtent()
		Do ##class(D1.Mock.Data.ClaimFile).%KillExtent()
		Do ##class(D1.Mock.Data.ClaimChiefComplaint).%KillExtent()
		Do ##class(D1.Mock.Data.ClaimInsurer).%KillExtent()
		// Not Claim*-prefixed, but written by PostPreAuth and is exactly what
		// its 409 duplicate check queries -- must be wiped alongside the rest
		// or a repeat crud_status="0" test still 409s after a "reset".
		Do ##class(D1.Mock.Data.PreAuthSubmission).%KillExtent()

		Quit:'pReseed

		// --- Insurer reference data (never written by any API) ---
		$$$THROWONERROR(tSC, ..AddPolicy("AN2026080001", "HN000001", "AIA", "American International Assurance Co., Ltd", "POL000001", "AIA001", "AIA Health Gold", "AIA-TH-998821", "INS00001"))
		$$$THROWONERROR(tSC, ..AddBenefit("AIA-TH-998821:ROOM", "AIA-TH-998821", "IPD", "Room and Board", "available", 1000000.00, 45000.00))
		$$$THROWONERROR(tSC, ..AddCoverage("AIA-TH-998821:ROOM", "1.1", "ROOM", "Room & Board", "PerDay", 5000.00, "THB", "Maximum 30 days"))
		$$$THROWONERROR(tSC, ..AddBenefit("AIA-TH-998821:SURGERY", "AIA-TH-998821", "IPD", "SURGERY", "available", 200000.00, 120000.00))
		$$$THROWONERROR(tSC, ..AddCoverage("AIA-TH-998821:SURGERY", "1", "SUR001", "Major Surgery", "PerCase", 200000.00, "THB", "Pre-authorization required"))
		$$$THROWONERROR(tSC, ..AddBenefit("AIA-TH-998821:ICU", "AIA-TH-998821", "IPD", "ICU", "exhausted", 300000.00, 0.00))
		$$$THROWONERROR(tSC, ..AddCoverage("AIA-TH-998821:ICU", "1", "ICU001", "ICU Room", "PerDay", 15000.00, "THB", "Maximum 20 days"))

		// --- One demo claim thread (data dictionary sample values) ---
		// --- insurer_info: the INSURED PERSON, not the insurance company.
		// Dictionary V1.0.3 sample keys INS00001..INS00005.
		$$$THROWONERROR(tSC, ..AddInsurer("INS00001", "1103701234567", "", "Mr.", "Somchai", "Sukjai", "male", "1985-04-15 00:00:00", "99 ถนนสุขุมวิท เขตวัฒนา กรุงเทพฯ 10110", "0812345678"))
		$$$THROWONERROR(tSC, ..AddInsurer("INS00003", "", "N12345678", "Ms.", "Malee", "Wongsawat", "female", "1992-11-02 00:00:00", "55 Chiang Mai-Lamphun Road", "0897654321"))

		$$$THROWONERROR(tSC, ..AddPatient("HN000001", "1103701234567", "", "Mr.", "Somchai", "Sukjai", "male", "1985-04-15 00:00:00", "99 ถนนสุขุมวิท เขตวัฒนา กรุงเทพฯ 10110", "0812345678"))
		$$$THROWONERROR(tSC, ..AddVisit("VN2026080001", "HN000001", "2026-08-01 00:00:00", "OPD", "MED", "Internal Medicine", "Fever and cough for 3 days", "2026-08-02 09:00:00"))
		$$$THROWONERROR(tSC, ..AddVisitProcedure("VN2026080001", "93.9", "Chest X-Ray", "2026-08-01 09:45:00"))
		$$$THROWONERROR(tSC, ..AddAdmission("AN2026080001", "HN000001", "2026-07-25 00:00:00", "WARD-05", "Medical Ward", "Private Room", "B01", "2026-08-05 00:00:00", "2026-08-05 00:00:00", "4", 125000.00))
		$$$THROWONERROR(tSC, ..AddChiefComplaint("AN2026080001", "HN000001", "Fever and cough for 3 days"))
		$$$THROWONERROR(tSC, ..AddDiagnosis("AN2026080001", "HN000001", "PRIMARY", "E11.9", "Type 2 diabetes mellitus without complications"))
		$$$THROWONERROR(tSC, ..AddPreAuth("REQ000000P1", "HN000001", "AN2026080001", "PA-2026-071122", "Pre-Accepted", "2026-07-09 20:50:15", 10000.00))
		$$$THROWONERROR(tSC, ..AddDischarge("REQ000000D1", "HN000001", "AN2026080001", "GCL-12345", "Approved", "2026-08-06 09:00:00", 120000.00, "2026-08-06 09:05:00", "2026-08-05 00:00:00", "Mr.", "Anan", "Prasert", ""))
		// --- A SECOND claim thread, deliberately still AWAITING A DECISION.
		// The first thread is fully decided (Pre-Accepted / Approved), so
		// without this GetRecordList correctly returns an empty worklist and
		// there is nothing to demonstrate -- nor anything for PatchPreAuth and
		// PatchDischarge to act on.
		//
		// Dated October so it cannot disturb the July (pre-auth) and August
		// (discharge) ranges the date-range tests rely on. GetRecordList does
		// not filter by date, so it appears regardless.
		$$$THROWONERROR(tSC, ..AddPatient("HN000002", "1209909876543", "", "Ms.", "Malee", "Wongsawat", "female", "1992-11-02 00:00:00", "55 Chiang Mai-Lamphun Road", "0897654321"))
		$$$THROWONERROR(tSC, ..AddAdmission("AN2026080002", "HN000002", "2026-10-01 00:00:00", "WARD-02", "Surgical Ward", "Standard Room", "A07", "2026-10-08 00:00:00", "2026-10-08 00:00:00", "7", 88000.00))
		// Shares the policy number with the first thread, the way the data
		// dictionary's own samples do -- policy_info's PK is admission_number.
		$$$THROWONERROR(tSC, ..AddPolicy("AN2026080002", "HN000002", "AIA", "American International Assurance Co., Ltd", "POL000001", "AIA001", "AIA Health Gold", "AIA-TH-998821", "INS00003"))
		$$$THROWONERROR(tSC, ..AddChiefComplaint("AN2026080002", "HN000002", "Abdominal pain for 2 days"))
		// Awaiting a pre-auth decision -> appears in GetRecordList("Pre-Auth").
		$$$THROWONERROR(tSC, ..AddPreAuth("REQ000000P2", "HN000002", "AN2026080002", "PA-2026-100077", "Pre-Authorize Submitted", "2026-10-02 09:15:00", 88000.00))
		// Awaiting a discharge decision -> appears in GetRecordList("Discharge").
		// gl_number and every authorization_* field are EMPTY, which is exactly
		// the state PatchDischarge exists to resolve.
		$$$THROWONERROR(tSC, ..AddDischarge("REQ000000D2", "HN000002", "AN2026080002", "", "Discharge Requested", "", "", "", "2026-10-08 00:00:00", "", "", "", ""))

		$$$THROWONERROR(tSC, ..AddBilling("REQ000000D1", "HN000001", "AN2026080001", "THB", 150000.00, 5000.00, 145000.00, 2000.00, 143000.00))
	}
	Catch ex {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

ClassMethod AddPatient(pHN, pCitizen, pPassport, pTitle, pFirst, pLast, pGender, pBirthDate, pAddress, pPhone) As %Status
{
	Set o = ##class(D1.Mock.Data.ClaimPatient).%New()
	Set o.HospitalNumber = pHN, o.CitizenId = pCitizen, o.PassportId = pPassport
	Set o.Title = pTitle, o.FirstName = pFirst, o.LastName = pLast
	Set o.Gender = pGender, o.BirthDate = pBirthDate
	Set o.Address = pAddress, o.PhoneNumber = pPhone
	Quit o.%Save()
}

ClassMethod AddVisit(pVN, pHN, pDate, pType, pDeptCode, pDeptName, pComplaint, pUpdate) As %Status
{
	Set o = ##class(D1.Mock.Data.ClaimVisit).%New()
	Set o.VisitNumber = pVN, o.HospitalNumber = pHN, o.VisitDate = pDate
	Set o.VisitType = pType, o.DepartmentCode = pDeptCode, o.DepartmentName = pDeptName
	Set o.ChiefComplaint = pComplaint, o.UpdateDate = pUpdate
	Quit o.%Save()
}

ClassMethod AddVisitProcedure(pVN, pCode, pName, pUpdate) As %Status
{
	Set o = ##class(D1.Mock.Data.ClaimVisitProcedure).%New()
	Set o.VisitNumber = pVN, o.ProcedureCode = pCode, o.ProcedureName = pName
	Set o.UpdateDate = pUpdate
	Quit o.%Save()
}

ClassMethod AddPolicy(pAN, pHN, pCompanyCode, pCompanyName, pPolicyId, pPlanCode, pPlanName, pPolicyNumber, pInsurerId = "") As %Status
{
	Set o = ##class(D1.Mock.Data.ClaimPolicy).%New()
	Set o.AdmissionNumber = pAN, o.HospitalNumber = pHN
	Set o.CompanyCode = pCompanyCode, o.CompanyName = pCompanyName
	Set o.PolicyId = pPolicyId, o.PlanCode = pPlanCode, o.PlanName = pPlanName
	Set o.PolicyNumber = pPolicyNumber
	Set o.InsurerId = pInsurerId
	Quit o.%Save()
}

ClassMethod AddBenefit(pKey, pPolicyNumber, pCode, pName, pStatus, pMax, pRemaining) As %Status
{
	Set o = ##class(D1.Mock.Data.ClaimBenefit).%New()
	Set o.BenefitKey = pKey, o.PolicyNumber = pPolicyNumber
	Set o.BenefitCode = pCode, o.BenefitName = pName, o.BenefitStatus = pStatus
	Set o.MaximumAmount = pMax, o.RemainingAmount = pRemaining
	Quit o.%Save()
}

ClassMethod AddCoverage(pBenefitKey, pItemNo, pCode, pName, pType, pAmount, pUnit, pRemark) As %Status
{
	Set o = ##class(D1.Mock.Data.CoverageItem).%New()
	Set o.BenefitKey = pBenefitKey, o.CoverageItemNo = pItemNo
	Set o.CoverageCode = pCode, o.CoverageName = pName, o.CoverageType = pType
	Set o.LimitAmount = pAmount, o.LimitUnit = pUnit, o.Remark = pRemark
	Quit o.%Save()
}

ClassMethod AddAdmission(pAN, pHN, pDate, pWard, pWardType, pRoomType, pBed, pExpected, pActual, pLos, pCost) As %Status
{
	Set o = ##class(D1.Mock.Data.ClaimAdmission).%New()
	Set o.AdmissionNumber = pAN, o.HospitalNumber = pHN, o.AdmissionDate = pDate
	Set o.WardNumber = pWard, o.WardType = pWardType, o.RoomType = pRoomType, o.BedNo = pBed
	Set o.ExpectedDischargeDate = pExpected, o.ActualDischargeDate = pActual
	Set o.EstimatedLengthOfStay = pLos, o.EstimatedCost = pCost
	Quit o.%Save()
}

ClassMethod AddDiagnosis(pAN, pHN, pType, pCode, pName) As %Status
{
	Set o = ##class(D1.Mock.Data.ClaimDiagnosis).%New()
	Set o.AdmissionNumber = pAN, o.HospitalNumber = pHN
	Set o.DiagnosisType = pType, o.DiagnosisCode = pCode, o.DiagnosisName = pName
	Quit o.%Save()
}

ClassMethod AddPreAuth(pClaimId, pHN, pAN, pCaseNumber, pStatus, pSubmitDate, pCost) As %Status
{
	Set o = ##class(D1.Mock.Data.ClaimPreAuth).%New()
	Set o.ClaimId = pClaimId, o.HospitalNumber = pHN, o.AdmissionNumber = pAN
	Set o.ClaimCaseNumber = pCaseNumber, o.ClaimStatus = pStatus
	Set o.SubmitDate = pSubmitDate, o.EstimatedCost = pCost
	Quit o.%Save()
}

ClassMethod AddChiefComplaint(pAN, pHN, pComplaint) As %Status
{
	Set o = ##class(D1.Mock.Data.ClaimChiefComplaint).%New()
	Set o.AdmissionNumber = pAN, o.HospitalNumber = pHN, o.ChiefComplaint = pComplaint
	Quit o.%Save()
}

/// insurer_info -- the insured PERSON. See D1.Mock.Data.ClaimInsurer.
ClassMethod AddInsurer(pId, pCitizen, pPassport, pTitle, pFirst, pLast, pGender, pDob, pAddress, pPhone) As %Status
{
	Set o = ##class(D1.Mock.Data.ClaimInsurer).%New()
	Set o.InsurerId = pId, o.CitizenId = pCitizen, o.PassportId = pPassport
	Set o.Title = pTitle, o.FirstName = pFirst, o.LastName = pLast
	Set o.Gender = pGender, o.BirthDate = pDob
	Set o.Address = pAddress, o.PhoneNumber = pPhone
	Quit o.%Save()
}

ClassMethod AddDischarge(pDischargeId, pHN, pAN, pGl, pStatus, pAuthDate, pAuthAmount, pGlDate, pDischDate = "", pAuthTitle = "", pAuthFirst = "", pAuthLast = "", pRemark = "") As %Status
{
	Set o = ##class(D1.Mock.Data.ClaimDischarge).%New()
	Set o.DischargeId = pDischargeId, o.HospitalNumber = pHN, o.AdmissionNumber = pAN
	Set o.GlNumber = pGl, o.DischargeStatus = pStatus
	Set o.AuthorizationDate = pAuthDate, o.AuthorizationAmount = pAuthAmount
	Set o.DischargeGlDate = pGlDate
	Set o.DischargeDate = pDischDate, o.Remark = pRemark
	Set o.AuthorizationTitle = pAuthTitle
	Set o.AuthorizationFirstName = pAuthFirst, o.AuthorizationLastName = pAuthLast
	Quit o.%Save()
}

ClassMethod AddBilling(pDischargeId, pHN, pAN, pCurrency, pTotal, pDiscount, pNet, pPatient, pInsurance) As %Status
{
	Set o = ##class(D1.Mock.Data.ClaimBilling).%New()
	Set o.DischargeId = pDischargeId, o.HospitalNumber = pHN, o.AdmissionNumber = pAN
	Set o.Currency = pCurrency, o.TotalCharge = pTotal, o.DiscountAmount = pDiscount
	Set o.NetCharge = pNet, o.PatientPayable = pPatient, o.InsurancePayable = pInsurance
	Quit o.%Save()
}

}
