/// API_PostDischarge: validate, then store.
///   missing field -> 400 | insert over existing -> 409 | update of absent -> 404
/// Every branch answers in-band over HTTP 200; only a storage failure escalates.
Class D1.Mock.BP.PostDischargeProcess Extends Ens.BusinessProcessBPL
{

XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='D1.Mock.Msg.PostDischargeRequest' response='D1.Mock.Msg.PostDischargeResponse' height='2000' width='2000'>
<context>
<property name='ErrMsg' type='%String' instantiate='0'/>
<property name='Exists' type='%Boolean' instantiate='0'/>
</context>
<sequence>
<code name='Validate'>
<annotation>Check the mandatory fields, and whether this discharge was submitted before.</annotation>
<![CDATA[
 Set context.ErrMsg = ##class(D1.Mock.BP.PostDischargeProcess).Validate(request)
 Set context.Exists = ##class(D1.Mock.BP.PostDischargeProcess).DischargeExists(request.ClaimId)
]]>
</code>
<switch name='Insert or update?'>
<case name='Bad request' condition='$Length(context.ErrMsg)&gt;0'>
<assign name='400 code' property="response.ResponseCode" value='"400"' action="set">
<annotation>A mandatory field is missing or invalid - reject before anything is written.</annotation>
</assign>
<assign name='400 message' property="response.ResponseMessage" value='context.ErrMsg' action="set"/>
</case>
<case name='Already submitted' condition='(request.CrudStatus="0")&amp;&amp;(context.Exists=1)'>
<assign name='409 code' property="response.ResponseCode" value='"409"' action="set">
<annotation>Insert of a discharge that is already stored - resend with crud_status "1".</annotation>
</assign>
<assign name='409 message' property="response.ResponseMessage" value='"A discharge already exists for claim_id "_request.ClaimId_" - use crud_status ""1"" to update it"' action="set"/>
</case>
<case name='Nothing to update' condition='(request.CrudStatus="1")&amp;&amp;(context.Exists=0)'>
<assign name='404 code' property="response.ResponseCode" value='"404"' action="set">
<annotation>Update of a discharge that was never submitted - resend with crud_status "0".</annotation>
</assign>
<assign name='404 message' property="response.ResponseMessage" value='"No discharge found for claim_id "_request.ClaimId_" - use crud_status ""0"" to insert it"' action="set"/>
</case>
<default name='Store'>
<call name='Store discharge' target='PostDischarge Operation' async='0'>
<annotation>Write discharge + billing, and snapshot patient / admission / policy / diagnoses.</annotation>
<request type='D1.Mock.Msg.PostDischargeRequest'>
<assign property="callrequest" value="request" action="set"/>
</request>
<response type='D1.Mock.Msg.PostDischargeResponse'>
<assign property="response.ResponseCode" value="callresponse.ResponseCode" action="set"/>
<assign property="response.ResponseMessage" value="callresponse.ResponseMessage" action="set"/>
</response>
</call>
</default>
</switch>
</sequence>
</process>
}

/// True if a discharge is already stored under this claim id.
/// Kept here (rather than on the table class) so the BPL has one obvious
/// entry point, matching PreAuthSubmission.AdmissionExists's role.
ClassMethod DischargeExists(pClaimId As %String) As %Boolean
{
	Set tId = ""
	Quit:pClaimId="" 0
	&sql(SELECT ID INTO :tId FROM D1_Mock_Data.ClaimDischarge WHERE DischargeId = :pClaimId)
	Quit:SQLCODE'=0 0
	Quit 1
}

/// Validate against the V1.0.3 spec's Mandatory column: "" when good,
/// otherwise the message that goes back to D1 in the 400 envelope.
/// 
/// Called from the BPL fully qualified -- BPL activities compile into a
/// generated ...Thread1 class.
ClassMethod Validate(pRequest As D1.Mock.Msg.PostDischargeRequest) As %String
{
	Quit:'$IsObject(pRequest) "Empty request"
	Quit:pRequest.CrudStatus="" "crud_status is required"
	Quit:(pRequest.CrudStatus'="0")&&(pRequest.CrudStatus'="1") "crud_status must be ""0"" (insert) or ""1"" (update)"
	Quit:pRequest.ClaimId="" "claim_id is required"
	Quit:pRequest.ClaimCaseNumber="" "claim_case_number is required"
	Quit:pRequest.ClaimStatus="" "claim_status is required"
	Quit:'$ListFind($ListBuild("Waiting for Medical", "Approved", "Rejected", "Discharge Requested"), pRequest.ClaimStatus) "claim_status must be one of ""Waiting for Medical"", ""Approved"", ""Rejected"", ""Discharge Requested"""
	Quit:pRequest.ClaimPerson.HospitalNumber="" "claim_person.hospital_number is required"
	Quit:pRequest.AdmissionInfo.AdmissionNumber="" "admission_info.admission_number is required"
	Quit:pRequest.Insurer.CompanyCode="" "insurer.company_code is required"
	Quit:pRequest.PoliciesInfo.PolicyNumber="" "policies_info.policy_number is required"
	Quit:pRequest.DiagnosisInfo.Count()<1 "diagnosis_info is required"
	Quit:pRequest.AttendingPhysician.Id="" "attending_physician.physician_id is required"
	Quit:pRequest.BillingInfo.Currency="" "billing_info.currency is required"
	Quit ""
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
