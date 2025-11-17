@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS view for Sales Order Header'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory: #M,
    dataClass: #MIXED
}
define view entity ZCDS_I_SALESORDER 
  as select from I_SalesDocument
  association [0..*] to ZCDS_I_SALESORDER_ITEM as _Item on $projection.SalesOrder = _Item.SalesOrder
{
      //  key cast( SalesOrder as vbeln_va preserving type )     as SalesOrder,
  key cast( SalesDocument as vbeln_va preserving type )  as SalesOrder,
      cast( SalesDocumentType as auart preserving type ) as SalesOrderType,
      cast( SalesOrganization as vkorg preserving type ) as SalesOrganization,
      cast( SoldToParty as kunag preserving type )       as Customer,
      _SoldToParty.BPCustomerName                        as CustomerName,
      SalesDocumentDate                                  as SalesOrderDate,
      CreatedByUser,
      _Item

}
where
  (
       SDDocumentCategory = 'C'
    or SDDocumentCategory = 'H'
  )
