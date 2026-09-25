/// Business Operation for API_D1GetPatient: reads IRIS's OWN patient_info
/// table. Adapter-less -- group 2 never touches the HIS.
/// 
/// Answers D1GetPatient's nested patient[] { patient_info } shape, which
/// V1.0.3 kept while group-1's GetPatient flattened -- hence its own
/// response class rather than a reuse.
Class D1.Mock.BO.D1GetPatientOperation Extends Ens.BusinessOperation
{

Parameter ADAPTER;

Parameter INVOCATION = "Queue";

Method GetPatient(pRequest As D1.Mock.Msg.GetPatientRequest, Output pResponse As D1.Mock.Msg.D1GetPatientResponse) As %Status
{
	Set pResponse = ##class(D1.Mock.Msg.D1GetPatientResponse).%New()
	Set tSC = $$$OK
	Try {
		Set tSC = ##class(D1.Mock.Util.ClaimIdentityResolver).Resolve(pRequest.IdentityType, pRequest.IdentityNo, .tHospitalNumber, .tAdmissionNumber)
		Quit:$$$ISERR(tSC)
		If tHospitalNumber = "" {
			Set pResponse.ResponseCode = "404"
			Set pResponse.ResponseMessage = "No patient found for identity " _ pRequest.IdentityType _ " " _ pRequest.IdentityNo
			Quit
		}

		Set tStmt = ##class(%SQL.Statement).%New()
		$$$THROWONERROR(tSC, tStmt.%Prepare("SELECT HospitalNumber, CitizenId, PassportId, Title, FirstName, LastName, Gender, BirthDate, Address, PhoneNumber FROM D1_Mock_Data.ClaimPatient WHERE HospitalNumber = ?"))
		Set tRs = tStmt.%Execute(tHospitalNumber)
		If tRs.%Next() {
			Set tInfo = ##class(D1.Mock.Msg.PatientInfo).%New()
			Set tInfo.HospitalNumber = tRs.%Get("HospitalNumber")
			Set tInfo.CitizenId = tRs.%Get("CitizenId")
			Set tInfo.PassportId = tRs.%Get("PassportId")
			Set tInfo.Title = tRs.%Get("Title")
			Set tInfo.FirstName = tRs.%Get("FirstName")
			Set tInfo.LastName = tRs.%Get("LastName")
			Set tInfo.Gender = tRs.%Get("Gender")
			Set tInfo.BirthDate = tRs.%Get("BirthDate")
			Set tInfo.Address = tRs.%Get("Address")
			Set tInfo.PhoneNumber = tRs.%Get("PhoneNumber")
			Set tWrapper = ##class(D1.Mock.Msg.D1PatientWrapper).%New()
			Set tWrapper.PatientInfo = tInfo
			Do pResponse.Patient.Insert(tWrapper)
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
  <MapItem MessageType="D1.Mock.Msg.GetPatientRequest">
    <Method>GetPatient</Method>
  </MapItem>
</MapItems>
}

}
