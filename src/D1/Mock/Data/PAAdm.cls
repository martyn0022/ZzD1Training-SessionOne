/// Mock HIS episode row, mirroring TrakCare's PAAdm resource (alias /Encounter).
/// Lives in MOCKDATA. One row per episode; this single resource backs BOTH
/// API_GetVisit and API_GetAdmission (TrakCare has no separate visit/admission
/// records -- both are the same PAAdm row, discriminated by PAADMType).
/// 
/// PAADMADMNo serves as visit number AND admission number: TrakCare maintains
/// no separate numbering series. IRIS therefore trusts, and cannot verify, the
/// identity_type (VN vs AN) a caller claims -- a documented demo limitation.
/// 
/// CARETYPDesc is a BEST-GUESS source for D1's ward_type: it is on the real
/// PAAdm resource, but whether "care type" means what the spec calls
/// "ward type" is unconfirmed. Verify with the client.
Class D1.Mock.Data.PAAdm Extends %Persistent
{

/// Episode number -- the visit number AND admission number, e.g. "VN-2569-100245"
Property PAADMADMNo As %String(MAXLEN = 50) [ Required ];

Index AdmNoIdx On PAADMADMNo [ Unique ];

/// Patient registry row id (-> Patient.PatientID)
Property PatientID As %String(MAXLEN = 50);

Index PatientIdx On PatientID;

/// Registration / hospital number as carried on the episode
Property RegNo As %String(MAXLEN = 50);

/// Medical record admission key -- what MRDiagnos / MRReasonForEnc filter on
Property Mradm As %String(MAXLEN = 50) [ SqlFieldName = mradm ];

Index MradmIdx On Mradm;

/// Episode type: O/E = outpatient/emergency (a "visit"), I = inpatient (an "admission")
Property PAADMType As %String(MAXLEN = 5);

/// Admission date, HIS display format DD/MM/YYYY
Property PAADMAdmDate As %String(MAXLEN = 20);

/// Admission time, e.g. "09:00"
Property PAADMAdmTime As %String(MAXLEN = 20);

/// Department group description. NOT the same concept as CTLoc's department --
/// the pinned department_code/name source is CTLoc, looked up by this value.
Property DEPDesc As %String(MAXLEN = 100);

/// Treating care provider code (-> CtCareProv.CTPCPCode)
Property CTPCPCode As %String(MAXLEN = 50);

/// Care type description -- best-guess source for D1's ward_type
Property CARETYPDesc As %String(MAXLEN = 50);

/// Ward description -- pinned source for D1's ward_number (description accepted
/// for the demo instead of PAAdmDischarge's WARDCode, per the context doc)
Property WARDDesc As %String(MAXLEN = 100);

/// Room type description. High population risk on real sites -- nullable in D1.
Property ROOMTDesc As %String(MAXLEN = 100);

/// Bed code. High population risk -- nullable in D1.
Property BEDCode As %String(MAXLEN = 50);

/// Physical discharge date -- the pinned source for actual_discharge_date
/// (not the medical or financial discharge dates, which also exist on the
/// real resource and routinely differ by days)
Property PAADMDischgDate As %String(MAXLEN = 20);

/// Estimated discharge date. High population risk -- nullable in D1.
Property EstDschrgDate As %String(MAXLEN = 20);

Storage Default
{
<Data name="PAAdmDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>PAADMADMNo</Value>
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
<Value>CARETYPDesc</Value>
</Value>
<Value name="12">
<Value>WARDDesc</Value>
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
<DataLocation>^D1.Mock.Data.PAAdmD</DataLocation>
<DefaultData>PAAdmDefaultData</DefaultData>
<IdLocation>^D1.Mock.Data.PAAdmD</IdLocation>
<IndexLocation>^D1.Mock.Data.PAAdmI</IndexLocation>
<StreamLocation>^D1.Mock.Data.PAAdmS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
