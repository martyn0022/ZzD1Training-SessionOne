/// Functional test tier for the whole API surface (the plan's Phase 9).
/// 
/// Fast and in-process: exercises the mock HIS row builders (SQL + identity
/// filters), the DTL transforms against hand-built raw messages, the shared
/// shape-fix helpers, the group-2 resolver and read operations, and every
/// write path's validate/store/snapshot logic -- WITHOUT going through HTTP
/// or the running production. The full HTTP path (routes, BPL orchestration,
/// Visual Trace) is the integration tier's job -- the Postman collection at
/// tests/D1-Claim_API.postman_collection.json.
/// 
/// Every test starts from BOTH fresh seeds, so assertions can rely on:
///   mock HIS (Loader)      -- 1001/HN00012345 inpatient VN-2569-100245;
///                             1002/HN00067890 outpatient VN-2569-100246
///                             (2 diagnoses -- exercises PRIMARY/SECONDARY)
///   IRIS claim (ClaimLoader) -- HN000001 / AN2026080001 / VN2026080001,
///                             plus AIA-TH-998821's three benefits (one
///                             deliberately exhausted)
/// 
/// Run (class already loaded/compiled in the namespace):
///   Do ##class(%UnitTest.Manager).DebugRunTestCase("", "D1.Mock.Test.ApiFunctionalTest")
Class D1.Mock.Test.ApiFunctionalTest Extends %UnitTest.TestCase
{

Method OnBeforeOneTest(testname As %String) As %Status
{
	Set tSC = ##class(D1.Mock.Data.Loader).Reset()
	Quit:$$$ISERR(tSC) tSC
	// PreAuthSubmission is the one write-path table neither loader clears --
	// nothing seeds it, so without this the write tests inherit each other's
	// rows and the duplicate-detection assertions depend on method ordering.
	Do ##class(D1.Mock.Data.PreAuthSubmission).%KillExtent()
	Quit ##class(D1.Mock.Data.ClaimLoader).Reset()
}

// ------------------------------------------------- Identity resolution layer

/// Every identity filter on the mock /Patient list reaches the same seeded
/// patient: HN, CID, PID directly; VN/AN via the episode fallback filter.
Method TestPatientListIdentityFilters()
{
	Set tRows = ##class(D1.Mock.API.HISService).PatientRows("HN00012345", "", "", "")
	Do $$$AssertEquals(tRows.%Size(), 1, "HN filter finds one patient")
	Do $$$AssertEquals(tRows.%Get(0).%Get("ID"), "1001", "HN resolves to PatientID 1001")

	Set tRows = ##class(D1.Mock.API.HISService).PatientRows("", "3-1258-00558-89-8", "", "")
	Do $$$AssertEquals(tRows.%Get(0).%Get("ID"), "1001", "CID (NationalID) resolves to 1001")

	Set tRows = ##class(D1.Mock.API.HISService).PatientRows("", "", "FF5588981", "")
	Do $$$AssertEquals(tRows.%Get(0).%Get("ID"), "1001", "PID (ForeignID) resolves to 1001")

	Set tRows = ##class(D1.Mock.API.HISService).PatientRows("", "", "", "VN-2569-100245")
	Do $$$AssertEquals(tRows.%Get(0).%Get("ID"), "1001", "VN/AN (EpisodeNo) resolves to 1001")

	Set tRows = ##class(D1.Mock.API.HISService).PatientRows("HN-DOES-NOT-EXIST", "", "", "")
	Do $$$AssertEquals(tRows.%Size(), 0, "Unknown identity yields empty results, not an error")
}

/// The single-call VN/AN episode resolver returns the linking keys.
Method TestPAAdmByLocTypeResolver()
{
	Set tRows = ##class(D1.Mock.API.HISService).PAAdmByLocTypeRows("VN-2569-100245")
	Do $$$AssertEquals(tRows.%Size(), 1, "Resolver finds the episode")
	Do $$$AssertEquals(tRows.%Get(0).%Get("PatientID"), "1001", "Episode links to PatientID 1001")
	Do $$$AssertEquals(tRows.%Get(0).%Get("mradm"), "VN-2569-100245", "mradm key present")
	Do $$$AssertEquals(tRows.%Get(0).%Get("RegNo"), "HN00012345", "RegNo present")
}

/// The by-id patient read serves RAW TrakCare field names -- the check that
/// matters most: clean names here would silently defeat the whole
/// anti-corruption design.
Method TestPatientResultsRawTrakShape()
{
	Set tResults = ##class(D1.Mock.API.HISService).PatientResults("1001")
	Do $$$AssertEquals(tResults.%Get("RegistrationNumber"), "HN00012345", "RegistrationNumber (raw name) present")
	Do $$$AssertEquals(tResults.%Get("PAPERDob"), "15/05/1990", "PAPERDob raw display format")
	Do $$$AssertEquals(tResults.%Get("CTSEXDesc"), "Male", "CTSEXDesc raw description")
	Do $$$AssertTrue('tResults.%IsDefined("GivenName"), "No clean-named GivenName field survives")
	Do $$$AssertTrue('tResults.%IsDefined("first_name"), "No D1-named first_name leaks into the HIS layer")
}

// ------------------------------------------------------------ DTL transforms

/// Flat V1.0.3 patient record: gender lower-cased, DOB reformatted, address
/// joined, title/last_name honestly empty (documented gaps).
Method TestPatientToD1FlatRecord()
{
	Set tSrc = ##class(D1.Mock.Msg.HIS.PatientResponse).%New()
	Set tSrc.Results.RegistrationNumber = "HN00012345"
	Set tSrc.Results.PAPERResidentNumber = "3-1258-00558-89-8"
	Set tSrc.Results.PAPERName = "Jaidee"
	Set tSrc.Results.PAPERName2 = "Somchai"
	Set tSrc.Results.TTLDesc = "Mr."
	Set tSrc.Results.CTSEXDesc = "Male"
	Set tSrc.Results.PAPERDob = "15/05/1990"
	Set tSrc.Results.PAPERStName = "99 Sukhumvit Road"
	Set tSrc.Results.CTCITDesc = "Bangkok"
	Set tSrc.Results.PAPERMobPhone = "081-234-5678"

	Set tTarget = ##class(D1.Mock.Msg.GetPatientResponse).%New()
	Do $$$AssertStatusOK(##class(D1.Mock.DT.PatientToD1).Transform(tSrc, .tTarget), "Transform runs")
	Do $$$AssertEquals(tTarget.ResponseCode, "200", "Envelope 200")
	Do $$$AssertEquals(tTarget.Patient.HospitalNumber, "HN00012345", "hospital_number mapped")
	Do $$$AssertEquals(tTarget.Patient.Gender, "male", "Gender lower-cased")
	Do $$$AssertEquals(tTarget.Patient.BirthDate, "1990-05-15 00:00:00", "DOB -> yyyy-MM-dd HH:mm:ss")
	Do $$$AssertEquals(tTarget.Patient.Address, "99 Sukhumvit Road, Bangkok", "Street+city joined")
	// PAPERName is TrakCare's Surname and PAPERName2 its Given Name -- an
	// earlier build had these the wrong way round, so assert both explicitly.
	Do $$$AssertEquals(tTarget.Patient.FirstName, "Somchai", "first_name <- PAPERName2 (Given Name)")
	Do $$$AssertEquals(tTarget.Patient.LastName, "Jaidee", "last_name <- PAPERName (Surname)")
	Do $$$AssertEquals(tTarget.Patient.Title, "Mr.", "title <- TTLDesc")
}

/// Visit projection: visit_info + type derivation, then the complaint and
/// procedure transforms appending onto the same response.
Method TestVisitTransformsIncludingComplaintAndProcedures()
{
	Set tAdm = ##class(D1.Mock.Msg.HIS.PAAdmResponse).%New()
	Set tItem = ##class(D1.Mock.Msg.HIS.PAAdmItem).%New()
	Set tItem.PAADMADMNo = "VN-2569-100245"
	Set tItem.RegNo = "HN00012345"
	Set tItem.PAADMType = "I"
	Set tItem.PAADMAdmDate = "15/05/2026"
	Set tItem.PAADMAdmTime = "09:00"
	Do tAdm.Results.Insert(tItem)

	Set tTarget = ##class(D1.Mock.Msg.GetVisitResponse).%New()
	Do $$$AssertStatusOK(##class(D1.Mock.DT.PAAdmToVisit).Transform(tAdm, .tTarget), "Visit transform runs")
	Do $$$AssertEquals(tTarget.HospitalNumber, "HN00012345", "hospital_number top-level (flat V1.0.3 shape)")
	Do $$$AssertEquals(tTarget.VisitInfo.VisitNumber, "VN-2569-100245", "visit_number mapped")
	Do $$$AssertEquals(tTarget.VisitInfo.VisitDate, "2026-05-15 09:00:00", "Date+time combined")
	Do $$$AssertEquals(tTarget.VisitInfo.VisitType, "IPD", "PAADMType I -> IPD")

	Set tRfe = ##class(D1.Mock.Msg.HIS.MrReasonForEncResponse).%New()
	Set tReason = ##class(D1.Mock.Msg.HIS.MrReasonForEncItem).%New()
	Set tReason.DescSnomed = "Fever"
	Do tRfe.Results.Insert(tReason)
	Do $$$AssertStatusOK(##class(D1.Mock.DT.MrReasonForEncToVisit).Transform(tRfe, .tTarget), "Complaint transform runs")
	Do $$$AssertEquals(tTarget.ComplaintInfo.ChiefComplaint, "Fever", "chief_complaint mapped")

	Set tProc = ##class(D1.Mock.Msg.HIS.MrProceduresResponse).%New()
	For i = 1:1:2 {
		Set tRow = ##class(D1.Mock.Msg.HIS.MrProceduresItem).%New()
		Set tRow.OPERCode = "PROC00" _ i
		Set tRow.OPERDesc = "Procedure " _ i
		Do tProc.Results.Insert(tRow)
	}
	Do $$$AssertStatusOK(##class(D1.Mock.DT.MrProceduresToVisit).Transform(tProc, .tTarget), "Procedures transform runs")
	Do $$$AssertEquals(tTarget.ProcedureInfo.Count(), 2, "One procedure_info entry per HIS row")
	Do $$$AssertEquals(tTarget.ProcedureInfo.GetAt(1).ProcedureCode, "PROC001", "procedure_code mapped")
}

/// Admission projection: single object, ward_type from the care type.
Method TestPAAdmToAdmissionMapsWardType()
{
	Set tAdm = ##class(D1.Mock.Msg.HIS.PAAdmResponse).%New()
	Set tItem = ##class(D1.Mock.Msg.HIS.PAAdmItem).%New()
	Set tItem.PAADMADMNo = "VN-2569-100245"
	Set tItem.RegNo = "HN00012345"
	Set tItem.PAADMAdmDate = "15/05/2026"
	Set tItem.PAADMAdmTime = "09:00"
	Set tItem.WARDDesc = "WARD01"
	// Deliberately NOT the ward master's value, so this test can tell them apart.
	Set tItem.CARETYPDesc = "Care type must not win"
	Set tItem.ROOMTDesc = "สามัญ ห้องรวม"
	Set tItem.BEDCode = "A01"
	Set tItem.EstDschrgDate = "31/07/2026"
	Do tAdm.Results.Insert(tItem)

	Set tTarget = ##class(D1.Mock.Msg.GetAdmissionResponse).%New()
	Do $$$AssertStatusOK(##class(D1.Mock.DT.PAAdmToAdmission).Transform(tAdm, .tTarget), "Admission transform runs")
	Do $$$AssertEquals(tTarget.AdmissionInfo.AdmissionNumber, "VN-2569-100245", "admission_number mapped")
	Do $$$AssertEquals(tTarget.VisitNumber, "VN-2569-100245", "visit_number echoed top-level")
	Do $$$AssertEquals(tTarget.AdmissionInfo.WardType, "Medical Ward", "ward_type <- ward master, NOT CARETYPDesc")
	Do $$$AssertEquals(tTarget.AdmissionInfo.WardNumber, "WARD01", "ward_number from WARDDesc (pinned)")
	Do $$$AssertEquals(tTarget.AdmissionInfo.ExpectedDischargeDate, "2026-07-31 00:00:00", "Expected discharge reformatted")
	Do $$$AssertEquals(tTarget.AdmissionInfo.ActualDischargeDate, "", "Empty discharge date stays empty (nullable)")
}

/// Diagnosis projection: PRIMARY/SECONDARY derivation, pinned code/name
/// convention, and NO attending_physician property on the V1.0.3 response.
Method TestMrDiagnosToD1TypeDerivationAndNoPhysician()
{
	Set tDx = ##class(D1.Mock.Msg.HIS.DiagnosisResponse).%New()
	Set tRow1 = ##class(D1.Mock.Msg.HIS.DiagnosisItem).%New()
	Set tRow1.MRDIATerminologyDesc = "ICD-10-CM"
	Set tRow1.MRCIDCode = "J45"
	Set tRow1.MRCIDDesc = "Asthma"
	Set tRow1.MRDIAPrinciple = "Y"
	Do tDx.Results.Insert(tRow1)
	Set tRow2 = ##class(D1.Mock.Msg.HIS.DiagnosisItem).%New()
	Set tRow2.MRDIATerminologyDesc = "ICD-10-CM"
	Set tRow2.MRCIDCode = "I10"
	Set tRow2.MRCIDDesc = "Essential hypertension"
	Set tRow2.MRDIAPrinciple = "N"
	Do tDx.Results.Insert(tRow2)

	Set tTarget = ##class(D1.Mock.Msg.GetDiagnosisResponse).%New()
	Do $$$AssertStatusOK(##class(D1.Mock.DT.MrDiagnosToD1).Transform(tDx, .tTarget), "Diagnosis transform runs")
	Do $$$AssertEquals(tTarget.DiagnosisInfo.Count(), 2, "Both rows kept -- genuinely repeating array")
	Do $$$AssertEquals(tTarget.DiagnosisInfo.GetAt(1).DiagnosisType, "PRIMARY", "Y -> PRIMARY")
	Do $$$AssertEquals(tTarget.DiagnosisInfo.GetAt(2).DiagnosisType, "SECONDARY", "N -> SECONDARY")
	Do $$$AssertEquals(tTarget.DiagnosisInfo.GetAt(1).Code, "ICD-10-CM", "diagnosis_code = terminology name (pinned, matches spec sample)")
	Do $$$AssertEquals(tTarget.DiagnosisInfo.GetAt(1).Name, "J45 - Asthma", "diagnosis_name = code - description")

	// V1.0.3 removed attending_physician from this response entirely --
	// a compiled property reappearing means the old shape crept back in.
	Do $$$AssertTrue('##class(%Dictionary.CompiledProperty).%ExistsId("D1.Mock.Msg.GetDiagnosisResponse||AttendingPhysician"), "GetDiagnosisResponse has no AttendingPhysician property")
}

/// Billing projection: amounts mapped 1:1; currency NOT set by the DTL
/// (config-sourced in the BO -- the documented TrakCare gap).
Method TestBillingTransformCurrencyLeftToConfig()
{
	Set tBill = ##class(D1.Mock.Msg.HIS.BillingResponse).%New()
	Set tRow = ##class(D1.Mock.Msg.HIS.BillingItem).%New()
	Set tRow.EpisodeID = "VN-2569-100245"
	Set tRow.GrossAmount = 150000.00
	Set tRow.DiscTotal = 5000.00
	Set tRow.NetAmount = 145000.00
	Set tRow.PatInvTot = 2000.00
	Set tRow.PayorInvTot = 143000.00
	Do tBill.Results.Insert(tRow)

	Set tTarget = ##class(D1.Mock.Msg.GetBillingResponse).%New()
	Do $$$AssertStatusOK(##class(D1.Mock.DT.ArPatientBillAllToBilling).Transform(tBill, .tTarget), "Billing transform runs")
	Do $$$AssertEquals(tTarget.BillingInfo.TotalCharge, 150000.00, "total_charge from GrossAmount")
	Do $$$AssertEquals(tTarget.BillingInfo.NetCharge, 145000.00, "net_charge from NetAmount")
	Do $$$AssertEquals(tTarget.BillingInfo.InsurancePayable, 143000.00, "insurance_payable from PayorInvTot")
	Do $$$AssertEquals(tTarget.BillingInfo.Currency, "", "Currency untouched by the DTL -- assigned from BO config only")
}

// ------------------------------------------------------------ Shared helpers

Method TestShapeFixHelpers()
{
	Do $$$AssertEquals(##class(D1.Mock.BP.PatientMapper).IsoDateTime("15/05/1990", ""), "1990-05-15 00:00:00", "Date only -> midnight")
	Do $$$AssertEquals(##class(D1.Mock.BP.PatientMapper).IsoDateTime("15/05/2026", "09:00"), "2026-05-15 09:00:00", "HH:MM time gains seconds")
	Do $$$AssertEquals(##class(D1.Mock.BP.PatientMapper).IsoDateTime("", "09:00"), "", "Empty date stays empty (nullable)")
	Do $$$AssertEquals(##class(D1.Mock.BP.PatientMapper).JoinAddress("Street", "City"), "Street, City", "Both parts joined")
	Do $$$AssertEquals(##class(D1.Mock.BP.PatientMapper).JoinAddress("", "City"), "City", "Empty street tolerated")
	Do $$$AssertEquals(##class(D1.Mock.BP.PatientMapper).VisitType("I"), "IPD", "I -> IPD")
	Do $$$AssertEquals(##class(D1.Mock.BP.PatientMapper).VisitType("O"), "OPD", "O -> OPD")
	Do $$$AssertEquals(##class(D1.Mock.BP.PatientMapper).VisitType("E"), "ER", "E -> ER")
	Do $$$AssertEquals(##class(D1.Mock.BP.PatientMapper).DiagnosisType("Y"), "PRIMARY", "Y -> PRIMARY")
	Do $$$AssertEquals(##class(D1.Mock.BP.PatientMapper).DiagnosisType("N"), "SECONDARY", "N -> SECONDARY")
}

// ---------------------------------------------------------------- PostPreAuth

/// Build a fully valid V1.0.3 pre-auth request for the seeded admission.
Method MakePreAuthRequest() As D1.Mock.Msg.PostPreAuthRequest
{
	Set tReq = ##class(D1.Mock.Msg.PostPreAuthRequest).%New()
	// V1.0.5 insurer block. The company half is load-bearing: it creates the
	// ClaimPolicy row that every V1.0.5 API resolves company_code through.
	Set tReq.Insurer.CompanyCode = "AIA"
	Set tReq.Insurer.CompanyName = "American International Assurance Co., Ltd"
	Set tReq.Insurer.InsurerId = "INS00001"
	Set tReq.Insurer.Title = "Mr.", tReq.Insurer.FirstName = "Somchai", tReq.Insurer.LastName = "Sukjai"
	Set tReq.CrudStatus = "0"
	Set tReq.HospitalCode = "RAMA9"
	Set tReq.Person.HospitalNumber = "HN00012345"
	Set tReq.Person.VisitNumber = "VN-2569-100245"
	Set tReq.Person.CitizenId = "3-1258-00558-89-8"
	Set tReq.Person.FirstName = "Somchai"
	Set tReq.Person.LastName = "Jaidee"
	Set tReq.Person.Gender = "male"
	Set tReq.Person.Birthdate = "1990-05-15 00:00:00"
	Set tReq.Person.Age = 36
	Set tReq.AuthStatus = "Pre-Authorize Submitted"
	Set tReq.ComplaintInfo.ChiefComplaint = "Fever"
	Set tProc = ##class(D1.Mock.Msg.ProcedureInfo).%New()
	Set tProc.ProcedureCode = "PROC001"
	Set tProc.ProcedureName = "Chest X-Ray"
	Do tReq.ProcedureInfo.Insert(tProc)
	Set tDx = ##class(D1.Mock.Msg.DiagnosisInfo).%New()
	Set tDx.DiagnosisType = "PRIMARY"
	Set tDx.Code = "ICD-10-CM"
	Set tDx.Name = "E11 - Type 2 diabetes mellitus"
	Do tReq.Diagnosis.Insert(tDx)
	Set tReq.Policies.PolicyId = "POL000001"
	Set tReq.Policies.PlanCode = "AIA001"
	Set tReq.Policies.PlanName = "AIA Health Gold"
	Set tReq.Policies.PolicyNumber = "AIA-TH-998821"
	Set tBenefit = ##class(D1.Mock.Msg.BenefitRef).%New()
	Set tBenefit.BenefitCode = "IPD"
	Set tBenefit.BenefitName = "Inpatient"
	Do tReq.Benefits.Insert(tBenefit)
	Set tReq.AttendingPhysician.Id = "S12345"
	Set tReq.AttendingPhysician.FirstName = "Somsak"
	Set tReq.AttendingPhysician.LastName = "Saksom"
	Set tReq.Admission.AdmissionNumber = "VN-2569-100245"
	Set tReq.Admission.WardNumber = "WARD01"
	Set tReq.Admission.RoomType = "สามัญ ห้องรวม"
	Set tReq.Admission.EstimatedAdmissionDate = "2026-05-15 00:00:00"
	Set tReq.Admission.EstimatedLengthOfStay = "5"
	Set tReq.Admission.EstimatedCost = "10,000.00"
	Set tReq.SubmitDate = "2026-07-09 10:00:15"
	Set tReq.UpdateDate = "2026-07-09 10:00:15"
	Quit tReq
}

/// Validate() accepts a complete payload and names the first missing field
/// on an incomplete one.
Method TestPreAuthValidate()
{
	Set tReq = ..MakePreAuthRequest()
	Do $$$AssertEquals(##class(D1.Mock.BP.PreAuthStoreProcess).Validate(tReq), "", "Complete V1.0.3 payload validates clean")

	Set tReq.ComplaintInfo.ChiefComplaint = ""
	Do $$$AssertEquals(##class(D1.Mock.BP.PreAuthStoreProcess).Validate(tReq), "complaint_info.chief_complaint is required", "Missing chief complaint reported")

	Set tBad = ##class(D1.Mock.Msg.PostPreAuthRequest).%New()
	Do $$$AssertTrue(##class(D1.Mock.BP.PreAuthStoreProcess).Validate(tBad) '= "", "Empty payload rejected")
}

/// Store() flattens the V1.0.3 shape into one row (scalar policy columns,
/// joined arrays), and the duplicate-insert guard sees the stored row.
Method TestPreAuthStoreAndDuplicateDetection()
{
	Set tReq = ..MakePreAuthRequest()
	Set tOp = ##class(D1.Mock.BO.PreAuthStoreOperation).%New("Test PreAuth Store")
	Do $$$AssertStatusOK(tOp.Store(tReq, .tResp), "Store runs")
	Do $$$AssertEquals(tResp.ResponseCode, "200", "Store answers 200")

	Do $$$AssertTrue(##class(D1.Mock.Data.PreAuthSubmission).AdmissionExists("VN-2569-100245", .tId), "Row exists after insert -- the 409 guard's input")

	Set tSub = ##class(D1.Mock.Data.PreAuthSubmission).%OpenId(tId)
	If $$$AssertTrue($IsObject(tSub), "Stored row opens") {
		Do $$$AssertEquals(tSub.PolicyNumber, "AIA-TH-998821", "Single policy stored in scalar column (V1.0.3 shape)")
		Do $$$AssertEquals(tSub.ChiefComplaint, "Fever", "Chief complaint stored")
		Do $$$AssertEquals(tSub.ProcedureCodes, "PROC001", "Single-entry array reads as plain value")
		Do $$$AssertEquals(tSub.EstimatedCost, 10000.00, "Quoted comma-separated cost stored numeric")
		Do $$$AssertEquals(tSub.PersonVisitNumber, "VN-2569-100245", "person.visit_number (new in V1.0.3) stored")
	}
}

/// PostPreAuth also projects into the group-2 tables the local reads serve --
/// and is the ONLY write path into visit_info / visit_procedure anywhere in
/// the spec, so a regression here silently empties those tables forever.
Method TestPreAuthSnapshotsPreAuthVisitAndProcedures()
{
	Set tReq = ..MakePreAuthRequest()
	Set tOp = ##class(D1.Mock.BO.PreAuthStoreOperation).%New("Test PreAuth Store")
	Do $$$AssertStatusOK(tOp.Store(tReq, .tResp), "Store runs")

	// claim_id has no source in the request, so IRIS generates it:
	// auth_id when sent, else "REQ-"_admission_number.
	Set tClaimId = "REQ-VN-2569-100245"
	Set tPreAuth = ..OpenBy("D1.Mock.Data.ClaimPreAuth", "ClaimId", tClaimId)
	If $$$AssertTrue($IsObject(tPreAuth), "ClaimPreAuth row created by the snapshot") {
		Do $$$AssertEquals(tPreAuth.ClaimCaseNumber, "", "claim_case_number NOT generated -- stays empty until PatchPreAuth supplies one")
		Do $$$AssertEquals(tPreAuth.ClaimStatus, "Pre-Authorize Submitted", "claim_status from auth_status")
		Do $$$AssertEquals(tPreAuth.AdmissionNumber, "VN-2569-100245", "Admission carried through")
		Do $$$AssertEquals(tPreAuth.EstimatedCost, 10000.00, "Cost normalized to numeric")
	}

	Set tVisit = ..OpenBy("D1.Mock.Data.ClaimVisit", "VisitNumber", "VN-2569-100245")
	If $$$AssertTrue($IsObject(tVisit), "ClaimVisit row created by the snapshot") {
		Do $$$AssertEquals(tVisit.ChiefComplaint, "Fever", "Chief complaint reached visit_info")
		Do $$$AssertEquals(tVisit.HospitalNumber, "HN00012345", "Hospital number carried through")
	}

	Do $$$AssertEquals(..CountWhere("D1_Mock_Data.ClaimVisitProcedure", "VisitNumber", "VN-2569-100245"), 1, "One visit_procedure row per submitted procedure")
}

// ------------------------------------------------------- Group-2 resolver

/// Every identity branch reaches the seeded demo claim thread.
Method TestClaimIdentityResolverAllBranches()
{
	Do ##class(D1.Mock.Util.ClaimIdentityResolver).Resolve("HN", "HN000001", .tHN, .tAN)
	Do $$$AssertEquals(tHN, "HN000001", "HN resolves directly")
	Do $$$AssertEquals(tAN, "", "HN implies no single admission")

	Do ##class(D1.Mock.Util.ClaimIdentityResolver).Resolve("CID", "1103701234567", .tHN, .tAN)
	Do $$$AssertEquals(tHN, "HN000001", "CID resolves via ClaimPatient")

	Do ##class(D1.Mock.Util.ClaimIdentityResolver).Resolve("VN", "VN2026080001", .tHN, .tAN)
	Do $$$AssertEquals(tHN, "HN000001", "VN resolves via ClaimVisit")

	Do ##class(D1.Mock.Util.ClaimIdentityResolver).Resolve("AN", "AN2026080001", .tHN, .tAN)
	Do $$$AssertEquals(tHN, "HN000001", "AN resolves via ClaimAdmission")
	Do $$$AssertEquals(tAN, "AN2026080001", "AN also yields the admission number")

	Do ##class(D1.Mock.Util.ClaimIdentityResolver).Resolve("AN", "AN-UNKNOWN", .tHN, .tAN)
	Do $$$AssertEquals(tHN, "", "Unknown identity resolves to empty, not an error")

	Do $$$AssertStatusNotOK(##class(D1.Mock.Util.ClaimIdentityResolver).Resolve("XX", "whatever", .tHN, .tAN), "Unsupported identity_type is an error status")
}

// ------------------------------------------------------ Group-2 read APIs

Method TestD1GetPatientReturnsSeededDemographics()
{
	Set tReq = ##class(D1.Mock.Msg.GetPatientRequest).%New()
	Set tReq.IdentityType = "HN", tReq.IdentityNo = "HN000001"
	Set tOp = ##class(D1.Mock.BO.D1GetPatientOperation).%New("Test D1GetPatient")
	Do $$$AssertStatusOK(tOp.GetPatient(tReq, .tResp), "Read runs")
	Do $$$AssertEquals(tResp.ResponseCode, "200", "200")
	Do $$$AssertEquals(tResp.Patient.Count(), 1, "One patient wrapper (D1GetPatient's nested shape, not GetPatient's flat one)")
	Do $$$AssertEquals(tResp.Patient.GetAt(1).PatientInfo.FirstName, "Somchai", "Demographics served from IRIS's own table")

	Set tReq.IdentityNo = "HN-UNKNOWN"
	Do $$$AssertStatusOK(tOp.GetPatient(tReq, .tMiss), "Unknown read runs")
	Do $$$AssertEquals(tMiss.ResponseCode, "404", "Unknown identity -> in-band 404")
}

Method TestD1GetPolicyReturnsInsurerAndPolicy()
{
	Set tReq = ##class(D1.Mock.Msg.D1GetPolicyRequest).%New()
	Set tReq.AdmissionNumber = "AN2026080001"
	Set tOp = ##class(D1.Mock.BO.D1GetPolicyOperation).%New("Test D1GetPolicy")
	Do $$$AssertStatusOK(tOp.GetPolicy(tReq, .tResp), "Read runs")
	Do $$$AssertEquals(tResp.ResponseCode, "200", "200")
	Do $$$AssertEquals(tResp.Insurer.CompanyCode, "AIA", "insurer block (new in V1.0.3) populated")
	Do $$$AssertEquals(tResp.Insurer.CompanyName, "American International Assurance Co., Ltd", "company_name (new dict column) served")
	Do $$$AssertEquals(tResp.Policies.PolicyNumber, "AIA-TH-998821", "policies is a single object in V1.0.3")
}

Method TestD1GetBenefitReturnsNestedCoverageItems()
{
	Set tReq = ##class(D1.Mock.Msg.D1GetBenefitRequest).%New()
	Set tReq.PolicyNumber = "AIA-TH-998821", tReq.CompanyCode = "AIA"
	Set tOp = ##class(D1.Mock.BO.D1GetBenefitOperation).%New("Test D1GetBenefit")
	Do $$$AssertStatusOK(tOp.GetBenefit(tReq, .tResp), "Read runs")
	Do $$$AssertEquals(tResp.ResponseCode, "200", "200")
	Do $$$AssertEquals(tResp.BenefitsInfo.Count(), 3, "All seeded benefits returned")
	Do $$$AssertEquals(tResp.HospitalNumber, "HN000001", "Claim context echoed from the policy row")
	// Seeded ICU benefit is deliberately exhausted -- exercises the enum.
	Set tFoundExhausted = 0
	For i = 1:1:tResp.BenefitsInfo.Count() {
		Set:tResp.BenefitsInfo.GetAt(i).BenefitStatus="exhausted" tFoundExhausted = 1
		Do $$$AssertTrue(tResp.BenefitsInfo.GetAt(i).CoverageItems.Count() > 0, "Each benefit nests at least one coverage item")
	}
	Do $$$AssertEquals(tFoundExhausted, 1, "The exhausted-benefit case is represented")
}

/// The BETWEEN boundary pair -- the assertion most likely to catch an
/// off-by-one, and the reason the out-of-range case is tested explicitly.
Method TestD1GetPreAuthInfoDateRangeBoundaries()
{
	Set tOp = ##class(D1.Mock.BO.D1GetPreAuthInfoOperation).%New("Test D1GetPreAuthInfo")

	Set tIn = ##class(D1.Mock.Msg.D1GetPreAuthInfoRequest).%New()
	Set tIn.StartReqDate = "2026-07-01 00:00:00", tIn.EndReqDate = "2026-07-31 00:00:00"
	Set tIn.IdentityType = "AN"
	Do $$$AssertStatusOK(tOp.GetPreAuthInfo(tIn, .tRespIn), "In-range read runs")
	Do $$$AssertEquals(tRespIn.PreAuth.Count(), 1, "Seeded pre-auth (2026-07-09) falls inside the range")
	Do $$$AssertEquals(tRespIn.PreAuth.GetAt(1).HospitalNumber, "HN000001", "Row carries its own hospital_number (V1.0.3 array shape)")

	Set tOut = ##class(D1.Mock.Msg.D1GetPreAuthInfoRequest).%New()
	Set tOut.StartReqDate = "2026-08-01 00:00:00", tOut.EndReqDate = "2026-08-31 00:00:00"
	Set tOut.IdentityType = "AN"
	Do $$$AssertStatusOK(tOp.GetPreAuthInfo(tOut, .tRespOut), "Out-of-range read runs")
	Do $$$AssertEquals(tRespOut.PreAuth.Count(), 0, "A pre-auth outside the range is excluded")
}

Method TestD1GetAdmissionByEachIdentityTypeIncludingCostFields()
{
	Set tOp = ##class(D1.Mock.BO.D1GetAdmissionOperation).%New("Test D1GetAdmission")
	// This endpoint kept the wider VN/HN/AN set even though group-1's
	// GetAdmission narrowed to VN/AN -- all three must reach the same row.
	Set tTypes = $ListBuild("AN", "HN", "VN")
	Set tValues = $ListBuild("AN2026080001", "HN000001", "VN2026080001")
	For i = 1:1:$ListLength(tTypes) {
		Set tReq = ##class(D1.Mock.Msg.GetAdmissionRequest).%New()
		Set tReq.IdentityType = $List(tTypes, i), tReq.IdentityNo = $List(tValues, i)
		Do $$$AssertStatusOK(tOp.GetAdmission(tReq, .tResp), "Read runs for " _ $List(tTypes, i))
		Do $$$AssertEquals(tResp.AdmissionNumber, "AN2026080001", $List(tTypes, i) _ " reaches the seeded admission")
	}
	// The two fields newly exposed in V1.0.3 must actually be wired up.
	Do $$$AssertEquals(tResp.Admission.EstimatedLengthOfStay, "4", "estimated_lengthofstay served")
	Do $$$AssertEquals(tResp.Admission.EstimatedCost, 125000.00, "estimated_cost served")
	// Empty on a patient still admitted -- correct, not a defect. The demo row
	// is seeded discharged so the field is exercised rather than assumed.
	Do $$$AssertEquals(tResp.Admission.ActualDischargeDate, "2026-08-05 00:00:00", "actual_discharge_date served")
	Do $$$AssertEquals(tResp.Admission.ExpectedDischargeDate, "2026-08-05 00:00:00", "expected_discharge_date served")
}

/// Documents the single-object-despite-range-query behaviour as an
/// intentional, tested choice rather than an accident.
Method TestD1GetDischargeInfoReturnsMostRecentInRange()
{
	Set tOp = ##class(D1.Mock.BO.D1GetDischargeInfoOperation).%New("Test D1GetDischargeInfo")
	Set tReq = ##class(D1.Mock.Msg.D1GetDischargeInfoRequest).%New()
	// Range is on DISCHARGE date now -- the seeded patient left on 2026-08-05.
	Set tReq.StartReqDate = "2026-08-01 00:00:00", tReq.EndReqDate = "2026-08-31 00:00:00"
	Set tReq.IdentityType = "AN"
	Do $$$AssertStatusOK(tOp.GetDischargeInfo(tReq, .tResp), "In-range read runs")
	Do $$$AssertEquals(tResp.ResponseCode, "200", "200")
	// V1.0.4: discharge is an ARRAY, each row split into insurer_info +
	// discharge_info. It was a single object with the identifiers on the
	// response root until this revision.
	Do $$$AssertEquals(tResp.Discharge.Count(), 1, "One seeded discharge in range")
	Set tEntry = tResp.Discharge.GetAt(1)
	Do $$$AssertEquals(tEntry.InsurerInfo.HospitalNumber, "HN000001", "hospital_number nested under insurer_info")
	Do $$$AssertEquals(tEntry.InsurerInfo.AdmissionNumber, "AN2026080001", "admission_number nested under insurer_info")
	Do $$$AssertEquals(tEntry.DischargeInfo.DischargeId, "REQ000000D1", "discharge_id nested under discharge_info")
	Do $$$AssertEquals(tEntry.DischargeInfo.GlNumber, "GCL-12345", "Guarantee letter served")
	Do $$$AssertEquals(tEntry.DischargeInfo.DischargeStatus, "Approved", "discharge_status served")

	Set tReq.StartReqDate = "2026-01-01 00:00:00", tReq.EndReqDate = "2026-01-31 00:00:00"
	Do $$$AssertStatusOK(tOp.GetDischargeInfo(tReq, .tMiss), "Out-of-range read runs")
	Do $$$AssertEquals(tMiss.ResponseCode, "404", "Nothing in range -> in-band 404")
}

// ----------------------------------------------------- Group-2 write APIs

/// The base64 round trip: what goes in as encoded text must come back out of
/// the stream as the original bytes.
/// 
/// The Thai content is deliberate -- it forces the trip through UTF-8. The
/// wire carries base64 of BYTES, never of a wide character string, so the
/// test encodes the way a real client does: UTF-8 out, base64, and back.
/// (Handing wide characters straight to Base64Encode is an <ILLEGAL VALUE>.)
Method TestPostFilesBase64RoundTrip()
{
	Set tOriginal = "D1 claim receipt: ใบรับรองแพทย์ 12345"
	Set tBytes = $ZConvert(tOriginal, "O", "UTF8")
	Set tReq = ##class(D1.Mock.Msg.PostFilesRequest).%New()
	Set tReq.CrudStatus = "0"
	Set tReq.HospitalNumber = "HN000001"
	Set tReq.AdmissionNumber = "AN2026080001"
	Set tReq.UpdateDate = "2026-08-07 10:00:00"
	Set tEntry = ##class(D1.Mock.Msg.SourceFileInfo).%New()
	Set tEntry.SourceId = "PDF01"
	Set tEntry.SourceName = "RAMA9_receipt"
	Set tEntry.SourceType = "pdf"
	Set tEntry.SourceFile = $System.Encryption.Base64Encode(tBytes)
	Do tReq.SourceInfo.Insert(tEntry)

	Set tOp = ##class(D1.Mock.BO.PostFilesOperation).%New("Test PostFiles")
	Do $$$AssertStatusOK(tOp.Store(tReq, .tResp), "Store runs")
	Do $$$AssertEquals(tResp.ResponseCode, "200", "200")

	Set tFile = ..OpenBy("D1.Mock.Data.ClaimFile", "SourceId", "PDF01")
	If $$$AssertTrue($IsObject(tFile), "ClaimFile row created") {
		Do tFile.FileContent.Rewind()
		Set tRead = tFile.FileContent.Read(32000)
		Do $$$AssertEquals(tRead, tBytes, "Decoded stream holds the original bytes")
		Do $$$AssertEquals($ZConvert(tRead, "I", "UTF8"), tOriginal, "Bytes read back as the original text")
		Do $$$AssertEquals(tFile.SourceType, "pdf", "Metadata stored alongside the content")
	}
}

Method TestPostFilesInsertsOneRowPerSourceEntry()
{
	Set tReq = ##class(D1.Mock.Msg.PostFilesRequest).%New()
	Set tReq.CrudStatus = "0"
	Set tReq.HospitalNumber = "HN000001"
	Set tReq.AdmissionNumber = "AN2026080001"
	For i = 1:1:3 {
		Set tEntry = ##class(D1.Mock.Msg.SourceFileInfo).%New()
		Set tEntry.SourceId = "PDF0" _ i
		Set tEntry.SourceName = "file" _ i
		Set tEntry.SourceType = "pdf"
		Set tEntry.SourceFile = $System.Encryption.Base64Encode("content " _ i)
		Do tReq.SourceInfo.Insert(tEntry)
	}
	Set tOp = ##class(D1.Mock.BO.PostFilesOperation).%New("Test PostFiles")
	Do $$$AssertStatusOK(tOp.Store(tReq, .tResp), "Store runs")
	Do $$$AssertEquals(..CountWhere("D1_Mock_Data.ClaimFile", "AdmissionNumber", "AN2026080001"), 3, "Three source_info entries -> three rows")
}

Method TestPostFilesValidationRejectsMissingFields()
{
	Set tOp = ##class(D1.Mock.BO.PostFilesOperation).%New("Test PostFiles")
	Set tBad = ##class(D1.Mock.Msg.PostFilesRequest).%New()
	Do $$$AssertStatusOK(tOp.Store(tBad, .tResp), "Invalid payload still returns a status")
	Do $$$AssertEquals(tResp.ResponseCode, "400", "Missing mandatory fields -> in-band 400")
}

/// The behaviour most worth guarding on the discharge path: without the
/// snapshot, the local read APIs would 404 for a claim IRIS has just stored.
Method TestPostDischargeSnapshotsPatientAdmissionPolicyDiagnosis()
{
	Set tReq = ##class(D1.Mock.Msg.PostDischargeRequest).%New()
	Set tReq.CrudStatus = "0"
	Set tReq.ClaimId = "REQ-DISCHARGE-1"
	Set tReq.ClaimCaseNumber = "PA-2026-071122"
	Set tReq.ClaimStatus = "Discharge Requested"
	Set tReq.ClaimPerson.HospitalNumber = "HN000009"
	Set tReq.ClaimPerson.CitizenId = "9999999999999"
	Set tReq.ClaimPerson.FirstName = "Nid"
	Set tReq.ClaimPerson.LastName = "Discharge"
	Set tReq.ClaimPerson.Gender = "female"
	Set tReq.ClaimPerson.BirthDate = "1979-02-02 00:00:00"
	Set tReq.ClaimPerson.Address = "Bangkok, Thailand"
	Set tReq.ClaimPerson.PhoneNumber = "081-000-0000"
	Set tReq.AdmissionInfo.AdmissionNumber = "AN-DISCHARGE-1"
	Set tReq.AdmissionInfo.AdmissionDate = "2026-08-01 00:00:00"
	Set tReq.AdmissionInfo.WardNumber = "WARD-09"
	Set tReq.AdmissionInfo.WardType = "Medical Ward"
	Set tReq.AdmissionInfo.ActualDischargeDate = "2026-08-05 00:00:00"
	Set tReq.Insurer.CompanyCode = "MTL"
	Set tReq.Insurer.CompanyName = "Muang Thai Life Assurance Public Company Limited"
	Set tReq.PoliciesInfo.PolicyNumber = "MTL-TH-998821"
	Set tReq.PoliciesInfo.PolicyId = "POL000002"
	Set tReq.PoliciesInfo.PolicyType = "Health"
	Set tDx = ##class(D1.Mock.Msg.DiagnosisInfo).%New()
	Set tDx.DiagnosisType = "PRIMARY", tDx.Code = "ICD-10-CM", tDx.Name = "J18.9 - Pneumonia"
	Do tReq.DiagnosisInfo.Insert(tDx)
	Set tReq.AttendingPhysician.Id = "S67890"
	Set tReq.BillingInfo.Currency = "THB"
	Set tReq.BillingInfo.TotalCharge = 150000.00
	Set tReq.BillingInfo.NetCharge = 145000.00
	Set tReq.BillingInfo.InsurancePayable = 143000.00

	Do $$$AssertEquals(##class(D1.Mock.BP.PostDischargeProcess).Validate(tReq), "", "Complete payload validates clean")

	Set tOp = ##class(D1.Mock.BO.PostDischargeOperation).%New("Test PostDischarge")
	Do $$$AssertStatusOK(tOp.Store(tReq, .tResp), "Store runs")
	Do $$$AssertEquals(tResp.ResponseCode, "200", "200")

	// The write-through: all four snapshot tables, not just discharge+billing.
	Do $$$AssertTrue($IsObject(..OpenBy("D1.Mock.Data.ClaimDischarge", "DischargeId", "REQ-DISCHARGE-1")), "discharge_info written")
	Do $$$AssertTrue($IsObject(..OpenBy("D1.Mock.Data.ClaimBilling", "DischargeId", "REQ-DISCHARGE-1")), "billing_info written")
	Set tPatient = ..OpenBy("D1.Mock.Data.ClaimPatient", "HospitalNumber", "HN000009")
	If $$$AssertTrue($IsObject(tPatient), "patient_info snapshot written") {
		Do $$$AssertEquals(tPatient.FirstName, "Nid", "Patient snapshot carries the posted name")
	}
	Set tAdm = ..OpenBy("D1.Mock.Data.ClaimAdmission", "AdmissionNumber", "AN-DISCHARGE-1")
	If $$$AssertTrue($IsObject(tAdm), "admission_info snapshot written") {
		Do $$$AssertEquals(tAdm.WardType, "Medical Ward", "Admission snapshot carries ward_type")
	}
	Set tPolicy = ..OpenBy("D1.Mock.Data.ClaimPolicy", "AdmissionNumber", "AN-DISCHARGE-1")
	If $$$AssertTrue($IsObject(tPolicy), "policy_info snapshot written") {
		Do $$$AssertEquals(tPolicy.CompanyName, "Muang Thai Life Assurance Public Company Limited", "Insurer block snapshot")
	}
	Do $$$AssertEquals(..CountWhere("D1_Mock_Data.ClaimDiagnosis", "AdmissionNumber", "AN-DISCHARGE-1"), 1, "diagnosis snapshot written")

	// The duplicate guard the BPL switches on.
	Do $$$AssertTrue(##class(D1.Mock.BP.PostDischargeProcess).DischargeExists("REQ-DISCHARGE-1"), "Stored discharge is visible to the 409 guard")
	Do $$$AssertTrue('##class(D1.Mock.BP.PostDischargeProcess).DischargeExists("REQ-NEVER-SENT"), "Unknown claim id is not")
}

/// gl_number / discharge_status / the GL date are insurer decision fields with
/// no source in any request, so IRIS generates placeholders. Without them the
/// D1GetDischargeInfo response comes back with empty fields.
/// 
/// Also guards the more serious bug: AuthorizationDate drives the range query,
/// so a discharge posted while actual_discharge_date is still empty (normal at
/// pre-auth stage) used to be stored but permanently unfindable.
/// V1.0.5: PostDischarge derives NOTHING. gl_number, the GL date and every
/// authorization_* field arrive via API_PatchDischarge; IRIS used to invent
/// them, including copying authorization_amount from insurance_payable.
/// 
/// Also pins the consequence of filtering on discharge_date: a claim still at
/// pre-auth stage has no discharge date, so it is correctly ABSENT from a
/// discharge-date range. That is not the old invisible-row bug -- D1 finds
/// those through GetRecordList, which filters on status rather than date.
Method TestPostDischargeDerivesNothing()
{
	Set tReq = ..MakeDischargeRequest("REQ-GL-1", "AN2026080001", "HN000001")
	// Pre-auth stage: the patient has not been discharged yet.
	Set tReq.AdmissionInfo.ActualDischargeDate = ""

	Set tOp = ##class(D1.Mock.BO.PostDischargeOperation).%New("Test PostDischarge")
	Do $$$AssertStatusOK(tOp.Store(tReq, .tResp), "Store runs")

	Set tRow = ..OpenBy("D1.Mock.Data.ClaimDischarge", "DischargeId", "REQ-GL-1")
	If $$$AssertTrue($IsObject(tRow), "Discharge stored") {
		Do $$$AssertEquals(tRow.GlNumber, "", "gl_number not invented")
		Do $$$AssertEquals(tRow.DischargeGlDate, "", "GL date not invented")
		Do $$$AssertEquals(tRow.AuthorizationDate, "", "authorization_date not copied from the discharge date")
		Do $$$AssertEquals(tRow.AuthorizationAmount, "", "authorization_amount not copied from insurance_payable")
		Do $$$AssertEquals(tRow.AuthorizationTitle, "", "authorization identity not invented")
		Do $$$AssertEquals(tRow.DischargeDate, "", "no discharge date, because none was sent")
		// V1.0.6+: claim_status is Required and IRIS stores exactly what's sent --
		// MakeDischargeRequest's default matches the spec's own sample.
		Do $$$AssertEquals(tRow.DischargeStatus, "Discharge Requested", "discharge_status from claim_status")
	}

	// Absent from a discharge-date range: correct, it has no discharge date.
	Set tRead = ##class(D1.Mock.Msg.D1GetDischargeInfoRequest).%New()
	Set tRead.StartReqDate = "2026-01-01 00:00:00", tRead.EndReqDate = "2026-12-31 23:59:59"
	Set tRead.IdentityType = "AN"
	Set tReadOp = ##class(D1.Mock.BO.D1GetDischargeInfoOperation).%New("Test D1GetDischargeInfo")
	Do $$$AssertStatusOK(tReadOp.GetDischargeInfo(tRead, .tReadResp), "Range read runs")
	Set tSeen = 0
	For i = 1:1:tReadResp.Discharge.Count() {
		Set:tReadResp.Discharge.GetAt(i).DischargeInfo.DischargeId="REQ-GL-1" tSeen = 1
	}
	Do $$$AssertEquals(tSeen, 0, "An undischarged claim is not in a discharge-date range")

	// ...but D1 can still find it, via the worklist. This is the replacement
	// for the synthesised date, and it lives on the right side of the line.
	Set tWl = ##class(D1.Mock.Msg.GetRecordListRequest).%New()
	Set tWl.ListMode = "Discharge", tWl.CompanyCode = "AIA"
	Set tWlOp = ##class(D1.Mock.BO.GetRecordListOperation).%New("Test GetRecordList")
	Do $$$AssertStatusOK(tWlOp.GetRecordList(tWl, .tWlResp), "Worklist runs")
	Set tFound = 0
	For i = 1:1:tWlResp.RecordList.Count() {
		Set:tWlResp.RecordList.GetAt(i).AdmissionNumber="AN2026080001" tFound = 1
	}
	Do $$$AssertEquals(tFound, 1, "GetRecordList is how D1 finds an undecided discharge")
}

/// The fallback: a ward with no row in the master degrades to CARETYPDesc
/// rather than going empty. Empty is the SIT symptom this whole change is
/// meant to stop coming back.
Method TestWardResolverFallsBackToCareType()
{
	Set tR = "D1.Mock.Util.WardResolver"
	Do $$$AssertEquals($classmethod(tR, "ResolveWardType", "WARD01", "ignored"), "Medical Ward", "Known ward code resolves from the master")
	Do $$$AssertEquals($classmethod(tR, "ResolveWardType", "Medical Ward 1", "ignored"), "Medical Ward", "Known ward DESCRIPTION resolves too (PAAdm sends WARDDesc)")
	Do $$$AssertEquals($classmethod(tR, "ResolveWardType", "ICU01", "ignored"), "ICU", "A second seeded ward, to prove it is a real lookup")
	Do $$$AssertEquals($classmethod(tR, "ResolveWardType", "WARD-NOT-SEEDED", "Day Case"), "Day Case", "Unknown ward falls back to care type")
	Do $$$AssertEquals($classmethod(tR, "ResolveWardType", "", "Day Case"), "Day Case", "Empty ward falls back to care type")
	Do $$$AssertEquals($classmethod(tR, "ResolveWardType", "WARD-NOT-SEEDED", ""), "", "No ward and no care type stays empty, never guessed")
}

/// V1.0.4 turned this response into an array. A range covering two discharges
/// must return both -- the old single-object shape silently dropped all but
/// the most recent, so a test asserting one row would have passed regardless.
Method TestD1GetDischargeInfoReturnsEveryMatchInRange()
{
	Set tOp = ##class(D1.Mock.BO.PostDischargeOperation).%New("Test PostDischarge")
	Set tA = ..MakeDischargeRequest("REQ-ARR-1", "AN-ARR-1", "HN00ARR01")
	Set tA.AdmissionInfo.ActualDischargeDate = "2026-06-10 00:00:00"
	Do $$$AssertStatusOK(tOp.Store(tA, .tR1), "First discharge stored")
	Set tB = ..MakeDischargeRequest("REQ-ARR-2", "AN-ARR-2", "HN00ARR02")
	Set tB.AdmissionInfo.ActualDischargeDate = "2026-06-20 00:00:00"
	Do $$$AssertStatusOK(tOp.Store(tB, .tR2), "Second discharge stored")

	Set tReq = ##class(D1.Mock.Msg.D1GetDischargeInfoRequest).%New()
	Set tReq.StartReqDate = "2026-06-01 00:00:00", tReq.EndReqDate = "2026-06-30 00:00:00"
	Set tReq.IdentityType = "AN"
	Set tReadOp = ##class(D1.Mock.BO.D1GetDischargeInfoOperation).%New("Test D1GetDischargeInfo")
	Do $$$AssertStatusOK(tReadOp.GetDischargeInfo(tReq, .tResp), "Range read runs")
	Do $$$AssertEquals(tResp.ResponseCode, "200", "200")
	Do $$$AssertEquals(tResp.Discharge.Count(), 2, "BOTH rows in range are returned")
	// ORDER BY AuthorizationDate DESC -- most recent first.
	Do $$$AssertEquals(tResp.Discharge.GetAt(1).DischargeInfo.DischargeId, "REQ-ARR-2", "Most recent first")
	Do $$$AssertEquals(tResp.Discharge.GetAt(2).DischargeInfo.DischargeId, "REQ-ARR-1", "Then the older one")

	// Each row is self-contained: identifiers travel with it, not on the root.
	Do $$$AssertEquals(tResp.Discharge.GetAt(1).InsurerInfo.HospitalNumber, "HN00ARR02", "Row 1 carries its own hospital_number")
	Do $$$AssertEquals(tResp.Discharge.GetAt(2).InsurerInfo.HospitalNumber, "HN00ARR01", "Row 2 carries its own")

	// Nothing in range -> in-band 404, unchanged by the array switch.
	Set tReq.StartReqDate = "2026-01-01 00:00:00", tReq.EndReqDate = "2026-01-31 00:00:00"
	Do $$$AssertStatusOK(tReadOp.GetDischargeInfo(tReq, .tMiss), "Out-of-range read runs")
	Do $$$AssertEquals(tMiss.ResponseCode, "404", "Empty range still 404s")
	Do $$$AssertEquals(tMiss.Discharge.Count(), 0, "and returns an empty array, not a stub row")
}

/// V1.0.4 renumbered D1GetPreAuthInfo so estimated_cost is a child of each
/// preauth[] row. It used to sit on the response root, where a multi-row
/// result could only report one value.
Method TestD1GetPreAuthInfoCostIsPerRow()
{
	Set tOp = ##class(D1.Mock.BO.D1GetPreAuthInfoOperation).%New("Test D1GetPreAuthInfo")
	Set tReq = ##class(D1.Mock.Msg.D1GetPreAuthInfoRequest).%New()
	Set tReq.StartReqDate = "2026-07-01 00:00:00", tReq.EndReqDate = "2026-07-31 00:00:00"
	Set tReq.IdentityType = "AN"
	Do $$$AssertStatusOK(tOp.GetPreAuthInfo(tReq, .tResp), "Read runs")
	Do $$$AssertEquals(tResp.ResponseCode, "200", "200")
	If $$$AssertTrue(tResp.PreAuth.Count() > 0, "Seeded pre-auth in range") {
		Do $$$AssertEquals(tResp.PreAuth.GetAt(1).EstimatedCost, 10000.00, "estimated_cost served on the ROW")
	}
	Do $$$AssertTrue('##class(%Dictionary.CompiledProperty).%ExistsId("D1.Mock.Msg.D1GetPreAuthInfoResponse||EstimatedCost"), "and no longer on the response root")
}

// ------------------------------------------------- V1.0.5

/// company_code is a tenancy boundary, not a lookup key. Three outcomes must
/// stay distinct -- collapsing 403 into 404 would let a caller probe which
/// admission numbers exist.
Method TestCompanyResolverThreeOutcomes()
{
	Set tR = "D1.Mock.Util.ClaimCompanyResolver"
	// Seeded: AN2026080001 belongs to AIA.
	Do $$$AssertEquals($classmethod(tR, "Check", "AN2026080001", "AIA", .tMsg), "200", "Right insurer proceeds")
	Do $$$AssertEquals($classmethod(tR, "Check", "AN2026080001", "MTL", .tMsg), "403", "Wrong insurer is REFUSED, not 404")
	Do $$$AssertEquals($classmethod(tR, "Check", "AN-DOES-NOT-EXIST", "AIA", .tMsg), "404", "Unknown admission is 404")
	Do $$$AssertEquals($classmethod(tR, "Check", "", "AIA", .tMsg), "400", "Missing admission_number is 400")
	Do $$$AssertEquals($classmethod(tR, "Check", "AN2026080001", "", .tMsg), "400", "Missing company_code is 400")
}

/// The snapshot that makes every other V1.0.5 API work: without a ClaimPolicy
/// row the admission is invisible to the company_code join. PostPreAuth could
/// not write one before V1.0.5 -- the request had no company_code.
Method TestPostPreAuthSnapshotsPolicyInsurerAndComplaint()
{
	Set tReq = ..MakePreAuthRequest()
	Set tOp = ##class(D1.Mock.BO.PreAuthStoreOperation).%New("Test PreAuthStore")
	Do $$$AssertStatusOK(tOp.Store(tReq, .tResp), "Store runs")
	Set tAdm = tReq.Admission.AdmissionNumber

	Set tPolicy = ..OpenBy("D1.Mock.Data.ClaimPolicy", "AdmissionNumber", tAdm)
	If $$$AssertTrue($IsObject(tPolicy), "policy_info row written by PostPreAuth") {
		Do $$$AssertEquals(tPolicy.CompanyCode, "AIA", "company_code from the new insurer block")
		Do $$$AssertEquals(tPolicy.CompanyName, "American International Assurance Co., Ltd", "company_name too")
	}
	// Proves the tenancy join actually resolves for a pre-auth-only admission.
	Do $$$AssertEquals($classmethod("D1.Mock.Util.ClaimCompanyResolver", "Check", tAdm, "AIA", .tMsg), "200", "Pre-auth is now visible to the company_code join")

	Set tIns = ..OpenBy("D1.Mock.Data.ClaimInsurer", "InsurerId", "INS00001")
	Do $$$AssertTrue($IsObject(tIns), "insurer_info row written (the INSURED PERSON)")
	// The link D1 supplied, stored rather than inferred.
	Do $$$AssertEquals(tPolicy.InsurerId, "INS00001", "admission -> insurer_id link stored from the request")

	Set tCc = ..OpenBy("D1.Mock.Data.ClaimChiefComplaint", "AdmissionNumber", tAdm)
	If $$$AssertTrue($IsObject(tCc), "patient_chiefcomplain_info row written") {
		Do $$$AssertEquals(tCc.ChiefComplaint, tReq.ComplaintInfo.ChiefComplaint, "same value as the request")
		// Deliberate duplicate, same source, same call -- cannot drift.
		Set tVisit = ..OpenBy("D1.Mock.Data.ClaimVisit", "VisitNumber", tReq.Person.VisitNumber)
		If $IsObject(tVisit) {
			Do $$$AssertEquals(tVisit.ChiefComplaint, tCc.ChiefComplaint, "ClaimVisit copy agrees (redundant, to be retired)")
		}
	}
}

/// A patch writes only what it carries. An absent optional field must mean
/// "leave alone", never "clear" -- otherwise a status-only patch would wipe
/// the case number.
Method TestPatchPreAuthWritesOnlySuppliedFields()
{
	Set tOp = ##class(D1.Mock.BO.PatchPreAuthOperation).%New("Test PatchPreAuth")
	Set tBefore = ..OpenBy("D1.Mock.Data.ClaimPreAuth", "AdmissionNumber", "AN2026080001")
	Set tCaseBefore = $Select($IsObject(tBefore): tBefore.ClaimCaseNumber, 1: "")

	Set tReq = ##class(D1.Mock.Msg.PatchPreAuthRequest).%New()
	Set tReq.AdmissionNumber = "AN2026080001", tReq.CompanyCode = "AIA"
	Set tReq.ClaimStatus = "Pre-Accepted"
	Do $$$AssertStatusOK(tOp.Patch(tReq, .tResp), "Patch runs")
	Do $$$AssertEquals(tResp.ResponseCode, "200", "200")

	Set tAfter = ..OpenBy("D1.Mock.Data.ClaimPreAuth", "AdmissionNumber", "AN2026080001")
	Do $$$AssertEquals(tAfter.ClaimStatus, "Pre-Accepted", "claim_status patched")
	Do $$$AssertEquals(tAfter.ClaimCaseNumber, tCaseBefore, "claim_case_number untouched, not cleared")
}

/// The tenancy boundary, end to end through an operation.
Method TestPatchRejectsAnotherInsurer()
{
	Set tOp = ##class(D1.Mock.BO.PatchPreAuthOperation).%New("Test PatchPreAuth")
	Set tReq = ##class(D1.Mock.Msg.PatchPreAuthRequest).%New()
	Set tReq.AdmissionNumber = "AN2026080001", tReq.CompanyCode = "MTL"
	Set tReq.ClaimStatus = "Rejected"
	Do $$$AssertStatusOK(tOp.Patch(tReq, .tResp), "Patch runs")
	Do $$$AssertEquals(tResp.ResponseCode, "403", "MTL cannot patch an AIA record")

	Set tRow = ..OpenBy("D1.Mock.Data.ClaimPreAuth", "AdmissionNumber", "AN2026080001")
	Do $$$AssertNotEquals(tRow.ClaimStatus, "Rejected", "and nothing was written")
}

/// PatchDischarge is what replaced the synthetic gl_number: post leaves the
/// insurer fields empty, patch fills them.
Method TestPatchDischargeSuppliesTheInsurerDecision()
{
	Set tBefore = ..OpenBy("D1.Mock.Data.ClaimDischarge", "AdmissionNumber", "AN2026080001")
	Do $$$AssertTrue($IsObject(tBefore), "Seeded discharge present")

	Set tOp = ##class(D1.Mock.BO.PatchDischargeOperation).%New("Test PatchDischarge")
	Set tReq = ##class(D1.Mock.Msg.PatchDischargeRequest).%New()
	Set tReq.AdmissionNumber = "AN2026080001", tReq.CompanyCode = "AIA"
	Set tReq.DischargeGlNumber = "GCL-99001"
	Set tReq.DischargeStatus = "Approved"
	Set tReq.AuthorizationTitle = "Mr.", tReq.AuthorizationFirstName = "Wichai"
	Set tReq.AuthorizationLastName = "Thongchai"
	Set tReq.AuthorizationAmount = 99000.00
	Set tReq.DischargeGlDate = "2026-08-14 10:00:00"
	Do $$$AssertStatusOK(tOp.Patch(tReq, .tResp), "Patch runs")
	Do $$$AssertEquals(tResp.ResponseCode, "200", "200")

	Set tRow = ..OpenBy("D1.Mock.Data.ClaimDischarge", "AdmissionNumber", "AN2026080001")
	// discharge_gl_number on the wire, GlNumber in the table.
	Do $$$AssertEquals(tRow.GlNumber, "GCL-99001", "discharge_gl_number -> GlNumber")
	Do $$$AssertEquals(tRow.DischargeStatus, "Approved", "status patched")
	Do $$$AssertEquals(tRow.AuthorizationFirstName, "Wichai", "who authorised it")
	Do $$$AssertEquals(tRow.AuthorizationAmount, 99000.00, "amount patched")

	// The client's cross-table sync: discharge_status also overwrites the
	// pre-auth row's overall status (was seeded "Pre-Accepted").
	Set tPreAuth = ..OpenBy("D1.Mock.Data.ClaimPreAuth", "AdmissionNumber", "AN2026080001")
	Do $$$AssertEquals(tPreAuth.ClaimStatus, "Approved", "ClaimPreAuth.ClaimStatus synced from discharge_status")
}

/// The insurer's worklist: both modes, and the tenancy filter. Statuses are
/// matched against the API spec's enums exactly -- IRIS generates the spec's
/// spelling, so no tolerance for the dictionary's "Summitted" typo is needed.
Method TestGetRecordListBothModes()
{
	Set tOp = ##class(D1.Mock.BO.GetRecordListOperation).%New("Test GetRecordList")

	Set tReq = ##class(D1.Mock.Msg.GetRecordListRequest).%New()
	Set tReq.ListMode = "Discharge", tReq.CompanyCode = "AIA"
	Do $$$AssertStatusOK(tOp.GetRecordList(tReq, .tResp), "Discharge mode runs")
	Do $$$AssertEquals(tResp.ResponseCode, "200", "200")

	// Seeded discharge is "Approved", so it is NOT outstanding work.
	Set tFound = 0
	For i = 1:1:tResp.RecordList.Count() {
		Set:tResp.RecordList.GetAt(i).AdmissionNumber="AN2026080001" tFound = 1
	}
	Do $$$AssertEquals(tFound, 0, "An Approved discharge is not on the worklist")

	// Post one that IS outstanding.
	Set tPost = ##class(D1.Mock.BO.PostDischargeOperation).%New("Test PostDischarge")
	Set tD = ..MakeDischargeRequest("REQ-WL-1", "AN2026080001", "HN000001")
	Do $$$AssertStatusOK(tPost.Store(tD, .tR), "Outstanding discharge stored")
	Do $$$AssertStatusOK(tOp.GetRecordList(tReq, .tResp2), "Discharge mode re-runs")
	Set tFound = 0
	For i = 1:1:tResp2.RecordList.Count() {
		Set:tResp2.RecordList.GetAt(i).AdmissionNumber="AN2026080001" tFound = 1
	}
	Do $$$AssertEquals(tFound, 1, "A 'Discharge Requested' row IS on the worklist")
	// Customer change: both statuses on every row, whatever the mode. Neither
	// is a new stored value -- claim_status IS ClaimPreAuth.ClaimStatus.
	For i = 1:1:tResp2.RecordList.Count() {
		If tResp2.RecordList.GetAt(i).AdmissionNumber = "AN2026080001" {
			Do $$$AssertEquals(tResp2.RecordList.GetAt(i).DischargeStatus, "Discharge Requested", "discharge_status on the row")
			Do $$$AssertNotEquals(tResp2.RecordList.GetAt(i).ClaimStatus, "", "claim_status joined in from the pre-auth")
		}
	}

	// Customer change: "Waiting for Medical" no longer qualifies for either
	// list -- a record in that state is on NEITHER worklist.
	// By DischargeId, NOT AdmissionNumber: this admission now has two discharge
	// rows (the seeded REQ000000D1 and the REQ-WL-1 just posted), and keying on
	// the admission picks an arbitrary one.
	Set tWfm = ..OpenBy("D1.Mock.Data.ClaimDischarge", "DischargeId", "REQ-WL-1")
	Set tWfm.DischargeStatus = "Waiting for Medical"
	Do $$$AssertStatusOK(tWfm.%Save(), "Status moved to Waiting for Medical")
	Do $$$AssertStatusOK(tOp.GetRecordList(tReq, .tWfmResp), "Worklist re-runs")
	Set tStill = 0
	For i = 1:1:tWfmResp.RecordList.Count() {
		Set:tWfmResp.RecordList.GetAt(i).AdmissionNumber="AN2026080001" tStill = 1
	}
	Do $$$AssertEquals(tStill, 0, "'Waiting for Medical' is excluded from both lists")

	// Put it back OUTSTANDING before the tenancy check below. Left as
	// "Waiting for Medical" the row is on no list at all, so that check would
	// pass without proving anything about tenancy.
	Set tWfm.DischargeStatus = "Discharge Requested"
	Do $$$AssertStatusOK(tWfm.%Save(), "Restored to outstanding")

	// Wrong insurer sees nothing of AIA's -- and AN2026080001 IS outstanding
	// again, so an absence here is genuinely the tenancy filter working.
	Do $$$AssertStatusOK(tOp.GetRecordList(tReq, .tSanity), "AIA still sees it")
	Set tOn = 0
	For i = 1:1:tSanity.RecordList.Count() {
		Set:tSanity.RecordList.GetAt(i).AdmissionNumber="AN2026080001" tOn = 1
	}
	Do $$$AssertEquals(tOn, 1, "AIA sees the restored row")
	Set tReq.CompanyCode = "MTL"
	Do $$$AssertStatusOK(tOp.GetRecordList(tReq, .tOther), "Other insurer runs")
	Set tLeak = 0
	For i = 1:1:tOther.RecordList.Count() {
		Set:tOther.RecordList.GetAt(i).AdmissionNumber="AN2026080001" tLeak = 1
	}
	Do $$$AssertEquals(tLeak, 0, "Records do not leak across insurers")

	Set tReq.ListMode = "Nonsense", tReq.CompanyCode = "AIA"
	Do $$$AssertStatusOK(tOp.GetRecordList(tReq, .tBad), "Bad mode runs")
	Do $$$AssertEquals(tBad.ResponseCode, "400", "Unknown list_mode is rejected in-band")
}

/// The widest read in the production: one call, ten tables.
Method TestGetDocumentInfoAssemblesEveryBlock()
{
	Set tOp = ##class(D1.Mock.BO.GetDocumentInfoOperation).%New("Test GetDocumentInfo")
	Set tReq = ##class(D1.Mock.Msg.GetDocumentInfoRequest).%New()
	Set tReq.AdmissionNumber = "AN2026080001", tReq.CompanyCode = "AIA"
	Do $$$AssertStatusOK(tOp.GetDocumentInfo(tReq, .tResp), "Read runs")
	Do $$$AssertEquals(tResp.ResponseCode, "200", "200")

	Set tDoc = tResp.DocumentInfo
	Do $$$AssertEquals(tDoc.Person.HospitalNumber, "HN000001", "person from ClaimPatient")
	Do $$$AssertEquals(tDoc.Person.ClaimId, "REQ000000P1", "claim identifiers from ClaimPreAuth")
	Do $$$AssertEquals(tDoc.Insurer.CompanyCode, "AIA", "insurer company from ClaimPolicy")
	Do $$$AssertEquals(tDoc.PoliciesInfo.PolicyNumber, "AIA-TH-998821", "policy from ClaimPolicy")
	Do $$$AssertNotEquals(tDoc.ComplaintInfo.ChiefComplaint, "", "complaint from the V1.0.3 table")
	Do $$$AssertEquals(tDoc.Department.DepartmentName, "Internal Medicine", "department from ClaimVisit")
	Do $$$AssertTrue(tDoc.DiagnosisInfo.Count() > 0, "diagnoses from ClaimDiagnosis")
	Do $$$AssertTrue(tDoc.ProcedureInfo.Count() > 0, "procedures from ClaimVisitProcedure")
	Do $$$AssertEquals(tDoc.Authorization.DischargeGlNumber, "GCL-12345", "authorization from ClaimDischarge")

	// Tenancy applies to reads as well as writes.
	Set tReq.CompanyCode = "MTL"
	Do $$$AssertStatusOK(tOp.GetDocumentInfo(tReq, .tDenied), "Wrong-insurer read runs")
	Do $$$AssertEquals(tDenied.ResponseCode, "403", "Another insurer cannot read the document")
}

/// The seed carries a second claim thread deliberately awaiting decisions on
/// both sides, so the worklist has something to return on a fresh database.
/// Without it GetRecordList answers empty and demonstrates nothing.
Method TestGetRecordListFindsTheSeededOutstandingClaim()
{
	Set tOp = ##class(D1.Mock.BO.GetRecordListOperation).%New("Test GetRecordList")
	Set tReq = ##class(D1.Mock.Msg.GetRecordListRequest).%New()
	Set tReq.CompanyCode = "AIA"

	Set tReq.ListMode = "Pre-Auth"
	Do $$$AssertStatusOK(tOp.GetRecordList(tReq, .tPa), "Pre-Auth mode runs")
	Set tHit = ""
	For i = 1:1:tPa.RecordList.Count() {
		Set:tPa.RecordList.GetAt(i).AdmissionNumber="AN2026080002" tHit = tPa.RecordList.GetAt(i)
	}
	If $$$AssertTrue($IsObject(tHit), "The undecided pre-auth is listed") {
		Do $$$AssertEquals(tHit.ClaimStatus, "Pre-Authorize Submitted", "claim_status served")
		Do $$$AssertEquals(tHit.DischargeStatus, "Discharge Requested", "discharge_status joined in from the other table")
	}
	// The DECIDED thread must not appear -- it is Pre-Accepted.
	Set tDecided = 0
	For i = 1:1:tPa.RecordList.Count() {
		Set:tPa.RecordList.GetAt(i).AdmissionNumber="AN2026080001" tDecided = 1
	}
	Do $$$AssertEquals(tDecided, 0, "A Pre-Accepted claim is not outstanding work")

	Set tReq.ListMode = "Discharge"
	Do $$$AssertStatusOK(tOp.GetRecordList(tReq, .tD), "Discharge mode runs")
	Set tHit2 = 0
	For i = 1:1:tD.RecordList.Count() {
		Set:tD.RecordList.GetAt(i).AdmissionNumber="AN2026080002" tHit2 = 1
	}
	Do $$$AssertEquals(tHit2, 1, "The undecided discharge is listed")

	// Empty result: 200 with an explicit null list, per the customer's request.
	Set tReq.CompanyCode = "NOSUCHINSURER"
	Do $$$AssertStatusOK(tOp.GetRecordList(tReq, .tEmpty), "Unknown insurer runs")
	Do $$$AssertEquals(tEmpty.ResponseCode, "200", "Empty worklist is 200, not 404")
	Do $$$AssertEquals(tEmpty.RecordList.Count(), 0, "and carries no rows")
}

// ---------------------------------------------------------------- Helpers

/// Open the single row where pColumn = pValue, or "" when there is none.
/// Keeps the assertions above readable.
/// Minimal valid PostDischarge payload, parameterised so tests do not collide.
/// 
/// Carries no authorization_* fields: PostDischarge derives nothing, and the
/// insurer's decision arrives separately via API_PatchDischarge.
ClassMethod MakeDischargeRequest(pClaimId As %String, pAdmission As %String, pHospital As %String) As D1.Mock.Msg.PostDischargeRequest
{
	Set tReq = ##class(D1.Mock.Msg.PostDischargeRequest).%New()
	Set tReq.CrudStatus = "0"
	Set tReq.ClaimId = pClaimId
	Set tReq.ClaimCaseNumber = "PA-TEST-001"
	Set tReq.ClaimPerson.HospitalNumber = pHospital
	Set tReq.ClaimPerson.FirstName = "Gl"
	Set tReq.ClaimPerson.LastName = "Tester"
	Set tReq.AdmissionInfo.AdmissionNumber = pAdmission
	Set tReq.AdmissionInfo.AdmissionDate = "2026-08-01 00:00:00"
	Set tReq.AdmissionInfo.ActualDischargeDate = "2026-08-06 00:00:00"
	Set tReq.Insurer.CompanyCode = "AIA"
	Set tReq.Insurer.CompanyName = "American International Assurance Co., Ltd"
	Set tReq.PoliciesInfo.PolicyNumber = "AIA-TH-998821"
	Set tReq.ClaimStatus = "Discharge Requested"
	Set tDx = ##class(D1.Mock.Msg.DiagnosisInfo).%New()
	Set tDx.DiagnosisType = "PRIMARY", tDx.Code = "ICD-10-CM", tDx.Name = "J18.9 - Pneumonia"
	Do tReq.DiagnosisInfo.Insert(tDx)
	Set tReq.AttendingPhysician.Id = "S67890"
	Set tReq.BillingInfo.Currency = "THB"
	Set tReq.BillingInfo.InsurancePayable = 143000.00
	Quit tReq
}

ClassMethod OpenBy(pClass As %String, pColumn As %String, pValue As %String) As %RegisteredObject
{
	// IRIS SQL naming: the LAST dot separates schema from table, every
	// earlier dot becomes an underscore.
	Set tDots = $Length(pClass, ".")
	Set tTable = $Translate($Piece(pClass, ".", 1, tDots - 1), ".", "_") _ "." _ $Piece(pClass, ".", tDots)
	Set tStmt = ##class(%SQL.Statement).%New()
	Set tSC = tStmt.%Prepare("SELECT ID FROM " _ tTable _ " WHERE " _ pColumn _ " = ?")
	Quit:$$$ISERR(tSC) ""
	Set tRs = tStmt.%Execute(pValue)
	Quit:'tRs.%Next() ""
	Quit $ClassMethod(pClass, "%OpenId", tRs.%Get("ID"))
}

/// Count rows where pColumn = pValue.
ClassMethod CountWhere(pTable As %String, pColumn As %String, pValue As %String) As %Integer
{
	Set tCount = 0
	Set tStmt = ##class(%SQL.Statement).%New()
	Set tSC = tStmt.%Prepare("SELECT COUNT(*) AS cnt FROM " _ pTable _ " WHERE " _ pColumn _ " = ?")
	Quit:$$$ISERR(tSC) 0
	Set tRs = tStmt.%Execute(pValue)
	If tRs.%Next() {
		Set tCount = tRs.%Get("cnt")
	}
	Quit tCount
}

}
