@EndUserText.label: 'Gate Entry Material Group'
@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
define view entity ZI_GateEntryMaterialGr
  as select from ZGE_MAKTL_FINAL
  association to parent ZI_GateEntryMaterialGr_S as _GateEntryMateriaAll on $projection.SingletonID = _GateEntryMateriaAll.SingletonID
{
  key MAKTL_GROUP as MaktlGroup,
  MATERIALGROUPTEXT as Materialgrouptext,
  @Semantics.systemDateTime.lastChangedAt: true
  LAST_CHANGED_AT as LastChangedAt,
  @Consumption.hidden: true
  1 as SingletonID,
  _GateEntryMateriaAll
}
