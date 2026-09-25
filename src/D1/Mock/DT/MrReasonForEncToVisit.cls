/// Data Transformation: raw HIS MRReasonForEnc row -> D1 GetVisit's
/// complaint_info block.
/// 
/// DescSnomed as the chief_complaint source is a BEST GUESS from a single
/// Postman example -- unverified against real data (plan open item 8);
/// Comments is the documented free-text fallback if it proves unsuitable.
Class D1.Mock.DT.MrReasonForEncToVisit Extends Ens.DataTransformDTL [ DependsOn = (D1.Mock.Msg.HIS.MrReasonForEncResponse, D1.Mock.Msg.GetVisitResponse) ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='D1.Mock.Msg.HIS.MrReasonForEncResponse' targetClass='D1.Mock.Msg.GetVisitResponse' create='existing' language='objectscript'>
<assign value='source.Results.(1).DescSnomed' property='target.ComplaintInfo.ChiefComplaint' action='set' >
<annotation>Best-guess raw source, unverified against real TrakCare data.</annotation>
</assign>
</transform>
}

}
