/// Request message for API_D1GetDischargeInfo V1.0.3 -- same date-range +
/// optional-identity shape as D1GetPreAuthInfo.
Class D1.Mock.Msg.D1GetDischargeInfoRequest Extends (Ens.Request, %JSON.Adaptor)
{

/// Range start, e.g. "2026-07-01 00:00:00"
Property StartReqDate As %String(%JSONFIELDNAME = "start_reqdate", MAXLEN = 30) [ Required ];

/// Range end, e.g. "2026-07-09 00:00:00"
Property EndReqDate As %String(%JSONFIELDNAME = "end_reqdate", MAXLEN = 30) [ Required ];

/// CID, PID, VN, HN, or AN
Property IdentityType As %String(%JSONFIELDNAME = "identity_type", MAXLEN = 10) [ Required ];

/// Optional per spec
Property IdentityNo As %String(%JSONFIELDNAME = "identity_no", MAXLEN = 50);

Property HospitalCode As %String(%JSONFIELDNAME = "hospital_code", MAXLEN = 50);

Storage Default
{
<Data name="D1GetDischargeInfoRequestDefaultData">
<Subscript>"D1GetDischargeInfoRequest"</Subscript>
<Value name="1">
<Value>StartReqDate</Value>
</Value>
<Value name="2">
<Value>EndReqDate</Value>
</Value>
<Value name="3">
<Value>IdentityType</Value>
</Value>
<Value name="4">
<Value>IdentityNo</Value>
</Value>
<Value name="5">
<Value>HospitalCode</Value>
</Value>
</Data>
<DefaultData>D1GetDischargeInfoRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
