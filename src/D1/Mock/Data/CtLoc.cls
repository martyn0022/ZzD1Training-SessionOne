/// Mock HIS location (department) lookup row, mirroring TrakCare's CTLoc
/// resource. Lives in MOCKDATA.
/// 
/// The PINNED source for D1's department_code / department_name (per
/// D1_TrakCare_Context.md CR 9): CTLOCCode / CTLOCDesc. PAAdm.DEPDesc is a
/// different concept (the department GROUP) and is only used as the lookup
/// key into this table, never served directly.
Class D1.Mock.Data.CtLoc Extends %Persistent
{

/// Location/department code, e.g. "MED" -- D1 department_code
Property CTLOCCode As %String(MAXLEN = 50) [ Required ];

Index CodeIdx On CTLOCCode [ Unique ];

/// Location/department description, e.g. "Internal Medicine" -- D1 department_name
Property CTLOCDesc As %String(MAXLEN = 100);

Index DescIdx On CTLOCDesc;

/// Hospital code the location belongs to, e.g. "RAMA9"
Property Hospital As %String(MAXLEN = 50);

Storage Default
{
<Data name="CtLocDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>CTLOCCode</Value>
</Value>
<Value name="3">
<Value>CTLOCDesc</Value>
</Value>
<Value name="4">
<Value>Hospital</Value>
</Value>
</Data>
<DataLocation>^D1.Mock.Data.CtLocD</DataLocation>
<DefaultData>CtLocDefaultData</DefaultData>
<IdLocation>^D1.Mock.Data.CtLocD</IdLocation>
<IndexLocation>^D1.Mock.Data.CtLocI</IndexLocation>
<StreamLocation>^D1.Mock.Data.CtLocS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
