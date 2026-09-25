/// Data Transformation: raw HIS CTCareProv practitioner row -> D1 GetVisit's
/// attending_physician block. Appends onto the response the VisitMapper BPL
/// carries (create='existing').
/// 
/// CTCPTitle / CTPCPSMCNo are high population risk on real sites -- both
/// nullable in the D1 contract; empty raw values pass through as empty.
Class D1.Mock.DT.CareProviderToVisitPhysician Extends Ens.DataTransformDTL [ DependsOn = (D1.Mock.Msg.HIS.CareProviderResponse, D1.Mock.Msg.GetVisitResponse) ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='D1.Mock.Msg.HIS.CareProviderResponse' targetClass='D1.Mock.Msg.GetVisitResponse' create='existing' language='objectscript'>
<assign value='source.Results.(1).CTPCPCode' property='target.AttendingPhysician.Id' action='set' />
<assign value='source.Results.(1).CTPCPTitle' property='target.AttendingPhysician.Title' action='set' />
<assign value='source.Results.(1).CTPCPFirstName' property='target.AttendingPhysician.FirstName' action='set' />
<assign value='source.Results.(1).CTPCPSurname' property='target.AttendingPhysician.LastName' action='set' />
<assign value='source.Results.(1).CTPCPSMCNo' property='target.AttendingPhysician.LicenseNo' action='set' />
</transform>
}

}
