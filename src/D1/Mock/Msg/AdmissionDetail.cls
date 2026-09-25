/// The admission_info object in API_GetAdmission's V1.0.3 response (single
/// object). JSON field names match the spec exactly.
/// 
/// ward_type has NO TrakCare source (confirmed absent from every resource in
/// the collection) -- always null on live HIS reads, per the documented gap.
/// room_type / bed_no / expected_discharge_date are high population risk on
/// real sites -- nullable.
Class D1.Mock.Msg.AdmissionDetail Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

Property AdmissionNumber As %String(%JSONFIELDNAME = "admission_number", MAXLEN = 50);

/// Admission date, wire format yyyy-MM-dd HH:mm:ss
Property AdmissionDate As %String(%JSONFIELDNAME = "admission_date", MAXLEN = 20);

/// Ward description (pinned: PAAdm.WARDDesc, description accepted for the demo)
Property WardNumber As %String(%JSONFIELDNAME = "ward_number", MAXLEN = 100);

/// No TrakCare source -- always null on live HIS reads (documented gap).
Property WardType As %String(%JSONFIELDNAME = "ward_type", MAXLEN = 50);

Property RoomType As %String(%JSONFIELDNAME = "room_type", MAXLEN = 100);

Property BedNo As %String(%JSONFIELDNAME = "bed_no", MAXLEN = 50);

/// Wire format yyyy-MM-dd HH:mm:ss, nullable
Property ExpectedDischargeDate As %String(%JSONFIELDNAME = "expected_discharge_date", MAXLEN = 20);

/// Physical discharge date (pinned source), wire format yyyy-MM-dd HH:mm:ss
Property ActualDischargeDate As %String(%JSONFIELDNAME = "actual_discharge_date", MAXLEN = 20);

Storage Default
{
<Data name="AdmissionDetailState">
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
<Value>ExpectedDischargeDate</Value>
</Value>
<Value name="8">
<Value>ActualDischargeDate</Value>
</Value>
</Data>
<State>AdmissionDetailState</State>
<StreamLocation>^D1.Mock.Msg.AdmissionDetailS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
