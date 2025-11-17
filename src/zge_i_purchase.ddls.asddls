@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for PO Item'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #M,
    dataClass: #MIXED
}
define view entity zge_i_purchase
  as select from I_PurchaseOrderItemAPI01
  association [0..1] to zge_i_pohead           as _PoHead     on  $projection.PurchasingDoc = _PoHead.PurchasingDoc
  association [0..1] to zcds_i_po_scheduleline as _Schedule   on  $projection.PurchasingDoc     = _Schedule.PurchaseOrder
                                                              and $projection.PurchaseOrderItem = _Schedule.PurchaseOrderItem
  association [0..1] to zcds_i_gate_po_qty_min as _TotalGeQty on  $projection.PurchasingDoc     = _TotalGeQty.PurchasingDoc
                                                              and $projection.PurchaseOrderItem = _TotalGeQty.PurchaseOrderItem
{
  key cast( PurchaseOrder as ebeln preserving type )                          as PurchasingDoc,
  key PurchaseOrderItem,
      cast( MaterialGroup as matkl preserving type )                          as MaterialGroup,
      cast( Material as matnr preserving type )                               as Material,
      cast( PurchaseOrderItemText as maktx preserving type )                  as MaterialDescription,
      cast( CompanyCode as bukrs preserving type )                            as CompanyCode,
      cast( Plant as werks_d preserving type )                                as Plant,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      OrderQuantity                                                           as PoQty,
      OverdelivTolrtdLmtRatioInPct                                            as Tolerance,
      cast( PurchaseOrderQuantityUnit as meins preserving type )              as Uom,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      //      coalesce(_OpenQty.OpenOrderQty, OrderQuantity )            as OpenOrderQty,
      _Schedule.ScheduleLineOrderQuantity - _Schedule.RoughGoodsReceiptQty    as OpenOrderQty,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      coalesce(_TotalGeQty.TotalGeQty, cast( '0.00' as abap.quan( 10,2 ) )  ) as TotalGeQty,
      _PoHead
}
where
  PurchasingDocumentDeletionCode = ''
