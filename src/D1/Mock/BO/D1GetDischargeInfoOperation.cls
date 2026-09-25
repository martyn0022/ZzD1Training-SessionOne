/// Business Operation for API_D1GetDischargeInfo: date-range read over IRIS's
/// own discharge_info table, with an optional identity filter. Adapter-less.
/// 
/// DischargeDate is a "yyyy-MM-dd HH:mm:ss" wire string, so a string
/// range comparison sorts chronologically -- same convention as
/// D1GetPreAuthInfo.
/// 
/// The response carries ONE discharge object (not an array) per the sheet,
/// despite being a range query -- the flagged inconsistency with
/// D1GetPreAuthInfo. Built as written: the most recent match in range wins,
/// documented rather than silently arbitrary.
Class D1.Mock.BO.D1GetDischargeInfoOperation Extends Ens.BusinessOperation
{

Parameter ADAPTER;

Parameter INVOCATION = "Queue";

Method GetDischargeInfo(pRequest As D1.Mock.Msg.D1GetDischargeInfoRequest, Output pResponse As D1.Mock.Msg.D1GetDischargeInfoResponse) As %Status
{
	Set pResponse = ##class(D1.Mock.Msg.D1GetDischargeInfoResponse).%New()
	Set tSC = $$$OK
	Try {
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

		Set tSql = "SELECT HospitalNumber, AdmissionNumber, DischargeId, GlNumber, DischargeStatus, AuthorizationDate, AuthorizationAmount, DischargeGlDate FROM D1_Mock_Data.ClaimDischarge WHERE DischargeDate >= ? AND DischargeDate <= ?"
		Set:tHospitalNumber'="" tSql = tSql _ " AND HospitalNumber = ?"
		// Filtered on DischargeDate: start_reqdate / end_reqdate are documented
		// as "Start Discharge Date", and V1.0.3 added the column. It used to
		// filter AuthorizationDate, which forced PostDischarge to synthesise
		// one so rows would not be invisible. A claim with no discharge date
		// is now correctly absent here -- D1 finds those through
		// API_GetRecordList, which filters on status, not date.
		// Most recent first.
		Set tSql = tSql _ " ORDER BY DischargeDate DESC"

		Set tStmt = ##class(%SQL.Statement).%New()
		$$$THROWONERROR(tSC, tStmt.%Prepare(tSql))
		If tHospitalNumber '= "" {
			Set tRs = tStmt.%Execute(pRequest.StartReqDate, pRequest.EndReqDate, tHospitalNumber)
		}
		Else {
			Set tRs = tStmt.%Execute(pRequest.StartReqDate, pRequest.EndReqDate)
		}

		// V1.0.4: every match in range, not just the most recent -- the
		// response is an array now, each row carrying its own identifiers.
		Set tCount = 0
		While tRs.%Next() {
			Set tEntry = ##class(D1.Mock.Msg.D1DischargeEntry).%New()
			Set tEntry.InsurerInfo.HospitalNumber = tRs.%Get("HospitalNumber")
			Set tEntry.InsurerInfo.AdmissionNumber = tRs.%Get("AdmissionNumber")
			Set tEntry.DischargeInfo.DischargeId = tRs.%Get("DischargeId")
			Set tEntry.DischargeInfo.GlNumber = tRs.%Get("GlNumber")
			Set tEntry.DischargeInfo.DischargeStatus = tRs.%Get("DischargeStatus")
			Set tEntry.DischargeInfo.AuthorizationDate = tRs.%Get("AuthorizationDate")
			Set tEntry.DischargeInfo.AuthorizationAmount = tRs.%Get("AuthorizationAmount")
			Set tEntry.DischargeInfo.DischargeGlDate = tRs.%Get("DischargeGlDate")
			Do pResponse.Discharge.Insert(tEntry)
			Set tCount = tCount + 1
		}
		If tCount = 0 {
			Set pResponse.ResponseCode = "404"
			Set pResponse.ResponseMessage = "No discharge found in the requested date range"
			Quit
		}
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
  <MapItem MessageType="D1.Mock.Msg.D1GetDischargeInfoRequest">
    <Method>GetDischargeInfo</Method>
  </MapItem>
</MapItems>
}

}
