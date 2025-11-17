@EndUserText.label: 'Gate Entry Material Group Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'GateEntryMateriaAll'
  }
}
define root view entity ZI_GateEntryMaterialGr_S
  as select from I_Language
    left outer join ZGE_MAKTL_FINAL on 0 = 0
  association [0..*] to I_ABAPTransportRequestText as _ABAPTransportRequestText on $projection.TransportRequestID = _ABAPTransportRequestText.TransportRequestID
  composition [0..*] of ZI_GateEntryMaterialGr as _GateEntryMaterialGr
{
  @UI.facet: [ {
    id: 'ZI_GateEntryMaterialGr', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: 'Gate Entry Material Group', 
    position: 1 , 
    targetElement: '_GateEntryMaterialGr'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _GateEntryMaterialGr,
  @UI.hidden: true
  max( ZGE_MAKTL_FINAL.LAST_CHANGED_AT ) as LastChangedAtMax,
  @ObjectModel.text.association: '_ABAPTransportRequestText'
  @UI.identification: [ {
    position: 1 , 
    type: #WITH_INTENT_BASED_NAVIGATION, 
    semanticObjectAction: 'manage'
  } ]
  @Consumption.semanticObject: 'CustomizingTransport'
  cast( '' as SXCO_TRANSPORT) as TransportRequestID,
  _ABAPTransportRequestText
}
where I_Language.Language = $session.system_language
