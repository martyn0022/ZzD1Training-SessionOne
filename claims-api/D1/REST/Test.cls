/// In-process check for the production-free REST stack: calls each endpoint's
/// Run() directly -- no HTTP, no web application, no production.
///
/// This is what the Handle()/Run() split exists for. The Postman suite covers
/// the same endpoints over HTTP and needs a web application, a reachable web
/// server and (for the original stack) a running production; this one needs
/// nothing but the namespace, so it fails fast and locally.
///
/// Run:
///   Do ##class(%UnitTest.Manager).DebugRunTestCase("", "D1.REST.Test")
///
/// Every assertion is pinned to D1.Mock.Data.ClaimLoader's seed, which
/// OnBeforeOneTest reloads, so the tests do not depend on each other's order.
/// Thread 1 (HN000001/AN2026080001) is fully decided; thread 2
/// (HN000002/AN2026080002) is deliberately still awaiting both decisions,
/// which is what the worklist and patch tests act on.
Class D1.REST.Test Extends %UnitTest.TestCase
{

Parameter HN = "HN000001";

Parameter AN = "AN2026080001";

Parameter HN2 = "HN000002";

Parameter AN2 = "AN2026080002";

Parameter POLICY = "AIA-TH-998821";

Parameter COMPANY = "AIA";

Method OnBeforeOneTest(testname As %String) As %Status
{
	Quit ##class(D1.Mock.Data.ClaimLoader).Reset()
}

/// The six /local/* reads answer from the seeded claim thread.
Method TestReads()
{
	Set tReq = ##class(D1.Mock.Msg.GetPatientRequest).%New()
	Set tReq.IdentityType = "HN", tReq.IdentityNo = ..#HN
	Do $$$AssertStatusOK(##class(D1.REST.Impl.LocalPatient).Run(tReq, .tPat), "LocalPatient runs")
	Do $$$AssertEquals(tPat.ResponseCode, "200", "LocalPatient answers 200")
	Do $$$AssertEquals(tPat.Patient.GetAt(1).PatientInfo.FirstName, "Somchai", "LocalPatient returns the seeded patient")

	Set tReq.IdentityType = "AN", tReq.IdentityNo = ..#AN
	Do $$$AssertStatusOK(##class(D1.REST.Impl.LocalPatient).Run(tReq, .tByAn), "LocalPatient by AN runs")
	Do $$$AssertEquals(tByAn.Patient.GetAt(1).PatientInfo.HospitalNumber, ..#HN, "AN resolves to the same patient")

	Set tReq.IdentityType = "HN", tReq.IdentityNo = "HN-DOES-NOT-EXIST"
	Do $$$AssertStatusOK(##class(D1.REST.Impl.LocalPatient).Run(tReq, .tMiss), "Unknown identity runs")
	Do $$$AssertEquals(tMiss.ResponseCode, "404", "not-found is in-band, not an error status")

	Set tPol = ##class(D1.Mock.Msg.D1GetPolicyRequest).%New()
	Set tPol.AdmissionNumber = ..#AN
	Do $$$AssertStatusOK(##class(D1.REST.Impl.LocalPolicy).Run(tPol, .tPolResp), "LocalPolicy runs")
	Do $$$AssertEquals(tPolResp.Insurer.CompanyCode, ..#COMPANY, "policy carries the insurer")
	Do $$$AssertEquals(tPolResp.Policies.PolicyNumber, ..#POLICY, "policy carries the policy number")

	Set tBen = ##class(D1.Mock.Msg.D1GetBenefitRequest).%New()
	Set tBen.PolicyNumber = ..#POLICY, tBen.CompanyCode = ..#COMPANY
	Do $$$AssertStatusOK(##class(D1.REST.Impl.LocalBenefit).Run(tBen, .tBenResp), "LocalBenefit runs")
	Do $$$AssertEquals(tBenResp.BenefitsInfo.Count(), 3, "three benefits on the seeded policy")
	Set tIcu = ..BenefitNamed(tBenResp, "ICU")
	Do $$$AssertTrue($IsObject(tIcu), "the ICU benefit is present")
	Do $$$AssertEquals(tIcu.BenefitStatus, "exhausted", "ICU is exhausted")
	Do $$$AssertEquals(+tIcu.RemainingAmount, 0, "ICU has nothing left")
	Set tRoom = ..BenefitNamed(tBenResp, "Room and Board")
	Do $$$AssertTrue($IsObject(tRoom), "the room benefit is present")
	Do $$$AssertEquals(tRoom.CoverageItems.GetAt(1).CoverageCode, "ROOM", "the nested coverage items are filled")

	Set tAdm = ##class(D1.Mock.Msg.GetAdmissionRequest).%New()
	Set tAdm.IdentityType = "AN", tAdm.IdentityNo = ..#AN
	Do $$$AssertStatusOK(##class(D1.REST.Impl.LocalAdmission).Run(tAdm, .tAdmResp), "LocalAdmission runs")
	Do $$$AssertEquals(tAdmResp.Admission.WardNumber, "WARD-05", "admission carries the ward")
	Do $$$AssertEquals(tAdmResp.Admission.RoomType, "Private Room", "admission carries the room type")

	Set tPa = ##class(D1.Mock.Msg.D1GetPreAuthInfoRequest).%New()
	Set tPa.StartReqDate = "2026-07-01 00:00:00", tPa.EndReqDate = "2026-07-31 23:59:59"
	Set tPa.IdentityType = "HN", tPa.IdentityNo = ..#HN
	Do $$$AssertStatusOK(##class(D1.REST.Impl.LocalPreAuthInfo).Run(tPa, .tPaResp), "LocalPreAuthInfo runs")
	Do $$$AssertEquals(tPaResp.PreAuth.Count(), 1, "one pre-auth in the July window")
	Do $$$AssertEquals(tPaResp.PreAuth.GetAt(1).ClaimId, "REQ000000P1", "the seeded pre-auth")

	// identity_no is optional: without it the whole window comes back
	Set tPa.EndReqDate = "2026-10-31 23:59:59", tPa.IdentityNo = ""
	Do $$$AssertStatusOK(##class(D1.REST.Impl.LocalPreAuthInfo).Run(tPa, .tPaAll), "LocalPreAuthInfo without an identity runs")
	Do $$$AssertEquals(tPaAll.PreAuth.Count(), 2, "both threads fall in the wider window")

	Set tDis = ##class(D1.Mock.Msg.D1GetDischargeInfoRequest).%New()
	Set tDis.StartReqDate = "2026-08-01 00:00:00", tDis.EndReqDate = "2026-08-31 23:59:59"
	Set tDis.IdentityType = "HN", tDis.IdentityNo = ..#HN
	Do $$$AssertStatusOK(##class(D1.REST.Impl.LocalDischargeInfo).Run(tDis, .tDisResp), "LocalDischargeInfo runs")
	Do $$$AssertEquals(tDisResp.Discharge.Count(), 1, "one discharge in the August window")
	Do $$$AssertEquals(tDisResp.Discharge.GetAt(1).DischargeInfo.GlNumber, "GCL-12345", "discharge carries the guarantee letter")

	Set tDis.StartReqDate = "2027-01-01 00:00:00", tDis.EndReqDate = "2027-01-31 23:59:59"
	Do $$$AssertStatusOK(##class(D1.REST.Impl.LocalDischargeInfo).Run(tDis, .tDisMiss), "Out-of-range read runs")
	Do $$$AssertEquals(tDisMiss.ResponseCode, "404", "an empty range is a 404")
}

/// The worklist modes and the ten-table document read, plus the tenancy
/// boundary both of them enforce through company_code.
Method TestWorklistAndDocument()
{
	Set tReq = ##class(D1.Mock.Msg.GetRecordListRequest).%New()
	Set tReq.ListMode = "Pre-Auth", tReq.CompanyCode = ..#COMPANY
	Do $$$AssertStatusOK(##class(D1.REST.Impl.RecordList).Run(tReq, .tPa), "Pre-Auth worklist runs")
	Set tRow = ..RowFor(tPa, ..#AN2)
	Do $$$AssertTrue($IsObject(tRow), "the undecided pre-auth is on the worklist")
	Do $$$AssertEquals(tRow.ClaimStatus, "Pre-Authorize Submitted", "with the status that put it there")
	Do $$$AssertTrue('$IsObject(..RowFor(tPa, ..#AN)), "the already-decided thread is not")

	Set tReq.ListMode = "Discharge"
	Do $$$AssertStatusOK(##class(D1.REST.Impl.RecordList).Run(tReq, .tDis), "Discharge worklist runs")
	Set tDisRow = ..RowFor(tDis, ..#AN2)
	Do $$$AssertTrue($IsObject(tDisRow), "the undecided discharge is on the worklist")
	Do $$$AssertEquals(tDisRow.DischargeStatus, "Discharge Requested", "with the status that put it there")

	Set tReq.ListMode = "All"
	Do $$$AssertStatusOK(##class(D1.REST.Impl.RecordList).Run(tReq, .tAll), "All mode runs")
	Do $$$AssertTrue(tAll.RecordList.Count() >= 2, "All is unfiltered by status")
	Set tAllRow = ..RowFor(tAll, ..#AN)
	Do $$$AssertTrue($IsObject(tAllRow), "the decided thread appears in All")
	// UNION ALL rather than UNION: a DISTINCT-style comparison would return
	// this in SQLUPPER collation ("APPROVED") instead of the stored value.
	Do $$$AssertEquals(tAllRow.DischargeStatus, "Approved", "stored casing survives the UNION ALL")

	Set tReq.ListMode = "Nonsense"
	Do $$$AssertStatusOK(##class(D1.REST.Impl.RecordList).Run(tReq, .tBad), "Bad mode runs")
	Do $$$AssertEquals(tBad.ResponseCode, "400", "an unknown list_mode is refused")

	Set tReq.ListMode = "All", tReq.CompanyCode = "ZZZ-NO-SUCH-INSURER"
	Do $$$AssertStatusOK(##class(D1.REST.Impl.RecordList).Run(tReq, .tNone), "Unknown insurer runs")
	Do $$$AssertEquals(tNone.ResponseCode, "200", "an empty worklist is a valid answer, not a 404")

	Set tDoc = ##class(D1.Mock.Msg.GetDocumentInfoRequest).%New()
	Set tDoc.AdmissionNumber = ..#AN, tDoc.CompanyCode = ..#COMPANY
	Do $$$AssertStatusOK(##class(D1.REST.Impl.DocumentInfo).Run(tDoc, .tDocResp), "DocumentInfo runs")
	Set tInfo = tDocResp.DocumentInfo
	Do $$$AssertEquals(tInfo.Person.FirstName, "Somchai", "person block filled")
	Do $$$AssertEquals(tInfo.Person.ClaimId, "REQ000000P1", "claim identifiers come from preauth_info")
	Do $$$AssertEquals(tInfo.PoliciesInfo.PolicyNumber, ..#POLICY, "policy block filled")
	Do $$$AssertEquals(tInfo.Insurer.InsurerId, "INS00001", "insured person resolved from insurer_id")
	Do $$$AssertEquals(+tInfo.BillingInfo.TotalCharge, 150000, "billing block filled")
	Do $$$AssertEquals(tInfo.Authorization.DischargeGlNumber, "GCL-12345", "authorization block filled")
	Do $$$AssertEquals(tInfo.DiagnosisInfo.GetAt(1).Code, "E11.9", "diagnosis block filled")

	Set tDoc.CompanyCode = "BLA"
	Do $$$AssertStatusOK(##class(D1.REST.Impl.DocumentInfo).Run(tDoc, .tDenied), "Wrong-insurer read runs")
	Do $$$AssertNotEquals(tDenied.ResponseCode, "200", "another insurer cannot read the claim")
}

/// Storing an attachment: the base64 decode, the upsert, and the validation.
Method TestFiles()
{
	Set tReq = ##class(D1.Mock.Msg.PostFilesRequest).%New()
	Set tReq.CrudStatus = "0"
	Set tReq.HospitalNumber = ..#HN
	Set tReq.AdmissionNumber = ..#AN
	Set tReq.UpdateDate = "2026-08-06 10:00:00"
	Do tReq.SourceInfo.Insert(..SourceEntry("SRC001", "discharge-summary.pdf"))
	Do $$$AssertStatusOK(##class(D1.REST.Impl.Files).Run(tReq, .tResp), "Files store runs")
	Do $$$AssertEquals(tResp.ResponseCode, "200", "the store succeeds")
	Do $$$AssertEquals(..FileCount(..#AN), 1, "one row stored")

	Set tReq.CrudStatus = "1"
	Do $$$AssertStatusOK(##class(D1.REST.Impl.Files).Run(tReq, .tAgain), "Resend runs")
	Do $$$AssertEquals(tAgain.ResponseCode, "200", "the resend succeeds")
	Do $$$AssertEquals(..FileCount(..#AN), 1, "a resend upserts rather than duplicating")

	Set tAn = ..#AN, tId = ""
	&sql(SELECT ID INTO :tId FROM D1_Mock_Data.ClaimFile WHERE AdmissionNumber = :tAn)
	Do $$$AssertEquals(SQLCODE, 0, "the stored row is findable")
	Set tFile = ##class(D1.Mock.Data.ClaimFile).%OpenId(tId)
	Do $$$AssertTrue($IsObject(tFile), "the stored row opens")
	Do $$$AssertEquals(tFile.FileContent.Read(32000), "Hello D1 API", "the base64 was decoded, not stored raw")

	Set tBad = ##class(D1.Mock.Msg.PostFilesRequest).%New()
	Set tBad.CrudStatus = "0", tBad.HospitalNumber = ..#HN, tBad.AdmissionNumber = ..#AN
	Do tBad.SourceInfo.Insert(..SourceEntry("", "no-id.pdf"))
	Do $$$AssertStatusOK(##class(D1.REST.Impl.Files).Run(tBad, .tBadResp), "An invalid payload still returns a status")
	Do $$$AssertEquals(tBadResp.ResponseCode, "400", "a missing source_id is refused")
}

/// The two patch endpoints, which carry the only real branch logic in the
/// package: an absent optional field means "leave alone", never "clear", and a
/// discharge decision also overwrites the claim's overall status.
Method TestPatchSemantics()
{
	Set tPa = ##class(D1.Mock.Msg.PatchPreAuthRequest).%New()
	Set tPa.AdmissionNumber = ..#AN2, tPa.CompanyCode = ..#COMPANY
	Set tPa.ClaimStatus = "Pre-Accepted"
	Do $$$AssertStatusOK(##class(D1.REST.Impl.PreAuthPatch).Run(tPa, .tPaResp), "PreAuthPatch runs")
	Do $$$AssertEquals(tPaResp.ResponseCode, "200", "the patch succeeds")

	Set tRead = ##class(D1.Mock.Msg.D1GetPreAuthInfoRequest).%New()
	Set tRead.StartReqDate = "2026-10-01 00:00:00", tRead.EndReqDate = "2026-10-31 23:59:59"
	Set tRead.IdentityType = "HN", tRead.IdentityNo = ..#HN2
	Do $$$AssertStatusOK(##class(D1.REST.Impl.LocalPreAuthInfo).Run(tRead, .tAfter), "Read-back runs")
	Do $$$AssertEquals(tAfter.PreAuth.GetAt(1).ClaimStatus, "Pre-Accepted", "the new status was written")
	Do $$$AssertEquals(tAfter.PreAuth.GetAt(1).ClaimCaseNumber, "PA-2026-100077", "the absent field was left alone, not cleared")

	Set tPa.CompanyCode = "BLA"
	Do $$$AssertStatusOK(##class(D1.REST.Impl.PreAuthPatch).Run(tPa, .tDenied), "Wrong-insurer patch runs")
	Do $$$AssertNotEquals(tDenied.ResponseCode, "200", "another insurer cannot patch the claim")

	Set tDis = ##class(D1.Mock.Msg.PatchDischargeRequest).%New()
	Set tDis.AdmissionNumber = ..#AN2, tDis.CompanyCode = ..#COMPANY
	Set tDis.DischargeGlNumber = "GCL-99999"
	Set tDis.DischargeStatus = "Approved"
	Set tDis.AuthorizationAmount = 80000
	Do $$$AssertStatusOK(##class(D1.REST.Impl.DischargePatch).Run(tDis, .tDisResp), "DischargePatch runs")
	Do $$$AssertEquals(tDisResp.ResponseCode, "200", "the patch succeeds")

	Set tDisRead = ##class(D1.Mock.Msg.D1GetDischargeInfoRequest).%New()
	Set tDisRead.StartReqDate = "2026-10-01 00:00:00", tDisRead.EndReqDate = "2026-10-31 23:59:59"
	Set tDisRead.IdentityType = "HN", tDisRead.IdentityNo = ..#HN2
	Do $$$AssertStatusOK(##class(D1.REST.Impl.LocalDischargeInfo).Run(tDisRead, .tDisAfter), "Read-back runs")
	Set tRow = tDisAfter.Discharge.GetAt(1).DischargeInfo
	Do $$$AssertEquals(tRow.GlNumber, "GCL-99999", "the guarantee letter was written")
	Do $$$AssertEquals(+tRow.AuthorizationAmount, 80000, "the authorised amount was written")

	// The sync back onto ClaimPreAuth.ClaimStatus, so that column tracks the
	// claim's current stage rather than only its pre-auth decision.
	Set tWl = ##class(D1.Mock.Msg.GetRecordListRequest).%New()
	Set tWl.ListMode = "All", tWl.CompanyCode = ..#COMPANY
	Do $$$AssertStatusOK(##class(D1.REST.Impl.RecordList).Run(tWl, .tWlResp), "Worklist runs")
	Set tWlRow = ..RowFor(tWlResp, ..#AN2)
	Do $$$AssertTrue($IsObject(tWlRow), "the admission is on the worklist")
	Do $$$AssertEquals(tWlRow.ClaimStatus, "Approved", "discharge_status was synced onto claim_status")
}

// ----------------------------------------------------------------- Helpers

/// The benefit with this name, or "" -- the seed's row order is not part of
/// the contract, so tests must not index into it.
ClassMethod BenefitNamed(pResponse As D1.Mock.Msg.D1GetBenefitResponse, pName As %String) As D1.Mock.Msg.BenefitDetail
{
	For i = 1:1:pResponse.BenefitsInfo.Count() {
		Set tItem = pResponse.BenefitsInfo.GetAt(i)
		Return:tItem.BenefitName=pName tItem
	}
	Return ""
}

/// The worklist row for this admission, or "".
ClassMethod RowFor(pResponse As D1.Mock.Msg.GetRecordListResponse, pAdmissionNumber As %String) As D1.Mock.Msg.RecordListItem
{
	For i = 1:1:pResponse.RecordList.Count() {
		Set tItem = pResponse.RecordList.GetAt(i)
		Return:tItem.AdmissionNumber=pAdmissionNumber tItem
	}
	Return ""
}

/// One source_info[] entry carrying "Hello D1 API" as base64.
ClassMethod SourceEntry(pSourceId As %String, pName As %String) As D1.Mock.Msg.SourceFileInfo
{
	Set tEntry = ##class(D1.Mock.Msg.SourceFileInfo).%New()
	Set tEntry.SourceId = pSourceId
	Set tEntry.SourceName = pName
	Set tEntry.SourceType = "pdf"
	Set tEntry.SourceFile = "SGVsbG8gRDEgQVBJ"
	Return tEntry
}

/// How many file rows this admission holds, for the upsert assertion.
ClassMethod FileCount(pAdmissionNumber As %String) As %Integer
{
	Set tCount = 0
	&sql(SELECT COUNT(*) INTO :tCount FROM D1_Mock_Data.ClaimFile WHERE AdmissionNumber = :pAdmissionNumber)
	Return tCount
}

}
