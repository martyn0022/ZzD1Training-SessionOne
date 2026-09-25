/// Mock HIS care provider (practitioner) row, mirroring TrakCare's CTCareProv
/// resource (alias /Practitioner). Lives in MOCKDATA.
/// 
/// This is the practitioner MASTER -- deliberately not PAPersonCareProvider,
/// which is a patient-to-provider role-assignment record carrying no name,
/// title, or license fields at all (verified against the real collection).
/// 
/// CTPCPTitle and CTPCPSMCNo are high population risk on real sites (title is
/// often embedded in the display name; license capture is local regulatory
/// practice, not a TrakCare default) -- both nullable in the D1 contract.
Class D1.Mock.Data.CtCareProv Extends %Persistent
{

/// Care provider code, e.g. "S12345" -- what PAAdm.CTPCPCode points at
Property CTPCPCode As %String(MAXLEN = 50) [ Required ];

Index CodeIdx On CTPCPCode [ Unique ];

/// Title, e.g. "Dr." -- high population risk, nullable downstream
Property CTPCPTitle As %String(MAXLEN = 20);

Property CTPCPFirstName As %String(MAXLEN = 100);

Property CTPCPSurname As %String(MAXLEN = 100);

/// Medical council registration number -- high population risk, nullable downstream
Property CTPCPSMCNo As %String(MAXLEN = 50);

Storage Default
{
<Data name="CtCareProvDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>CTPCPCode</Value>
</Value>
<Value name="3">
<Value>CTPCPTitle</Value>
</Value>
<Value name="4">
<Value>CTPCPFirstName</Value>
</Value>
<Value name="5">
<Value>CTPCPSurname</Value>
</Value>
<Value name="6">
<Value>CTPCPSMCNo</Value>
</Value>
</Data>
<DataLocation>^D1.Mock.Data.CtCareProvD</DataLocation>
<DefaultData>CtCareProvDefaultData</DefaultData>
<IdLocation>^D1.Mock.Data.CtCareProvD</IdLocation>
<IndexLocation>^D1.Mock.Data.CtCareProvI</IndexLocation>
<StreamLocation>^D1.Mock.Data.CtCareProvS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
