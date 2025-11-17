@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for Billing Item'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zcds_i_invitem
  as select from I_BillingDocumentItemBasic
  association[0..1] to zcds_i_invhead as _Head on $projection.Invoice = _Head.Invoice
{
  key cast( BillingDocument as vbeln preserving type ) as Invoice,
  key BillingDocumentItem                              as InvoiceItem,
      Product                                          as Material,
      BillingDocumentItemText                          as MaterialDescription,
      BillingQuantity                                  as OrderQuantity,
      BillingQuantity                                  as OpenOrderQuantity,
      BillingQuantityUnit,
      Plant,
      SalesDocument,                            
      _Head

}
