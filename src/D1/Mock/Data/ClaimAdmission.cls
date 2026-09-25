/// Group-2 admission_info table (data dictionary V1.0.2). Written by
/// PostDischarge's admission_info snapshot (and lightly seeded for
/// cold-start smoke tests); read by D1GetAdmission.
Class D1.Mock.Data.ClaimAdmission Extends %Persistent
{

Property AdmissionNumber As %String(MAXLEN = 50) [ Required ];

Index AdmissionIdx On AdmissionNumber [ Unique ];

Property HospitalNumber As %String(MAXLEN = 50) [ Required ];

Index HospitalIdx On HospitalNumber;

/// Wire format yyyy-MM-dd HH:mm:ss, stored verbatim
Property AdmissionDate As %String(MAXLEN = 20);

Property WardNumber As %String(MAXLEN = 100);

Property WardType As %String(MAXLEN = 50);

Property RoomType As %String(MAXLEN = 100);

Property BedNo As %String(MAXLEN = 50);

Property ExpectedDischargeDate As %String(MAXLEN = 20);

Property ActualDischargeDate As %String(MAXLEN = 20);

/// Days
Property EstimatedLengthOfStay As %String(MAXLEN = 10);

Property EstimatedCost As %Numeric(SCALE = 2);

Storage Default
{
<Data name="ClaimAdmissionDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>AdmissionNumber</Value>
</Value>
<Value name="3">
<Value>HospitalNumber</Value>
</Value>
<Value name="4">
<Value>AdmissionDate</Value>
</Value>
<Value name="5">
<Value>WardNumber</Value>
</Value>
<Value name="6">
<Value>WardType</Value>
</Value>
<Value name="7">
<Value>RoomType</Value>
</Value>
<Value name="8">
<Value>BedNo</Value>
</Value>
<Value name="9">
<Value>ExpectedDischargeDate</Value>
</Value>
<Value name="10">
<Value>ActualDischargeDate</Value>
</Value>
<Value name="11">
<Value>EstimatedLengthOfStay</Value>
</Value>
<Value name="12">
<Value>EstimatedCost</Value>
</Value>
</Data>
<DataLocation>^D1.Mock.Data.ClaimAdmissionD</DataLocation>
<DefaultData>ClaimAdmissionDefaultData</DefaultData>
<IdLocation>^D1.Mock.Data.ClaimAdmissionD</IdLocation>
<IndexLocation>^D1.Mock.Data.ClaimAdmissionI</IndexLocation>
<StreamLocation>^D1.Mock.Data.ClaimAdmissionS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
