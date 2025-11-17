@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS view for Gate PO Qty'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory: #M,
    dataClass: #MIXED
}
define view entity zcds_i_gate_po_qty
  as select from zge_i_head as _Head
  association [0..1] to zge_i_item as _Item on $projection.GateNumber = _Item.GateNumber
{
  key _Head.GateNumber        as GateNumber,
  key _Item.ItemNumber        as ItemNumber,
      PurchasingDoc           as PurchasingDoc,
      _Item.PurchaseOrderItem as PurchaseOrderItem,
      _Item.Matnr             as Material,
      @Semantics.quantity.unitOfMeasure : 'Meins'
      _Item.QtyReceived       as QtyRecieved,
      _Item.Uom             as Meins
}
where
        IsCancelled  != 'X'
//  and   not(
//      GateStatus     =  'Close'
//      and TareWeight =  0.00
//    )
