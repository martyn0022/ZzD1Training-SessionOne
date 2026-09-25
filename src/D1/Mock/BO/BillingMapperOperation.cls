/// Business Operation for API_GetBilling V1.0.3: one HIS billing read (the
/// HIS operation resolves the admission and filters the bill rows), one DTL,
/// plus the config-sourced currency -- a plain adapter-less BO, since the
/// admission filter is imperative logic, not a field mapping.
/// 
/// currency NEVER comes from the HIS: no currency field exists anywhere on
/// TrakCare's billing resources (exhaustively verified -- see plan). It is
/// assigned from the SETTINGS-exposed DefaultCurrency after the transform,
/// so a real deployment sets it per hospital in the Management Portal.
Class D1.Mock.BO.BillingMapperOperation Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

/// The HIS-calling operation this flow reads through.
Property HISTargetConfigName As %String(MAXLEN = 1000) [ InitialExpression = "HIS Operation" ];

/// Currency code served on every billing response -- per-hospital
/// integration-layer configuration, standing in for the currency TrakCare
/// cannot provide.
Property DefaultCurrency As %String(MAXLEN = 3) [ InitialExpression = "THB" ];

Parameter SETTINGS = "HISTargetConfigName:Basic,DefaultCurrency:Basic";

Method GetBilling(pRequest As D1.Mock.Msg.GetBillingRequest, Output pResponse As D1.Mock.Msg.GetBillingResponse) As %Status
{
	Set tSC = $$$OK
	Try {
		Set pResponse = ##class(D1.Mock.Msg.GetBillingResponse).%New()

		Set tHISRequest = ##class(D1.Mock.Msg.HIS.BillingRequest).%New()
		Set tHISRequest.AdmissionNumber = pRequest.AdmissionNumber
		Set tHISRequest.Hospital = pRequest.HospitalCode
		Set tSC = ..SendRequestSync(..HISTargetConfigName, tHISRequest, .tBillResp)
		Quit:$$$ISERR(tSC)

		If '##class(D1.Mock.BP.PatientMapper).HasRows(tBillResp) {
			Set pResponse.ResponseCode = "404"
			Set pResponse.ResponseMessage = "No billing found for admission_number " _ pRequest.AdmissionNumber
			Quit
		}

		Set tSC = ##class(D1.Mock.DT.ArPatientBillAllToBilling).Transform(tBillResp, .pResponse)
		Quit:$$$ISERR(tSC)

		// Config-sourced, never mapped -- the documented TrakCare gap.
		Set pResponse.BillingInfo.Currency = ..DefaultCurrency
	}
	Catch ex {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

/// Draw the connection to the HIS operation in the production diagram.
ClassMethod OnGetConnections(Output pArray As %String, pItem As Ens.Config.Item)
{
	Do ##super(.pArray, pItem)
	If pItem.GetModifiedSetting("HISTargetConfigName", .tTarget), (tTarget '= "") {
		Set pArray(tTarget) = ""
	}
}

XData MessageMap
{
<MapItems>
  <MapItem MessageType="D1.Mock.Msg.GetBillingRequest">
    <Method>GetBilling</Method>
  </MapItem>
</MapItems>
}

}
