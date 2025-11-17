@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS view for Gate PO Qty min'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory: #M,
    dataClass: #MIXED
}
define view entity zcds_i_gate_po_qty_min
  as select from zcds_i_gate_po_qty
{
  key PurchasingDoc,
  key PurchaseOrderItem,
      @Semantics.quantity.unitOfMeasure : 'Meins'
      sum( QtyRecieved ) as TotalGeQty,
      Meins
}
group by
  PurchasingDoc,
  PurchaseOrderItem,
  Meins
