Include %occStatus

/// POST /discharge/patch (API_PatchDischarge, V1.0.5) -- records the insurer's
/// discharge decision: guarantee letter, status, and who authorised it.
///
/// The spec names some of these "Patch" but specifies Method: Post
/// throughout, so the route is a POST.
///
/// This is the API that retired the synthetic gl_number. Before V1.0.5 no
/// request carried these fields, so PostDischarge generated placeholders;
/// it no longer does, and a discharge legitimately shows them empty until
/// this call arrives.
///
/// Patch semantics: only fields present in the request are written.
Class D1.REST.Impl.DischargePatch Extends D1.REST.Base
{

ClassMethod Handle() As %Status
{
	Try {
		Set tRequest = ##class(D1.Mock.Msg.PatchDischargeRequest).%New()
		Set tSC = ..ImportBody(tRequest)
		Return:$$$ISERR(tSC) ..BadRequest($System.Status.GetErrorText(tSC))
		Return:tRequest.AdmissionNumber="" ..BadRequest("admission_number is required")
		Return:tRequest.CompanyCode="" ..BadRequest("company_code is required")
		Set tSC = ..Run(tRequest, .tResponse)
		Return:$$$ISERR(tSC) ..ServerError($System.Status.GetErrorText(tSC))
		Return ..WriteResponse(tResponse)
	}
	Catch ex {
		Return ..ServerError(ex.DisplayString())
	}
}

ClassMethod Run(pRequest As D1.Mock.Msg.PatchDischargeRequest, Output pResponse As D1.Mock.Msg.PatchDischargeResponse) As %Status
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
		// side (/local/discharge-info) serves it as gl_number.
		Set:pRequest.DischargeGlNumber'="" tRow.GlNumber = pRequest.DischargeGlNumber
		Set:pRequest.DischargeStatus'="" tRow.DischargeStatus = pRequest.DischargeStatus
		Set:pRequest.AuthorizationTitle'="" tRow.AuthorizationTitle = pRequest.AuthorizationTitle
		Set:pRequest.AuthorizationFirstName'="" tRow.AuthorizationFirstName = pRequest.AuthorizationFirstName
		Set:pRequest.AuthorizationLastName'="" tRow.AuthorizationLastName = pRequest.AuthorizationLastName
		Set:pRequest.AuthorizationDate'="" tRow.AuthorizationDate = pRequest.AuthorizationDate
		Set:pRequest.AuthorizationAmount'="" tRow.AuthorizationAmount = pRequest.AuthorizationAmount
		Set:pRequest.DischargeGlDate'="" tRow.DischargeGlDate = pRequest.DischargeGlDate
		$$$THROWONERROR(tSC, tRow.%Save())

		// The client wants ClaimPreAuth.ClaimStatus to track the claim's overall
		// current status, so a new discharge_status overwrites it too.
		//
		// Reused from the original tree rather than copied, like the message and
		// data classes. It is a plain ClassMethod, so no production has to be
		// running for this to work -- the class merely happens to live on a
		// business operation.
		If pRequest.DischargeStatus'="" {
			$$$THROWONERROR(tSC, ##class(D1.Mock.BO.PostDischargeOperation).SyncPreAuthStatus(pRequest.DischargeStatus, tAdm))
		}

		Do ..Log("Patched discharge " _ tRow.DischargeId _ " for admission_number " _ tAdm _ " (company_code " _ pRequest.CompanyCode _ ", discharge_status " _ tRow.DischargeStatus _ ")")
		Set pResponse.ResponseCode = "200"
		Set pResponse.ResponseMessage = "Success"
	}
	Catch ex {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

}