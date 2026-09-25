/// Persists an API_PostFiles payload: base64 source_file decoded into
/// ClaimFile.FileContent, one row per source_info[] entry.
/// 
/// Decoding is chunked on 4-char boundaries (4 base64 chars = 3 bytes) so a
/// large attachment survives the string-length limit.
Class D1.Mock.BO.PostFilesOperation Extends Ens.BusinessOperation
{

Parameter ADAPTER;

Parameter INVOCATION = "Queue";

/// Base64 characters decoded per pass. A multiple of 4 so each chunk is a
/// whole number of encoded groups.
Parameter DECODECHUNK = 32000;

Method Store(pRequest As D1.Mock.Msg.PostFilesRequest, Output pResponse As D1.Mock.Msg.PostFilesResponse) As %Status
{
	Set pResponse = ##class(D1.Mock.Msg.PostFilesResponse).%New()
	Set tSC = $$$OK
	Try {
		Set tErr = ..Validate(pRequest)
		If tErr '= "" {
			Set pResponse.ResponseCode = "400"
			Set pResponse.ResponseMessage = tErr
			Quit
		}

		For i = 1:1:pRequest.SourceInfo.Count() {
			Set tEntry = pRequest.SourceInfo.GetAt(i)
			// Upsert so a resend replaces rather than duplicates.
			Set tFile = ..OpenOrNew(pRequest.AdmissionNumber, tEntry.SourceId)
			Set tFile.SourceId = tEntry.SourceId
			Set tFile.AdmissionNumber = pRequest.AdmissionNumber
			Set tFile.HospitalNumber = pRequest.HospitalNumber
			Set tFile.SourceName = tEntry.SourceName
			Set tFile.SourceType = tEntry.SourceType
			Set tFile.UpdateDate = pRequest.UpdateDate
			$$$THROWONERROR(tSC, ..DecodeInto(tFile.FileContent, tEntry.SourceFile))
			$$$THROWONERROR(tSC, tFile.%Save())
		}

		$$$LOGINFO("Stored " _ pRequest.SourceInfo.Count() _ " file(s) for admission_number " _ pRequest.AdmissionNumber)
		Set pResponse.ResponseCode = "200"
		Set pResponse.ResponseMessage = "Success"
	}
	Catch ex {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

/// The stored row for this file, or a new one. Kept separate so the upsert
/// intent reads clearly at the call site.
ClassMethod OpenOrNew(pAdmissionNumber As %String, pSourceId As %String) As D1.Mock.Data.ClaimFile [ Private ]
{
	Set tId = ""
	&sql(SELECT ID INTO :tId FROM D1_Mock_Data.ClaimFile WHERE AdmissionNumber = :pAdmissionNumber AND SourceId = :pSourceId)
	If SQLCODE = 0 {
		Set tFile = ##class(D1.Mock.Data.ClaimFile).%OpenId(tId)
		Quit:$IsObject(tFile) tFile
	}
	Quit ##class(D1.Mock.Data.ClaimFile).%New()
}

/// Decode base64 text into a binary stream, replacing whatever it held.
/// Chunked on 4-character boundaries so large attachments survive the
/// string-length limit.
ClassMethod DecodeInto(pStream As %Stream.Object, pBase64 As %String) As %Status [ Private ]
{
	Do pStream.Clear()
	Quit:pBase64="" $$$OK
	// Encoders wrap base64 across lines; newlines would corrupt the decode.
	Set tClean = $Translate(pBase64, $Char(13, 10, 9, 32), "")
	Set tLen = $Length(tClean)
	For tPos = 1:..#DECODECHUNK:tLen {
		Set tChunk = $Extract(tClean, tPos, tPos + ..#DECODECHUNK - 1)
		Set tSC = pStream.Write($System.Encryption.Base64Decode(tChunk))
		Quit:$$$ISERR(tSC)
	}
	Quit $Get(tSC, $$$OK)
}

/// Validate against the spec's Mandatory column: "" when good, otherwise the
/// message that goes back to D1 in the 400 envelope.
ClassMethod Validate(pRequest As D1.Mock.Msg.PostFilesRequest) As %String
{
	Quit:'$IsObject(pRequest) "Empty request"
	Quit:pRequest.CrudStatus="" "crud_status is required"
	Quit:(pRequest.CrudStatus'="0")&&(pRequest.CrudStatus'="1") "crud_status must be ""0"" (insert) or ""1"" (update)"
	Quit:pRequest.HospitalNumber="" "hospital_number is required"
	Quit:pRequest.AdmissionNumber="" "admission_number is required"
	Quit:pRequest.SourceInfo.Count()<1 "source_info is required"
	For i = 1:1:pRequest.SourceInfo.Count() {
		If pRequest.SourceInfo.GetAt(i).SourceId = "" {
			Return "source_info[" _ i _ "].source_id is required"
		}
	}
	Quit ""
}

XData MessageMap
{
<MapItems>
  <MapItem MessageType="D1.Mock.Msg.PostFilesRequest">
    <Method>Store</Method>
  </MapItem>
</MapItems>
}

}
