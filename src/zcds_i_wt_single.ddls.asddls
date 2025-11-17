@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS view for Weight single'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zcds_i_wt_single
  as select from zcds_tf_gate_wt
{
  key GateNumber,
  key ItemNumber,
      packingunit,
      GrossWeight,
      TareWeight,
      NetWeight,
      VendorGrossWeight,
      VendorTareWeight,
      row_no
}
