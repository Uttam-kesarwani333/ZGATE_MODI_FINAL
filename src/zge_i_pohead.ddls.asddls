@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for PO head'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory: #M,
    dataClass: #MIXED
}
define view entity zge_i_pohead
  as select from I_PurchaseOrderAPI01
 association [0..*] to zge_i_purchase as _PoItem on $projection.PurchasingDoc = _PoItem.PurchasingDoc
{
  key PurchaseOrder                             as PurchasingDoc,
      PurchaseOrderType                         as PoType,
      CreatedByUser,
      CreationDate,
      PurchaseOrderDate,
      cast( Supplier as lifnr preserving type ) as Supplier,
      _Supplier.SupplierName,
     _PoItem
}
