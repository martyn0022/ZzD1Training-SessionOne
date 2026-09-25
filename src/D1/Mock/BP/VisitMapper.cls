/// API_GetVisit: the widest group-1 fan-out -- the episode read supplies the
/// keys for four more, each appended by its own chained DTL.
/// 
/// Secondary transforms are guarded by HasRows so an absent lookup leaves its
/// block empty rather than failing the visit. See docs/PRODUCTION_FLOWS.md.
Class D1.Mock.BP.VisitMapper Extends Ens.BusinessProcessBPL
{

/// BPL Definition
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='D1.Mock.Msg.GetVisitRequest' response='D1.Mock.Msg.GetVisitResponse' height='2000' width='2200' >
<context>
<property name='AdmResp' type='D1.Mock.Msg.HIS.PAAdmResponse' instantiate='0' />
<property name='DocResp' type='D1.Mock.Msg.HIS.CareProviderResponse' instantiate='0' />
<property name='LocResp' type='D1.Mock.Msg.HIS.CtLocResponse' instantiate='0' />
<property name='RfeResp' type='D1.Mock.Msg.HIS.MrReasonForEncResponse' instantiate='0' />
<property name='ProcResp' type='D1.Mock.Msg.HIS.MrProceduresResponse' instantiate='0' />
</context>
<sequence xend='200' yend='1750' >
<call name='Get Episode' target='HIS Operation' async='0' xpos='200' ypos='250' >
<annotation><![CDATA[Read 1: resolve VN/AN and fetch the episode -- supplies every follow-on key.]]></annotation>
<request type='D1.Mock.Msg.HIS.PAAdmRequest' >
<assign property="callrequest.IdentityType" value="request.IdentityType" action="set" />
<assign property="callrequest.IdentityNo" value="request.IdentityNo" action="set" />
</request>
<response type='D1.Mock.Msg.HIS.PAAdmResponse' >
<assign property="context.AdmResp" value="callresponse" action="set" />
</response>
</call>
<if name='Episode found?' condition='##class(D1.Mock.BP.PatientMapper).HasRows(context.AdmResp)' xpos='200' ypos='350' xend='200' yend='1650' >
<annotation><![CDATA[Empty episode list -> in-band 404 envelope (HTTP 200).]]></annotation>
<true>
<call name='Get Care Provider' target='HIS Operation' async='0' xpos='470' ypos='500' >
<annotation><![CDATA[Read 2: practitioner detail, keyed by the episode's CTPCPCode.]]></annotation>
<request type='D1.Mock.Msg.HIS.CareProviderRequest' >
<assign property="callrequest.Code" value="context.AdmResp.Results.GetAt(1).CTPCPCode" action="set" />
</request>
<response type='D1.Mock.Msg.HIS.CareProviderResponse' >
<assign property="context.DocResp" value="callresponse" action="set" />
</response>
</call>
<call name='Get Department' target='HIS Operation' async='0' xpos='470' ypos='600' >
<annotation><![CDATA[Read 3: pinned department code/name lookup, keyed by the episode's DEPDesc.]]></annotation>
<request type='D1.Mock.Msg.HIS.CtLocRequest' >
<assign property="callrequest.Description" value="context.AdmResp.Results.GetAt(1).DEPDesc" action="set" />
<assign property="callrequest.Hospital" value="request.HospitalCode" action="set" />
</request>
<response type='D1.Mock.Msg.HIS.CtLocResponse' >
<assign property="context.LocResp" value="callresponse" action="set" />
</response>
</call>
<call name='Get Chief Complaint' target='HIS Operation' async='0' xpos='470' ypos='700' >
<annotation><![CDATA[Read 4: reason for encounter, keyed by the episode's mradm.]]></annotation>
<request type='D1.Mock.Msg.HIS.MrReasonForEncRequest' >
<assign property="callrequest.Mradm" value="context.AdmResp.Results.GetAt(1).Mradm" action="set" />
</request>
<response type='D1.Mock.Msg.HIS.MrReasonForEncResponse' >
<assign property="context.RfeResp" value="callresponse" action="set" />
</response>
</call>
<call name='Get Procedures' target='HIS Operation' async='0' xpos='470' ypos='800' >
<annotation><![CDATA[Read 5: procedures performed, keyed by the episode's EpisodeID.]]></annotation>
<request type='D1.Mock.Msg.HIS.MrProceduresRequest' >
<assign property="callrequest.EpisodeID" value="context.AdmResp.Results.GetAt(1).EpisodeID" action="set" />
</request>
<response type='D1.Mock.Msg.HIS.MrProceduresResponse' >
<assign property="context.ProcResp" value="callresponse" action="set" />
</response>
</call>
<transform name='Map visit' class='D1.Mock.DT.PAAdmToVisit' source='context.AdmResp' target='response' xpos='470' ypos='900' >
<annotation><![CDATA[Episode -> envelope + hospital_number + visit_info.]]></annotation>
</transform>
<if name='Physician found?' condition='##class(D1.Mock.BP.PatientMapper).HasRows(context.DocResp)' xpos='470' ypos='1000' xend='470' yend='1150' >
<true>
<transform name='Map physician' class='D1.Mock.DT.CareProviderToVisitPhysician' source='context.DocResp' target='response' xpos='740' ypos='1100' />
</true>
</if>
<if name='Department found?' condition='##class(D1.Mock.BP.PatientMapper).HasRows(context.LocResp)' xpos='470' ypos='1250' xend='470' yend='1400' >
<true>
<transform name='Map department' class='D1.Mock.DT.CtLocToVisitDepartment' source='context.LocResp' target='response' xpos='740' ypos='1350' />
</true>
</if>
<if name='Complaint found?' condition='##class(D1.Mock.BP.PatientMapper).HasRows(context.RfeResp)' xpos='470' ypos='1450' xend='470' yend='1600' >
<true>
<transform name='Map complaint' class='D1.Mock.DT.MrReasonForEncToVisit' source='context.RfeResp' target='response' xpos='740' ypos='1550' />
</true>
</if>
<transform name='Map procedures' class='D1.Mock.DT.MrProceduresToVisit' source='context.ProcResp' target='response' xpos='470' ypos='1650' >
<annotation><![CDATA[foreach over the rows -- an empty list is safely a no-op, no guard needed.]]></annotation>
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
