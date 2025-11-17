@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for Billing Header'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory: #M,
    dataClass: #TRANSACTIONAL
}
define view entity zcds_i_invhead
  as select from I_BillingDocumentBasic
  association [0..*] to zcds_i_invitem as _Item on $projection.Invoice = _Item.Invoice
{
  key cast( BillingDocument as vbeln preserving type )     as Invoice,
      cast( BillingDocumentType as fkart preserving type ) as InvoiceType,
      CreationDate                                         as InvoiceDate,
      cast( SalesOrganization as vkorg preserving type )   as SalesOrganization,
      cast( SoldToParty as kunag preserving type )         as Customer,
      _SoldToParty.BPCustomerName                          as CustomerName,
      YY1_VehicleNo_BDH                                    as VechicleNo,
      YY1_LRGCNo_BDH                                       as LrNo,
      _Item
}
