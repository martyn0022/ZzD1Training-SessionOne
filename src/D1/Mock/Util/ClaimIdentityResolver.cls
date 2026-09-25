/// Identity dispatch for the group-2 reads -- the local-table counterpart of
/// HISOperation's HTTP resolver.
/// 
///   HN / CID / PID -> ClaimPatient      VN -> ClaimVisit      AN -> ClaimAdmission
/// 
/// pAdmissionNumber is "" for patient-level identities (one patient can span
/// several admissions). An unknown identity yields "" with an OK status --
/// "not found" is in-band data for the callers, not an error.
Class D1.Mock.Util.ClaimIdentityResolver
{

ClassMethod Resolve(pIdentityType As %String, pIdentityNo As %String, Output pHospitalNumber As %String, Output pAdmissionNumber As %String) As %Status
{
	Set pHospitalNumber = "", pAdmissionNumber = ""
	Quit:pIdentityNo="" $$$OK
	If pIdentityType = "HN" {
		&sql(SELECT HospitalNumber INTO :pHospitalNumber FROM D1_Mock_Data.ClaimPatient WHERE HospitalNumber = :pIdentityNo)
		Set:SQLCODE'=0 pHospitalNumber = ""
		Quit $$$OK
	}
	If pIdentityType = "CID" {
		// ClaimPatient.CitizenId is stored dash-stripped (varchar(13)); a
		// dashed lookup value ("3-1258-00558-89-8") must be stripped the
		// same way or it will never match.
		Set tCitizenId = $Translate(pIdentityNo, "-")
		&sql(SELECT HospitalNumber INTO :pHospitalNumber FROM D1_Mock_Data.ClaimPatient WHERE CitizenId = :tCitizenId)
		Set:SQLCODE'=0 pHospitalNumber = ""
		Quit $$$OK
	}
	If pIdentityType = "PID" {
		&sql(SELECT HospitalNumber INTO :pHospitalNumber FROM D1_Mock_Data.ClaimPatient WHERE PassportId = :pIdentityNo)
		Set:SQLCODE'=0 pHospitalNumber = ""
		Quit $$$OK
	}
	If pIdentityType = "VN" {
		&sql(SELECT HospitalNumber INTO :pHospitalNumber FROM D1_Mock_Data.ClaimVisit WHERE VisitNumber = :pIdentityNo)
		Set:SQLCODE'=0 pHospitalNumber = ""
		Quit $$$OK
	}
	If pIdentityType = "AN" {
		Set pAdmissionNumber = pIdentityNo
		&sql(SELECT HospitalNumber INTO :pHospitalNumber FROM D1_Mock_Data.ClaimAdmission WHERE AdmissionNumber = :pIdentityNo)
		If SQLCODE '= 0 {
			Set pHospitalNumber = "", pAdmissionNumber = ""
		}
		Quit $$$OK
	}
	Quit $$$ERROR($$$GeneralError, "Unsupported identity_type: " _ pIdentityType)
}

}
