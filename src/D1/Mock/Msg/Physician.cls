/// Attending physician from the HIS (response element 5, attending_physician).
/// A single object, not a list.
Class D1.Mock.Msg.Physician Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

Property Id As %String(%JSONFIELDNAME = "physician_id", MAXLEN = 50);

Property Title As %String(%JSONFIELDNAME = "physician_title", MAXLEN = 20);

Property FirstName As %String(%JSONFIELDNAME = "physician_firstname", MAXLEN = 100);

Property LastName As %String(%JSONFIELDNAME = "physician_lastName", MAXLEN = 100);

Property LicenseNo As %String(%JSONFIELDNAME = "medical_license_no", MAXLEN = 50);

Storage Default
{
<Data name="PhysicianState">
<Value name="1">
<Value>Id</Value>
</Value>
<Value name="2">
<Value>Title</Value>
</Value>
<Value name="3">
<Value>FirstName</Value>
</Value>
<Value name="4">
<Value>LastName</Value>
</Value>
<Value name="5">
<Value>LicenseNo</Value>
</Value>
</Data>
<State>PhysicianState</State>
<StreamLocation>^D1.Mock.Msg.PhysicianS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
