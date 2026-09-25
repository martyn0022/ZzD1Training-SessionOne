/// The "admission" object in API_D1GetAdmission's V1.0.3 response.
/// 
/// Same eight fields as group-1's AdmissionDetail plus
/// estimated_lengthofstay / estimated_cost, which IRIS's own admission_info
/// table carries but the live HIS episode read does not expose -- which is
/// why this is its own class rather than a reuse.
Class D1.Mock.Msg.D1AdmissionDetail Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

Property AdmissionNumber As %String(%JSONFIELDNAME = "admission_number", MAXLEN = 50);

/// Wire format yyyy-MM-dd HH:mm:ss
Property AdmissionDate As %String(%JSONFIELDNAME = "admission_date", MAXLEN = 20);

Property WardNumber As %String(%JSONFIELDNAME = "ward_number", MAXLEN = 100);

Property WardType As %String(%JSONFIELDNAME = "ward_type", MAXLEN = 50);

Property RoomType As %String(%JSONFIELDNAME = "room_type", MAXLEN = 100);

Property BedNo As %String(%JSONFIELDNAME = "bed_no", MAXLEN = 50);

/// Days
Property EstimatedLengthOfStay As %String(%JSONFIELDNAME = "estimated_lengthofstay", MAXLEN = 10);

Property EstimatedCost As %Numeric(%JSONFIELDNAME = "estimated_cost", SCALE = 2);

Property ExpectedDischargeDate As %String(%JSONFIELDNAME = "expected_discharge_date", MAXLEN = 20);

Property ActualDischargeDate As %String(%JSONFIELDNAME = "actual_discharge_date", MAXLEN = 20);

Storage Default
{
<Data name="D1AdmissionDetailState">
<Value name="1">
<Value>AdmissionNumber</Value>
</Value>
<Value name="2">
<Value>AdmissionDate</Value>
</Value>
<Value name="3">
<Value>WardNumber</Value>
</Value>
<Value name="4">
<Value>WardType</Value>
</Value>
<Value name="5">
<Value>RoomType</Value>
</Value>
<Value name="6">
<Value>BedNo</Value>
</Value>
<Value name="7">
<Value>EstimatedLengthOfStay</Value>
</Value>
<Value name="8">
<Value>EstimatedCost</Value>
</Value>
<Value name="9">
<Value>ExpectedDischargeDate</Value>
</Value>
<Value name="10">
<Value>ActualDischargeDate</Value>
</Value>
</Data>
<State>D1AdmissionDetailState</State>
<StreamLocation>^D1.Mock.Msg.D1AdmissionDetailS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
