@EndUserText.label: 'Material Group TMG'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_MaterialGroupTmg
  as select from ZGE_MATKL
  association to parent ZI_MaterialGroupTmg_S as _MaterialGroupTmgAll on $projection.SingletonID = _MaterialGroupTmgAll.SingletonID
{
  key MATERIAL_GROUP as MaterialGroup,
  MATERIALGROUPTEXT as Materialgrouptext,
  @Semantics.systemDateTime.lastChangedAt: true
  LAST_CHANGED_AT as LastChangedAt,
  @Consumption.hidden: true
  1 as SingletonID,
  _MaterialGroupTmgAll
}
