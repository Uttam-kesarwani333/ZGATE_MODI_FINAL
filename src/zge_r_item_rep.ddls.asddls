@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Item Entiry'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory: #M,
    dataClass: #MIXED
}
define view entity ZGE_R_ITEM_REP 
  as select from zge_i_item_rep
 association        to parent ZGE_R_HEAD_REP as _Head on $projection.GateNumber = _Head.GateNumber

  association [0..1] to ZGE_I_Product     as _Mat  on $projection.Material = _Mat.Material
{
  key GateNumber,
  key ItemNumber,
//      PurchasingDoc,
//      PurchaseOrderItem,
      Matnr as Material,
      Maktx as MaterialDescription,
      QtyOrdered,
      QtyReceived,
      TotalGeQty,
      Meins,
      Uom,
//      Tolerance,
      Werks,
//      QtyOut,
//      QtyIn,
//      ItemRemark,
      _Head,
      _Mat
}
