/// The "admission" object in API_PostPreAuth V1.0.3 (was admission_info[] --
/// now a single object, gaining admission_number / ward_number / ward_type /
/// bed_no over the V1.0.2 shape).
/// 
/// estimated_cost is carried as a string because the spec's sample sends it
/// quoted ("10000.00"); it is coerced to a numeric column by the storage
/// operation.
Class D1.Mock.Msg.AdmissionInfo Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

/// The submission key, e.g. "AN00012345"
Property AdmissionNumber As %String(%JSONFIELDNAME = "admission_number", MAXLEN = 50);

Property WardNumber As %String(%JSONFIELDNAME = "ward_number", MAXLEN = 100);

Property WardType As %String(%JSONFIELDNAME = "ward_type", MAXLEN = 50);

/// Room type / ward, e.g. "สามัญ ห้องรวม"
Property RoomType As %String(%JSONFIELDNAME = "room_type", MAXLEN = 100);

Property BedNo As %String(%JSONFIELDNAME = "bed_no", MAXLEN = 50);

/// Wire format yyyy-MM-dd HH:mm:ss per V1.0.3
Property EstimatedAdmissionDate As %String(%JSONFIELDNAME = "estimated_admission_date", MAXLEN = 20);

/// Length of stay, in days
Property EstimatedLengthOfStay As %String(%JSONFIELDNAME = "estimated_lengthofstay", MAXLEN = 10);

Property EstimatedCost As %String(%JSONFIELDNAME = "estimated_cost", MAXLEN = 20);

Storage Default
{
<Data name="AdmissionInfoState">
<Value name="1">
<Value>AdmissionNumber</Value>
</Value>
<Value name="2">
<Value>WardNumber</Value>
</Value>
<Value name="3">
<Value>WardType</Value>
</Value>
<Value name="4">
<Value>RoomType</Value>
</Value>
<Value name="5">
<Value>BedNo</Value>
</Value>
<Value name="6">
<Value>EstimatedAdmissionDate</Value>
</Value>
<Value name="7">
<Value>EstimatedLengthOfStay</Value>
</Value>
<Value name="8">
<Value>EstimatedCost</Value>
</Value>
</Data>
<State>AdmissionInfoState</State>
<StreamLocation>^D1.Mock.Msg.AdmissionInfoS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
