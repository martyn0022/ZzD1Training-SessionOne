/// Data Transformation: raw HIS PAAdm (episode) row -> D1 GetVisit V1.0.3
/// envelope + visit_info. The physician, department, complaint, and procedure
/// blocks are appended by sibling transforms chained in the VisitMapper BPL.
Class D1.Mock.DT.PAAdmToVisit Extends Ens.DataTransformDTL [ DependsOn = (D1.Mock.Msg.HIS.PAAdmResponse, D1.Mock.Msg.GetVisitResponse) ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='D1.Mock.Msg.HIS.PAAdmResponse' targetClass='D1.Mock.Msg.GetVisitResponse' create='existing' language='objectscript'>
<assign value='"200"' property='target.ResponseCode' action='set' />
<assign value='"Success"' property='target.ResponseMessage' action='set' />
<assign value='source.Results.(1).RegNo' property='target.HospitalNumber' action='set' />
<assign value='source.Results.(1).PAADMADMNo' property='target.VisitInfo.VisitNumber' action='set' />
<assign value='##class(D1.Mock.BP.PatientMapper).IsoDateTime(source.Results.(1).PAADMAdmDate,source.Results.(1).PAADMAdmTime)' property='target.VisitInfo.VisitDate' action='set' >
<annotation>Shape fix: HIS separate DD/MM/YYYY date + HH:MM time -> one yyyy-MM-dd HH:mm:ss.</annotation>
</assign>
<assign value='##class(D1.Mock.BP.PatientMapper).VisitType(source.Results.(1).PAADMType)' property='target.VisitInfo.VisitType' action='set' >
<annotation>Best-guess derivation: PAADMType I -> IPD, O -> OPD, E -> ER.</annotation>
</assign>
</transform>
}

}
