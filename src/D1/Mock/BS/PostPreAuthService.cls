/// Inbound Business Service for API_PostPreAuth.
/// 
/// Adapter-less, exactly like D1.Mock.BS.PatientService: invoked on demand from
/// the REST dispatch class (D1.Mock.API.D1API) via Ens.Director.CreateBusinessService
/// + ProcessInput. Relays the submission into the production so it is tracked in
/// the message viewer, then returns the acknowledgement envelope.
/// 
/// TargetConfigName lets you re-point the entry: at the storing process now, or at
/// a routing process that also forwards to the insurer later, without code changes.
Class D1.Mock.BS.PostPreAuthService Extends Ens.BusinessService
{

Parameter ADAPTER;

/// Where to send the submission (the process that validates it and calls the
/// storage operation).
Property TargetConfigName As %String(MAXLEN = 1000) [ InitialExpression = "PreAuth Store Process" ];

Parameter SETTINGS = "TargetConfigName:Basic";

Method OnProcessInput(pInput As D1.Mock.Msg.PostPreAuthRequest, Output pOutput As D1.Mock.Msg.PostPreAuthResponse) As %Status
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
