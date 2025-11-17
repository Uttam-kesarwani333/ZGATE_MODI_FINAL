@EndUserText.label: 'Material Group for Gate Entry Singleton'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'MaterialGroupForAll'
  }
}
define root view entity ZI_MaterialGroupForGat_S
  as select from I_Language
    left outer join zge_matkl on 0 = 0
  association [0..*] to I_ABAPTransportRequestText as _ABAPTransportRequestText on $projection.TransportRequestID = _ABAPTransportRequestText.TransportRequestID
  composition [0..*] of ZI_MaterialGroupForGat as _MaterialGroupForGat
{
  @UI.facet: [ {
    id: 'ZI_MaterialGroupForGat', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: 'Material Group for Gate Entry', 
    position: 1 , 
    targetElement: '_MaterialGroupForGat'
  } ]
  @UI.lineItem: [ {
    position: 1 
  } ]
  key 1 as SingletonID,
  _MaterialGroupForGat,
  @UI.hidden: true
  max( zge_matkl.last_changed_at ) as LastChangedAtMax,
  @ObjectModel.text.association: '_ABAPTransportRequestText'
  @UI.identification: [ {
    position: 1 , 
    type: #WITH_INTENT_BASED_NAVIGATION, 
    semanticObjectAction: 'manage'
  } ]
  @Consumption.semanticObject: 'CustomizingTransport'
  cast( '' as sxco_transport) as TransportRequestID,
  _ABAPTransportRequestText
}
where I_Language.Language = $session.system_language
