@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root view for Formula table'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZQM_R_FORMULA
  as select from ZQM_I_FORMULA
  //composition of target_data_source_name as _association_name
{
  key sno,
      Werks,
      Matkl,
      Verwmerkm,
      Kurztext,
      OnlyPost,
      Rejection,
      DepVerwmerkm,
      DepKurztext,
      OnAvg,
      BaseQc,
      BaseQcKurztext
      //    _association_name // Make association public
}
