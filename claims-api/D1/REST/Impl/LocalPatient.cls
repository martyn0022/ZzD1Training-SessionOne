Include %occStatus

/// POST /local/patient -- reads IRIS's OWN patient_info table. Never touches
/// the HIS.
///
/// Answers the nested patient[] { patient_info } shape, which V1.0.3 kept
/// while group-1's GetPatient flattened -- hence its own response class rather
/// than a reuse.
Class D1.REST.Impl.LocalPatient Extends D1.REST.Base
{

ClassMethod Handle() As %Status
{
	Try {
		Set tRequest = ##class(D1.Mock.Msg.GetPatientRequest).%New()
		Set tSC = ..ImportBody(tRequest)
		Return:$$$ISERR(tSC) ..BadRequest($System.Status.GetErrorText(tSC))
		If (tRequest.IdentityType = "") || (tRequest.IdentityNo = "") {
			Return ..BadRequest("identity_type and identity_no are required")
		}
		If '$ListFind($ListBuild("CID", "PID", "VN", "HN", "AN"), tRequest.IdentityType) {
			Return ..BadRequest("identity_type must be one of CID, PID, VN, HN, AN")
		}
		Set tSC = ..Run(tRequest, .tResponse)
		Return:$$$ISERR(tSC) ..ServerError($System.Status.GetErrorText(tSC))
		Return ..WriteResponse(tResponse)
	}
	Catch ex {
		Return ..ServerError(ex.DisplayString())
	}
}

ClassMethod Run(pRequest As D1.Mock.Msg.GetPatientRequest, Output pResponse As D1.Mock.Msg.D1GetPatientResponse) As %Status
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

}