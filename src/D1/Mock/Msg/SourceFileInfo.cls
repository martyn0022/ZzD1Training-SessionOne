/// One source_info[] entry in API_PostFiles V1.0.3 -- carries the file
/// CONTENT as base64 (source_file), replacing V1.0.2's source_url path.
/// 
/// Deliberately separate from D1.Mock.Msg.SourceRefInfo (PostDischarge's
/// still-URL-shaped source_info[]): the same conceptual block uses two
/// different transports across the two sheets in this revision, a flagged
/// spec inconsistency built as written (plan open item 9).
Class D1.Mock.Msg.SourceFileInfo Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

/// Attach file ID, e.g. "PDF01"
Property SourceId As %String(%JSONFIELDNAME = "source_id", MAXLEN = 50);

/// Attach file name, e.g. "RAMA9_receipt"
Property SourceName As %String(%JSONFIELDNAME = "source_name", MAXLEN = 255);

/// Attach file type, e.g. "pdf"
Property SourceType As %String(%JSONFIELDNAME = "source_type", MAXLEN = 50);

/// Base64 file content, decoded to bytes by PostFilesOperation.
/// MAXLEN is IRIS's string ceiling (~2.7 MB decoded); for larger files switch
/// to %Stream.GlobalBinary, which %JSON.Adaptor base64-decodes on import.
Property SourceFile As %String(%JSONFIELDNAME = "source_file", MAXLEN = 3641144);

Storage Default
{
<Data name="SourceFileInfoState">
<Value name="1">
<Value>SourceId</Value>
</Value>
<Value name="2">
<Value>SourceName</Value>
</Value>
<Value name="3">
<Value>SourceType</Value>
</Value>
<Value name="4">
<Value>SourceFile</Value>
</Value>
</Data>
<State>SourceFileInfoState</State>
<StreamLocation>^D1.Mock.Msg.SourceFileInfoS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
