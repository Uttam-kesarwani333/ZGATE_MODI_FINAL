@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS view for MIGO Header'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZCDS_GRN_HEAD
  as select from I_MaterialDocumentHeader_2
{
  key MaterialDocumentYear,
  key MaterialDocument,
      MaterialDocumentHeaderText,
      substring( MaterialDocumentHeaderText, 4, 10 ) as GateEntry
}
where
  MaterialDocumentHeaderText is not initial
