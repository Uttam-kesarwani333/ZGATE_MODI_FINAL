@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS view for MIGO Header'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZCDS_GRN_HEAD_MAX
  as select from ZCDS_GRN_HEAD
{
  key MaterialDocumentYear,
  key max(MaterialDocument) as MaterialDocument,
      GateEntry
}
group by
  MaterialDocumentYear,
  GateEntry
having GateEntry is not initial
