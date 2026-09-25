/// Data Transformation: raw HIS CTLoc row -> D1 GetVisit's department
/// code/name -- the PINNED source pairing (CTLOCCode/CTLOCDesc), not
/// PAAdm.DEPDesc which is the department-group concept.
Class D1.Mock.DT.CtLocToVisitDepartment Extends Ens.DataTransformDTL [ DependsOn = (D1.Mock.Msg.HIS.CtLocResponse, D1.Mock.Msg.GetVisitResponse) ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='D1.Mock.Msg.HIS.CtLocResponse' targetClass='D1.Mock.Msg.GetVisitResponse' create='existing' language='objectscript'>
<assign value='source.Results.(1).CTLOCCode' property='target.VisitInfo.DepartmentCode' action='set' >
<annotation>Nullable on real sites -- sparse location code tables return blanks.</annotation>
</assign>
<assign value='source.Results.(1).CTLOCDesc' property='target.VisitInfo.DepartmentName' action='set' />
</transform>
}

}
