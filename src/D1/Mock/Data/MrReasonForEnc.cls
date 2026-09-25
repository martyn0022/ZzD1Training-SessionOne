/// Mock HIS reason-for-encounter row, mirroring TrakCare's MRReasonForEnc
/// resource. Lives in MOCKDATA. Filtered by mradm, same episode-scoped key
/// as MRDiagnos.
/// 
/// UNVERIFIED SOURCING (unlike every other mock table): DescSnomed as the
/// chief_complaint source was picked from a single Postman example payload,
/// not verified against real data the way D1_TrakCare_Context.md verified the
/// other resources. Comments (free text) is the documented fallback if
/// DescSnomed proves too clinically-coded in practice. Validate before
/// treating as settled -- see plan open item 8.
Class D1.Mock.Data.MrReasonForEnc Extends %Persistent
{

/// Reason-for-encounter row id
Property ReasonID As %String(MAXLEN = 50) [ Required ];

Index ReasonIDIdx On ReasonID [ Unique ];

/// Medical record admission key (-> PAAdm.mradm)
Property Mradm As %String(MAXLEN = 50) [ SqlFieldName = mradm ];

Index MradmIdx On Mradm;

/// SNOMED-coded reason description, e.g. "Fever" -- best-guess chief_complaint source
Property DescSnomed As %String(MAXLEN = 255);

/// Free-text comments -- the documented fallback chief_complaint source
Property Comments As %String(MAXLEN = 500);

/// SNOMED concept id -- not requested by D1, kept for raw-contract completeness
Property ConceptID As %String(MAXLEN = 50);

Storage Default
{
<Data name="MrReasonForEncDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ReasonID</Value>
</Value>
<Value name="3">
<Value>Mradm</Value>
</Value>
<Value name="4">
<Value>DescSnomed</Value>
</Value>
<Value name="5">
<Value>Comments</Value>
</Value>
<Value name="6">
<Value>ConceptID</Value>
</Value>
</Data>
<DataLocation>^D1.Mock.Data.MrReasonForEncD</DataLocation>
<DefaultData>MrReasonForEncDefaultData</DefaultData>
<IdLocation>^D1.Mock.Data.MrReasonForEncD</IdLocation>
<IndexLocation>^D1.Mock.Data.MrReasonForEncI</IndexLocation>
<StreamLocation>^D1.Mock.Data.MrReasonForEncS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
