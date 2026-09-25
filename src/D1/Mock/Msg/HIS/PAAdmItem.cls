/// One raw episode row from the HIS PAAdm list (an element of "results").
/// Property names match TrakCare's real field names 1:1; Mradm carries the
/// wire name "mradm" via %JSONFIELDNAME (the one lower-case raw name).
/// 
/// This row is the hub of every group-1 flow: PAADMADMNo is the visit AND
/// admission number, mradm keys the clinical reads (MRDiagnos /
/// MRReasonForEnc), EpisodeID keys MRProcedures, CTPCPCode keys the
/// practitioner lookup, and DEPDesc keys the CTLoc department lookup.
Class D1.Mock.Msg.HIS.PAAdmItem Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

/// Ignore the episode attributes we do not model.
Parameter %JSONIGNOREINVALIDFIELD = 1;

/// Visit / admission number -- one numbering series for both
Property PAADMADMNo As %String(MAXLEN = 50);

/// Episode id -- keys the MRProcedures read
Property EpisodeID As %String(MAXLEN = 50);

/// Patient registry row id
Property PatientID As %String(MAXLEN = 50);

/// Registration / hospital number
Property RegNo As %String(MAXLEN = 50);

/// Medical record admission key -- keys MRDiagnos / MRReasonForEnc
Property Mradm As %String(%JSONFIELDNAME = "mradm", MAXLEN = 50);

/// O/E = visit, I = admission
Property PAADMType As %String(MAXLEN = 5);

Property PAADMAdmDate As %String(MAXLEN = 20);

Property PAADMAdmTime As %String(MAXLEN = 20);

/// Department group description -- the CTLoc lookup key, not served directly
Property DEPDesc As %String(MAXLEN = 100);

/// Treating care provider code -- keys the CTCareProv read
Property CTPCPCode As %String(MAXLEN = 50);

Property WARDDesc As %String(MAXLEN = 100);

/// Care type -- best-guess source for ward_type
Property CARETYPDesc As %String(MAXLEN = 50);

Property ROOMTDesc As %String(MAXLEN = 100);

Property BEDCode As %String(MAXLEN = 50);

/// Physical discharge date -- pinned actual_discharge_date source
Property PAADMDischgDate As %String(MAXLEN = 20);

Property EstDschrgDate As %String(MAXLEN = 20);

Storage Default
{
<Data name="PAAdmItemState">
<Value name="1">
<Value>PAADMADMNo</Value>
</Value>
<Value name="2">
<Value>EpisodeID</Value>
</Value>
<Value name="3">
<Value>PatientID</Value>
</Value>
<Value name="4">
<Value>RegNo</Value>
</Value>
<Value name="5">
<Value>Mradm</Value>
</Value>
<Value name="6">
<Value>PAADMType</Value>
</Value>
<Value name="7">
<Value>PAADMAdmDate</Value>
</Value>
<Value name="8">
<Value>PAADMAdmTime</Value>
</Value>
<Value name="9">
<Value>DEPDesc</Value>
</Value>
<Value name="10">
<Value>CTPCPCode</Value>
</Value>
<Value name="11">
<Value>WARDDesc</Value>
</Value>
<Value name="12">
<Value>CARETYPDesc</Value>
</Value>
<Value name="13">
<Value>ROOMTDesc</Value>
</Value>
<Value name="14">
<Value>BEDCode</Value>
</Value>
<Value name="15">
<Value>PAADMDischgDate</Value>
</Value>
<Value name="16">
<Value>EstDschrgDate</Value>
</Value>
</Data>
<State>PAAdmItemState</State>
<StreamLocation>^D1.Mock.Msg.HIS.PAAdmItemS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
