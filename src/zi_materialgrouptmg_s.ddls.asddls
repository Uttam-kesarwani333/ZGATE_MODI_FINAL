@EndUserText.label: 'Material Group TMG Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'MaterialGroupTmgAll'
  }
}
define root view entity ZI_MaterialGroupTmg_S
  as select from I_Language
    left outer join ZGE_MATKL on 0 = 0
  association [0..*] to I_ABAPTransportRequestText as _ABAPTransportRequestText on $projection.TransportRequestID = _ABAPTransportRequestText.TransportRequestID
  composition [0..*] of ZI_MaterialGroupTmg as _MaterialGroupTmg
{
  @UI.facet: [ {
    id: 'ZI_MaterialGroupTmg', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: 'Material Group TMG', 
    position: 1 , 
    targetElement: '_MaterialGroupTmg'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _MaterialGroupTmg,
  @UI.hidden: true
  max( ZGE_MATKL.LAST_CHANGED_AT ) as LastChangedAtMax,
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
