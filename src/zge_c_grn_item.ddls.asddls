@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS composition for GRN item'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory: #M,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define view entity zge_c_grn_item 
as projection on zge_r_grn_item
{
    key GateNumber,
    key ItemNumber,
    PurchasingDoc,
    PurchaseOrderItem,
    Material,
    MaterialDescription,
    StorageLocation,
    Batch,
    QtyOrdered,
    QtyReceived,
    TotalGeQty,
    Meins,
    Uom,
    Tolerance,
    Werks,
    /* Associations */
    _Head : redirected to parent zge_c_grn_head,
    _Mat
}
