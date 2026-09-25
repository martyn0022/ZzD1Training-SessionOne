/// API_GetDiagnosis: episode read (for mradm + the echo fields), then the
/// diagnosis read. No physician hop -- V1.0.3 removed attending_physician
/// from this response.
/// 
/// An episode with zero diagnoses still answers 200 with an empty array:
/// "found visit, nothing recorded" differs from "visit not found" (404).
Class D1.Mock.BP.DiagnosisMapper Extends Ens.BusinessProcessBPL
{

/// BPL Definition
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='D1.Mock.Msg.GetDiagnosisRequest' response='D1.Mock.Msg.GetDiagnosisResponse' height='2000' width='2000' >
<context>
<property name='AdmResp' type='D1.Mock.Msg.HIS.PAAdmResponse' instantiate='0' />
<property name='DxResp' type='D1.Mock.Msg.HIS.DiagnosisResponse' instantiate='0' />
</context>
<sequence xend='200' yend='1000' >
<call name='Get Episode' target='HIS Operation' async='0' xpos='200' ypos='250' >
<annotation><![CDATA[Read 1: resolve VN/AN and fetch the episode -- supplies mradm and the echo fields.]]></annotation>
<request type='D1.Mock.Msg.HIS.PAAdmRequest' >
<assign property="callrequest.IdentityType" value="request.IdentityType" action="set" />
<assign property="callrequest.IdentityNo" value="request.IdentityNo" action="set" />
</request>
<response type='D1.Mock.Msg.HIS.PAAdmResponse' >
<assign property="context.AdmResp" value="callresponse" action="set" />
</response>
</call>
<if name='Episode found?' condition='##class(D1.Mock.BP.PatientMapper).HasRows(context.AdmResp)' xpos='200' ypos='350' xend='200' yend='900' >
<annotation><![CDATA[Empty episode list -> in-band 404 envelope (HTTP 200).]]></annotation>
<true>
<call name='Get Diagnoses' target='HIS Operation' async='0' xpos='470' ypos='500' >
<annotation><![CDATA[Read 2: diagnosis rows, keyed by the episode's mradm.]]></annotation>
<request type='D1.Mock.Msg.HIS.DiagnosisRequest' >
<assign property="callrequest.Mradm" value="context.AdmResp.Results.GetAt(1).Mradm" action="set" />
</request>
<response type='D1.Mock.Msg.HIS.DiagnosisResponse' >
<assign property="context.DxResp" value="callresponse" action="set" />
</response>
</call>
<assign name='Echo hospital number' property='response.HospitalNumber' value='context.AdmResp.Results.GetAt(1).RegNo' action='set' xpos='470' ypos='600' >
<annotation><![CDATA[Echo fields come from the episode -- not present on the diagnosis rows.]]></annotation>
</assign>
<assign name='Echo visit number' property='response.VisitNumber' value='context.AdmResp.Results.GetAt(1).PAADMADMNo' action='set' xpos='470' ypos='700' />
<assign name='Echo admission number' property='response.AdmissionNumber' value='context.AdmResp.Results.GetAt(1).PAADMADMNo' action='set' xpos='470' ypos='800' >
<annotation><![CDATA[Same value under both names -- one episode numbering series.]]></annotation>
</assign>
<transform name='Map diagnoses' class='D1.Mock.DT.MrDiagnosToD1' source='context.DxResp' target='response' xpos='470' ypos='900' >
<annotation><![CDATA[Envelope + diagnosis_info[] -- an empty list stays an empty array with a 200.]]></annotation>
</transform>
</true>
<false>
<code name='404 Not Found' xpos='200' ypos='500' >
<![CDATA[
 Set response.ResponseCode = "404"
 Set response.ResponseMessage = "No visit found for identity "_request.IdentityType_" "_request.IdentityNo
]]>
</code>
</false>
</if>
</sequence>
</process>
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
