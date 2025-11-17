@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for Product'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory: #M,
    dataClass: #MIXED
}
define view entity ZGE_I_Product
  as select from I_Product
  association [0..1] to I_ProductText as _Desc on  $projection.Material = _Desc.Product
                                               and _Desc.Language       = $session.system_language
 association  [0..*] to I_ProductPlantBasic as _Plant on $projection.Material = _Plant.Product
{
  key cast( Product as matnr preserving type )      as Material,
  key _Plant.Plant                                  as Plant,
      _Desc.ProductName                             as MaterialDescription,
      cast( ProductType as mtart preserving type  ) as MaterialType,
      cast( BaseUnit as meins preserving type )     as BaseUnit

}
