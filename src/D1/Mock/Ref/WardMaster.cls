/// Master list of wards for a hospital -- IRIS-OWNED reference data, not a
/// TrakCare mirror. It lives in D1.Mock.Ref (not D1.Mock.Data) precisely
/// because one column is invented; the Data package holds faithful raw-Trak
/// mirrors only, and the integration suite asserts that boundary.
/// 
/// STOPGAP for the demo. TrakCare has no ward_type field anywhere, so this
/// table asserts the mapping locally instead of deriving it.
/// 
/// Every column except WardType mirrors TrakCare's CTLoc resource, which IS
/// the real ward master: wards are locations, and GET /CTLoc?LocationTypeID=
/// filters to them. Cutover is therefore "populate from the live CTLoc" plus
/// a decision about WardType -- not a redesign.
/// 
/// Caveats, in full, in docs/PRODUCTION_FLOWS.md:
///   - Nothing keeps this in sync with the hospital's real ward list.
///   - ward_type may belong to the ADMISSION, not the ward: TrakCare carries
///     MRADMCareTypeDR per episode and has first-class support for boarders
///     and outliers (patients placed in a ward that does not match their
///     service), for whom a ward-derived type is simply wrong.
Class D1.Mock.Ref.WardMaster Extends %Persistent
{

/// Ward code, e.g. "WARD01" -- CTLoc.CTLOCCode
Property CTLOCCode As %String(MAXLEN = 50) [ Required ];

Index CodeIdx On CTLOCCode [ Unique ];

/// Ward description, e.g. "Medical Ward 1" -- CTLoc.CTLOCDesc.
/// Indexed because PAAdm hands us WARDDesc, not a code.
Property CTLOCDesc As %String(MAXLEN = 100);

Index DescIdx On CTLOCDesc;

/// Location type -- CTLoc.CTLOCType. Distinguishes ward from clinic/theatre,
/// NOT one ward type from another. Kept so a live CTLoc load round-trips.
Property CTLOCType As %String(MAXLEN = 20);

/// Owning department, e.g. "Internal Medicine" -- CTLoc.DEPDesc. The nearest
/// real TrakCare basis for WardType, kept alongside it so the asserted
/// mapping can be reviewed against something sourced.
Property DEPDesc As %String(MAXLEN = 100);

/// Hospital the ward belongs to -- CTLoc.HOSPDesc. Ward codes are only
/// unique within a hospital; the lookup ignores this today because the
/// production assumes a single-hospital deployment.
Property Hospital As %String(MAXLEN = 50);

/// THE INVENTED COLUMN. D1's ward_type, e.g. "Medical Ward". No TrakCare
/// field carries this meaning -- it is asserted here, by hand.
Property WardType As %String(MAXLEN = 50);

Storage Default
{
<Data name="WardMasterDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>CTLOCCode</Value>
</Value>
<Value name="3">
<Value>CTLOCDesc</Value>
</Value>
<Value name="4">
<Value>CTLOCType</Value>
</Value>
<Value name="5">
<Value>DEPDesc</Value>
</Value>
<Value name="6">
<Value>Hospital</Value>
</Value>
<Value name="7">
<Value>WardType</Value>
</Value>
</Data>
<DataLocation>^D1.Mock.Ref.WardMasterD</DataLocation>
<DefaultData>WardMasterDefaultData</DefaultData>
<IdLocation>^D1.Mock.Ref.WardMasterD</IdLocation>
<IndexLocation>^D1.Mock.Ref.WardMasterI</IndexLocation>
<StreamLocation>^D1.Mock.Ref.WardMasterS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
