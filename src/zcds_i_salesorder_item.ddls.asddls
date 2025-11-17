@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS view for Sales Order Item'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZCDS_I_SALESORDER_ITEM 
  as select from I_SalesDocumentItem
  association [0..1] to ZCDS_I_SALESORDER      as _Head     on  $projection.SalesOrder = _Head.SalesOrder
  association [0..1] to ZCDS_I_SO_SCHEDULELINE as _Schedule on  $projection.SalesOrder     = _Schedule.SalesOrder
                                                            and $projection.SalesOrderItem = _Schedule.SalesOrderItem
{
  key cast( SalesDocument as vbeln_va preserving type )              as SalesOrder,
  key cast( SalesDocumentItem as posnr_va preserving type )          as SalesOrderItem,
      cast( Product as matnr preserving type )                       as Material,
      _ProductText[Language = $session.system_language ].ProductName as MaterialDescription,
      cast( Batch as charg_d preserving type )                       as Batch,
      Plant,
      _Plant.PlantName                                               as PlantName,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      OrderQuantity - _Schedule.DelQty                               as OrderQuantity,
     // OrderQuantity,
      cast( OrderQuantityUnit as meins preserving type )             as Uom,
      _Head
}
where
  (
       SDDocumentCategory = 'C'
    or SDDocumentCategory = 'H'
  )
