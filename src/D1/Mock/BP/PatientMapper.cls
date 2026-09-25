/// API_GetPatient: one HIS demographics read, one DTL.
/// 
/// Also hosts the helper classmethods every group-1 DTL and BPL shares.
/// BPL GOTCHA: activities compile into a generated ...Thread1 class, so these
/// must be called fully qualified -- ##class(D1.Mock.BP.PatientMapper).X(),
/// never ..X().
Class D1.Mock.BP.PatientMapper Extends Ens.BusinessProcessBPL
{

/// True if the patient read actually returned a record.
ClassMethod HasPatient(pResp As D1.Mock.Msg.HIS.PatientResponse) As %Boolean
{
	Quit:'$IsObject(pResp) 0
	Quit:'$IsObject(pResp.Results) 0
	Quit pResp.Results.RegistrationNumber '= ""
}

/// True if a list-envelope HIS response carries at least one row.
/// Untyped on purpose -- works for every Msg.HIS.*Response with a Results list.
ClassMethod HasRows(pResp) As %Boolean
{
	Quit:'$IsObject(pResp) 0
	Quit pResp.Results.Count() > 0
}

/// Combine a raw HIS DD/MM/YYYY date and HH:MM time into the D1 wire format
/// yyyy-MM-dd HH:mm:ss. Empty date in -> empty out (nullable fields stay
/// null); empty time -> 00:00:00; anything unparseable passes through as-is.
ClassMethod IsoDateTime(pDate As %String, pTime As %String = "") As %String
{
	Quit:pDate="" ""
	Set tIso = pDate
	Try {
		Set tIso = $ZDate($ZDateH(pDate, 4), 3)
	}
	Catch {
		Set tIso = pDate
	}
	Set tTime = $Select(pTime = "": "00:00:00", $Length(pTime) = 5: pTime _ ":00", 1: pTime)
	Quit tIso _ " " _ tTime
}

/// Join street + city into a single address line, tolerating either empty.
ClassMethod JoinAddress(pStreet As %String, pCity As %String) As %String
{
	Quit:pCity="" pStreet
	Quit:pStreet="" pCity
	Quit pStreet _ ", " _ pCity
}

/// Best-guess visit_type derivation from the raw episode type:
/// I -> IPD, O -> OPD, E -> ER; anything else passes through raw.
ClassMethod VisitType(pPAADMType As %String) As %String
{
	Quit $Case(pPAADMType, "I": "IPD", "O": "OPD", "E": "ER", : pPAADMType)
}

/// Best-guess diagnosis_type derivation from the raw principal flag:
/// Y -> PRIMARY, anything else -> SECONDARY. The spec only ever samples
/// "PRIMARY" -- flag if a richer enum surfaces.
ClassMethod DiagnosisType(pPrinciple As %String) As %String
{
	Quit $Select(pPrinciple = "Y": "PRIMARY", 1: "SECONDARY")
}

/// BPL Definition
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='D1.Mock.Msg.GetPatientRequest' response='D1.Mock.Msg.GetPatientResponse' height='2000' width='2000' >
<context>
<property name='PatResp' type='D1.Mock.Msg.HIS.PatientResponse' instantiate='0' />
</context>
<sequence xend='200' yend='700' >
<call name='Get Patient' target='HIS Operation' async='0' xpos='200' ypos='250' >
<annotation><![CDATA[One read: the HIS operation resolves the identity and fetches the demographics.]]></annotation>
<request type='D1.Mock.Msg.HIS.PatientRequest' >
<assign property="callrequest.IdentityType" value="request.IdentityType" action="set" />
<assign property="callrequest.IdentityNo" value="request.IdentityNo" action="set" />
</request>
<response type='D1.Mock.Msg.HIS.PatientResponse' >
<assign property="context.PatResp" value="callresponse" action="set" />
</response>
</call>
<if name='Patient found?' condition='##class(D1.Mock.BP.PatientMapper).HasPatient(context.PatResp)' xpos='200' ypos='350' xend='200' yend='600' >
<annotation><![CDATA[Empty response -> in-band 404 envelope (HTTP 200).]]></annotation>
<true>
<transform name='Map patient' class='D1.Mock.DT.PatientToD1' source='context.PatResp' target='response' xpos='470' ypos='500' >
<annotation><![CDATA[Raw PAPER*/CT* fields -> D1 clean contract (the anti-corruption boundary).]]></annotation>
</transform>
</true>
<false>
<code name='404 Not Found' xpos='200' ypos='500' >
<![CDATA[
 Set response.ResponseCode = "404"
 Set response.ResponseMessage = "No patient found for identity "_request.IdentityType_" "_request.IdentityNo
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
