/// Request to the HIS for one practitioner, by care provider code
/// (GET /CTCareProv?Code=). The code comes from the episode's CTPCPCode.
Class D1.Mock.Msg.HIS.CareProviderRequest Extends Ens.Request
{

/// Care provider code, e.g. "S12345"
Property Code As %String(MAXLEN = 50);

Storage Default
{
<Data name="CareProviderRequestDefaultData">
<Subscript>"CareProviderRequest"</Subscript>
<Value name="1">
<Value>Code</Value>
</Value>
</Data>
<DefaultData>CareProviderRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
