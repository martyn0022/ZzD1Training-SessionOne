/// Inbound Business Service for API_GetAdmission.
/// 
/// Adapter-less: invoked on demand from the REST dispatch class (D1API) via
/// Ens.Director.CreateBusinessService + ProcessInput.
Class D1.Mock.BS.AdmissionService Extends Ens.BusinessService
{

Parameter ADAPTER;

/// Where to send the GetAdmission request (the admission mapping operation).
Property TargetConfigName As %String(MAXLEN = 1000) [ InitialExpression = "Admission Mapper" ];

Parameter SETTINGS = "TargetConfigName:Basic";

Method OnProcessInput(pInput As D1.Mock.Msg.GetAdmissionRequest, Output pOutput As D1.Mock.Msg.GetAdmissionResponse) As %Status
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
