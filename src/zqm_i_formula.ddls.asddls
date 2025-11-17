@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for QC Parameter Formula'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZQM_I_FORMULA 
  as select from zqmt_qc_formula
{
  key sno,
      werks            as Werks,
      matkl            as Matkl,
      verwmerkm        as Verwmerkm,
      kurztext         as Kurztext,
      only_post        as OnlyPost,
      rejection        as Rejection,
      dep_verwmerkm    as DepVerwmerkm,
      dep_kurztext     as DepKurztext,
      on_avg           as OnAvg,
      base_qc          as BaseQc,
      base_qc_kurztext as BaseQcKurztext
}
