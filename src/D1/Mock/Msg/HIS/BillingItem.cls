/// One raw patient bill row from the HIS ARPatientBillAll list.
/// PatInvTot/PayorInvTot are INVOICED amounts, not outstanding balances.
/// No currency field exists on the real resource -- D1's currency comes from
/// IRIS config, never from this row.
Class D1.Mock.Msg.HIS.BillingItem Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

/// Ignore the ~160 bill attributes we do not model.
Parameter %JSONIGNOREINVALIDFIELD = 1;

Property PatientID As %String(MAXLEN = 50);

/// Episode/admission this bill belongs to -- the caller's filter key
Property EpisodeID As %String(MAXLEN = 50);

Property Hospital As %String(MAXLEN = 50);

/// -> D1 total_charge
Property GrossAmount As %Numeric(SCALE = 2);

/// -> D1 discount_amount
Property DiscTotal As %Numeric(SCALE = 2);

/// -> D1 net_charge
Property NetAmount As %Numeric(SCALE = 2);

/// -> D1 patient_payable
Property PatInvTot As %Numeric(SCALE = 2);

/// -> D1 insurance_payable
Property PayorInvTot As %Numeric(SCALE = 2);

Storage Default
{
<Data name="BillingItemState">
<Value name="1">
<Value>PatientID</Value>
</Value>
<Value name="2">
<Value>EpisodeID</Value>
</Value>
<Value name="3">
<Value>Hospital</Value>
</Value>
<Value name="4">
<Value>GrossAmount</Value>
</Value>
<Value name="5">
<Value>DiscTotal</Value>
</Value>
<Value name="6">
<Value>NetAmount</Value>
</Value>
<Value name="7">
<Value>PatInvTot</Value>
</Value>
<Value name="8">
<Value>PayorInvTot</Value>
</Value>
</Data>
<State>BillingItemState</State>
<StreamLocation>^D1.Mock.Msg.HIS.BillingItemS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
