/// The billing_info object in API_GetBilling's V1.0.3 response (single
/// object), also reused by PostDischarge's request.
/// 
/// currency is CONFIG-SOURCED, never mapped from the HIS -- no currency field
/// exists anywhere on TrakCare's billing resources (verified exhaustively).
/// Amounts are exported as plain JSON numbers per the spec's own CR (the
/// quoted comma-separated samples are a documented spec typo).
Class D1.Mock.Msg.BillingInfo Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

/// e.g. "THB" -- from the billing flow's DefaultCurrency setting
Property Currency As %String(%JSONFIELDNAME = "currency", MAXLEN = 3);

Property TotalCharge As %Numeric(%JSONFIELDNAME = "total_charge", SCALE = 2);

Property DiscountAmount As %Numeric(%JSONFIELDNAME = "discount_amount", SCALE = 2);

Property NetCharge As %Numeric(%JSONFIELDNAME = "net_charge", SCALE = 2);

Property PatientPayable As %Numeric(%JSONFIELDNAME = "patient_payable", SCALE = 2);

Property InsurancePayable As %Numeric(%JSONFIELDNAME = "insurance_payable", SCALE = 2);

Storage Default
{
<Data name="BillingInfoState">
<Value name="1">
<Value>Currency</Value>
</Value>
<Value name="2">
<Value>TotalCharge</Value>
</Value>
<Value name="3">
<Value>DiscountAmount</Value>
</Value>
<Value name="4">
<Value>NetCharge</Value>
</Value>
<Value name="5">
<Value>PatientPayable</Value>
</Value>
<Value name="6">
<Value>InsurancePayable</Value>
</Value>
</Data>
<State>BillingInfoState</State>
<StreamLocation>^D1.Mock.Msg.BillingInfoS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
