/// One element of D1GetDischargeInfo's discharge[] array (V1.0.4).
/// 
/// V1.0.4 restructured this response: what was a single "discharge" object
/// with hospital_number/admission_number sitting at the top level is now an
/// array, each row self-contained and split into two nested blocks. That
/// finally makes it consistent with D1GetPreAuthInfo, whose array shape it
/// contradicted in V1.0.3.
Class D1.Mock.Msg.D1DischargeEntry Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

/// Despite the name, this holds the hospital and admission numbers.
Property InsurerInfo As D1.Mock.Msg.DischargeInsurerInfo(%JSONFIELDNAME = "insurer_info");

Property DischargeInfo As D1.Mock.Msg.DischargeDetail(%JSONFIELDNAME = "discharge_info");

Storage Default
{
<Data name="D1DischargeEntryState">
<Value name="1">
<Value>InsurerInfo</Value>
</Value>
<Value name="2">
<Value>DischargeInfo</Value>
</Value>
</Data>
<State>D1DischargeEntryState</State>
<StreamLocation>^D1.Mock.Msg.D1DischargeEntryS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
