@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS view for SO schedule Line'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory: #M,
    dataClass: #MIXED
}
define view entity ZCDS_I_SO_SCHEDULELINE 
  as select from I_SalesDocumentScheduleLine
{
  key SalesDocument as SalesOrder,
  key SalesDocumentItem as  SalesOrderItem,
      cast( OrderQuantityUnit as meins preserving type ) as Uom,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      sum( DeliveredQtyInOrderQtyUnit )                  as DelQty
}
group by
  SalesDocument,
  SalesDocumentItem,
  OrderQuantityUnit
