/// Data Transformation: raw HIS PAAdm (episode) row -> D1 GetAdmission V1.0.3.
/// The whole response comes from this one transform (single HIS resource).
/// 
/// ward_type is mapped from CARETYPDesc (care type) on the same episode read
/// -- a BEST GUESS, not a confirmed equivalence. Verify with the client.
Class D1.Mock.DT.PAAdmToAdmission Extends Ens.DataTransformDTL [ DependsOn = (D1.Mock.Msg.HIS.PAAdmResponse, D1.Mock.Msg.GetAdmissionResponse) ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='D1.Mock.Msg.HIS.PAAdmResponse' targetClass='D1.Mock.Msg.GetAdmissionResponse' create='existing' language='objectscript'>
<assign value='"200"' property='target.ResponseCode' action='set' />
<assign value='"Success"' property='target.ResponseMessage' action='set' />
<assign value='source.Results.(1).RegNo' property='target.HospitalNumber' action='set' />
<assign value='source.Results.(1).PAADMADMNo' property='target.VisitNumber' action='set' />
<assign value='source.Results.(1).PAADMADMNo' property='target.AdmissionInfo.AdmissionNumber' action='set' >
<annotation>Same PAADMADMNo under both names -- one episode numbering series.</annotation>
</assign>
<assign value='##class(D1.Mock.BP.PatientMapper).IsoDateTime(source.Results.(1).PAADMAdmDate,source.Results.(1).PAADMAdmTime)' property='target.AdmissionInfo.AdmissionDate' action='set' />
<assign value='source.Results.(1).WARDDesc' property='target.AdmissionInfo.WardNumber' action='set' >
<annotation>Pinned: ward description accepted for the demo instead of PAAdmDischarge's ward code.</annotation>
</assign>
<assign value='##class(D1.Mock.Util.WardResolver).ResolveWardType(source.Results.(1).WARDDesc,source.Results.(1).CARETYPDesc)' property='target.AdmissionInfo.WardType' action='set' >
<annotation>STOPGAP: ward_type from the IRIS-owned ward master (D1_Mock_Ref.WardMaster), keyed on the episode's ward; CARETYPDesc only if that ward has no row. TrakCare has no ward_type field, so both are asserted, not sourced.</annotation>
</assign>
<assign value='source.Results.(1).ROOMTDesc' property='target.AdmissionInfo.RoomType' action='set' />
<assign value='source.Results.(1).BEDCode' property='target.AdmissionInfo.BedNo' action='set' />
<assign value='##class(D1.Mock.BP.PatientMapper).IsoDateTime(source.Results.(1).EstDschrgDate,"")' property='target.AdmissionInfo.ExpectedDischargeDate' action='set' />
<assign value='##class(D1.Mock.BP.PatientMapper).IsoDateTime(source.Results.(1).PAADMDischgDate,"")' property='target.AdmissionInfo.ActualDischargeDate' action='set' >
<annotation>Pinned: PHYSICAL discharge date, not medical or financial.</annotation>
</assign>
</transform>
}

}
