/// Inbound Business Service for API_GetPatient.
/// 
/// Adapter-less: invoked on demand from the REST dispatch class
/// (D1.Mock.API.PatientAPI) via Ens.Director.CreateBusinessService + ProcessInput.
/// Relays the request into the production so it is tracked, then returns the
/// response. TargetConfigName lets you point it at the BO now, or a routing
/// Business Process later, without code changes.
Class D1.Mock.BS.PatientService Extends Ens.BusinessService
{

Parameter ADAPTER;

/// Where to send the GetPatient request (the mapping Business Process, which
/// fans out to the HIS operation and transforms the result).
Property TargetConfigName As %String(MAXLEN = 1000) [ InitialExpression = "Patient Mapper" ];

Parameter SETTINGS = "TargetConfigName:Basic";

Method OnProcessInput(pInput As D1.Mock.Msg.GetPatientRequest, Output pOutput As D1.Mock.Msg.GetPatientResponse) As %Status
{
	Quit ..SendRequestSync(..TargetConfigName, pInput, .pOutput)
}

/// Draw the connection to the configured target in the production diagram.
ClassMethod OnGetConnections(Output pArray As %String, pItem As Ens.Config.Item)
{
	Do ##super(.pArray, pItem)
	If pItem.GetModifiedSetting("TargetConfigName", .tTarget), (tTarget '= "") {
		Set pArray(tTarget) = ""
	}
}

}
