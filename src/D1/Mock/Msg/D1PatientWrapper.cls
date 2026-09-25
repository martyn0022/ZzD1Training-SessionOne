/// One patient[] element in API_D1GetPatient's V1.0.3 response -- an object
/// wrapping patient_info. D1GetPatient kept this nested shape while
/// API_GetPatient flattened, so the two no longer share a response class
/// (a flagged V1.0.3 divergence, built as written).
Class D1.Mock.Msg.D1PatientWrapper Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

Property PatientInfo As D1.Mock.Msg.PatientInfo(%JSONFIELDNAME = "patient_info");

Storage Default
{
<Data name="D1PatientWrapperState">
<Value name="1">
<Value>PatientInfo</Value>
</Value>
</Data>
<State>D1PatientWrapperState</State>
<StreamLocation>^D1.Mock.Msg.D1PatientWrapperS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
