/// Mock HIS patient bill row, mirroring TrakCare's ARPatientBillAll resource.
/// Lives in MOCKDATA. Queried by PatientID + Hospital -- the real resource has
/// NO admission-number query parameter, so the calling operation filters the
/// returned rows on EpisodeID in code to isolate one admission's bill.
/// 
/// No currency column: confirmed absent from all 166 fields of the real
/// resource (and no CT_Currency code-table resource exists anywhere in the
/// collection). D1's currency field is served from IRIS config instead.
/// 
/// PatInvTot / PayorInvTot are INVOICED amounts, not outstanding balances --
/// do not confuse with PatOutstandAmt / payor outstanding on the real resource.
Class D1.Mock.Data.ArPatientBillAll Extends %Persistent
{

/// Patient registry row id (-> Patient.PatientID)
Property PatientID As %String(MAXLEN = 50);

Index PatientIdx On PatientID;

/// Episode/admission this bill belongs to (-> PAAdm.PAADMADMNo)
Property EpisodeID As %String(MAXLEN = 50);

Index EpisodeIdx On EpisodeID;

/// Hospital code, e.g. "RAMA9"
Property Hospital As %String(MAXLEN = 50);

/// -> D1 total_charge
Property GrossAmount As %Numeric(SCALE = 2);

/// -> D1 discount_amount
Property DiscTotal As %Numeric(SCALE = 2);

/// -> D1 net_charge
Property NetAmount As %Numeric(SCALE = 2);

/// -> D1 patient_payable (invoiced, not outstanding)
Property PatInvTot As %Numeric(SCALE = 2);

/// -> D1 insurance_payable (invoiced, not outstanding)
Property PayorInvTot As %Numeric(SCALE = 2);

Storage Default
{
<Data name="ArPatientBillAllDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>PatientID</Value>
</Value>
<Value name="3">
<Value>EpisodeID</Value>
</Value>
<Value name="4">
<Value>Hospital</Value>
</Value>
<Value name="5">
<Value>GrossAmount</Value>
</Value>
<Value name="6">
<Value>DiscTotal</Value>
</Value>
<Value name="7">
<Value>NetAmount</Value>
</Value>
<Value name="8">
<Value>PatInvTot</Value>
</Value>
<Value name="9">
<Value>PayorInvTot</Value>
</Value>
</Data>
<DataLocation>^D1.Mock.Data.ArPatientBillAllD</DataLocation>
<DefaultData>ArPatientBillAllDefaultData</DefaultData>
<IdLocation>^D1.Mock.Data.ArPatientBillAllD</IdLocation>
<IndexLocation>^D1.Mock.Data.ArPatientBillAllI</IndexLocation>
<StreamLocation>^D1.Mock.Data.ArPatientBillAllS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
