/// The "insurer_info" block inside each D1GetDischargeInfo response row,
/// new in V1.0.4.
/// 
/// The spec's label is misleading: it carries the patient's hospital number
/// and the admission number, not insurer data. Built as written. Distinct
/// from D1.Mock.Msg.InsurerInfo, which is the real insurer block
/// (company_code / company_name) used by D1GetPolicy and PostDischarge.
Class D1.Mock.Msg.DischargeInsurerInfo Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

Property HospitalNumber As %String(%JSONFIELDNAME = "hospital_number", MAXLEN = 50);

Property AdmissionNumber As %String(%JSONFIELDNAME = "admission_number", MAXLEN = 50);

Storage Default
{
<Data name="DischargeInsurerInfoState">
<Value name="1">
<Value>HospitalNumber</Value>
</Value>
<Value name="2">
<Value>AdmissionNumber</Value>
</Value>
</Data>
<State>DischargeInsurerInfoState</State>
<StreamLocation>^D1.Mock.Msg.DischargeInBBA6S</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
