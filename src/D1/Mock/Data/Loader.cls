/// Seeds the mock HIS tables (raw Trak shape). Run:
///   Do ##class(D1.Mock.Data.Loader).Reset()
/// or  CALL D1_Mock_Data.Loader_Reset()
/// 
/// Two demo patients threaded through every table so each group-1 API has a
/// coherent end-to-end trace:
///   1001 / HN00012345 / VN-2569-100245 -- inpatient, 1 diagnosis, 2 procedures
///   1002 / HN00067890 / VN-2569-100246 -- outpatient, 2 diagnoses (exercises
///                                         the PRIMARY/SECONDARY derivation)
/// 
/// IRIS's own claim tables are seeded separately by ClaimLoader, deliberately
/// sharing no identifiers. See docs/PRODUCTION_FLOWS.md.
Class D1.Mock.Data.Loader
{

/// Exposed as a SQL stored procedure so it can be run from the Management
/// Portal without a terminal session:  CALL D1_Mock_Data.Loader_Reset()
ClassMethod Reset() As %Status [ SqlProc ]
{
	Set tSC = $$$OK
	Try {
		Do ##class(D1.Mock.Data.PAAdm).%KillExtent()
		Do ##class(D1.Mock.Data.Patient).%KillExtent()
		Do ##class(D1.Mock.Data.CtCareProv).%KillExtent()
		Do ##class(D1.Mock.Data.CtLoc).%KillExtent()
		Do ##class(D1.Mock.Data.MrDiagnos).%KillExtent()
		Do ##class(D1.Mock.Data.MrProcedures).%KillExtent()
		Do ##class(D1.Mock.Data.MrReasonForEnc).%KillExtent()
		Do ##class(D1.Mock.Data.ArPatientBillAll).%KillExtent()
		Do ##class(D1.Mock.Ref.WardMaster).%KillExtent()

		// --- Patients: raw PA_Person shape, keyed by internal row id ---
		$$$THROWONERROR(tSC, ..AddPatient("1001", "HN00012345", "3-1258-00558-89-8", "FF5588981", "Jaidee", "Somchai", "Mr.", "Male", "15/05/1990", "99 Sukhumvit Road", "Bangkok", "081-234-5678"))
		$$$THROWONERROR(tSC, ..AddPatient("1002", "HN00067890", "1-1011-00223-45-6", "", "Wongsawat", "Malee", "Ms.", "Female", "27/03/1998", "55 Chiang Mai-Lamphun Road", "Chiang Mai", "089-765-4321"))

		// --- Episodes (PAAdm): visit AND admission -- one numbering series ---
		$$$THROWONERROR(tSC, ..AddPAAdm("VN-2569-100245", "1001", "HN00012345", "VN-2569-100245", "I", "15/05/2026", "09:00", "Internal Medicine", "S12345", "WARD01", "Acute", "สามัญ ห้องรวม", "A01", "31/07/2026", "31/07/2026"))
		$$$THROWONERROR(tSC, ..AddPAAdm("VN-2569-100246", "1002", "HN00067890", "VN-2569-100246", "O", "27/05/2026", "10:00", "General Surgery", "S67890", "", "", "", "", "27/05/2026", ""))

		// --- Care providers (CTCareProv): the practitioner master ---
		$$$THROWONERROR(tSC, ..AddCareProv("S12345", "Mr.", "Somsak", "Saksom", "12345"))
		$$$THROWONERROR(tSC, ..AddCareProv("S67890", "Dr.", "Anong", "Boonmee", "67890"))

		// --- Locations (CTLoc): the pinned department code/name source ---
		$$$THROWONERROR(tSC, ..AddCtLoc("MED", "Internal Medicine", "RAMA9"))
		$$$THROWONERROR(tSC, ..AddCtLoc("SUR", "General Surgery", "RAMA9"))

		// --- Ward master: IRIS-OWNED reference data, not a TrakCare mirror.
		// Columns mirror CTLoc (the real ward master, wards being locations)
		// except WardType, which is asserted -- TrakCare has no such field.
		// The five WardType values are D1's own data-dictionary samples.
		$$$THROWONERROR(tSC, ..AddWard("WARD01", "Medical Ward 1", "W", "Internal Medicine", "Medical Ward", "RAMA9"))
		$$$THROWONERROR(tSC, ..AddWard("WARD02", "Surgical Ward 1", "W", "General Surgery", "Surgical Ward", "RAMA9"))
		$$$THROWONERROR(tSC, ..AddWard("ICU01", "Intensive Care Unit", "W", "Critical Care", "ICU", "RAMA9"))
		$$$THROWONERROR(tSC, ..AddWard("MAT01", "Maternity Ward 1", "W", "Obstetrics", "Maternity Ward", "RAMA9"))
		$$$THROWONERROR(tSC, ..AddWard("ORT01", "Orthopedic Ward 1", "W", "Orthopedics", "Orthopedic Ward", "RAMA9"))

		// --- Diagnoses (MRDiagnos), keyed by mradm ---
		$$$THROWONERROR(tSC, ..AddDiagnosis("DX-1001-1", "VN-2569-100245", "VN-2569-100245", "ICD-10-CM", "E11", "Type 2 diabetes mellitus", "Y", "15/05/2026"))
		$$$THROWONERROR(tSC, ..AddDiagnosis("DX-1002-1", "VN-2569-100246", "VN-2569-100246", "ICD-10-CM", "J45", "Asthma", "Y", "27/05/2026"))
		$$$THROWONERROR(tSC, ..AddDiagnosis("DX-1002-2", "VN-2569-100246", "VN-2569-100246", "ICD-10-CM", "I10", "Essential hypertension", "N", "27/05/2026"))

		// --- Procedures (MRProcedures), keyed by EpisodeID ---
		$$$THROWONERROR(tSC, ..AddProcedure("PR-1001-1", "VN-2569-100245", "PROC001", "Chest X-Ray", "15/05/2026", "09:45"))
		$$$THROWONERROR(tSC, ..AddProcedure("PR-1001-2", "VN-2569-100245", "PROC002", "Complete Blood Count (CBC)", "15/05/2026", "10:15"))
		$$$THROWONERROR(tSC, ..AddProcedure("PR-1002-1", "VN-2569-100246", "PROC003", "Electrocardiogram (ECG)", "27/05/2026", "10:30"))

		// --- Chief complaints (MRReasonForEnc), keyed by mradm ---
		$$$THROWONERROR(tSC, ..AddReasonForEnc("RFE-1001", "VN-2569-100245", "Fever", "Fever and cough for 3 days", "386661006"))
		$$$THROWONERROR(tSC, ..AddReasonForEnc("RFE-1002", "VN-2569-100246", "Shortness of breath", "Wheezing since last night", "267036007"))

		// --- Bills (ARPatientBillAll), matched to the admission via EpisodeID ---
		$$$THROWONERROR(tSC, ..AddBill("1001", "VN-2569-100245", "RAMA9", 150000.00, 5000.00, 145000.00, 2000.00, 143000.00))
		$$$THROWONERROR(tSC, ..AddBill("1002", "VN-2569-100246", "RAMA9", 8500.00, 0.00, 8500.00, 8500.00, 0.00))
	}
	Catch ex {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

ClassMethod AddPatient(pId, pRegNo, pResident, pPassport, pSurname, pGivenName, pTitle, pSex, pDob, pStreet, pCity, pPhone) As %Status
{
	Set o = ##class(D1.Mock.Data.Patient).%New()
	Set o.PatientID = pId, o.RegistrationNumber = pRegNo
	Set o.PAPERResidentNumber = pResident, o.PAPERPassportNumber = pPassport
	Set o.PAPERName = pSurname, o.PAPERName2 = pGivenName, o.TTLDesc = pTitle
	Set o.CTSEXDesc = pSex, o.PAPERDob = pDob
	Set o.PAPERStName = pStreet, o.CTCITDesc = pCity, o.PAPERMobPhone = pPhone
	Quit o.%Save()
}

ClassMethod AddPAAdm(pAdmNo, pPatientId, pRegNo, pMradm, pType, pAdmDate, pAdmTime, pDepDesc, pCPCode, pWard, pCareType, pRoomType, pBed, pDischgDate, pEstDschrg) As %Status
{
	Set o = ##class(D1.Mock.Data.PAAdm).%New()
	Set o.PAADMADMNo = pAdmNo, o.PatientID = pPatientId, o.RegNo = pRegNo
	Set o.Mradm = pMradm, o.PAADMType = pType
	Set o.PAADMAdmDate = pAdmDate, o.PAADMAdmTime = pAdmTime
	Set o.DEPDesc = pDepDesc, o.CTPCPCode = pCPCode
	Set o.WARDDesc = pWard, o.CARETYPDesc = pCareType
	Set o.ROOMTDesc = pRoomType, o.BEDCode = pBed
	Set o.PAADMDischgDate = pDischgDate, o.EstDschrgDate = pEstDschrg
	Quit o.%Save()
}

ClassMethod AddCareProv(pCode, pTitle, pFirst, pSurname, pSMCNo) As %Status
{
	Set o = ##class(D1.Mock.Data.CtCareProv).%New()
	Set o.CTPCPCode = pCode, o.CTPCPTitle = pTitle
	Set o.CTPCPFirstName = pFirst, o.CTPCPSurname = pSurname
	Set o.CTPCPSMCNo = pSMCNo
	Quit o.%Save()
}

ClassMethod AddWard(pCode, pDesc, pLocType, pDepDesc, pWardType, pHospital) As %Status
{
	Set o = ##class(D1.Mock.Ref.WardMaster).%New()
	Set o.CTLOCCode = pCode, o.CTLOCDesc = pDesc, o.CTLOCType = pLocType
	Set o.DEPDesc = pDepDesc, o.WardType = pWardType, o.Hospital = pHospital
	Quit o.%Save()
}

ClassMethod AddCtLoc(pCode, pDesc, pHospital) As %Status
{
	Set o = ##class(D1.Mock.Data.CtLoc).%New()
	Set o.CTLOCCode = pCode, o.CTLOCDesc = pDesc, o.Hospital = pHospital
	Quit o.%Save()
}

ClassMethod AddDiagnosis(pId, pMradm, pAdmNo, pTerminology, pCode, pDesc, pPrinciple, pDate) As %Status
{
	Set o = ##class(D1.Mock.Data.MrDiagnos).%New()
	Set o.DiagID = pId, o.Mradm = pMradm, o.PAADMADMNo = pAdmNo
	Set o.MRDIATerminologyDesc = pTerminology
	Set o.MRCIDCode = pCode, o.MRCIDDesc = pDesc
	Set o.MRDIAPrinciple = pPrinciple, o.MRDIADate = pDate
	Quit o.%Save()
}

ClassMethod AddProcedure(pId, pEpisodeId, pCode, pDesc, pDate, pTime) As %Status
{
	Set o = ##class(D1.Mock.Data.MrProcedures).%New()
	Set o.ProcID = pId, o.EpisodeID = pEpisodeId
	Set o.OPERCode = pCode, o.OPERDesc = pDesc
	Set o.PROCDate = pDate, o.PROCTime = pTime
	Quit o.%Save()
}

ClassMethod AddReasonForEnc(pId, pMradm, pDescSnomed, pComments, pConceptId) As %Status
{
	Set o = ##class(D1.Mock.Data.MrReasonForEnc).%New()
	Set o.ReasonID = pId, o.Mradm = pMradm
	Set o.DescSnomed = pDescSnomed, o.Comments = pComments, o.ConceptID = pConceptId
	Quit o.%Save()
}

ClassMethod AddBill(pPatientId, pEpisodeId, pHospital, pGross, pDisc, pNet, pPatInv, pPayorInv) As %Status
{
	Set o = ##class(D1.Mock.Data.ArPatientBillAll).%New()
	Set o.PatientID = pPatientId, o.EpisodeID = pEpisodeId, o.Hospital = pHospital
	Set o.GrossAmount = pGross, o.DiscTotal = pDisc, o.NetAmount = pNet
	Set o.PatInvTot = pPatInv, o.PayorInvTot = pPayorInv
	Quit o.%Save()
}

}
