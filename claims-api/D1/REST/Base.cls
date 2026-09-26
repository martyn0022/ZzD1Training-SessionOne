Include %occStatus

/// Shared HTTP/JSON plumbing for the production-free D1 REST stack.
///
/// Every D1.REST.Impl class extends this and splits in two:
///   Handle() owns the HTTP contract -- read the body, validate, write JSON.
///   Run()    owns the logic and takes a message object, so %UnitTest can
///            exercise it without a web request (and without a production).
///
/// D1.REST.Test is that test -- the seam is not speculative, it is the only
/// way to check this code without standing up a web application first.
///
/// These endpoints answer straight from IRIS's own tables -- no business
/// process to orchestrate, nothing to route, and no outbound call needing a
/// configured adapter -- hence no production, no business service and no
/// business operation. The Ensemble event log goes with them; Log() below
/// keeps the write paths' audit line in messages.log instead.
Class D1.REST.Base Extends %RegisteredObject [ Abstract ]
{

Parameter HTTP400BADREQUEST = "400 Bad Request";

Parameter HTTP500INTERNALSERVERERROR = "500 Internal Server Error";

/// Read the JSON body (with the UTF-8 fix) and import it into pRequest.
ClassMethod ImportBody(pRequest As %JSON.Adaptor) As %Status
{
	If '$IsObject(%request.Content) {
		Return $$$ERROR($$$GeneralError, "Request body is required")
	}
	Try {
		Set tJson = ##class(%DynamicAbstractObject).%FromJSON(..ReadBodyAsUnicode())
	}
	Catch parseEx {
		Return $$$ERROR($$$GeneralError, "Invalid JSON body: " _ parseEx.DisplayString())
	}
	If '$IsObject(tJson) || ($ClassName(tJson) '= "%Library.DynamicObject") {
		Return $$$ERROR($$$GeneralError, "Request body must be a JSON object")
	}
	Return pRequest.%JSONImport(tJson)
}

/// Read the request body and hand back real characters, not UTF-8 bytes.
///
/// The body arrives here undecoded: posting the spec's own sample room_type
/// "สามัญ ห้องรวม" stored as the UTF-8 byte sequence instead of 13 Thai code
/// points, and declaring "charset=utf-8" made no difference. Left alone it
/// corrupts every non-ASCII value.
ClassMethod ReadBodyAsUnicode() As %String
{
	Set tRaw = ""
	Do %request.Content.Rewind()
	While '%request.Content.AtEnd {
		Set tRaw = tRaw _ %request.Content.Read(32000)
	}
	Return ..DecodeUTF8(tRaw)
}

/// Decode a UTF-8 byte string, leaving anything already decoded untouched.
///
/// A character above 255 means the stream was translated for us after all (a
/// different CSP/gateway configuration would do that), and decoding a second
/// time would corrupt it -- so bail out in that case. Pure ASCII decodes to
/// itself, so the common path is unaffected either way.
ClassMethod DecodeUTF8(pRaw As %String) As %String
{
	Quit:pRaw="" pRaw
	Set tWide = 0
	For i = 1:1:$Length(pRaw) {
		If $Ascii(pRaw, i) > 255 {
			Set tWide = 1
			Quit
		}
	}
	Quit:tWide pRaw
	Try {
		Set tOut = $ZConvert(pRaw, "I", "UTF8")
	}
	Catch {
		// Not valid UTF-8 -- keep the bytes rather than lose the payload.
		Set tOut = pRaw
	}
	Return tOut
}

/// Write a response message as the JSON body.
ClassMethod WriteResponse(pResponse As %JSON.Adaptor) As %Status
{
	Set %response.ContentType = "application/json"
	Do pResponse.%JSONExport()
	Return $$$OK
}

/// Answer a 400 with the standard envelope.
ClassMethod BadRequest(pMessage As %String) As %Status
{
	Set %response.Status = ..#HTTP400BADREQUEST
	Return ..WriteEnvelope("400", pMessage)
}

/// Answer a 500 with the standard envelope.
ClassMethod ServerError(pMessage As %String) As %Status
{
	Set %response.Status = ..#HTTP500INTERNALSERVERERROR
	Return ..WriteEnvelope("500", pMessage)
}

/// Write a status envelope (used for error cases).
ClassMethod WriteEnvelope(pCode As %String, pMessage As %String) As %Status
{
	Set %response.ContentType = "application/json"
	Write {"response_code": (pCode), "response_message": (pMessage)}.%ToJSON()
	Return $$$OK
}

/// Audit line for the write paths, replacing the production's $$$LOGINFO.
ClassMethod Log(pMessage As %String)
{
	Do ##class(%SYS.System).WriteToConsoleLog("[D1.REST] " _ pMessage)
}

}
