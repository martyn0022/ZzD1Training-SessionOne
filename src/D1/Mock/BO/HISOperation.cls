/// Outbound HTTP client for the HIS (TrakCare). Every call matches TrakCare's
/// real contract -- paths, query params, auth headers, envelope shapes -- so a
/// live deployment is an adapter config change, not a rewrite.
/// 
/// Also owns identity dispatch: D1's identity_type/identity_no resolved to a
/// TrakCare PatientID. See docs/PRODUCTION_FLOWS.md.
Class D1.Mock.BO.HISOperation Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.HTTP.OutboundAdapter";

Parameter INVOCATION = "Queue";

Property Adapter As EnsLib.HTTP.OutboundAdapter;

/// Base path for the Patient resource (list + /:id).
Property PatientPath As %String [ InitialExpression = "/api/his/Patient" ];

/// Base path for the PAAdm (episode) list resource.
Property AdmPath As %String [ InitialExpression = "/api/his/PAAdm" ];

/// Base path for the PAAdmByLocType episode resolver.
Property AdmByLocTypePath As %String [ InitialExpression = "/api/his/PAAdmByLocType" ];

/// Base path for the MRDiagnos resource.
Property DiagnosisPath As %String [ InitialExpression = "/api/his/MRDiagnos" ];

/// Base path for the MRProcedures resource.
Property ProceduresPath As %String [ InitialExpression = "/api/his/MRProcedures" ];

/// Base path for the MRReasonForEnc resource.
Property ReasonForEncPath As %String [ InitialExpression = "/api/his/MRReasonForEnc" ];

/// Base path for the CTCareProv (practitioner) resource.
Property CareProviderPath As %String [ InitialExpression = "/api/his/CTCareProv" ];

/// Base path for the CTLoc (location/department) resource.
Property LocPath As %String [ InitialExpression = "/api/his/CTLoc" ];

/// Base path for the ARPatientBillAll resource.
Property BillingPath As %String [ InitialExpression = "/api/his/ARPatientBillAll" ];

/// HIS API user (sent as the TUSERNAME header).
Property HISUsername As %String [ InitialExpression = "d1integration" ];

/// HIS API password (sent as the TPASSWORD header).
Property HISPassword As %String [ InitialExpression = "changeit" ];

Parameter SETTINGS = "PatientPath:Basic,AdmPath:Basic,AdmByLocTypePath:Basic,DiagnosisPath:Basic,ProceduresPath:Basic,ReasonForEncPath:Basic,CareProviderPath:Basic,LocPath:Basic,BillingPath:Basic,HISUsername:Basic,HISPassword:Basic";

// ------------------------------------------------------- Request handlers

/// Demographics: resolve the identity to a PatientID, then GET /Patient/:id.
/// An unresolvable identity returns an empty response (no Results).
Method GetPatient(pRequest As D1.Mock.Msg.HIS.PatientRequest, Output pResponse As D1.Mock.Msg.HIS.PatientResponse) As %Status
{
	Set pResponse = ##class(D1.Mock.Msg.HIS.PatientResponse).%New()
	Set tSC = ..ResolvePatientByIdentity(pRequest.IdentityType, pRequest.IdentityNo, .tPatientId, .tEpisodeNo)
	Quit:$$$ISERR(tSC) tSC
	Quit:tPatientId="" $$$OK
	Quit ..Fetch(..PatientPath _ "/" _ $ZConvert(tPatientId, "O", "URL"), "GetPatient", pResponse)
}

/// Episode detail: resolve the identity, then GET /PAAdm?PatientID=.
/// For VN/AN the returned rows are pruned to the requested episode, so
/// Results.GetAt(1) is always the episode the caller asked about.
Method GetPAAdm(pRequest As D1.Mock.Msg.HIS.PAAdmRequest, Output pResponse As D1.Mock.Msg.HIS.PAAdmResponse) As %Status
{
	Set pResponse = ##class(D1.Mock.Msg.HIS.PAAdmResponse).%New()
	Set tSC = ..ResolvePatientByIdentity(pRequest.IdentityType, pRequest.IdentityNo, .tPatientId, .tEpisodeNo)
	Quit:$$$ISERR(tSC) tSC
	Quit:tPatientId="" $$$OK
	Set tPath = ..AdmPath _ "?PatientID=" _ $ZConvert(tPatientId, "O", "URL") _ "&_count=25&page=1"
	Set tSC = ..Fetch(tPath, "GetPAAdm", pResponse)
	Quit:$$$ISERR(tSC) tSC
	Do:tEpisodeNo'="" ..PruneToEpisode(pResponse, tEpisodeNo)
	Quit $$$OK
}

/// Diagnoses for one episode: GET /MRDiagnos?mradm=.
Method GetMrDiagnos(pRequest As D1.Mock.Msg.HIS.DiagnosisRequest, Output pResponse As D1.Mock.Msg.HIS.DiagnosisResponse) As %Status
{
	Set pResponse = ##class(D1.Mock.Msg.HIS.DiagnosisResponse).%New()
	Set tPath = ..DiagnosisPath _ "?mradm=" _ $ZConvert(pRequest.Mradm, "O", "URL") _ "&_count=25&page=1"
	Quit ..Fetch(tPath, "GetMrDiagnos", pResponse)
}

/// Procedures for one episode: GET /MRProcedures?EpisodeID=.
Method GetMrProcedures(pRequest As D1.Mock.Msg.HIS.MrProceduresRequest, Output pResponse As D1.Mock.Msg.HIS.MrProceduresResponse) As %Status
{
	Set pResponse = ##class(D1.Mock.Msg.HIS.MrProceduresResponse).%New()
	Set tPath = ..ProceduresPath _ "?EpisodeID=" _ $ZConvert(pRequest.EpisodeID, "O", "URL") _ "&_count=25&page=1"
	Quit ..Fetch(tPath, "GetMrProcedures", pResponse)
}

/// Reason for encounter (chief complaint) for one episode: GET /MRReasonForEnc?mradm=.
Method GetMrReasonForEnc(pRequest As D1.Mock.Msg.HIS.MrReasonForEncRequest, Output pResponse As D1.Mock.Msg.HIS.MrReasonForEncResponse) As %Status
{
	Set pResponse = ##class(D1.Mock.Msg.HIS.MrReasonForEncResponse).%New()
	Set tPath = ..ReasonForEncPath _ "?mradm=" _ $ZConvert(pRequest.Mradm, "O", "URL") _ "&_count=25&page=1"
	Quit ..Fetch(tPath, "GetMrReasonForEnc", pResponse)
}

/// Practitioner detail: GET /CTCareProv?Code=.
Method GetCtCareProv(pRequest As D1.Mock.Msg.HIS.CareProviderRequest, Output pResponse As D1.Mock.Msg.HIS.CareProviderResponse) As %Status
{
	Set pResponse = ##class(D1.Mock.Msg.HIS.CareProviderResponse).%New()
	Set tPath = ..CareProviderPath _ "?Code=" _ $ZConvert(pRequest.Code, "O", "URL") _ "&_count=25&page=1"
	Quit ..Fetch(tPath, "GetCtCareProv", pResponse)
}

/// Location/department lookup: GET /CTLoc?Description=&Hospital=.
Method GetCtLoc(pRequest As D1.Mock.Msg.HIS.CtLocRequest, Output pResponse As D1.Mock.Msg.HIS.CtLocResponse) As %Status
{
	Set pResponse = ##class(D1.Mock.Msg.HIS.CtLocResponse).%New()
	Set tPath = ..LocPath _ "?Description=" _ $ZConvert(pRequest.Description, "O", "URL")
	Set:pRequest.Hospital'="" tPath = tPath _ "&Hospital=" _ $ZConvert(pRequest.Hospital, "O", "URL")
	Set tPath = tPath _ "&_count=25&page=1"
	Quit ..Fetch(tPath, "GetCtLoc", pResponse)
}

/// Patient bill for one admission. The real resource has no admission-number
/// parameter: resolve the admission to a PatientID via the episode resolver,
/// fetch the patient's bills, then filter on EpisodeID here.
Method GetArPatientBillAll(pRequest As D1.Mock.Msg.HIS.BillingRequest, Output pResponse As D1.Mock.Msg.HIS.BillingResponse) As %Status
{
	Set pResponse = ##class(D1.Mock.Msg.HIS.BillingResponse).%New()
	Set tSC = ..ResolvePatientByIdentity("AN", pRequest.AdmissionNumber, .tPatientId, .tEpisodeNo)
	Quit:$$$ISERR(tSC) tSC
	Quit:tPatientId="" $$$OK
	Set tPath = ..BillingPath _ "?PatientID=" _ $ZConvert(tPatientId, "O", "URL")
	Set:pRequest.Hospital'="" tPath = tPath _ "&Hospital=" _ $ZConvert(pRequest.Hospital, "O", "URL")
	Set tPath = tPath _ "&_count=25&page=1"
	Set tSC = ..Fetch(tPath, "GetArPatientBillAll", pResponse)
	Quit:$$$ISERR(tSC) tSC
	// The admission filter the real resource lacks.
	For i = pResponse.Results.Count():-1:1 {
		If pResponse.Results.GetAt(i).EpisodeID '= pRequest.AdmissionNumber {
			Do pResponse.Results.RemoveAt(i)
		}
	}
	Quit $$$OK
}

// -------------------------------------------------------- Identity resolver

/// Resolve a D1 identity into TrakCare's internal PatientID.
/// For VN/AN, pEpisodeNo also returns the episode number so callers can
/// narrow multi-episode lists to the one the caller asked about; for
/// patient-level identities (CID/PID/HN) it stays "".
/// An unknown identity yields pPatientId="" with an OK status -- "not found"
/// is in-band data here, not an error.
Method ResolvePatientByIdentity(pIdentityType As %String, pIdentityNo As %String, Output pPatientId As %String, Output pEpisodeNo As %String) As %Status
{
	Set pPatientId = "", pEpisodeNo = ""
	Set tEncoded = $ZConvert(pIdentityNo, "O", "URL")
	If (pIdentityType = "VN") || (pIdentityType = "AN") {
		Set tSC = ..FetchJson(..AdmByLocTypePath _ "?EpisodeNo=" _ tEncoded _ "&_count=25&page=1", .tJson)
		Quit:$$$ISERR(tSC) tSC
		Set tResults = tJson.%Get("results")
		If $IsObject(tResults) && (tResults.%Size() > 0) {
			Set pPatientId = tResults.%Get(0).%Get("PatientID")
			Set pEpisodeNo = pIdentityNo
		}
		Quit $$$OK
	}
	Set tParam = $Case(pIdentityType, "CID": "NationalID", "PID": "ForeignID", "HN": "RegistrationNo", : "")
	Quit:tParam="" $$$ERROR($$$GeneralError, "Unsupported identity_type: " _ pIdentityType)
	Set tSC = ..FetchJson(..PatientPath _ "?" _ tParam _ "=" _ tEncoded _ "&_count=25&page=1", .tJson)
	Quit:$$$ISERR(tSC) tSC
	Set tResults = tJson.%Get("results")
	If $IsObject(tResults) && (tResults.%Size() > 0) {
		Set pPatientId = tResults.%Get(0).%Get("ID")
	}
	Quit $$$OK
}

/// Drop every episode row except the one matching pEpisodeNo.
ClassMethod PruneToEpisode(pResponse As D1.Mock.Msg.HIS.PAAdmResponse, pEpisodeNo As %String)
{
	For i = pResponse.Results.Count():-1:1 {
		If pResponse.Results.GetAt(i).PAADMADMNo '= pEpisodeNo {
			Do pResponse.Results.RemoveAt(i)
		}
	}
}

// ----------------------------------------------------------------- Helpers

/// Shared GET helper: authenticate, call the HIS, load the JSON body into the
/// (already-instantiated) response message via %JSONImport.
Method Fetch(pPath As %String, pLabel As %String, pResponse As %JSON.Adaptor) As %Status
{
	Set tSC = $$$OK
	Try {
		$$$LOGINFO(pLabel _ " -> GET " _ pPath)
		Set tSC = ..HttpGet(pPath, .tHttpResponse)
		Quit:$$$ISERR(tSC)
		Set tSC = pResponse.%JSONImport(tHttpResponse.Data)
	}
	Catch ex {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

/// GET helper for resolver internals: returns the parsed body as a
/// %DynamicObject instead of importing into a message class.
Method FetchJson(pPath As %String, Output pJson As %DynamicObject) As %Status
{
	Set tSC = $$$OK, pJson = {}
	Try {
		Set tSC = ..HttpGet(pPath, .tHttpResponse)
		Quit:$$$ISERR(tSC)
		Set pJson = ##class(%DynamicAbstractObject).%FromJSON(tHttpResponse.Data)
	}
	Catch ex {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

/// One authenticated HTTP GET through the adapter.
Method HttpGet(pPath As %String, Output pHttpResponse As %Net.HttpResponse) As %Status
{
	Set tSC = $$$OK
	Try {
		Set tHttpRequest = ##class(%Net.HttpRequest).%New()
		Do tHttpRequest.SetHeader("TUSERNAME", ..HISUsername)
		Do tHttpRequest.SetHeader("TPASSWORD", ..HISPassword)
		Do tHttpRequest.SetHeader("TENCRYPTED", "false")

		// NB: pURL is the LAST arg, after the pData array.
		Set tSC = ..Adapter.SendFormDataArray(.pHttpResponse, "GET", tHttpRequest, "", , pPath)
		Quit:$$$ISERR(tSC)

		If '$IsObject(pHttpResponse) {
			Set tSC = $$$ERROR($$$GeneralError, "No HTTP response received from HIS")
			Quit
		}
		If (pHttpResponse.StatusCode '= 200) {
			Set tSC = $$$ERROR($$$GeneralError, "HIS returned HTTP " _ pHttpResponse.StatusCode)
		}
	}
	Catch ex {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

XData MessageMap
{
<MapItems>
  <MapItem MessageType="D1.Mock.Msg.HIS.PatientRequest">
    <Method>GetPatient</Method>
  </MapItem>
  <MapItem MessageType="D1.Mock.Msg.HIS.PAAdmRequest">
    <Method>GetPAAdm</Method>
  </MapItem>
  <MapItem MessageType="D1.Mock.Msg.HIS.DiagnosisRequest">
    <Method>GetMrDiagnos</Method>
  </MapItem>
  <MapItem MessageType="D1.Mock.Msg.HIS.MrProceduresRequest">
    <Method>GetMrProcedures</Method>
  </MapItem>
  <MapItem MessageType="D1.Mock.Msg.HIS.MrReasonForEncRequest">
    <Method>GetMrReasonForEnc</Method>
  </MapItem>
  <MapItem MessageType="D1.Mock.Msg.HIS.CareProviderRequest">
    <Method>GetCtCareProv</Method>
  </MapItem>
  <MapItem MessageType="D1.Mock.Msg.HIS.CtLocRequest">
    <Method>GetCtLoc</Method>
  </MapItem>
  <MapItem MessageType="D1.Mock.Msg.HIS.BillingRequest">
    <Method>GetArPatientBillAll</Method>
  </MapItem>
</MapItems>
}

}
