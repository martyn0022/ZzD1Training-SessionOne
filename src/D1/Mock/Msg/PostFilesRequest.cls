/// Request message for API_PostFiles V1.0.3 (D1 Service -> IRIS).
/// 
/// V1.0.3 flattened the claim_info[]/admission_info[] wrappers to top-level
/// scalars and swapped source_url for base64 source_file content.
/// 
/// No [ Required ] markers: a missing field must come back as a 400 envelope
/// from the operation, not an Ensemble message-save failure.
Class D1.Mock.Msg.PostFilesRequest Extends (Ens.Request, %JSON.Adaptor)
{

/// "0" - Insert, "1" - Update
Property CrudStatus As %String(%JSONFIELDNAME = "crud_status", MAXLEN = 1);

Property HospitalNumber As %String(%JSONFIELDNAME = "hospital_number", MAXLEN = 50);

Property AdmissionNumber As %String(%JSONFIELDNAME = "admission_number", MAXLEN = 50);

/// One entry per attached file, each carrying base64 content
Property SourceInfo As list Of D1.Mock.Msg.SourceFileInfo(%JSONFIELDNAME = "source_info");

Property UpdateDate As %String(%JSONFIELDNAME = "update_date", MAXLEN = 30);

Storage Default
{
<Data name="PostFilesRequestDefaultData">
<Subscript>"PostFilesRequest"</Subscript>
<Value name="1">
<Value>CrudStatus</Value>
</Value>
<Value name="2">
<Value>HospitalNumber</Value>
</Value>
<Value name="3">
<Value>AdmissionNumber</Value>
</Value>
<Value name="4">
<Value>SourceInfo</Value>
</Value>
<Value name="5">
<Value>UpdateDate</Value>
</Value>
</Data>
<DefaultData>PostFilesRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
