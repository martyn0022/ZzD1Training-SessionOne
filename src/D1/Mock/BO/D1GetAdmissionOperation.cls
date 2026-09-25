/// Business Operation for API_D1GetAdmission: reads IRIS's own
/// admission_info table. Adapter-less.
/// 
/// This sheet kept the WIDER identity set (VN/HN/AN) even though group-1's
/// API_GetAdmission narrowed to VN/AN in V1.0.3 -- an asymmetry built as
/// written (plan open item 10). For a patient-level identity (HN/CID/PID)
/// the resolver cannot pick a single admission, so the most recent one for
/// that patient is returned.
Class D1.Mock.BO.D1GetAdmissionOperation Extends Ens.BusinessOperation
{

Parameter ADAPTER;

Parameter INVOCATION = "Queue";

Method GetAdmission(pRequest As D1.Mock.Msg.GetAdmissionRequest, Output pResponse As D1.Mock.Msg.D1GetAdmissionResponse) As %Status
{
	Set pResponse = ##class(D1.Mock.Msg.D1GetAdmissionResponse).%New()
	Set tSC = $$$OK
	Try {
		Set tSC = ##class(D1.Mock.Util.ClaimIdentityResolver).Resolve(pRequest.IdentityType, pRequest.IdentityNo, .tHospitalNumber, .tAdmissionNumber)
		Quit:$$$ISERR(tSC)
		If (tHospitalNumber = "") && (tAdmissionNumber = "") {
			Set pResponse.ResponseCode = "404"
			Set pResponse.ResponseMessage = "No admission found for identity " _ pRequest.IdentityType _ " " _ pRequest.IdentityNo
			Quit
		}

		Set tStmt = ##class(%SQL.Statement).%New()
		If tAdmissionNumber '= "" {
			$$$THROWONERROR(tSC, tStmt.%Prepare("SELECT AdmissionNumber, HospitalNumber, AdmissionDate, WardNumber, WardType, RoomType, BedNo, ExpectedDischargeDate, ActualDischargeDate, EstimatedLengthOfStay, EstimatedCost FROM D1_Mock_Data.ClaimAdmission WHERE AdmissionNumber = ?"))
			Set tRs = tStmt.%Execute(tAdmissionNumber)
		}
		Else {
			// Patient-level identity implies no single admission: take the latest.
			$$$THROWONERROR(tSC, tStmt.%Prepare("SELECT AdmissionNumber, HospitalNumber, AdmissionDate, WardNumber, WardType, RoomType, BedNo, ExpectedDischargeDate, ActualDischargeDate, EstimatedLengthOfStay, EstimatedCost FROM D1_Mock_Data.ClaimAdmission WHERE HospitalNumber = ? ORDER BY AdmissionDate DESC"))
			Set tRs = tStmt.%Execute(tHospitalNumber)
		}

		If 'tRs.%Next() {
			Set pResponse.ResponseCode = "404"
			Set pResponse.ResponseMessage = "No admission found for identity " _ pRequest.IdentityType _ " " _ pRequest.IdentityNo
			Quit
		}
		Set pResponse.HospitalNumber = tRs.%Get("HospitalNumber")
		Set pResponse.AdmissionNumber = tRs.%Get("AdmissionNumber")
		Set pResponse.Admission.AdmissionNumber = tRs.%Get("AdmissionNumber")
		Set pResponse.Admission.AdmissionDate = tRs.%Get("AdmissionDate")
		Set pResponse.Admission.WardNumber = tRs.%Get("WardNumber")
		Set pResponse.Admission.WardType = tRs.%Get("WardType")
		Set pResponse.Admission.RoomType = tRs.%Get("RoomType")
		Set pResponse.Admission.BedNo = tRs.%Get("BedNo")
		Set pResponse.Admission.EstimatedLengthOfStay = tRs.%Get("EstimatedLengthOfStay")
		Set pResponse.Admission.EstimatedCost = tRs.%Get("EstimatedCost")
		Set pResponse.Admission.ExpectedDischargeDate = tRs.%Get("ExpectedDischargeDate")
		Set pResponse.Admission.ActualDischargeDate = tRs.%Get("ActualDischargeDate")
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
  <MapItem MessageType="D1.Mock.Msg.GetAdmissionRequest">
    <Method>GetAdmission</Method>
  </MapItem>
</MapItems>
}

}
