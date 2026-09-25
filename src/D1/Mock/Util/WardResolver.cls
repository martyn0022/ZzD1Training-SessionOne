/// Resolves D1's ward_type for an episode.
/// 
/// Order: the IRIS-owned ward master, then PAAdm.CARETYPDesc as a fallback.
/// Both are stopgaps -- TrakCare has no ward_type field. The fallback exists
/// so an unseeded ward degrades to the older best guess instead of going
/// empty, which is the symptom that was reported from SIT.
/// 
/// Consequence worth knowing: a wrong value has two possible origins. Check
/// D1_Mock_Ref.WardMaster for the ward first; an absent row means you are
/// looking at the care-type fallback.
Class D1.Mock.Util.WardResolver
{

/// pWard is PAAdm.WARDDesc; pCareType is PAAdm.CARETYPDesc.
ClassMethod ResolveWardType(pWard As %String, pCareType As %String = "") As %String
{
	Quit:pWard="" pCareType
	Set tType = ""
	&sql(SELECT WardType INTO :tType FROM D1_Mock_Ref.WardMaster WHERE CTLOCCode = :pWard)
	If SQLCODE '= 0 {
		// PAAdm sends a ward DESCRIPTION while the master is keyed by code,
		// so accept either -- a rename on one side should not break both.
		Set tType = ""
		&sql(SELECT TOP 1 WardType INTO :tType FROM D1_Mock_Ref.WardMaster WHERE CTLOCDesc = :pWard)
		Set:SQLCODE'=0 tType = ""
	}
	Quit $Select(tType'="": tType, 1: pCareType)
}

}
