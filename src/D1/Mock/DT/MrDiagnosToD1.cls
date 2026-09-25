/// Data Transformation: raw HIS MRDiagnos rows -> D1 GetDiagnosis V1.0.3's
/// diagnosis_info[] + envelope. The top-level echo fields (hospital_number /
/// visit_number / admission_number) are assigned by the DiagnosisMapper BPL
/// from the episode read, since they are not on the diagnosis rows.
/// 
/// Pinned mapping convention (matches the spec's own samples as written):
///   diagnosis_code = the terminology NAME (MRDIATerminologyDesc, "ICD-10-CM")
///   diagnosis_name = "<code> - <description>" concatenated
///   diagnosis_type = PRIMARY/SECONDARY derived from the Y/N principal flag
Class D1.Mock.DT.MrDiagnosToD1 Extends Ens.DataTransformDTL [ DependsOn = (D1.Mock.Msg.HIS.DiagnosisResponse, D1.Mock.Msg.GetDiagnosisResponse) ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='D1.Mock.Msg.HIS.DiagnosisResponse' targetClass='D1.Mock.Msg.GetDiagnosisResponse' create='existing' language='objectscript'>
<assign value='"200"' property='target.ResponseCode' action='set' />
<assign value='"Success"' property='target.ResponseMessage' action='set' />
<foreach property='source.Results' key='k1' >
<assign value='##class(D1.Mock.BP.PatientMapper).DiagnosisType(source.Results.(k1).MRDIAPrinciple)' property='target.DiagnosisInfo.(k1).DiagnosisType' action='set' >
<annotation>Best-guess enum derivation: Y -> PRIMARY, else SECONDARY.</annotation>
</assign>
<assign value='source.Results.(k1).MRDIATerminologyDesc' property='target.DiagnosisInfo.(k1).Code' action='set' />
<assign value='source.Results.(k1).MRCIDCode_" - "_source.Results.(k1).MRCIDDesc' property='target.DiagnosisInfo.(k1).Name' action='set' />
</foreach>
</transform>
}

}
