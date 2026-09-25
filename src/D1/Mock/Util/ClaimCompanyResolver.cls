/// Tenancy check for the V1.0.5 APIs, all of which take company_code as a
/// REQUIRED field: PatchPreAuth, PatchDischarge, GetRecordList,
/// GetDocumentInfo.
/// 
/// company_code is not a lookup key -- it is an authorisation boundary. D1
/// serves several insurers, and one insurer must not read or patch another's
/// records. Every call that names an admission goes through Check() first.
/// 
/// WHY THE JOIN: neither preauth_info nor discharge_info carries company_code
/// in data dictionary V1.0.3. It lives only on policy_info, whose PK is
/// admission_number -- so exactly one insurer owns any given admission, and
/// admission -> policy -> company is single-valued and unambiguous. The
/// dictionary and the API spec were revised on the same day and the column
/// still was not added to the other two tables, so this normalisation reads
/// as deliberate rather than an oversight.
/// 
/// The dependency this creates: an admission with no ClaimPolicy row is
/// invisible to every API above. PostPreAuth must therefore snapshot
/// ClaimPolicy -- which is why V1.0.5 added the insurer block to its request.
Class D1.Mock.Util.ClaimCompanyResolver
{

/// Outcome codes, matching the in-band envelope the callers return.
/// "200" the admission belongs to this insurer, proceed
/// "404" no policy row -- unknown admission, or a pre-auth stored before
///       PostPreAuth snapshotted the policy
/// "403" the admission exists but belongs to a DIFFERENT insurer
/// 
/// 403 rather than 404 on a mismatch is a deliberate choice: it is not a
/// missing record, it is a refused one, and collapsing the two would let a
/// caller probe which admission numbers exist. The spec defines neither.
ClassMethod Check(pAdmissionNumber As %String, pCompanyCode As %String, Output pMessage As %String) As %String
{
	Set pMessage = ""
	If pAdmissionNumber = "" {
		Set pMessage = "admission_number is required"
		Quit "400"
	}
	If pCompanyCode = "" {
		Set pMessage = "company_code is required"
		Quit "400"
	}

	Set tOwner = ""
	&sql(SELECT CompanyCode INTO :tOwner FROM D1_Mock_Data.ClaimPolicy WHERE AdmissionNumber = :pAdmissionNumber)
	If SQLCODE '= 0 {
		Set pMessage = "No policy found for admission_number " _ pAdmissionNumber
		Quit "404"
	}
	If tOwner '= pCompanyCode {
		Set pMessage = "admission_number " _ pAdmissionNumber _ " does not belong to company_code " _ pCompanyCode
		Quit "403"
	}
	Quit "200"
}

}
