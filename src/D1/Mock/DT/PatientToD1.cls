/// Data Transformation: raw HIS Patient resource -> D1 GetPatient V1.0.3.
/// 
/// THE anti-corruption boundary for demographics: the only place raw
/// PAPER*/CT* names become D1's clean contract. Shape fixes stay visible as
/// mapping lines: gender lower-cased, DOB reformatted to yyyy-MM-dd HH:mm:ss,
/// street+city joined.
/// 
/// create='existing' -- writes into the response object the BPL passes in.
Class D1.Mock.DT.PatientToD1 Extends Ens.DataTransformDTL [ DependsOn = (D1.Mock.Msg.HIS.PatientResponse, D1.Mock.Msg.GetPatientResponse) ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='D1.Mock.Msg.HIS.PatientResponse' targetClass='D1.Mock.Msg.GetPatientResponse' create='existing' language='objectscript'>
<assign value='"200"' property='target.ResponseCode' action='set' />
<assign value='"Success"' property='target.ResponseMessage' action='set' />
<assign value='source.Results.RegistrationNumber' property='target.Patient.HospitalNumber' action='set' />
<assign value='source.Results.PAPERResidentNumber' property='target.Patient.CitizenId' action='set' >
<annotation>Best-guess raw source for the citizen ID (documented gap).</annotation>
</assign>
<assign value='source.Results.PAPERPassportNumber' property='target.Patient.PassportId' action='set' />
<assign value='source.Results.TTLDesc' property='target.Patient.Title' action='set' />
<assign value='source.Results.PAPERName2' property='target.Patient.FirstName' action='set' >
<annotation>PAPERName2 is TrakCare's Given Name.</annotation>
</assign>
<assign value='source.Results.PAPERName' property='target.Patient.LastName' action='set' >
<annotation>PAPERName is TrakCare's Surname -- not a surname.</annotation>
</assign>
<assign value='$ZCONVERT(source.Results.CTSEXDesc,"L")' property='target.Patient.Gender' action='set' >
<annotation>Shape fix: HIS "Male"/"Female" -> D1 lower-case gender.</annotation>
</assign>
<assign value='##class(D1.Mock.BP.PatientMapper).IsoDateTime(source.Results.PAPERDob,"")' property='target.Patient.BirthDate' action='set' >
<annotation>Shape fix: HIS DD/MM/YYYY -> yyyy-MM-dd HH:mm:ss.</annotation>
</assign>
<assign value='##class(D1.Mock.BP.PatientMapper).JoinAddress(source.Results.PAPERStName,source.Results.CTCITDesc)' property='target.Patient.Address' action='set' >
<annotation>Shape fix: street + city joined into one address line.</annotation>
</assign>
<assign value='source.Results.PAPERMobPhone' property='target.Patient.PhoneNumber' action='set' />
</transform>
}

}
