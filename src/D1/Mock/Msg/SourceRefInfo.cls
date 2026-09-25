/// One source_info[] entry in API_PostDischarge V1.0.3 -- still a URL
/// REFERENCE (source_url), unlike PostFiles which moved to base64 content in
/// the same revision. A flagged spec inconsistency, built as written rather
/// than normalized (plan open item 9).
Class D1.Mock.Msg.SourceRefInfo Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor)
{

/// Attach file ID, e.g. "PDF01"
Property SourceId As %String(%JSONFIELDNAME = "source_id", MAXLEN = 50);

/// Attach file name, e.g. "RAMA9_receipt"
Property SourceName As %String(%JSONFIELDNAME = "source_name", MAXLEN = 255);

/// Attach file type, e.g. ".pdf"
Property SourceType As %String(%JSONFIELDNAME = "source_type", MAXLEN = 50);

/// Attach file URL, e.g. "/data1/source/(auth_id)/"
Property SourceUrl As %String(%JSONFIELDNAME = "source_url", MAXLEN = 500);

Storage Default
{
<Data name="SourceRefInfoState">
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
<Value>SourceUrl</Value>
</Value>
</Data>
<State>SourceRefInfoState</State>
<StreamLocation>^D1.Mock.Msg.SourceRefInfoS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
