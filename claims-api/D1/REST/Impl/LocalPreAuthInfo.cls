Include %occStatus

/// POST /local/preauth-info -- date-range read over IRIS's own preauth_info
/// table, with an optional identity filter.
///
/// SubmitDate is stored as a "yyyy-MM-dd HH:mm:ss" wire string, so a string
/// BETWEEN sorts correctly (ISO-8601-ordered text compares chronologically);
/// no date parsing is needed, and none is done -- storing dates verbatim is
/// the codebase convention.
///
/// V1.0.3 made preauth an ARRAY of self-contained rows, so a range spanning
/// several admissions answers correctly.
Class D1.REST.Impl.LocalPreAuthInfo Extends D1.REST.Base
{

ClassMethod Handle() As %Status
{
	Try {
		Set tRequest = ##class(D1.Mock.Msg.D1GetPreAuthInfoRequest).%New()
		Set tSC = ..ImportBody(tRequest)
		Return:$$$ISERR(tSC) ..BadRequest($System.Status.GetErrorText(tSC))
		If (tRequest.StartReqDate = "") || (tRequest.EndReqDate = "") {
			Return ..BadRequest("start_reqdate and end_reqdate are required")
		}
		Return:tRequest.IdentityType="" ..BadRequest("identity_type is required")
		Set tSC = ..Run(tRequest, .tResponse)
		Return:$$$ISERR(tSC) ..ServerError($System.Status.GetErrorText(tSC))
		Return ..WriteResponse(tResponse)
	}
	Catch ex {
		Return ..ServerError(ex.DisplayString())
	}
}

ClassMethod Run(pRequest As D1.Mock.Msg.D1GetPreAuthInfoRequest, Output pResponse As D1.Mock.Msg.D1GetPreAuthInfoResponse) As %Status
{
	Set pResponse = ##class(D1.Mock.Msg.D1GetPreAuthInfoResponse).%New()
	Set tSC = $$$OK
	Try {
		// identity_no is optional: when omitted, the whole window is returned.
		Set tHospitalNumber = ""
		If pRequest.IdentityNo '= "" {
			Set tSC = ##class(D1.Mock.Util.ClaimIdentityResolver).Resolve(pRequest.IdentityType, pRequest.IdentityNo, .tHospitalNumber, .tAdmissionNumber)
			Quit:$$$ISERR(tSC)
			If tHospitalNumber = "" {
				Set pResponse.ResponseCode = "404"
				Set pResponse.ResponseMessage = "No patient found for identity " _ pRequest.IdentityType _ " " _ pRequest.IdentityNo
				Quit
			}
		}

		Set tSql = "SELECT HospitalNumber, AdmissionNumber, ClaimId, ClaimCaseNumber, ClaimStatus, SubmitDate, EstimatedCost FROM D1_Mock_Data.ClaimPreAuth WHERE SubmitDate >= ? AND SubmitDate <= ?"
		Set:tHospitalNumber'="" tSql = tSql _ " AND HospitalNumber = ?"
		Set tSql = tSql _ " ORDER BY SubmitDate"

		Set tStmt = ##class(%SQL.Statement).%New()
		$$$THROWONERROR(tSC, tStmt.%Prepare(tSql))
		If tHospitalNumber '= "" {
			Set tRs = tStmt.%Execute(pRequest.StartReqDate, pRequest.EndReqDate, tHospitalNumber)
		}
		Else {
			Set tRs = tStmt.%Execute(pRequest.StartReqDate, pRequest.EndReqDate)
		}

		While tRs.%Next() {
			Set tRow = ##class(D1.Mock.Msg.PreAuthDetail).%New()
			Set tRow.HospitalNumber = tRs.%Get("HospitalNumber")
			Set tRow.AdmissionNumber = tRs.%Get("AdmissionNumber")
			Set tRow.ClaimId = tRs.%Get("ClaimId")
			Set tRow.ClaimCaseNumber = tRs.%Get("ClaimCaseNumber")
			Set tRow.ClaimStatus = tRs.%Get("ClaimStatus")
			Set tRow.SubmitDate = tRs.%Get("SubmitDate")
			Set tRow.EstimatedCost = tRs.%Get("EstimatedCost")
			Do pResponse.PreAuth.Insert(tRow)
		}
		Set pResponse.ResponseCode = "200"
		Set pResponse.ResponseMessage = "Success"
	}
	Catch ex {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

}