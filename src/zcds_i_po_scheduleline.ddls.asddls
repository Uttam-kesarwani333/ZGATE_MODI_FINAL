@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS view for PO schedule Line'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory: #M,
    dataClass: #MIXED
}
define view entity zcds_i_po_scheduleline
  as select from I_PurOrdScheduleLineAPI01
{
  key cast( PurchaseOrder as ebeln preserving type )             as PurchaseOrder,
  key cast( PurchaseOrderItem as ebelp preserving type )         as PurchaseOrderItem,
      //  key PurchaseOrderScheduleLine,
      @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
      sum( ScheduleLineOrderQuantity )                           as ScheduleLineOrderQuantity,
      @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
      sum( RoughGoodsReceiptQty )                                as RoughGoodsReceiptQty,
      cast( PurchaseOrderQuantityUnit as meins preserving type ) as PurchaseOrderQuantityUnit
}
group by
  PurchaseOrder,
  PurchaseOrderItem,
  PurchaseOrderQuantityUnit
