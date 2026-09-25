/// API_PostPreAuth: validate, then store.
///   missing field -> 400 | insert over existing -> 409 | update of absent -> 404
/// Every branch answers in-band over HTTP 200; only a storage failure escalates.
Class D1.Mock.BP.PreAuthStoreProcess Extends Ens.BusinessProcessBPL
{

XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='D1.Mock.Msg.PostPreAuthRequest' response='D1.Mock.Msg.PostPreAuthResponse' height='2000' width='2000'>
<context>
<property name='ErrMsg' type='%String' instantiate='0'/>
<property name='Exists' type='%Boolean' instantiate='0'/>
</context>
<sequence>
<code name='Validate'>
<annotation>Check the mandatory fields, and whether this admission was submitted before.</annotation>
<![CDATA[
 Set context.ErrMsg = ##class(D1.Mock.BP.PreAuthStoreProcess).Validate(request)
 Set context.Exists = ##class(D1.Mock.Data.PreAuthSubmission).AdmissionExists(request.Admission.AdmissionNumber, .tId)
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
<annotation>Insert of an admission that is already stored - resend with crud_status "1".</annotation>
</assign>
<assign name='409 message' property="response.ResponseMessage" value='"A submission already exists for admission_number "_request.Admission.AdmissionNumber_" - use crud_status ""1"" to update it"' action="set"/>
</case>
<case name='Nothing to update' condition='(request.CrudStatus="1")&amp;&amp;(context.Exists=0)'>
<assign name='404 code' property="response.ResponseCode" value='"404"' action="set">
<annotation>Update of an admission that was never submitted - resend with crud_status "0".</annotation>
</assign>
<assign name='404 message' property="response.ResponseMessage" value='"No submission found for admission_number "_request.Admission.AdmissionNumber_" - use crud_status ""0"" to insert it"' action="set"/>
</case>
<default name='Store'>
<call name='Store submission' target='PreAuth Store Operation' async='0'>
<annotation>Write the whole payload as one flat row in D1.Mock.Data.PreAuthSubmission.</annotation>
<request type='D1.Mock.Msg.PostPreAuthRequest'>
<assign property="callrequest" value="request" action="set"/>
</request>
<response type='D1.Mock.Msg.PostPreAuthResponse'>
<assign property="response.ResponseCode" value="callresponse.ResponseCode" action="set"/>
<assign property="response.ResponseMessage" value="callresponse.ResponseMessage" action="set"/>
</response>
</call>
</default>
</switch>
</sequence>
</process>
}

/// Validate the payload against the V1.0.3 spec's Mandatory column: "" when
/// it is good, otherwise the message that goes back to D1 in the 400 envelope.
/// 
/// This is why D1.Mock.Msg.PostPreAuthRequest marks nothing [ Required ] -- a
/// missing field has to reach here to be reported, not fail the message save.
/// 
/// auth_id is deliberately NOT required despite the spec's Mandatory flag:
/// the spec's own sample sends NULL on insert (the id is assigned later in
/// the claim lifecycle).
/// 
/// Called from the BPL fully qualified (##class(...).Validate) -- BPL
/// activities compile into a generated ...Thread1 class.
ClassMethod Validate(pRequest As D1.Mock.Msg.PostPreAuthRequest) As %String
{
	Quit:'$IsObject(pRequest) "Empty request"
	Quit:pRequest.CrudStatus="" "crud_status is required"
	Quit:(pRequest.CrudStatus'="0")&&(pRequest.CrudStatus'="1") "crud_status must be ""0"" (insert) or ""1"" (update)"
	Quit:pRequest.AuthStatus="" "auth_status is required"
	Quit:'$ListFind($ListBuild("Waiting for Medical", "Pre-Accepted", "Rejected", "Pre-Authorize Submitted"), pRequest.AuthStatus) "auth_status must be one of ""Waiting for Medical"", ""Pre-Accepted"", ""Rejected"", ""Pre-Authorize Submitted"""
	Quit:pRequest.HospitalCode="" "hospital_code is required"
	Quit:pRequest.Person.HospitalNumber="" "person.hospital_number is required"
	Quit:pRequest.Person.VisitNumber="" "person.visit_number is required"
	Quit:pRequest.ComplaintInfo.ChiefComplaint="" "complaint_info.chief_complaint is required"
	Quit:pRequest.Diagnosis.Count()<1 "diagnosis is required"
	Quit:pRequest.Policies.PolicyNumber="" "policies.policy_number is required"
	Quit:pRequest.Benefits.Count()<1 "benefits is required"
	Quit:pRequest.AttendingPhysician.Id="" "attending_physician.physician_id is required"
	Quit:pRequest.Admission.AdmissionNumber="" "admission.admission_number is required"
	Quit:pRequest.SubmitDate="" "submit_date is required"
	Quit:pRequest.UpdateDate="" "update_date is required"
	Quit ""
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
