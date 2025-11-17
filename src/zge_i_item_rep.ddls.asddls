@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for Gate report Item'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory: #M,
    dataClass: #MIXED
}
define view entity zge_i_item_rep
  as select from zge_itm
{
  key gate_number                            as GateNumber,
  key item_number                            as ItemNumber,
//      ebeln                                  as PurchasingDoc,
//      ebelp                                  as PurchaseOrderItem,
      cast( matnr as matnr preserving type ) as Matnr,
      maktx                                  as Maktx,
      storage_location                       as StorageLocation,
      batch                                  as Batch,
      qty_ordered                            as QtyOrdered,
      qty_received                           as QtyReceived,
      total_ge_qty                           as TotalGeQty,
      meins                                  as Meins,
      uom                                    as Uom,
//      tolerance                              as Tolerance,
      werks                                  as Werks
//      qty_out                                as QtyOut,
//      qty_in                                 as QtyIn,
//      item_remark                            as ItemRemark
}
