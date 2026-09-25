/// Group-2 file_info table (data dictionary V1.0.2). Written by PostFiles;
/// one row per attached file.
/// 
/// V1.0.2 dropped the source_url column and API_PostFiles V1.0.3 sends
/// source_file (base64) instead -- the decoded BYTES are stored here in a
/// binary stream, matching the API's own description ("Record into Database")
/// literally. AdmissionNumber is indexed non-unique: multiple files per
/// admission is the realistic case despite the sheet listing it as PK.
Class D1.Mock.Data.ClaimFile Extends %Persistent
{

/// Attach file ID, e.g. "PDF01"
Property SourceId As %String(MAXLEN = 50) [ Required ];

Property AdmissionNumber As %String(MAXLEN = 50) [ Required ];

Index AdmissionIdx On AdmissionNumber;

Index SourceIdx On (AdmissionNumber, SourceId) [ Unique ];

Property HospitalNumber As %String(MAXLEN = 50);

/// e.g. "RAMA9_receipt"
Property SourceName As %String(MAXLEN = 255);

/// e.g. "pdf"
Property SourceType As %String(MAXLEN = 50);

/// The decoded file bytes (sent base64 on the wire)
Property FileContent As %Stream.GlobalBinary;

Property UpdateDate As %String(MAXLEN = 30);

Storage Default
{
<Data name="ClaimFileDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>SourceId</Value>
</Value>
<Value name="3">
<Value>AdmissionNumber</Value>
</Value>
<Value name="4">
<Value>HospitalNumber</Value>
</Value>
<Value name="5">
<Value>SourceName</Value>
</Value>
<Value name="6">
<Value>SourceType</Value>
</Value>
<Value name="7">
<Value>FileContent</Value>
</Value>
<Value name="8">
<Value>UpdateDate</Value>
</Value>
</Data>
<DataLocation>^D1.Mock.Data.ClaimFileD</DataLocation>
<DefaultData>ClaimFileDefaultData</DefaultData>
<IdLocation>^D1.Mock.Data.ClaimFileD</IdLocation>
<IndexLocation>^D1.Mock.Data.ClaimFileI</IndexLocation>
<StreamLocation>^D1.Mock.Data.ClaimFileS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
