/// document_info.hospital
Class D1.Mock.Msg.DocHospital Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

Property HospitalCode As %String(%JSONFIELDNAME = "hospital_code", MAXLEN = 50);

Storage Default
{
<Data name="DocHospitalState">
<Value name="1">
<Value>HospitalCode</Value>
</Value>
</Data>
<State>DocHospitalState</State>
<StreamLocation>^D1.Mock.Msg.DocHospitalS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
