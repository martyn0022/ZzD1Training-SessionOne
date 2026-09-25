/// One raw practitioner record from the HIS CTCareProv list. Property names
/// match TrakCare's real CTCareProv fields 1:1.
/// 
/// This is the ONLY place structured physician details exist -- deliberately
/// CTCareProv (the practitioner master), not PAPersonCareProvider (a
/// role-assignment record with no name/title/license fields).
Class D1.Mock.Msg.HIS.CareProviderResult Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

/// Ignore the practitioner attributes we do not model.
Parameter %JSONIGNOREINVALIDFIELD = 1;

/// Care provider code -> D1 physician_id
Property CTPCPCode As %String(MAXLEN = 50);

/// Title, e.g. "Dr." -- high population risk, nullable in D1
Property CTPCPTitle As %String(MAXLEN = 20);

Property CTPCPFirstName As %String(MAXLEN = 100);

Property CTPCPSurname As %String(MAXLEN = 100);

/// Medical council registration number -> D1 medical_license_no -- nullable
Property CTPCPSMCNo As %String(MAXLEN = 50);

Storage Default
{
<Data name="CareProviderResultState">
<Value name="1">
<Value>CTPCPCode</Value>
</Value>
<Value name="2">
<Value>CTPCPTitle</Value>
</Value>
<Value name="3">
<Value>CTPCPFirstName</Value>
</Value>
<Value name="4">
<Value>CTPCPSurname</Value>
</Value>
<Value name="5">
<Value>CTPCPSMCNo</Value>
</Value>
</Data>
<State>CareProviderResultState</State>
<StreamLocation>^D1.Mock.Ms9EC9.CareProvideCFEFS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
