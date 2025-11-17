@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'cds view for GRN item'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory: #M,
    dataClass: #MIXED
}
define view entity zge_r_grn_item 
  as select from zge_i_item
  association        to parent zge_r_grn_head as _Head on $projection.GateNumber = _Head.GateNumber
  association [0..1] to ZGE_I_Product         as _Mat  on $projection.Material = _Mat.Material

{
  key GateNumber,
  key ItemNumber,
      PurchasingDoc,
      PurchaseOrderItem,
      Matnr as Material,
      Maktx as MaterialDescription,
      StorageLocation,
      Batch,
      QtyOrdered,
      QtyReceived,
      TotalGeQty,
      Meins,
      Uom,
      Tolerance,
      Werks,
      _Head,
      _Mat
}
