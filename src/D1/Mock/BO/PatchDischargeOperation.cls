/// Business Operation for API_PatchDischarge (V1.0.5): records the insurer's
/// discharge decision -- guarantee letter, status, and who authorised it.
/// 
/// This is the API that retired the synthetic gl_number. Before V1.0.5 no
/// request carried these fields, so PostDischarge generated placeholders;
/// it no longer does, and a discharge legitimately shows them empty until
/// this call arrives.
/// 
/// Patch semantics: only fields present in the request are written.
/// 
/// discharge_status, when present, also overwrites ClaimPreAuth.ClaimStatus
/// for this admission (PostDischargeOperation.SyncPreAuthStatus) -- the
/// client wants that column to track the claim's overall current status.
Class D1.Mock.BO.PatchDischargeOperation Extends Ens.BusinessOperation
{

Parameter ADAPTER;

Parameter INVOCATION = "Queue";

Method Patch(pRequest As D1.Mock.Msg.PatchDischargeRequest, Output pResponse As D1.Mock.Msg.PatchDischargeResponse) As %Status
{
	Set pResponse = ##class(D1.Mock.Msg.PatchDischargeResponse).%New()
	Set tSC = $$$OK
	Try {
		Set tCode = ##class(D1.Mock.Util.ClaimCompanyResolver).Check(pRequest.AdmissionNumber, pRequest.CompanyCode, .tMsg)
		If tCode '= "200" {
			Set pResponse.ResponseCode = tCode, pResponse.ResponseMessage = tMsg
			Quit
		}

		Set tAdm = pRequest.AdmissionNumber, tId = ""
	// An admission can hold SEVERAL discharge rows -- DischargeId is unique,
	// AdmissionNumber is not -- but the spec keys this call on the admission
	// alone and offers no discharge_id to disambiguate. Take the most recent
	// so the behaviour is at least deterministic; without the ORDER BY the row
	// chosen is arbitrary. Raised with the spec owners.
		&sql(SELECT TOP 1 ID INTO :tId FROM D1_Mock_Data.ClaimDischarge WHERE AdmissionNumber = :tAdm ORDER BY ID DESC)
		Set tRow = $Select(SQLCODE = 0: ##class(D1.Mock.Data.ClaimDischarge).%OpenId(tId), 1: "")
		If '$IsObject(tRow) {
			Set pResponse.ResponseCode = "404"
			Set pResponse.ResponseMessage = "No discharge found for admission_number " _ tAdm
			Quit
		}

		// discharge_gl_number on the wire, GlNumber in the table -- the read
		// side (D1GetDischargeInfo) serves it as gl_number.
		Set:pRequest.DischargeGlNumber'="" tRow.GlNumber = pRequest.DischargeGlNumber
		Set:pRequest.DischargeStatus'="" tRow.DischargeStatus = pRequest.DischargeStatus
		Set:pRequest.AuthorizationTitle'="" tRow.AuthorizationTitle = pRequest.AuthorizationTitle
		Set:pRequest.AuthorizationFirstName'="" tRow.AuthorizationFirstName = pRequest.AuthorizationFirstName
		Set:pRequest.AuthorizationLastName'="" tRow.AuthorizationLastName = pRequest.AuthorizationLastName
		Set:pRequest.AuthorizationDate'="" tRow.AuthorizationDate = pRequest.AuthorizationDate
		Set:pRequest.AuthorizationAmount'="" tRow.AuthorizationAmount = pRequest.AuthorizationAmount
		Set:pRequest.DischargeGlDate'="" tRow.DischargeGlDate = pRequest.DischargeGlDate
		$$$THROWONERROR(tSC, tRow.%Save())

		// Same overall-status sync PostDischargeOperation does; only when this
		// patch actually carries a new discharge_status.
		If pRequest.DischargeStatus'="" {
			$$$THROWONERROR(tSC, ##class(D1.Mock.BO.PostDischargeOperation).SyncPreAuthStatus(pRequest.DischargeStatus, tAdm))
		}

		$$$LOGINFO("Patched discharge " _ tRow.DischargeId _ " for admission_number " _ tAdm _ " (company_code " _ pRequest.CompanyCode _ ", discharge_status " _ tRow.DischargeStatus _ ")")
		Set pResponse.ResponseCode = "200"
		Set pResponse.ResponseMessage = "Success"
	}
	Catch ex {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

XData MessageMap
{
<MapItems>
  <MapItem MessageType="D1.Mock.Msg.PatchDischargeRequest">
    <Method>Patch</Method>
  </MapItem>
</MapItems>
}

}
