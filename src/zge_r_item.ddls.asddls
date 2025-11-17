@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Item Entiry'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory: #M,
    dataClass: #MIXED
}
define view entity zge_r_item
  as select from zge_i_item
  association        to parent zge_r_head as _Head   on  $projection.GateNumber = _Head.GateNumber

  association [0..1] to ZGE_I_Product     as _Mat    on  $projection.Material = _Mat.Material
  association [0..1] to zge_i_purchase    as _PoItem on  $projection.PurchasingDoc     = _PoItem.PurchasingDoc
                                                     and $projection.PurchaseOrderItem = _PoItem.PurchaseOrderItem
{
  key GateNumber,
  key ItemNumber,
      PurchasingDoc,
      PurchaseOrderItem,
      Matnr as Material,
      Maktx as MaterialDescription,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      case
      when PurchasingDoc is initial then QtyOrdered
      else cast( _PoItem.OpenOrderQty as abap.quan(10,2) )
      end   as QtyOrdered,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      QtyReceived,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      case
      when PurchasingDoc is initial then TotalGeQty
      else _PoItem.TotalGeQty
      end   as TotalGeQty,
      //      TotalGeQty,
      Meins,
      Uom,
      Tolerance,
      Werks,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      QtyOut,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      QtyIn,
      ItemRemark,
      _Head,
      _Mat
}
