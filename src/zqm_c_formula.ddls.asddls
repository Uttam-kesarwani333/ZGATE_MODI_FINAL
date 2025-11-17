@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for Formula'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZQM_C_FORMULA
  provider contract transactional_query
  as projection on ZQM_R_FORMULA
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
