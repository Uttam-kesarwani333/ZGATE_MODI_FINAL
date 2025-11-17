@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for Gate Number'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory: #M,
    dataClass: #MIXED
}
define view entity zge_i_genum 
  as select from zge_i_head
{
  key GateNumber,
      GateType,
      GateStatus,
      PurchasingDoc,
      Supplier,
      Plant,
      VehichleNo,
      CreatedOn
}
