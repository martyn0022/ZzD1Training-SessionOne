/// The complaint_info object (chief complaint), new in V1.0.3 -- shared by
/// GetVisit's response and PostPreAuth's request.
Class D1.Mock.Msg.ComplaintInfo Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

/// e.g. "Fever" -- sourced from MRReasonForEnc.DescSnomed (best-guess mapping)
Property ChiefComplaint As %String(%JSONFIELDNAME = "chief_complaint", MAXLEN = 255);

Storage Default
{
<Data name="ComplaintInfoState">
<Value name="1">
<Value>ChiefComplaint</Value>
</Value>
</Data>
<State>ComplaintInfoState</State>
<StreamLocation>^D1.Mock.Msg.ComplaintInfoS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
