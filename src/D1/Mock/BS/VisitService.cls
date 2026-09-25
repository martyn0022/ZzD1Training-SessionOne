/// Inbound Business Service for API_GetVisit.
/// 
/// Adapter-less: invoked on demand from the REST dispatch class (D1API) via
/// Ens.Director.CreateBusinessService + ProcessInput. Relays the request into
/// the production so it is tracked, then returns the response.
Class D1.Mock.BS.VisitService Extends Ens.BusinessService
{

Parameter ADAPTER;

/// Where to send the GetVisit request (the visit mapping Business Process).
Property TargetConfigName As %String(MAXLEN = 1000) [ InitialExpression = "Visit Mapper" ];

Parameter SETTINGS = "TargetConfigName:Basic";

Method OnProcessInput(pInput As D1.Mock.Msg.GetVisitRequest, Output pOutput As D1.Mock.Msg.GetVisitResponse) As %Status
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
