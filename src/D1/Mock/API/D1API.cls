/// D1-facing REST API, served under /api/d1.
///
///   Group 1 (live HIS):  /patient /visit /admission /diagnosis /billing /preauth
///   Group 2 (IRIS only): /local/* /files /discharge
///
/// All routes are POST with a JSON body (V1.0.3 dropped query params).
/// Each builds a request message, enters the production through its business
/// service, and returns the JSON envelope. See docs/PRODUCTION_FLOWS.md.
Class D1.Mock.API.D1API Extends %CSP.REST
{

Parameter CONTENTTYPE = "application/json";

Parameter CHARSET = "utf-8";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
  <Route Url="/patient" Method="POST" Call="GetPatient" />
  <Route Url="/visit" Method="POST" Call="GetVisit" />
  <Route Url="/admission" Method="POST" Call="GetAdmission" />
  <Route Url="/diagnosis" Method="POST" Call="GetDiagnosis" />
  <Route Url="/billing" Method="POST" Call="GetBilling" />
  <Route Url="/preauth" Method="POST" Call="PostPreAuth" />
  <Route Url="/local/patient" Method="POST" Call="D1GetPatient" />
  <Route Url="/local/policy" Method="POST" Call="D1GetPolicy" />
  <Route Url="/local/benefit" Method="POST" Call="D1GetBenefit" />
  <Route Url="/local/preauth-info" Method="POST" Call="D1GetPreAuthInfo" />
  <Route Url="/local/admission" Method="POST" Call="D1GetAdmission" />
  <Route Url="/local/discharge-info" Method="POST" Call="D1GetDischargeInfo" />
  <Route Url="/files" Method="POST" Call="PostFiles" />
  <Route Url="/discharge" Method="POST" Call="PostDischarge" />
  <Route Url="/preauth/patch" Method="POST" Call="PatchPreAuth" />
  <Route Url="/discharge/patch" Method="POST" Call="PatchDischarge" />
  <Route Url="/record-list" Method="POST" Call="GetRecordList" />
  <Route Url="/document-info" Method="POST" Call="GetDocumentInfo" />
  <Route Url="/reset" Method="POST" Call="Reset" />
</Routes>
}

// ------------------------------------------------------ Group-1 read routes

/// POST /d1/patient -- accepts the full identity set (CID/PID/VN/HN/AN).
ClassMethod GetPatient() As %Status
{
	Try {
		Set tRequest = ##class(D1.Mock.Msg.GetPatientRequest).%New()
		Set tSC = ..ImportBody(tRequest)
		Return:$$$ISERR(tSC) ..BadRequest($System.Status.GetErrorText(tSC))
		If (tRequest.IdentityType = "") || (tRequest.IdentityNo = "") {
			Return ..BadRequest("identity_type and identity_no are required")
		}
		If '$ListFind($ListBuild("CID", "PID", "VN", "HN", "AN"), tRequest.IdentityType) {
			Return ..BadRequest("identity_type must be one of CID, PID, VN, HN, AN")
		}
		Return ..CallService("Patient Service", tRequest)
	}
	Catch ex {
		Set %response.Status = ..#HTTP500INTERNALSERVERERROR
		Return ..WriteEnvelope("500", ex.DisplayString())
	}
}

/// POST /d1/visit -- VN/AN only per V1.0.3.
ClassMethod GetVisit() As %Status
{
	Try {
		Set tRequest = ##class(D1.Mock.Msg.GetVisitRequest).%New()
		Set tSC = ..ImportBody(tRequest)
		Return:$$$ISERR(tSC) ..BadRequest($System.Status.GetErrorText(tSC))
		If (tRequest.IdentityType = "") || (tRequest.IdentityNo = "") {
			Return ..BadRequest("identity_type and identity_no are required")
		}
		If '$ListFind($ListBuild("VN", "AN"), tRequest.IdentityType) {
			Return ..BadRequest("identity_type must be VN or AN")
		}
		Return ..CallService("Visit Service", tRequest)
	}
	Catch ex {
		Set %response.Status = ..#HTTP500INTERNALSERVERERROR
		Return ..WriteEnvelope("500", ex.DisplayString())
	}
}

/// POST /d1/admission -- identity_type required (VN/AN), rest optional per spec.
ClassMethod GetAdmission() As %Status
{
	Try {
		Set tRequest = ##class(D1.Mock.Msg.GetAdmissionRequest).%New()
		Set tSC = ..ImportBody(tRequest)
		Return:$$$ISERR(tSC) ..BadRequest($System.Status.GetErrorText(tSC))
		If tRequest.IdentityType = "" {
			Return ..BadRequest("identity_type is required")
		}
		If '$ListFind($ListBuild("VN", "AN"), tRequest.IdentityType) {
			Return ..BadRequest("identity_type must be VN or AN")
		}
		Return ..CallService("Admission Service", tRequest)
	}
	Catch ex {
		Set %response.Status = ..#HTTP500INTERNALSERVERERROR
		Return ..WriteEnvelope("500", ex.DisplayString())
	}
}

/// POST /d1/diagnosis -- VN/AN only per V1.0.3.
ClassMethod GetDiagnosis() As %Status
{
	Try {
		Set tRequest = ##class(D1.Mock.Msg.GetDiagnosisRequest).%New()
		Set tSC = ..ImportBody(tRequest)
		Return:$$$ISERR(tSC) ..BadRequest($System.Status.GetErrorText(tSC))
		If (tRequest.IdentityType = "") || (tRequest.IdentityNo = "") {
			Return ..BadRequest("identity_type and identity_no are required")
		}
		If '$ListFind($ListBuild("VN", "AN"), tRequest.IdentityType) {
			Return ..BadRequest("identity_type must be VN or AN")
		}
		Return ..CallService("Diagnosis Service", tRequest)
	}
	Catch ex {
		Set %response.Status = ..#HTTP500INTERNALSERVERERROR
		Return ..WriteEnvelope("500", ex.DisplayString())
	}
}

/// POST /d1/billing -- keyed by admission_number.
ClassMethod GetBilling() As %Status
{
	Try {
		Set tRequest = ##class(D1.Mock.Msg.GetBillingRequest).%New()
		Set tSC = ..ImportBody(tRequest)
		Return:$$$ISERR(tSC) ..BadRequest($System.Status.GetErrorText(tSC))
		If tRequest.AdmissionNumber = "" {
			Return ..BadRequest("admission_number is required")
		}
		Return ..CallService("Billing Service", tRequest)
	}
	Catch ex {
		Set %response.Status = ..#HTTP500INTERNALSERVERERROR
		Return ..WriteEnvelope("500", ex.DisplayString())
	}
}

// ------------------------------------------------- Group-2 read routes

/// POST /d1/local/patient -- IRIS's own patient_info table.
ClassMethod D1GetPatient() As %Status
{
	Try {
		Set tRequest = ##class(D1.Mock.Msg.GetPatientRequest).%New()
		Set tSC = ..ImportBody(tRequest)
		Return:$$$ISERR(tSC) ..BadRequest($System.Status.GetErrorText(tSC))
		If (tRequest.IdentityType = "") || (tRequest.IdentityNo = "") {
			Return ..BadRequest("identity_type and identity_no are required")
		}
		If '$ListFind($ListBuild("CID", "PID", "VN", "HN", "AN"), tRequest.IdentityType) {
			Return ..BadRequest("identity_type must be one of CID, PID, VN, HN, AN")
		}
		Return ..CallService("D1GetPatient Service", tRequest)
	}
	Catch ex {
		Set %response.Status = ..#HTTP500INTERNALSERVERERROR
		Return ..WriteEnvelope("500", ex.DisplayString())
	}
}

/// POST /d1/local/policy -- keyed by admission_number.
ClassMethod D1GetPolicy() As %Status
{
	Try {
		Set tRequest = ##class(D1.Mock.Msg.D1GetPolicyRequest).%New()
		Set tSC = ..ImportBody(tRequest)
		Return:$$$ISERR(tSC) ..BadRequest($System.Status.GetErrorText(tSC))
		If tRequest.AdmissionNumber = "" {
			Return ..BadRequest("admission_number is required")
		}
		Return ..CallService("D1GetPolicy Service", tRequest)
	}
	Catch ex {
		Set %response.Status = ..#HTTP500INTERNALSERVERERROR
		Return ..WriteEnvelope("500", ex.DisplayString())
	}
}

/// POST /d1/local/benefit -- keyed by policy_number + company_code.
ClassMethod D1GetBenefit() As %Status
{
	Try {
		Set tRequest = ##class(D1.Mock.Msg.D1GetBenefitRequest).%New()
		Set tSC = ..ImportBody(tRequest)
		Return:$$$ISERR(tSC) ..BadRequest($System.Status.GetErrorText(tSC))
		If (tRequest.PolicyNumber = "") || (tRequest.CompanyCode = "") {
			Return ..BadRequest("policy_number and company_code are required")
		}
		Return ..CallService("D1GetBenefit Service", tRequest)
	}
	Catch ex {
		Set %response.Status = ..#HTTP500INTERNALSERVERERROR
		Return ..WriteEnvelope("500", ex.DisplayString())
	}
}

/// POST /d1/local/preauth-info -- date range + optional identity filter.
ClassMethod D1GetPreAuthInfo() As %Status
{
	Try {
		Set tRequest = ##class(D1.Mock.Msg.D1GetPreAuthInfoRequest).%New()
		Set tSC = ..ImportBody(tRequest)
		Return:$$$ISERR(tSC) ..BadRequest($System.Status.GetErrorText(tSC))
		If (tRequest.StartReqDate = "") || (tRequest.EndReqDate = "") {
			Return ..BadRequest("start_reqdate and end_reqdate are required")
		}
		If tRequest.IdentityType = "" {
			Return ..BadRequest("identity_type is required")
		}
		Return ..CallService("D1GetPreAuthInfo Service", tRequest)
	}
	Catch ex {
		Set %response.Status = ..#HTTP500INTERNALSERVERERROR
		Return ..WriteEnvelope("500", ex.DisplayString())
	}
}

/// POST /d1/local/admission -- IRIS's own admission_info table.
/// Accepts VN/HN/AN: this sheet kept the wider identity set even though
/// group-1's GetAdmission narrowed to VN/AN in V1.0.3.
ClassMethod D1GetAdmission() As %Status
{
	Try {
		Set tRequest = ##class(D1.Mock.Msg.GetAdmissionRequest).%New()
		Set tSC = ..ImportBody(tRequest)
		Return:$$$ISERR(tSC) ..BadRequest($System.Status.GetErrorText(tSC))
		If tRequest.IdentityType = "" {
			Return ..BadRequest("identity_type is required")
		}
		If '$ListFind($ListBuild("VN", "HN", "AN"), tRequest.IdentityType) {
			Return ..BadRequest("identity_type must be one of VN, HN, AN")
		}
		Return ..CallService("D1GetAdmission Service", tRequest)
	}
	Catch ex {
		Set %response.Status = ..#HTTP500INTERNALSERVERERROR
		Return ..WriteEnvelope("500", ex.DisplayString())
	}
}

/// POST /d1/local/discharge-info -- date range + optional identity filter.
ClassMethod D1GetDischargeInfo() As %Status
{
	Try {
		Set tRequest = ##class(D1.Mock.Msg.D1GetDischargeInfoRequest).%New()
		Set tSC = ..ImportBody(tRequest)
		Return:$$$ISERR(tSC) ..BadRequest($System.Status.GetErrorText(tSC))
		If (tRequest.StartReqDate = "") || (tRequest.EndReqDate = "") {
			Return ..BadRequest("start_reqdate and end_reqdate are required")
		}
		If tRequest.IdentityType = "" {
			Return ..BadRequest("identity_type is required")
		}
		Return ..CallService("D1GetDischargeInfo Service", tRequest)
	}
	Catch ex {
		Set %response.Status = ..#HTTP500INTERNALSERVERERROR
		Return ..WriteEnvelope("500", ex.DisplayString())
	}
}

// ------------------------------------------------------------ Write routes

/// POST /d1/preauth  with the V1.0.3 API_PostPreAuth body.
/// Stores the submission in IRIS and returns the acknowledgement envelope.
ClassMethod PostPreAuth() As %Status
{
	Try {
		If '$IsObject(%request.Content) {
			Set %response.Status = ..#HTTP400BADREQUEST
			Return ..WriteEnvelope("400", "Request body is required")
		}
		Try {
			Set tJson = ##class(%DynamicAbstractObject).%FromJSON(..ReadBodyAsUnicode())
		}
		Catch parseEx {
			Set %response.Status = ..#HTTP400BADREQUEST
			Return ..WriteEnvelope("400", "Invalid JSON body: " _ parseEx.DisplayString())
		}
		If '$IsObject(tJson) || ($ClassName(tJson) '= "%Library.DynamicObject") {
			Set %response.Status = ..#HTTP400BADREQUEST
			Return ..WriteEnvelope("400", "Request body must be a JSON object")
		}
		Do ..NormalizePreAuthTypes(tJson)

		Set tRequest = ##class(D1.Mock.Msg.PostPreAuthRequest).%New()
		Set tSC = tRequest.%JSONImport(tJson)
		If $$$ISERR(tSC) {
			Set %response.Status = ..#HTTP400BADREQUEST
			Return ..WriteEnvelope("400", "Invalid JSON body: " _ $System.Status.GetErrorText(tSC))
		}
		Return ..CallService("PostPreAuth Service", tRequest)
	}
	Catch ex {
		Set %response.Status = ..#HTTP500INTERNALSERVERERROR
		Return ..WriteEnvelope("500", ex.DisplayString())
	}
}

/// POST /d1/files  with the V1.0.3 API_PostFiles body (base64 file content).
/// Stores the decoded bytes in IRIS's own file_info table.
ClassMethod PostFiles() As %Status
{
	Try {
		Set tRequest = ##class(D1.Mock.Msg.PostFilesRequest).%New()
		Set tSC = ..ImportBody(tRequest)
		Return:$$$ISERR(tSC) ..BadRequest($System.Status.GetErrorText(tSC))
		Return ..CallService("PostFiles Service", tRequest)
	}
	Catch ex {
		Set %response.Status = ..#HTTP500INTERNALSERVERERROR
		Return ..WriteEnvelope("500", ex.DisplayString())
	}
}

/// POST /d1/discharge  with the V1.0.3 API_PostDischarge body.
/// Stores discharge + billing and snapshots the patient / admission /
/// policy / diagnosis detail the payload carries.
ClassMethod PostDischarge() As %Status
{
	Try {
		Set tRequest = ##class(D1.Mock.Msg.PostDischargeRequest).%New()
		Set tSC = ..ImportBody(tRequest, "NormalizeDischargeTypes")
		Return:$$$ISERR(tSC) ..BadRequest($System.Status.GetErrorText(tSC))
		Return ..CallService("PostDischarge Service", tRequest)
	}
	Catch ex {
		Set %response.Status = ..#HTTP500INTERNALSERVERERROR
		Return ..WriteEnvelope("500", ex.DisplayString())
	}
}

// ----------------------------------------------------------------- Helpers

/// Read the JSON body (with the UTF-8 fix) and import it into pRequest.
/// Shared by every JSON-body route.
///
/// pNormalizer optionally names a classmethod on this class that fixes up the
/// parsed JSON before import -- needed where the spec's own samples send a
/// value in the wrong JSON type for the property it lands on.
/// API_PatchPreAuth (V1.0.5). The spec names some of these "Patch" but specifies
/// Method: Post throughout, so every route is a POST.
ClassMethod PatchPreAuth() As %Status
{
	Try {
		Set tRequest = ##class(D1.Mock.Msg.PatchPreAuthRequest).%New()
		Set tSC = ..ImportBody(tRequest)
		Return:$$$ISERR(tSC) ..BadRequest($System.Status.GetErrorText(tSC))
		Return:tRequest.AdmissionNumber="" ..BadRequest("admission_number is required")
		Return:tRequest.CompanyCode="" ..BadRequest("company_code is required")
		Return ..CallService("PatchPreAuth Service", tRequest)
	}
	Catch ex {
		Set %response.Status = ..#HTTP500INTERNALSERVERERROR
		Return ..WriteEnvelope("500", ex.DisplayString())
	}
}

/// API_PatchDischarge (V1.0.5). The spec names some of these "Patch" but specifies
/// Method: Post throughout, so every route is a POST.
ClassMethod PatchDischarge() As %Status
{
	Try {
		Set tRequest = ##class(D1.Mock.Msg.PatchDischargeRequest).%New()
		Set tSC = ..ImportBody(tRequest)
		Return:$$$ISERR(tSC) ..BadRequest($System.Status.GetErrorText(tSC))
		Return:tRequest.AdmissionNumber="" ..BadRequest("admission_number is required")
		Return:tRequest.CompanyCode="" ..BadRequest("company_code is required")
		Return ..CallService("PatchDischarge Service", tRequest)
	}
	Catch ex {
		Set %response.Status = ..#HTTP500INTERNALSERVERERROR
		Return ..WriteEnvelope("500", ex.DisplayString())
	}
}

/// Testing utility, not part of the D1 API spec: wipes the group-2 claim
/// tables (and PreAuthSubmission) so a resubmitted admission_number/claim_id
/// won't 409 against leftover data from a prior test run.
///
/// Body is optional. {"reseed": "1"} wipes and reseeds the demo dataset
/// (see ClaimLoader.Reset); omitted or "0" (the default) just wipes.
ClassMethod Reset() As %Status
{
	Try {
		Set tReseed = 0
		If $IsObject(%request.Content) && (%request.Content.Size > 0) {
			Set tJson = ##class(%DynamicAbstractObject).%FromJSON(..ReadBodyAsUnicode())
			If $IsObject(tJson) {
				Set tReseed = tJson.%Get("reseed", 0)
			}
		}
		If (tReseed '= 0) && (tReseed '= 1) && (tReseed '= "0") && (tReseed '= "1") {
			Return ..BadRequest("reseed must be ""0"" or ""1""")
		}
		Set tSC = ##class(D1.Mock.Data.ClaimLoader).Reset(+tReseed)
		If $$$ISERR(tSC) {
			Set %response.Status = ..#HTTP500INTERNALSERVERERROR
			Return ..WriteEnvelope("500", $System.Status.GetErrorText(tSC))
		}
		Return ..WriteEnvelope("200", $Select(+tReseed: "Tables wiped and reseeded", 1: "Tables wiped"))
	}
	Catch ex {
		Set %response.Status = ..#HTTP500INTERNALSERVERERROR
		Return ..WriteEnvelope("500", ex.DisplayString())
	}
}

/// API_GetRecordList (V1.0.5). The spec names some of these "Patch" but specifies
/// Method: Post throughout, so every route is a POST.
ClassMethod GetRecordList() As %Status
{
	Try {
		Set tRequest = ##class(D1.Mock.Msg.GetRecordListRequest).%New()
		Set tSC = ..ImportBody(tRequest)
		Return:$$$ISERR(tSC) ..BadRequest($System.Status.GetErrorText(tSC))
		Return:tRequest.ListMode="" ..BadRequest("list_mode is required")
		Return:tRequest.CompanyCode="" ..BadRequest("company_code is required")
		Return ..CallService("GetRecordList Service", tRequest)
	}
	Catch ex {
		Set %response.Status = ..#HTTP500INTERNALSERVERERROR
		Return ..WriteEnvelope("500", ex.DisplayString())
	}
}

/// API_GetDocumentInfo (V1.0.5). The spec names some of these "Patch" but specifies
/// Method: Post throughout, so every route is a POST.
ClassMethod GetDocumentInfo() As %Status
{
	Try {
		Set tRequest = ##class(D1.Mock.Msg.GetDocumentInfoRequest).%New()
		Set tSC = ..ImportBody(tRequest)
		Return:$$$ISERR(tSC) ..BadRequest($System.Status.GetErrorText(tSC))
		Return:tRequest.AdmissionNumber="" ..BadRequest("admission_number is required")
		Return:tRequest.CompanyCode="" ..BadRequest("company_code is required")
		Return ..CallService("GetDocumentInfo Service", tRequest)
	}
	Catch ex {
		Set %response.Status = ..#HTTP500INTERNALSERVERERROR
		Return ..WriteEnvelope("500", ex.DisplayString())
	}
}

ClassMethod ImportBody(pRequest As %JSON.Adaptor, pNormalizer As %String = "") As %Status
{
	If '$IsObject(%request.Content) {
		Return $$$ERROR($$$GeneralError, "Request body is required")
	}
	Try {
		Set tJson = ##class(%DynamicAbstractObject).%FromJSON(..ReadBodyAsUnicode())
	}
	Catch parseEx {
		Return $$$ERROR($$$GeneralError, "Invalid JSON body: " _ parseEx.DisplayString())
	}
	If '$IsObject(tJson) || ($ClassName(tJson) '= "%Library.DynamicObject") {
		Return $$$ERROR($$$GeneralError, "Request body must be a JSON object")
	}
	Do:pNormalizer'="" $ClassMethod($ClassName(), pNormalizer, tJson)
	Return pRequest.%JSONImport(tJson)
}

/// Spec samples every billing amount quoted and comma-separated
/// ("150,000.00"); unconverted it aborts the whole %JSONImport.
ClassMethod NormalizeDischargeTypes(pJson As %DynamicObject)
{
	Set tBilling = pJson.%Get("billing_info")
	Quit:'$IsObject(tBilling)
	Quit:$ClassName(tBilling)'="%Library.DynamicObject"
	Set tFields = $ListBuild("total_charge", "discount_amount", "net_charge", "patient_payable", "insurance_payable")
	For i = 1:1:$ListLength(tFields) {
		Set tField = $List(tFields, i)
		Continue:'tBilling.%IsDefined(tField)
		Continue:tBilling.%GetTypeOf(tField)="number"
		// Strip thousands separators and stray spaces before converting.
		Do tBilling.%Set(tField, +$Translate(tBilling.%Get(tField), ", "), "number")
	}
}

/// Answer a 400 with the standard envelope.
ClassMethod BadRequest(pMessage As %String) As %Status
{
	Set %response.Status = ..#HTTP400BADREQUEST
	Return ..WriteEnvelope("400", pMessage)
}

/// Read the request body and hand back real characters, not UTF-8 bytes.
///
/// The body arrives here undecoded: posting the spec's own sample room_type
/// "สามัญ ห้องรวม" stored as the UTF-8 byte sequence instead of 13 Thai code
/// points, and declaring "charset=utf-8" made no difference. Left alone it
/// corrupts every non-ASCII value.
ClassMethod ReadBodyAsUnicode() As %String
{
	Set tRaw = ""
	Do %request.Content.Rewind()
	While '%request.Content.AtEnd {
		Set tRaw = tRaw _ %request.Content.Read(32000)
	}
	Quit ..DecodeUTF8(tRaw)
}

/// Decode a UTF-8 byte string, leaving anything already decoded untouched.
///
/// A character above 255 means the stream was translated for us after all (a
/// different CSP/gateway configuration would do that), and decoding a second
/// time would corrupt it -- so bail out in that case. Pure ASCII decodes to
/// itself, so the common path is unaffected either way.
ClassMethod DecodeUTF8(pRaw As %String) As %String
{
	Quit:pRaw="" pRaw
	Set tWide = 0
	For i = 1:1:$Length(pRaw) {
		If $Ascii(pRaw, i) > 255 {
			Set tWide = 1
			Quit
		}
	}
	Quit:tWide pRaw
	Set tOut = pRaw
	Try {
		Set tOut = $ZConvert(pRaw, "I", "UTF8")
	}
	Catch {
		// Not valid UTF-8 -- keep the bytes rather than lose the payload.
		Set tOut = pRaw
	}
	Quit tOut
}

/// Line up the numeric-ish pre-auth fields with the types their message
/// properties declare, before %JSONImport sees them.
///
/// %JSON.Adaptor matches JSON types to property types strictly: a quoted
/// "age" landing on %Integer, or an unquoted estimated_cost landing on
/// %String, fails with "#9406 Unexpected format" and aborts the WHOLE import.
/// The V1.0.3 spec's own samples send age unquoted (18) but estimated_cost
/// quoted ("10000.00") -- coerce rather than reject a payload that is
/// otherwise fine. person and admission are single objects in V1.0.3.
ClassMethod NormalizePreAuthTypes(pJson As %DynamicObject)
{
	Do ..CoerceObjectField(pJson.%Get("person"), "age", "number")
	Do ..CoerceObjectField(pJson.%Get("admission"), "estimated_cost", "string")
}

/// Coerce pField to pType ("number" or "string") on one JSON object, leaving
/// an already-right type (or an absent field/object) untouched.
ClassMethod CoerceObjectField(pObject As %DynamicObject, pField As %String, pType As %String)
{
	Quit:'$IsObject(pObject)
	Quit:$ClassName(pObject)'="%Library.DynamicObject"
	Quit:'pObject.%IsDefined(pField)
	Quit:pObject.%GetTypeOf(pField)=pType
	Set tValue = pObject.%Get(pField)
	Do pObject.%Set(pField, $Select(pType = "number": +tValue, 1: tValue _ ""), pType)
}

/// Enter the production via a business service (tracked as a message session)
/// and write its response as JSON.
ClassMethod CallService(pServiceName As %String, pRequest As Ens.Request) As %Status
{
	Set tSC = ##class(Ens.Director).CreateBusinessService(pServiceName, .tService)
	If $$$ISERR(tSC) {
		Set %response.Status = ..#HTTP500INTERNALSERVERERROR
		Return ..WriteEnvelope("500", $System.Status.GetErrorText(tSC))
	}
	Set tSC = tService.ProcessInput(pRequest, .tResponse)
	If $$$ISERR(tSC) {
		Set %response.Status = ..#HTTP500INTERNALSERVERERROR
		Return ..WriteEnvelope("500", $System.Status.GetErrorText(tSC))
	}
	Set %response.ContentType = "application/json"
	Do tResponse.%JSONExport()
	Return $$$OK
}

/// Write a status envelope (used for error cases).
ClassMethod WriteEnvelope(pCode As %String, pMessage As %String) As %Status
{
	Set %response.ContentType = "application/json"
	Write {"response_code": (pCode), "response_message": (pMessage)}.%ToJSON()
	Return $$$OK
}

}
