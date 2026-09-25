/// Inbound Business Service for API_D1GetDischargeInfo (group 2 -- IRIS's own tables, no HIS).
/// 
/// Adapter-less: invoked on demand from the REST dispatch class (D1API) via
/// Ens.Director.CreateBusinessService + ProcessInput.
Class D1.Mock.BS.D1GetDischargeInfoService Extends Ens.BusinessService
{

Parameter ADAPTER;

/// Where to send the request (the group-2 read operation).
Property TargetConfigName As %String(MAXLEN = 1000) [ InitialExpression = "D1GetDischargeInfo Operation" ];

Parameter SETTINGS = "TargetConfigName:Basic";

Method OnProcessInput(pInput As D1.Mock.Msg.D1GetDischargeInfoRequest, Output pOutput As D1.Mock.Msg.D1GetDischargeInfoResponse) As %Status
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
