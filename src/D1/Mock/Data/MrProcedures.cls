/// Mock HIS procedure row, mirroring TrakCare's MRProcedures resource.
/// Lives in MOCKDATA. One row per procedure performed during an episode.
/// 
/// Sourcing note: OPERCode/OPERDesc -> D1 procedure_code/procedure_name is the
/// same Code+Desc pairing convention as diagnosis and department, so it carries
/// the same confidence. The raw row does NOT echo mradm -- it links back to the
/// episode via EpisodeID (which the mock keys to PAAdm.PAADMADMNo).
Class D1.Mock.Data.MrProcedures Extends %Persistent
{

/// Procedure row id (raw field PROCRowId)
Property ProcID As %String(MAXLEN = 50) [ Required ];

Index ProcIDIdx On ProcID [ Unique ];

/// Episode this procedure belongs to (-> PAAdm.PAADMADMNo)
Property EpisodeID As %String(MAXLEN = 50);

Index EpisodeIdx On EpisodeID;

/// Procedure code, e.g. "PROC001" -- D1 procedure_code
Property OPERCode As %String(MAXLEN = 20);

/// Procedure description, e.g. "Appendectomy" -- D1 procedure_name
Property OPERDesc As %String(MAXLEN = 255);

/// Procedure date, HIS display format DD/MM/YYYY
Property PROCDate As %String(MAXLEN = 20);

/// Procedure time, e.g. "09:45"
Property PROCTime As %String(MAXLEN = 20);

Storage Default
{
<Data name="MrProceduresDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ProcID</Value>
</Value>
<Value name="3">
<Value>EpisodeID</Value>
</Value>
<Value name="4">
<Value>OPERCode</Value>
</Value>
<Value name="5">
<Value>OPERDesc</Value>
</Value>
<Value name="6">
<Value>PROCDate</Value>
</Value>
<Value name="7">
<Value>PROCTime</Value>
</Value>
</Data>
<DataLocation>^D1.Mock.Data.MrProceduresD</DataLocation>
<DefaultData>MrProceduresDefaultData</DefaultData>
<IdLocation>^D1.Mock.Data.MrProceduresD</IdLocation>
<IndexLocation>^D1.Mock.Data.MrProceduresI</IndexLocation>
<StreamLocation>^D1.Mock.Data.MrProceduresS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
