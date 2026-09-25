Include %occStatus

/// POST /local/benefit -- the insurer reference data (benefit_info plus its
/// coverage items) for one policy.
///
/// Two-level read: benefits joined to the policy (so company_code filters),
/// then the coverage items per benefit. hospital_number / admission_number
/// come from the policy row -- the benefit table itself is policy-scoped, not
/// admission-scoped.
Class D1.REST.Impl.LocalBenefit Extends D1.REST.Base
{

ClassMethod Handle() As %Status
{
	Try {
		Set tRequest = ##class(D1.Mock.Msg.D1GetBenefitRequest).%New()
		Set tSC = ..ImportBody(tRequest)
		Return:$$$ISERR(tSC) ..BadRequest($System.Status.GetErrorText(tSC))
		If (tRequest.PolicyNumber = "") || (tRequest.CompanyCode = "") {
			Return ..BadRequest("policy_number and company_code are required")
		}
		Set tSC = ..Run(tRequest, .tResponse)
		Return:$$$ISERR(tSC) ..ServerError($System.Status.GetErrorText(tSC))
		Return ..WriteResponse(tResponse)
	}
	Catch ex {
		Return ..ServerError(ex.DisplayString())
	}
}

ClassMethod Run(pRequest As D1.Mock.Msg.D1GetBenefitRequest, Output pResponse As D1.Mock.Msg.D1GetBenefitResponse) As %Status
{
	Set pResponse = ##class(D1.Mock.Msg.D1GetBenefitResponse).%New()
	Set tSC = $$$OK
	Try {
		// The policy row supplies the claim context the response echoes.
		Set tStmt = ##class(%SQL.Statement).%New()
		$$$THROWONERROR(tSC, tStmt.%Prepare("SELECT HospitalNumber, AdmissionNumber FROM D1_Mock_Data.ClaimPolicy WHERE PolicyNumber = ? AND CompanyCode = ?"))
		Set tRs = tStmt.%Execute(pRequest.PolicyNumber, pRequest.CompanyCode)
		If 'tRs.%Next() {
			Set pResponse.ResponseCode = "404"
			Set pResponse.ResponseMessage = "No policy found for policy_number " _ pRequest.PolicyNumber _ " and company_code " _ pRequest.CompanyCode
			Quit
		}
		Set pResponse.HospitalNumber = tRs.%Get("HospitalNumber")
		Set pResponse.AdmissionNumber = tRs.%Get("AdmissionNumber")

		Set tBenefitStmt = ##class(%SQL.Statement).%New()
		$$$THROWONERROR(tSC, tBenefitStmt.%Prepare("SELECT BenefitKey, BenefitCode, BenefitName, BenefitStatus, MaximumAmount, RemainingAmount FROM D1_Mock_Data.ClaimBenefit WHERE PolicyNumber = ? ORDER BY BenefitKey"))
		Set tBenefitRs = tBenefitStmt.%Execute(pRequest.PolicyNumber)
		While tBenefitRs.%Next() {
			Set tBenefit = ##class(D1.Mock.Msg.BenefitDetail).%New()
			Set tBenefit.BenefitCode = tBenefitRs.%Get("BenefitCode")
			Set tBenefit.BenefitName = tBenefitRs.%Get("BenefitName")
			Set tBenefit.BenefitStatus = tBenefitRs.%Get("BenefitStatus")
			Set tBenefit.MaximumAmount = tBenefitRs.%Get("MaximumAmount")
			Set tBenefit.RemainingAmount = tBenefitRs.%Get("RemainingAmount")
			$$$THROWONERROR(tSC, ..AddCoverageItems(tBenefit, tBenefitRs.%Get("BenefitKey")))
			Do pResponse.BenefitsInfo.Insert(tBenefit)
		}
		Set pResponse.ResponseCode = "200"
		Set pResponse.ResponseMessage = "Success"
	}
	Catch ex {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

/// Fill one benefit's nested coverage_items[] from the child table.
ClassMethod AddCoverageItems(pBenefit As D1.Mock.Msg.BenefitDetail, pBenefitKey As %String) As %Status [ Private ]
{
	Set tStmt = ##class(%SQL.Statement).%New()
	Set tSC = tStmt.%Prepare("SELECT CoverageItemNo, CoverageCode, CoverageName, CoverageType, LimitAmount, LimitUnit, Remark FROM D1_Mock_Data.CoverageItem WHERE BenefitKey = ? ORDER BY CoverageItemNo")
	Quit:$$$ISERR(tSC) tSC
	Set tRs = tStmt.%Execute(pBenefitKey)
	While tRs.%Next() {
		Set tItem = ##class(D1.Mock.Msg.CoverageItemInfo).%New()
		Set tItem.CoverageItem = tRs.%Get("CoverageItemNo")
		Set tItem.CoverageCode = tRs.%Get("CoverageCode")
		Set tItem.CoverageName = tRs.%Get("CoverageName")
		Set tItem.CoverageType = tRs.%Get("CoverageType")
		Set tItem.LimitAmount = tRs.%Get("LimitAmount")
		Set tItem.LimitUnit = tRs.%Get("LimitUnit")
		Set tItem.Remark = tRs.%Get("Remark")
		Do pBenefit.CoverageItems.Insert(tItem)
	}
	Return $$$OK
}

}