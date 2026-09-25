/// Group-2 visit_info table (NEW in data dictionary V1.0.2). Written by
/// PostPreAuth's snapshot (person.visit_number + complaint_info) -- currently
/// the ONLY write path; the spec defines no read API for it yet (plan open
/// item 11).
Class D1.Mock.Data.ClaimVisit Extends %Persistent
{

Property VisitNumber As %String(MAXLEN = 50) [ Required ];

Index VisitIdx On VisitNumber [ Unique ];

Property HospitalNumber As %String(MAXLEN = 50);

/// Wire format yyyy-MM-dd HH:mm:ss
Property VisitDate As %String(MAXLEN = 20);

/// e.g. "OPD" / "IPD" / "ER"
Property VisitType As %String(MAXLEN = 30);

Property DepartmentCode As %String(MAXLEN = 50);

Property DepartmentName As %String(MAXLEN = 100);

/// DUPLICATE, to be retired. Data dictionary V1.0.3 introduced
/// patient_chiefcomplain_info (D1.Mock.Data.ClaimChiefComplaint), which
/// PostPreAuth now also writes with this same value. Both are kept because
/// the dictionary still lists chief_complaint on visit_info. Remove THIS one
/// once it drops off visit_info -- GetDocumentInfo reads the other table.
Property ChiefComplaint As %String(MAXLEN = 500);

Property UpdateDate As %String(MAXLEN = 30);

Storage Default
{
<Data name="ClaimVisitDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>VisitNumber</Value>
</Value>
<Value name="3">
<Value>HospitalNumber</Value>
</Value>
<Value name="4">
<Value>VisitDate</Value>
</Value>
<Value name="5">
<Value>VisitType</Value>
</Value>
<Value name="6">
<Value>DepartmentCode</Value>
</Value>
<Value name="7">
<Value>DepartmentName</Value>
</Value>
<Value name="8">
<Value>ChiefComplaint</Value>
</Value>
<Value name="9">
<Value>UpdateDate</Value>
</Value>
</Data>
<DataLocation>^D1.Mock.Data.ClaimVisitD</DataLocation>
<DefaultData>ClaimVisitDefaultData</DefaultData>
<IdLocation>^D1.Mock.Data.ClaimVisitD</IdLocation>
<IndexLocation>^D1.Mock.Data.ClaimVisitI</IndexLocation>
<StreamLocation>^D1.Mock.Data.ClaimVisitS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
