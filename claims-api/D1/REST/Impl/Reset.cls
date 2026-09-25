Include %occStatus

/// POST /reset -- testing utility, not part of the D1 API spec: wipes the
/// claim tables (and PreAuthSubmission) so a resubmitted
/// admission_number/claim_id won't 409 against leftover data from a prior
/// test run.
///
/// Body is optional. {"reseed": "1"} wipes and reseeds the demo dataset
/// (see ClaimLoader.Reset); omitted or "0" (the default) just wipes.
Class D1.REST.Impl.Reset Extends D1.REST.Base
{

ClassMethod Handle() As %Status
{
	Try {
		Set tReseed = 0
		If $IsObject(%request.Content) && (%request.Content.Size > 0) {
			Set tJson = ##class(%DynamicAbstractObject).%FromJSON(..ReadBodyAsUnicode())
			If $IsObject(tJson) {
				Set tReseed = tJson.%Get("reseed", 0)
			}
		}
		If (tReseed '= 0) && (tReseed '= 1) && (tReseed '= "0") && (tReseed '= "1") {
			Return ..BadRequest("reseed must be ""0"" or ""1""")
		}
		Set tSC = ##class(D1.Mock.Data.ClaimLoader).Reset(+tReseed)
		Return:$$$ISERR(tSC) ..ServerError($System.Status.GetErrorText(tSC))
		Return ..WriteEnvelope("200", $Select(+tReseed: "Tables wiped and reseeded", 1: "Tables wiped"))
	}
	Catch ex {
		Return ..ServerError(ex.DisplayString())
	}
}

}