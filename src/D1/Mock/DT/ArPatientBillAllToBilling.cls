/// Data Transformation: raw HIS ARPatientBillAll row -> D1 GetBilling V1.0.3.
/// The BO has already filtered Results to the requested admission's rows.
/// 
/// currency is NOT assigned here: no currency field exists anywhere on the raw
/// resource (exhaustively verified). The BillingMapperOperation assigns it
/// from its SETTINGS-exposed DefaultCurrency after this transform runs --
/// config-sourced, never mapped.
Class D1.Mock.DT.ArPatientBillAllToBilling Extends Ens.DataTransformDTL [ DependsOn = (D1.Mock.Msg.HIS.BillingResponse, D1.Mock.Msg.GetBillingResponse) ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='D1.Mock.Msg.HIS.BillingResponse' targetClass='D1.Mock.Msg.GetBillingResponse' create='existing' language='objectscript'>
<assign value='"200"' property='target.ResponseCode' action='set' />
<assign value='"Success"' property='target.ResponseMessage' action='set' />
<assign value='source.Results.(1).GrossAmount' property='target.BillingInfo.TotalCharge' action='set' />
<assign value='source.Results.(1).DiscTotal' property='target.BillingInfo.DiscountAmount' action='set' />
<assign value='source.Results.(1).NetAmount' property='target.BillingInfo.NetCharge' action='set' />
<assign value='source.Results.(1).PatInvTot' property='target.BillingInfo.PatientPayable' action='set' >
<annotation>Invoiced amount, not the outstanding balance.</annotation>
</assign>
<assign value='source.Results.(1).PayorInvTot' property='target.BillingInfo.InsurancePayable' action='set' />
</transform>
}

}
