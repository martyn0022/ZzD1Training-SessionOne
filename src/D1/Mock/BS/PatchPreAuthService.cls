/// Inbound Business Service for API_PatchPreAuth (group 2 -- IRIS's own tables, no HIS).
/// 
/// Adapter-less: invoked on demand from the REST dispatch class (D1API) via
/// Ens.Director.CreateBusinessService + ProcessInput.
Class D1.Mock.BS.PatchPreAuthService Extends Ens.BusinessService
{

Parameter ADAPTER;

Property TargetConfigName As %String(MAXLEN = 1000) [ InitialExpression = "PatchPreAuth Operation" ];

Parameter SETTINGS = "TargetConfigName:Basic";

Method OnProcessInput(pInput As D1.Mock.Msg.PatchPreAuthRequest, Output pOutput As D1.Mock.Msg.PatchPreAuthResponse) As %Status
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
