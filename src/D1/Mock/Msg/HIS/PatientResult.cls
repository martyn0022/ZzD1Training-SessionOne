/// One raw HIS patient record: the flat object under "results" in a
/// GET /Patient/:id response. Property names match TrakCare's REAL raw field
/// names 1:1 (PAPER* = PA_Person, CT*Desc = code table), so %JSONImport works
/// with no aliasing and this message would deserialize a real deployment's
/// response unchanged.
/// 
/// Documented gaps (see the plan's database document):
///   PAPERResidentNumber -- best-guess citizen ID source
Class D1.Mock.Msg.HIS.PatientResult Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

/// Ignore the ~490 raw attributes we do not model.
Parameter %JSONIGNOREINVALIDFIELD = 1;

/// Hospital / medical record number
Property RegistrationNumber As %String(MAXLEN = 50);

/// Best-guess citizen ID field
Property PAPERResidentNumber As %String(MAXLEN = 30);

Property PAPERPassportNumber As %String(MAXLEN = 30);

/// Surname (TrakCare's own description for this field)
Property PAPERName As %String(MAXLEN = 100);

/// Given name
Property PAPERName2 As %String(MAXLEN = 100);

/// Title description, e.g. "Mr."
Property TTLDesc As %String(MAXLEN = 20);

/// Sex description, e.g. "Male"
Property CTSEXDesc As %String(MAXLEN = 20);

/// Date of birth, HIS display format DD/MM/YYYY
Property PAPERDob As %String(MAXLEN = 10);

Property PAPERStName As %String(MAXLEN = 255);

Property CTCITDesc As %String(MAXLEN = 100);

Property PAPERMobPhone As %String(MAXLEN = 30);

Storage Default
{
<Data name="PatientResultState">
<Value name="1">
<Value>RegistrationNumber</Value>
</Value>
<Value name="2">
<Value>PAPERResidentNumber</Value>
</Value>
<Value name="3">
<Value>PAPERPassportNumber</Value>
</Value>
<Value name="4">
<Value>PAPERName</Value>
</Value>
<Value name="5">
<Value>PAPERName2</Value>
</Value>
<Value name="6">
<Value>TTLDesc</Value>
</Value>
<Value name="7">
<Value>CTSEXDesc</Value>
</Value>
<Value name="8">
<Value>PAPERDob</Value>
</Value>
<Value name="9">
<Value>PAPERStName</Value>
</Value>
<Value name="10">
<Value>CTCITDesc</Value>
</Value>
<Value name="11">
<Value>PAPERMobPhone</Value>
</Value>
</Data>
<State>PatientResultState</State>
<StreamLocation>^D1.Mock.Msg.HIS.PatientResultS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
