/// One flat row per pre-authorization submission -- the full-fidelity archive
/// of the raw payload. The same submission is also projected into the group-2
/// tables that API_D1GetPreAuthInfo actually reads (see PreAuthStoreOperation).
/// 
/// Single-valued wire objects get ordinary columns; the three genuinely
/// repeating arrays (procedure_info, diagnosis, benefits) get columns holding
/// every entry joined by DELIMITER, positionally aligned.
/// 
/// Dates stored verbatim; only ClaimAge and EstimatedCost are numeric.
Class D1.Mock.Data.PreAuthSubmission Extends %Persistent
{

/// Separator between entries in the joined array columns. A space either side
/// so it stays readable in Thai and English values alike.
Parameter DELIMITER = " | ";

/// Admission Number -- the submission key (from admission.admission_number)
Property AdmissionNumber As %String(MAXLEN = 50) [ Required ];

Index AdmissionIdx On AdmissionNumber [ Unique ];

/// auth_id as sent, e.g. "REQ000000P1" (may be empty on insert)
Property AuthId As %String(MAXLEN = 50);

Property HospitalCode As %String(MAXLEN = 50);

/// crud_status as sent on the request that produced this row
Property CrudStatus As %String(MAXLEN = 1);

/// auth_status as sent (V1.0.6) -- also projected onto ClaimPreAuth.ClaimStatus
Property AuthStatus As %String(MAXLEN = 50);

Property SubmitDate As %String(MAXLEN = 30);

Property UpdateDate As %String(MAXLEN = 30);

/// When IRIS actually stored the row (ODBC timestamp)
Property ReceivedAt As %TimeStamp;

// --- person (single object) ---

Property PersonHospitalNumber As %String(MAXLEN = 50);

Property PersonVisitNumber As %String(MAXLEN = 50);

/// Stripped of dashes to fit the data dictionary's varchar(13) -- the wire
/// value ("3-1258-00558-89-8") is 18 characters; only PersonHospitalNumber
/// and the other person fields keep this row's raw-archive fidelity.
Property CitizenId As %String(MAXLEN = 13);

Property PassportId As %String(MAXLEN = 30);

Property ClaimTitle As %String(MAXLEN = 20);

Property ClaimFirstName As %String(MAXLEN = 100);

Property ClaimLastName As %String(MAXLEN = 100);

Property ClaimGender As %String(MAXLEN = 20);

/// Wire format yyyy-MM-dd HH:mm:ss, stored verbatim
Property ClaimBirthdate As %String(MAXLEN = 20);

Property ClaimAge As %Integer;

// --- complaint_info (single object) ---

Property ChiefComplaint As %String(MAXLEN = 255);

// --- procedure_info[] (every entry, joined by DELIMITER) ---

Property ProcedureCodes As %String(MAXLEN = 500);

Property ProcedureNames As %String(MAXLEN = 2000);

// --- diagnosis[] (every entry, joined by DELIMITER) ---

Property DiagnosisTypes As %String(MAXLEN = 500);

Property DiagnosisCodes As %String(MAXLEN = 500);

Property DiagnosisNames As %String(MAXLEN = 2000);

// --- policies (single object in V1.0.3 -- plain scalar columns) ---

Property PolicyId As %String(MAXLEN = 50);

Property PlanCode As %String(MAXLEN = 50);

Property PlanName As %String(MAXLEN = 200);

Property PolicyNumber As %String(MAXLEN = 50);

// --- benefits[] (every entry, joined by DELIMITER) ---

Property BenefitCodes As %String(MAXLEN = 500);

Property BenefitNames As %String(MAXLEN = 1000);

// --- attending_physician (single object) ---

Property PhysicianId As %String(MAXLEN = 50);

Property PhysicianTitle As %String(MAXLEN = 20);

Property PhysicianFirstName As %String(MAXLEN = 100);

Property PhysicianLastName As %String(MAXLEN = 100);

Property MedicalLicenseNo As %String(MAXLEN = 50);

// --- admission (single object) ---

Property WardNumber As %String(MAXLEN = 100);

Property WardType As %String(MAXLEN = 50);

/// Room type / ward, e.g. "สามัญ ห้องรวม"
Property RoomType As %String(MAXLEN = 100);

Property BedNo As %String(MAXLEN = 50);

Property EstimatedAdmissionDate As %String(MAXLEN = 20);

Property EstimatedLengthOfStay As %String(MAXLEN = 10);

/// Sent quoted and possibly with thousands separators; stored numeric.
Property EstimatedCost As %Numeric(SCALE = 2);

/// True if a submission is already stored for this admission number; the row
/// id comes back in pId so the caller can open and overwrite it.
ClassMethod AdmissionExists(pAdmissionNumber As %String, Output pId As %String) As %Boolean
{
	Set pId = ""
	Quit:pAdmissionNumber="" 0
	&sql(SELECT ID INTO :pId FROM D1_Mock_Data.PreAuthSubmission WHERE AdmissionNumber = :pAdmissionNumber)
	Quit:SQLCODE'=0 0
	Quit 1
}

Storage Default
{
<Data name="PreAuthSubmissionDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>AdmissionNumber</Value>
</Value>
<Value name="3">
<Value>AuthId</Value>
</Value>
<Value name="4">
<Value>HospitalCode</Value>
</Value>
<Value name="5">
<Value>CrudStatus</Value>
</Value>
<Value name="6">
<Value>SubmitDate</Value>
</Value>
<Value name="7">
<Value>UpdateDate</Value>
</Value>
<Value name="8">
<Value>ReceivedAt</Value>
</Value>
<Value name="9">
<Value>PersonHospitalNumber</Value>
</Value>
<Value name="10">
<Value>PersonVisitNumber</Value>
</Value>
<Value name="11">
<Value>CitizenId</Value>
</Value>
<Value name="12">
<Value>PassportId</Value>
</Value>
<Value name="13">
<Value>ClaimTitle</Value>
</Value>
<Value name="14">
<Value>ClaimFirstName</Value>
</Value>
<Value name="15">
<Value>ClaimLastName</Value>
</Value>
<Value name="16">
<Value>ClaimGender</Value>
</Value>
<Value name="17">
<Value>ClaimBirthdate</Value>
</Value>
<Value name="18">
<Value>ClaimAge</Value>
</Value>
<Value name="19">
<Value>ChiefComplaint</Value>
</Value>
<Value name="20">
<Value>ProcedureCodes</Value>
</Value>
<Value name="21">
<Value>ProcedureNames</Value>
</Value>
<Value name="22">
<Value>DiagnosisTypes</Value>
</Value>
<Value name="23">
<Value>DiagnosisCodes</Value>
</Value>
<Value name="24">
<Value>DiagnosisNames</Value>
</Value>
<Value name="25">
<Value>PolicyId</Value>
</Value>
<Value name="26">
<Value>PlanCode</Value>
</Value>
<Value name="27">
<Value>PlanName</Value>
</Value>
<Value name="28">
<Value>PolicyNumber</Value>
</Value>
<Value name="29">
<Value>BenefitCodes</Value>
</Value>
<Value name="30">
<Value>BenefitNames</Value>
</Value>
<Value name="31">
<Value>PhysicianId</Value>
</Value>
<Value name="32">
<Value>PhysicianTitle</Value>
</Value>
<Value name="33">
<Value>PhysicianFirstName</Value>
</Value>
<Value name="34">
<Value>PhysicianLastName</Value>
</Value>
<Value name="35">
<Value>MedicalLicenseNo</Value>
</Value>
<Value name="36">
<Value>WardNumber</Value>
</Value>
<Value name="37">
<Value>WardType</Value>
</Value>
<Value name="38">
<Value>RoomType</Value>
</Value>
<Value name="39">
<Value>BedNo</Value>
</Value>
<Value name="40">
<Value>EstimatedAdmissionDate</Value>
</Value>
<Value name="41">
<Value>EstimatedLengthOfStay</Value>
</Value>
<Value name="42">
<Value>EstimatedCost</Value>
</Value>
<Value name="43">
<Value>AuthStatus</Value>
</Value>
</Data>
<DataLocation>^D1.Mock.Data.PreAuthSubm8753D</DataLocation>
<DefaultData>PreAuthSubmissionDefaultData</DefaultData>
<IdLocation>^D1.Mock.Data.PreAuthSubm8753D</IdLocation>
<IndexLocation>^D1.Mock.Data.PreAuthSubm8753I</IndexLocation>
<StreamLocation>^D1.Mock.Data.PreAuthSubm8753S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
