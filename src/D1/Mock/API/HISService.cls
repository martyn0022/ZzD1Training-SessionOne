/// Mock HIS (TrakCare) REST API, served under /api/his.
/// 
/// Routes, query params, envelopes and field names mirror the REAL TrakCare
/// contract -- raw names and all. Backed by the D1_Mock_Data raw-Trak tables.
/// Unknown keys return an empty "results" with HTTP 200.
/// 
/// Does not enforce the TUSERNAME/TPASSWORD headers it accepts.
/// See docs/PRODUCTION_FLOWS.md.
Class D1.Mock.API.HISService Extends %CSP.REST
{

Parameter CONTENTTYPE = "application/json";

Parameter CHARSET = "utf-8";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
  <Route Url="/Patient/:id" Method="GET" Call="GetPatientById" />
  <Route Url="/Patient" Method="GET" Call="GetPatients" />
  <Route Url="/PAAdmByLocType" Method="GET" Call="GetPAAdmByLocType" />
  <Route Url="/PAAdm" Method="GET" Call="GetPAAdms" />
  <Route Url="/MRDiagnos" Method="GET" Call="GetMrDiagnos" />
  <Route Url="/MRProcedures" Method="GET" Call="GetMrProcedures" />
  <Route Url="/MRReasonForEnc" Method="GET" Call="GetMrReasonForEnc" />
  <Route Url="/CTCareProv" Method="GET" Call="GetCtCareProv" />
  <Route Url="/CTLoc" Method="GET" Call="GetCtLoc" />
  <Route Url="/ARPatientBillAll" Method="GET" Call="GetArPatientBillAll" />
</Routes>
}

// ---------------------------------------------------------------- Patient

/// GET /Patient?RegistrationNo=|NationalID=|ForeignID=|EpisodeNo=
/// The identity-resolution list: thin rows carrying ID + RegistrationNo,
/// mirroring the real list's field names (which differ from the by-id shape).
ClassMethod GetPatients() As %Status
{
	Set %response.ContentType = "application/json"
	Set tRows = ..PatientRows(%request.Get("RegistrationNo"), %request.Get("NationalID"), %request.Get("ForeignID"), %request.Get("EpisodeNo"))
	Write ..ListEnvelope(tRows).%ToJSON()
	Return $$$OK
}

/// Build the patient list rows for one identity filter. Exactly one filter is
/// expected per call (matching how the resolver queries the real API); when
/// several are passed the first non-empty one wins, in the order below.
ClassMethod PatientRows(pRegistrationNo As %String = "", pNationalID As %String = "", pForeignID As %String = "", pEpisodeNo As %String = "") As %DynamicArray
{
	Set tRows = []
	Set tSql = "SELECT PatientID, RegistrationNumber FROM D1_Mock_Data.Patient WHERE "
	If pRegistrationNo '= "" {
		Set tSql = tSql _ "RegistrationNumber = ?", tArg = pRegistrationNo
	}
	ElseIf pNationalID '= "" {
		Set tSql = tSql _ "PAPERResidentNumber = ?", tArg = pNationalID
	}
	ElseIf pForeignID '= "" {
		Set tSql = tSql _ "PAPERPassportNumber = ?", tArg = pForeignID
	}
	ElseIf pEpisodeNo '= "" {
		Set tSql = tSql _ "PatientID IN (SELECT PatientID FROM D1_Mock_Data.PAAdm WHERE PAADMADMNo = ?)", tArg = pEpisodeNo
	}
	Else {
		Return tRows
	}
	Set tStmt = ##class(%SQL.Statement).%New()
	Set tSC = tStmt.%Prepare(tSql)
	Return:$$$ISERR(tSC) tRows
	Set tRs = tStmt.%Execute(tArg)
	While tRs.%Next() {
		Set tItem = {}
		Do tItem.%Set("ID", tRs.%Get("PatientID"))
		Do tItem.%Set("RegistrationNo", tRs.%Get("RegistrationNumber"))
		Do tRows.%Push(tItem)
	}
	Return tRows
}

/// GET /Patient/:id  ->  { "results": { ...raw PA_Person fields... } }
ClassMethod GetPatientById(pId As %String) As %Status
{
	Set %response.ContentType = "application/json"
	Set tEnvelope = {}
	Do tEnvelope.%Set("results", ..PatientResults(pId))
	Write tEnvelope.%ToJSON()
	Return $$$OK
}

/// Build the flat raw "results" object for one patient id.
/// Empty object when the patient is unknown.
ClassMethod PatientResults(pId As %String) As %DynamicObject
{
	Set tResults = {}
	Set tStmt = ##class(%SQL.Statement).%New()
	Set tSC = tStmt.%Prepare("SELECT RegistrationNumber, PAPERResidentNumber, PAPERPassportNumber, PAPERName, PAPERName2, TTLDesc, CTSEXDesc, PAPERDob, PAPERStName, CTCITDesc, PAPERMobPhone FROM D1_Mock_Data.Patient WHERE PatientID = ?")
	Return:$$$ISERR(tSC) tResults
	Set tRs = tStmt.%Execute(pId)
	If tRs.%Next() {
		Do tResults.%Set("RegistrationNumber", tRs.%Get("RegistrationNumber"))
		Do tResults.%Set("PAPERResidentNumber", tRs.%Get("PAPERResidentNumber"))
		Do tResults.%Set("PAPERPassportNumber", tRs.%Get("PAPERPassportNumber"))
		Do tResults.%Set("PAPERName", tRs.%Get("PAPERName"))
		Do tResults.%Set("PAPERName2", tRs.%Get("PAPERName2"))
		Do tResults.%Set("TTLDesc", tRs.%Get("TTLDesc"))
		Do tResults.%Set("CTSEXDesc", tRs.%Get("CTSEXDesc"))
		Do tResults.%Set("PAPERDob", tRs.%Get("PAPERDob"))
		Do tResults.%Set("PAPERStName", tRs.%Get("PAPERStName"))
		Do tResults.%Set("CTCITDesc", tRs.%Get("CTCITDesc"))
		Do tResults.%Set("PAPERMobPhone", tRs.%Get("PAPERMobPhone"))
	}
	Return tResults
}

// ------------------------------------------------------------------ PAAdm

/// GET /PAAdmByLocType?EpisodeNo=  ->  episode resolver rows.
/// The single-call VN/AN resolver: episode number in, the linking keys out.
ClassMethod GetPAAdmByLocType() As %Status
{
	Set %response.ContentType = "application/json"
	Set tRows = ..PAAdmByLocTypeRows(%request.Get("EpisodeNo"))
	Write ..ListEnvelope(tRows).%ToJSON()
	Return $$$OK
}

/// Resolver row shape per D1_TrakCare_Context.md: EpisodeID, AdmNo, PatientID,
/// RegNo, mradm, Hosp. The mock has no separate episode row id, so EpisodeID
/// carries the admission number.
ClassMethod PAAdmByLocTypeRows(pEpisodeNo As %String) As %DynamicArray
{
	Set tRows = []
	Quit:pEpisodeNo="" tRows
	Set tStmt = ##class(%SQL.Statement).%New()
	Set tSC = tStmt.%Prepare("SELECT PAADMADMNo, PatientID, RegNo, mradm FROM D1_Mock_Data.PAAdm WHERE PAADMADMNo = ?")
	Return:$$$ISERR(tSC) tRows
	Set tRs = tStmt.%Execute(pEpisodeNo)
	While tRs.%Next() {
		Set tItem = {}
		Do tItem.%Set("EpisodeID", tRs.%Get("PAADMADMNo"))
		Do tItem.%Set("AdmNo", tRs.%Get("PAADMADMNo"))
		Do tItem.%Set("PatientID", tRs.%Get("PatientID"))
		Do tItem.%Set("RegNo", tRs.%Get("RegNo"))
		Do tItem.%Set("mradm", tRs.%Get("mradm"))
		Do tItem.%Set("Hosp", "RAMA9")
		Do tRows.%Push(tItem)
	}
	Return tRows
}

/// GET /PAAdm?PatientID=  ->  full episode rows (visit/admission detail).
ClassMethod GetPAAdms() As %Status
{
	Set %response.ContentType = "application/json"
	Set tRows = ..PAAdmRows(%request.Get("PatientID"))
	Write ..ListEnvelope(tRows).%ToJSON()
	Return $$$OK
}

ClassMethod PAAdmRows(pPatientId As %String) As %DynamicArray
{
	Set tRows = []
	Quit:pPatientId="" tRows
	Set tStmt = ##class(%SQL.Statement).%New()
	Set tSC = tStmt.%Prepare("SELECT PAADMADMNo, PatientID, RegNo, mradm, PAADMType, PAADMAdmDate, PAADMAdmTime, DEPDesc, CTPCPCode, WARDDesc, CARETYPDesc, ROOMTDesc, BEDCode, PAADMDischgDate, EstDschrgDate FROM D1_Mock_Data.PAAdm WHERE PatientID = ?")
	Return:$$$ISERR(tSC) tRows
	Set tRs = tStmt.%Execute(pPatientId)
	While tRs.%Next() {
		Set tItem = {}
		Do tItem.%Set("PAADMADMNo", tRs.%Get("PAADMADMNo"))
		Do tItem.%Set("EpisodeID", tRs.%Get("PAADMADMNo"))
		Do tItem.%Set("PatientID", tRs.%Get("PatientID"))
		Do tItem.%Set("RegNo", tRs.%Get("RegNo"))
		Do tItem.%Set("mradm", tRs.%Get("mradm"))
		Do tItem.%Set("PAADMType", tRs.%Get("PAADMType"))
		Do tItem.%Set("PAADMAdmDate", tRs.%Get("PAADMAdmDate"))
		Do tItem.%Set("PAADMAdmTime", tRs.%Get("PAADMAdmTime"))
		Do tItem.%Set("DEPDesc", tRs.%Get("DEPDesc"))
		Do tItem.%Set("CTPCPCode", tRs.%Get("CTPCPCode"))
		Do tItem.%Set("WARDDesc", tRs.%Get("WARDDesc"))
		Do tItem.%Set("CARETYPDesc", tRs.%Get("CARETYPDesc"))
		Do tItem.%Set("ROOMTDesc", tRs.%Get("ROOMTDesc"))
		Do tItem.%Set("BEDCode", tRs.%Get("BEDCode"))
		Do tItem.%Set("PAADMDischgDate", tRs.%Get("PAADMDischgDate"))
		Do tItem.%Set("EstDschrgDate", tRs.%Get("EstDschrgDate"))
		Do tRows.%Push(tItem)
	}
	Return tRows
}

// ------------------------------------------------------- Clinical resources

/// GET /MRDiagnos?mradm=  ->  diagnosis rows for one episode.
ClassMethod GetMrDiagnos() As %Status
{
	Set %response.ContentType = "application/json"
	Set tRows = ..MrDiagnosRows(%request.Get("mradm"))
	Write ..ListEnvelope(tRows).%ToJSON()
	Return $$$OK
}

ClassMethod MrDiagnosRows(pMradm As %String) As %DynamicArray
{
	Set tRows = []
	Quit:pMradm="" tRows
	Set tStmt = ##class(%SQL.Statement).%New()
	Set tSC = tStmt.%Prepare("SELECT DiagID, mradm, PAADMADMNo, MRDIATerminologyDesc, MRCIDCode, MRCIDDesc, MRDIAPrinciple, MRDIADate FROM D1_Mock_Data.MrDiagnos WHERE mradm = ? ORDER BY DiagID")
	Return:$$$ISERR(tSC) tRows
	Set tRs = tStmt.%Execute(pMradm)
	While tRs.%Next() {
		Set tItem = {}
		Do tItem.%Set("ID", tRs.%Get("DiagID"))
		Do tItem.%Set("mradm", tRs.%Get("mradm"))
		Do tItem.%Set("PAADMADMNo", tRs.%Get("PAADMADMNo"))
		Do tItem.%Set("MRDIATerminologyDesc", tRs.%Get("MRDIATerminologyDesc"))
		Do tItem.%Set("MRCIDCode", tRs.%Get("MRCIDCode"))
		Do tItem.%Set("MRCIDDesc", tRs.%Get("MRCIDDesc"))
		Do tItem.%Set("MRDIAPrinciple", tRs.%Get("MRDIAPrinciple"))
		Do tItem.%Set("MRDIADate", tRs.%Get("MRDIADate"))
		Do tRows.%Push(tItem)
	}
	Return tRows
}

/// GET /MRProcedures?EpisodeID=  ->  procedure rows for one episode.
ClassMethod GetMrProcedures() As %Status
{
	Set %response.ContentType = "application/json"
	Set tRows = ..MrProceduresRows(%request.Get("EpisodeID"))
	Write ..ListEnvelope(tRows).%ToJSON()
	Return $$$OK
}

ClassMethod MrProceduresRows(pEpisodeId As %String) As %DynamicArray
{
	Set tRows = []
	Quit:pEpisodeId="" tRows
	Set tStmt = ##class(%SQL.Statement).%New()
	Set tSC = tStmt.%Prepare("SELECT ProcID, EpisodeID, OPERCode, OPERDesc, PROCDate, PROCTime FROM D1_Mock_Data.MrProcedures WHERE EpisodeID = ? ORDER BY ProcID")
	Return:$$$ISERR(tSC) tRows
	Set tRs = tStmt.%Execute(pEpisodeId)
	While tRs.%Next() {
		Set tItem = {}
		Do tItem.%Set("PROCRowId", tRs.%Get("ProcID"))
		Do tItem.%Set("EpisodeID", tRs.%Get("EpisodeID"))
		Do tItem.%Set("OPERCode", tRs.%Get("OPERCode"))
		Do tItem.%Set("OPERDesc", tRs.%Get("OPERDesc"))
		Do tItem.%Set("PROCDate", tRs.%Get("PROCDate"))
		Do tItem.%Set("PROCTime", tRs.%Get("PROCTime"))
		Do tRows.%Push(tItem)
	}
	Return tRows
}

/// GET /MRReasonForEnc?mradm=  ->  reason-for-encounter rows for one episode.
ClassMethod GetMrReasonForEnc() As %Status
{
	Set %response.ContentType = "application/json"
	Set tRows = ..MrReasonForEncRows(%request.Get("mradm"))
	Write ..ListEnvelope(tRows).%ToJSON()
	Return $$$OK
}

ClassMethod MrReasonForEncRows(pMradm As %String) As %DynamicArray
{
	Set tRows = []
	Quit:pMradm="" tRows
	Set tStmt = ##class(%SQL.Statement).%New()
	Set tSC = tStmt.%Prepare("SELECT ReasonID, mradm, DescSnomed, Comments, ConceptID FROM D1_Mock_Data.MrReasonForEnc WHERE mradm = ? ORDER BY ReasonID")
	Return:$$$ISERR(tSC) tRows
	Set tRs = tStmt.%Execute(pMradm)
	While tRs.%Next() {
		Set tItem = {}
		Do tItem.%Set("ID", tRs.%Get("ReasonID"))
		Do tItem.%Set("mradm", tRs.%Get("mradm"))
		Do tItem.%Set("DescSnomed", tRs.%Get("DescSnomed"))
		Do tItem.%Set("Comments", tRs.%Get("Comments"))
		Do tItem.%Set("ConceptID", tRs.%Get("ConceptID"))
		Do tRows.%Push(tItem)
	}
	Return tRows
}

// ------------------------------------------------------------ Lookup tables

/// GET /CTCareProv?Code=  ->  practitioner rows.
ClassMethod GetCtCareProv() As %Status
{
	Set %response.ContentType = "application/json"
	Set tRows = ..CtCareProvRows(%request.Get("Code"))
	Write ..ListEnvelope(tRows).%ToJSON()
	Return $$$OK
}

ClassMethod CtCareProvRows(pCode As %String) As %DynamicArray
{
	Set tRows = []
	Quit:pCode="" tRows
	Set tStmt = ##class(%SQL.Statement).%New()
	Set tSC = tStmt.%Prepare("SELECT CTPCPCode, CTPCPTitle, CTPCPFirstName, CTPCPSurname, CTPCPSMCNo FROM D1_Mock_Data.CtCareProv WHERE CTPCPCode = ?")
	Return:$$$ISERR(tSC) tRows
	Set tRs = tStmt.%Execute(pCode)
	While tRs.%Next() {
		Set tItem = {}
		Do tItem.%Set("CTPCPCode", tRs.%Get("CTPCPCode"))
		Do tItem.%Set("CTPCPTitle", tRs.%Get("CTPCPTitle"))
		Do tItem.%Set("CTPCPFirstName", tRs.%Get("CTPCPFirstName"))
		Do tItem.%Set("CTPCPSurname", tRs.%Get("CTPCPSurname"))
		Do tItem.%Set("CTPCPSMCNo", tRs.%Get("CTPCPSMCNo"))
		Do tRows.%Push(tItem)
	}
	Return tRows
}

/// GET /CTLoc?Description=&Hospital=  ->  location/department rows.
ClassMethod GetCtLoc() As %Status
{
	Set %response.ContentType = "application/json"
	Set tRows = ..CtLocRows(%request.Get("Description"), %request.Get("Hospital"))
	Write ..ListEnvelope(tRows).%ToJSON()
	Return $$$OK
}

ClassMethod CtLocRows(pDescription As %String, pHospital As %String = "") As %DynamicArray
{
	Set tRows = []
	Quit:pDescription="" tRows
	Set tStmt = ##class(%SQL.Statement).%New()
	If pHospital '= "" {
		Set tSC = tStmt.%Prepare("SELECT CTLOCCode, CTLOCDesc, Hospital FROM D1_Mock_Data.CtLoc WHERE CTLOCDesc = ? AND Hospital = ?")
		Return:$$$ISERR(tSC) tRows
		Set tRs = tStmt.%Execute(pDescription, pHospital)
	}
	Else {
		Set tSC = tStmt.%Prepare("SELECT CTLOCCode, CTLOCDesc, Hospital FROM D1_Mock_Data.CtLoc WHERE CTLOCDesc = ?")
		Return:$$$ISERR(tSC) tRows
		Set tRs = tStmt.%Execute(pDescription)
	}
	While tRs.%Next() {
		Set tItem = {}
		Do tItem.%Set("CTLOCCode", tRs.%Get("CTLOCCode"))
		Do tItem.%Set("CTLOCDesc", tRs.%Get("CTLOCDesc"))
		Do tItem.%Set("Hospital", tRs.%Get("Hospital"))
		Do tRows.%Push(tItem)
	}
	Return tRows
}

// ---------------------------------------------------------------- Billing

/// GET /ARPatientBillAll?PatientID=&Hospital=  ->  bill rows for one patient.
/// No admission-number parameter exists on the real resource -- the caller
/// filters on EpisodeID.
ClassMethod GetArPatientBillAll() As %Status
{
	Set %response.ContentType = "application/json"
	Set tRows = ..ArPatientBillAllRows(%request.Get("PatientID"), %request.Get("Hospital"))
	Write ..ListEnvelope(tRows).%ToJSON()
	Return $$$OK
}

ClassMethod ArPatientBillAllRows(pPatientId As %String, pHospital As %String = "") As %DynamicArray
{
	Set tRows = []
	Quit:pPatientId="" tRows
	Set tStmt = ##class(%SQL.Statement).%New()
	If pHospital '= "" {
		Set tSC = tStmt.%Prepare("SELECT PatientID, EpisodeID, Hospital, GrossAmount, DiscTotal, NetAmount, PatInvTot, PayorInvTot FROM D1_Mock_Data.ArPatientBillAll WHERE PatientID = ? AND Hospital = ?")
		Return:$$$ISERR(tSC) tRows
		Set tRs = tStmt.%Execute(pPatientId, pHospital)
	}
	Else {
		Set tSC = tStmt.%Prepare("SELECT PatientID, EpisodeID, Hospital, GrossAmount, DiscTotal, NetAmount, PatInvTot, PayorInvTot FROM D1_Mock_Data.ArPatientBillAll WHERE PatientID = ?")
		Return:$$$ISERR(tSC) tRows
		Set tRs = tStmt.%Execute(pPatientId)
	}
	While tRs.%Next() {
		Set tItem = {}
		Do tItem.%Set("PatientID", tRs.%Get("PatientID"))
		Do tItem.%Set("EpisodeID", tRs.%Get("EpisodeID"))
		Do tItem.%Set("Hospital", tRs.%Get("Hospital"))
		Do tItem.%Set("GrossAmount", tRs.%Get("GrossAmount"))
		Do tItem.%Set("DiscTotal", tRs.%Get("DiscTotal"))
		Do tItem.%Set("NetAmount", tRs.%Get("NetAmount"))
		Do tItem.%Set("PatInvTot", tRs.%Get("PatInvTot"))
		Do tItem.%Set("PayorInvTot", tRs.%Get("PayorInvTot"))
		Do tRows.%Push(tItem)
	}
	Return tRows
}

// ----------------------------------------------------------------- Shared

/// Wrap a results array in the standard TrakCare list envelope
/// (results_count / results_limit / results_page / links / results).
ClassMethod ListEnvelope(pRows As %DynamicArray) As %DynamicObject
{
	Set tEnvelope = {}
	Do tEnvelope.%Set("results_count", pRows.%Size())
	Do tEnvelope.%Set("results_limit", 25)
	Do tEnvelope.%Set("results_page", 1)
	Set tLinks = {}
	Do tLinks.%Set("previous_page", "")
	Do tLinks.%Set("next_page", "")
	Do tEnvelope.%Set("links", tLinks)
	Do tEnvelope.%Set("results", pRows)
	Return tEnvelope
}

}
