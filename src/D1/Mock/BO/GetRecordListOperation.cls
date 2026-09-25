/// Business Operation for API_GetRecordList (V1.0.5): the insurer's worklist
/// of records still awaiting their decision.
/// 
/// company_code lives only on policy_info, so every mode joins through it --
/// which is also the tenancy boundary. An admission with no policy row is
/// invisible here; PostPreAuth snapshots one precisely so that pre-auths are
/// not.
/// 
/// Statuses come straight from the API spec's enums. IRIS generates the
/// spec's spelling on insert, so no leniency is needed here -- matching
/// variants would only hide a mismatch that D1 should see.
/// 
/// The customer narrowed "Pre-Auth"/"Discharge" mode's filter to exactly one
/// status each: "Pre-Authorize Submitted" and "Discharge Requested".
/// "Waiting for Medical" was dropped, so a record in that state appears on
/// NEITHER worklist.
/// 
/// Each row carries BOTH statuses (claim_status, discharge_status) via an
/// outer join, so one call shows the whole state of an admission. Neither is
/// a new stored value; claim_status was named auth_status before the spec
/// renamed it to match D1GetPreAuthInfo's field name (see RecordListItem).
/// 
/// "All" (V1.0.8): every admission with a policy under this insurer,
/// unfiltered by status, one row per admission_number.
Class D1.Mock.BO.GetRecordListOperation Extends Ens.BusinessOperation
{

Parameter ADAPTER;

Parameter INVOCATION = "Queue";

Method GetRecordList(pRequest As D1.Mock.Msg.GetRecordListRequest, Output pResponse As D1.Mock.Msg.GetRecordListResponse) As %Status
{
	Set pResponse = ##class(D1.Mock.Msg.GetRecordListResponse).%New()
	Set tSC = $$$OK
	Try {
		If pRequest.CompanyCode = "" {
			Set pResponse.ResponseCode = "400", pResponse.ResponseMessage = "company_code is required"
			Quit
		}

		Set tMultiBind = 0
		If pRequest.ListMode = "Pre-Auth" {
			Set tSql = "SELECT p.AdmissionNumber, p.ClaimStatus AS ClaimStat, d.DischargeStatus AS DischStat "
				_ "FROM D1_Mock_Data.ClaimPreAuth p "
				_ "JOIN D1_Mock_Data.ClaimPolicy pol ON pol.AdmissionNumber = p.AdmissionNumber "
				_ "LEFT JOIN D1_Mock_Data.ClaimDischarge d ON d.AdmissionNumber = p.AdmissionNumber "
				_ "WHERE pol.CompanyCode = ? AND p.ClaimStatus = 'Pre-Authorize Submitted' "
				_ "ORDER BY p.AdmissionNumber"
		}
		ElseIf pRequest.ListMode = "Discharge" {
			Set tSql = "SELECT d.AdmissionNumber, p.ClaimStatus AS ClaimStat, d.DischargeStatus AS DischStat "
				_ "FROM D1_Mock_Data.ClaimDischarge d "
				_ "JOIN D1_Mock_Data.ClaimPolicy pol ON pol.AdmissionNumber = d.AdmissionNumber "
				_ "LEFT JOIN D1_Mock_Data.ClaimPreAuth p ON p.AdmissionNumber = d.AdmissionNumber "
				_ "WHERE pol.CompanyCode = ? AND d.DischargeStatus = 'Discharge Requested' "
				_ "ORDER BY d.AdmissionNumber"
		}
		ElseIf pRequest.ListMode = "All" {
			// V1.0.8: every admission with a policy under this insurer, one row
			// each, both statuses (claim_status from ClaimPreAuth, discharge_status
			// from ClaimDischarge -- either can be absent). PostDischarge/
			// PatchDischarge now also overwrite ClaimPreAuth.ClaimStatus (see
			// PostDischargeOperation), so claim_status here already reflects the
			// latest stage for admissions that have a pre-auth row; the second
			// branch only exists for the edge case of a discharge with no
			// preceding pre-auth row at all.
			//
			// Two mutually exclusive branches (the second explicitly excludes what
			// the first already covers) so UNION ALL never needs to de-dup them.
			// Deliberately not plain UNION or COALESCE: both force IRIS SQL through
			// a DISTINCT-style comparison that returns %String columns in their
			// default SQLUPPER collation ("Approved" comes back "APPROVED") instead
			// of the stored value.
			Set tSql = "SELECT p.AdmissionNumber, p.ClaimStatus AS ClaimStat, d.DischargeStatus AS DischStat "
				_ "FROM D1_Mock_Data.ClaimPreAuth p "
				_ "JOIN D1_Mock_Data.ClaimPolicy pol ON pol.AdmissionNumber = p.AdmissionNumber "
				_ "LEFT JOIN D1_Mock_Data.ClaimDischarge d ON d.AdmissionNumber = p.AdmissionNumber "
				_ "WHERE pol.CompanyCode = ? "
				_ "UNION ALL "
				_ "SELECT d.AdmissionNumber, NULL, d.DischargeStatus "
				_ "FROM D1_Mock_Data.ClaimDischarge d "
				_ "JOIN D1_Mock_Data.ClaimPolicy pol ON pol.AdmissionNumber = d.AdmissionNumber "
				_ "WHERE pol.CompanyCode = ? "
				_ "AND NOT EXISTS (SELECT 1 FROM D1_Mock_Data.ClaimPreAuth p2 WHERE p2.AdmissionNumber = d.AdmissionNumber) "
				_ "ORDER BY AdmissionNumber"
			Set tMultiBind = 1
		}
		Else {
			Set pResponse.ResponseCode = "400"
			Set pResponse.ResponseMessage = "list_mode must be 'Pre-Auth', 'Discharge', or 'All', got '" _ pRequest.ListMode _ "'"
			Quit
		}

		Set tStmt = ##class(%SQL.Statement).%New()
		$$$THROWONERROR(tSC, tStmt.%Prepare(tSql))
		Set tRs = $Select(tMultiBind: tStmt.%Execute(pRequest.CompanyCode, pRequest.CompanyCode), 1: tStmt.%Execute(pRequest.CompanyCode))
		While tRs.%Next() {
			Set tItem = ##class(D1.Mock.Msg.RecordListItem).%New()
			Set tItem.AdmissionNumber = tRs.%Get("AdmissionNumber")
			Set tItem.ClaimStatus = tRs.%Get("ClaimStat")
			Set tItem.DischargeStatus = tRs.%Get("DischStat")
			Do pResponse.RecordList.Insert(tItem)
		}

		// An empty worklist is a valid answer, not a 404 -- it means the
		// insurer has nothing outstanding. %JSONNULL on the response makes
		// that surface as "record_list": null rather than a missing key.
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
  <MapItem MessageType="D1.Mock.Msg.GetRecordListRequest">
    <Method>GetRecordList</Method>
  </MapItem>
</MapItems>
}

}
