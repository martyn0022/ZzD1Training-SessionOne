/// Business Operation for API_D1GetPolicy: reads IRIS's own policy_info
/// table, keyed directly by admission_number. Adapter-less.
Class D1.Mock.BO.D1GetPolicyOperation Extends Ens.BusinessOperation
{

Parameter ADAPTER;

Parameter INVOCATION = "Queue";

Method GetPolicy(pRequest As D1.Mock.Msg.D1GetPolicyRequest, Output pResponse As D1.Mock.Msg.D1GetPolicyResponse) As %Status
{
	Set pResponse = ##class(D1.Mock.Msg.D1GetPolicyResponse).%New()
	Set tSC = $$$OK
	Try {
		Set tStmt = ##class(%SQL.Statement).%New()
		$$$THROWONERROR(tSC, tStmt.%Prepare("SELECT HospitalNumber, AdmissionNumber, CompanyCode, CompanyName, PolicyId, PlanCode, PlanName, PolicyNumber FROM D1_Mock_Data.ClaimPolicy WHERE AdmissionNumber = ?"))
		Set tRs = tStmt.%Execute(pRequest.AdmissionNumber)
		If 'tRs.%Next() {
			Set pResponse.ResponseCode = "404"
			Set pResponse.ResponseMessage = "No policy found for admission_number " _ pRequest.AdmissionNumber
			Quit
		}
		Set pResponse.HospitalNumber = tRs.%Get("HospitalNumber")
		Set pResponse.AdmissionNumber = tRs.%Get("AdmissionNumber")
		Set pResponse.Insurer.CompanyCode = tRs.%Get("CompanyCode")
		Set pResponse.Insurer.CompanyName = tRs.%Get("CompanyName")
		Set pResponse.Policies.PolicyId = tRs.%Get("PolicyId")
		Set pResponse.Policies.PlanCode = tRs.%Get("PlanCode")
		Set pResponse.Policies.PlanName = tRs.%Get("PlanName")
		Set pResponse.Policies.PolicyNumber = tRs.%Get("PolicyNumber")
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
  <MapItem MessageType="D1.Mock.Msg.D1GetPolicyRequest">
    <Method>GetPolicy</Method>
  </MapItem>
</MapItems>
}

}
