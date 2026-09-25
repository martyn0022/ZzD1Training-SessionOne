/// Business Operation for API_GetAdmission V1.0.3: one HIS episode read, one
/// DTL, invoked programmatically -- a plain adapter-less BO instead of a BPL,
/// since a single-call single-transform flow doesn't warrant the graphical
/// orchestration layer (per the plan's per-API judgment).
/// 
/// Calls the HIS Operation config item via SendRequestSync (distinct pool,
/// no deadlock risk), then runs the PAAdmToAdmission transform in code.
Class D1.Mock.BO.AdmissionMapperOperation Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

/// The HIS-calling operation this flow reads through.
Property HISTargetConfigName As %String(MAXLEN = 1000) [ InitialExpression = "HIS Operation" ];

Parameter SETTINGS = "HISTargetConfigName:Basic";

Method GetAdmission(pRequest As D1.Mock.Msg.GetAdmissionRequest, Output pResponse As D1.Mock.Msg.GetAdmissionResponse) As %Status
{
	Set tSC = $$$OK
	Try {
		Set pResponse = ##class(D1.Mock.Msg.GetAdmissionResponse).%New()

		Set tHISRequest = ##class(D1.Mock.Msg.HIS.PAAdmRequest).%New()
		Set tHISRequest.IdentityType = pRequest.IdentityType
		Set tHISRequest.IdentityNo = pRequest.IdentityNo
		Set tSC = ..SendRequestSync(..HISTargetConfigName, tHISRequest, .tAdmResp)
		Quit:$$$ISERR(tSC)

		If '##class(D1.Mock.BP.PatientMapper).HasRows(tAdmResp) {
			Set pResponse.ResponseCode = "404"
			Set pResponse.ResponseMessage = "No admission found for identity " _ pRequest.IdentityType _ " " _ pRequest.IdentityNo
			Quit
		}

		// The one transform: raw episode row -> the whole V1.0.3 response
		// (envelope, echo fields, admission_info; ward_type from CARETYPDesc (best guess)).
		Set tSC = ##class(D1.Mock.DT.PAAdmToAdmission).Transform(tAdmResp, .pResponse)
	}
	Catch ex {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

/// Draw the connection to the HIS operation in the production diagram.
ClassMethod OnGetConnections(Output pArray As %String, pItem As Ens.Config.Item)
{
	Do ##super(.pArray, pItem)
	If pItem.GetModifiedSetting("HISTargetConfigName", .tTarget), (tTarget '= "") {
		Set pArray(tTarget) = ""
	}
}

XData MessageMap
{
<MapItems>
  <MapItem MessageType="D1.Mock.Msg.GetAdmissionRequest">
    <Method>GetAdmission</Method>
  </MapItem>
</MapItems>
}

}
