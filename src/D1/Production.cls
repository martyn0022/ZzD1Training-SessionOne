Class D1.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="D1.Production" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="Patient Service" Category="GetPatient" ClassName="D1.Mock.BS.PatientService" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="PostPreAuth Service" Category="PostPreAuth" ClassName="D1.Mock.BS.PostPreAuthService" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="Patient Mapper" Category="GetPatient" ClassName="D1.Mock.BP.PatientMapper" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="PreAuth Store Process" Category="PostPreAuth" ClassName="D1.Mock.BP.PreAuthStoreProcess" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="HIS Operation" Category="GetPatient,GetVisit,GetAdmission,GetDiagnosis,GetBilling" ClassName="D1.Mock.BO.HISOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="HTTPPort">80</Setting>
    <Setting Target="Adapter" Name="HTTPServer">webgateway</Setting>
    <Setting Target="Adapter" Name="Credentials">iris</Setting>
  </Item>
  <Item Name="Visit Service" Category="GetVisit" ClassName="D1.Mock.BS.VisitService" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="Visit Mapper" Category="GetVisit" ClassName="D1.Mock.BP.VisitMapper" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="Admission Service" Category="GetAdmission" ClassName="D1.Mock.BS.AdmissionService" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="Admission Mapper" Category="GetAdmission" ClassName="D1.Mock.BO.AdmissionMapperOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="Diagnosis Service" Category="GetDiagnosis" ClassName="D1.Mock.BS.DiagnosisService" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="Diagnosis Mapper" Category="GetDiagnosis" ClassName="D1.Mock.BP.DiagnosisMapper" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="Billing Service" Category="GetBilling" ClassName="D1.Mock.BS.BillingService" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="Billing Mapper" Category="GetBilling" ClassName="D1.Mock.BO.BillingMapperOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="PreAuth Store Operation" Category="PostPreAuth" ClassName="D1.Mock.BO.PreAuthStoreOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="D1GetPatient Service" Category="D1GetPatient" ClassName="D1.Mock.BS.D1GetPatientService" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="D1GetPatient Operation" Category="D1GetPatient" ClassName="D1.Mock.BO.D1GetPatientOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="D1GetPolicy Service" Category="D1GetPolicy" ClassName="D1.Mock.BS.D1GetPolicyService" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="D1GetPolicy Operation" Category="D1GetPolicy" ClassName="D1.Mock.BO.D1GetPolicyOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="D1GetBenefit Service" Category="D1GetBenefit" ClassName="D1.Mock.BS.D1GetBenefitService" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="D1GetBenefit Operation" Category="D1GetBenefit" ClassName="D1.Mock.BO.D1GetBenefitOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="D1GetPreAuthInfo Service" Category="D1GetPreAuthInfo" ClassName="D1.Mock.BS.D1GetPreAuthInfoService" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="D1GetPreAuthInfo Operation" Category="D1GetPreAuthInfo" ClassName="D1.Mock.BO.D1GetPreAuthInfoOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="D1GetAdmission Service" Category="D1GetAdmission" ClassName="D1.Mock.BS.D1GetAdmissionService" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="D1GetAdmission Operation" Category="D1GetAdmission" ClassName="D1.Mock.BO.D1GetAdmissionOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="D1GetDischargeInfo Service" Category="D1GetDischargeInfo" ClassName="D1.Mock.BS.D1GetDischargeInfoService" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="D1GetDischargeInfo Operation" Category="D1GetDischargeInfo" ClassName="D1.Mock.BO.D1GetDischargeInfoOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="PostFiles Service" Category="PostFiles" ClassName="D1.Mock.BS.PostFilesService" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="PostFiles Operation" Category="PostFiles" ClassName="D1.Mock.BO.PostFilesOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="PostDischarge Service" Category="PostDischarge" ClassName="D1.Mock.BS.PostDischargeService" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="PostDischarge Process" Category="PostDischarge" ClassName="D1.Mock.BP.PostDischargeProcess" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="PostDischarge Operation" Category="PostDischarge" ClassName="D1.Mock.BO.PostDischargeOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="PatchPreAuth Service" Category="PatchPreAuth" ClassName="D1.Mock.BS.PatchPreAuthService" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="PatchPreAuth Operation" Category="PatchPreAuth" ClassName="D1.Mock.BO.PatchPreAuthOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="PatchDischarge Service" Category="PatchDischarge" ClassName="D1.Mock.BS.PatchDischargeService" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="PatchDischarge Operation" Category="PatchDischarge" ClassName="D1.Mock.BO.PatchDischargeOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="GetRecordList Service" Category="GetRecordList" ClassName="D1.Mock.BS.GetRecordListService" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="GetRecordList Operation" Category="GetRecordList" ClassName="D1.Mock.BO.GetRecordListOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="GetDocumentInfo Service" Category="GetDocumentInfo" ClassName="D1.Mock.BS.GetDocumentInfoService" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="GetDocumentInfo Operation" Category="GetDocumentInfo" ClassName="D1.Mock.BO.GetDocumentInfoOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
</Production>
}

}
