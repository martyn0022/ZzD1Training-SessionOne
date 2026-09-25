/// Business Operation for API_PatchPreAuth (V1.0.5): records the insurer's
/// pre-authorization decision against IRIS's own preauth_info row.
/// 
/// Patch semantics: only fields the request actually carries are written.
/// An absent or empty optional field means "leave alone", never "clear" --
/// otherwise a patch that reports only a status would wipe the case number.
Class D1.Mock.BO.PatchPreAuthOperation Extends Ens.BusinessOperation
{

Parameter ADAPTER;

Parameter INVOCATION = "Queue";

Method Patch(pRequest As D1.Mock.Msg.PatchPreAuthRequest, Output pResponse As D1.Mock.Msg.PatchPreAuthResponse) As %Status
{
	Set pResponse = ##class(D1.Mock.Msg.PatchPreAuthResponse).%New()
	Set tSC = $$$OK
	Try {
		// Tenancy first: one insurer must not patch another's record.
		Set tCode = ##class(D1.Mock.Util.ClaimCompanyResolver).Check(pRequest.AdmissionNumber, pRequest.CompanyCode, .tMsg)
		If tCode '= "200" {
			Set pResponse.ResponseCode = tCode, pResponse.ResponseMessage = tMsg
			Quit
		}

		Set tAdm = pRequest.AdmissionNumber, tId = ""
		// Same shape as PatchDischarge: ClaimId is unique, AdmissionNumber is
		// not, so an admission can hold several pre-auths (a resubmission with
		// a fresh auth_id makes a new row). The spec keys this call on the
		// admission alone, so take the most recent rather than an arbitrary
		// one. Raised with the spec owners.
		&sql(SELECT TOP 1 ID INTO :tId FROM D1_Mock_Data.ClaimPreAuth WHERE AdmissionNumber = :tAdm ORDER BY ID DESC)
		Set tRow = $Select(SQLCODE = 0: ##class(D1.Mock.Data.ClaimPreAuth).%OpenId(tId), 1: "")
		If '$IsObject(tRow) {
			Set pResponse.ResponseCode = "404"
			Set pResponse.ResponseMessage = "No pre-authorization found for admission_number " _ tAdm
			Quit
		}

		Set:pRequest.ClaimCaseNumber'="" tRow.ClaimCaseNumber = pRequest.ClaimCaseNumber
		Set:pRequest.ClaimStatus'="" tRow.ClaimStatus = pRequest.ClaimStatus
		Set:pRequest.SubmitDate'="" tRow.SubmitDate = pRequest.SubmitDate
		$$$THROWONERROR(tSC, tRow.%Save())

		$$$LOGINFO("Patched pre-auth " _ tRow.ClaimId _ " for admission_number " _ tAdm _ " (company_code " _ pRequest.CompanyCode _ ", claim_status " _ tRow.ClaimStatus _ ")")
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
  <MapItem MessageType="D1.Mock.Msg.PatchPreAuthRequest">
    <Method>Patch</Method>
  </MapItem>
</MapItems>
}

}
