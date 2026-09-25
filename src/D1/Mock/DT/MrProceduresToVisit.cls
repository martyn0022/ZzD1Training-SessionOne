/// Data Transformation: raw HIS MRProcedures rows -> D1 GetVisit's
/// procedure_info[] -- the one genuinely-repeating block on the visit.
Class D1.Mock.DT.MrProceduresToVisit Extends Ens.DataTransformDTL [ DependsOn = (D1.Mock.Msg.HIS.MrProceduresResponse, D1.Mock.Msg.GetVisitResponse) ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='D1.Mock.Msg.HIS.MrProceduresResponse' targetClass='D1.Mock.Msg.GetVisitResponse' create='existing' language='objectscript'>
<foreach property='source.Results' key='k1' >
<assign value='source.Results.(k1).OPERCode' property='target.ProcedureInfo.(k1).ProcedureCode' action='set' />
<assign value='source.Results.(k1).OPERDesc' property='target.ProcedureInfo.(k1).ProcedureName' action='set' />
</foreach>
</transform>
}

}
