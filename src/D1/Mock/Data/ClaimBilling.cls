/// Group-2 billing_info table (data dictionary V1.0.2). Written by
/// PostDischarge's billing_info block. Auto ID + DischargeId indexed.
Class D1.Mock.Data.ClaimBilling Extends %Persistent
{

Property DischargeId As %String(MAXLEN = 50) [ Required ];

Index DischargeIdIdx On DischargeId [ Unique ];

Property HospitalNumber As %String(MAXLEN = 50);

Property AdmissionNumber As %String(MAXLEN = 50);

Index AdmissionIdx On AdmissionNumber;

/// e.g. "THB"
Property Currency As %String(MAXLEN = 3);

Property TotalCharge As %Numeric(SCALE = 2);

Property DiscountAmount As %Numeric(SCALE = 2);

Property NetCharge As %Numeric(SCALE = 2);

Property PatientPayable As %Numeric(SCALE = 2);

Property InsurancePayable As %Numeric(SCALE = 2);

Storage Default
{
<Data name="ClaimBillingDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>DischargeId</Value>
</Value>
<Value name="3">
<Value>HospitalNumber</Value>
</Value>
<Value name="4">
<Value>AdmissionNumber</Value>
</Value>
<Value name="5">
<Value>Currency</Value>
</Value>
<Value name="6">
<Value>TotalCharge</Value>
</Value>
<Value name="7">
<Value>DiscountAmount</Value>
</Value>
<Value name="8">
<Value>NetCharge</Value>
</Value>
<Value name="9">
<Value>PatientPayable</Value>
</Value>
<Value name="10">
<Value>InsurancePayable</Value>
</Value>
</Data>
<DataLocation>^D1.Mock.Data.ClaimBillingD</DataLocation>
<DefaultData>ClaimBillingDefaultData</DefaultData>
<IdLocation>^D1.Mock.Data.ClaimBillingD</IdLocation>
<IndexLocation>^D1.Mock.Data.ClaimBillingI</IndexLocation>
<StreamLocation>^D1.Mock.Data.ClaimBillingS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
