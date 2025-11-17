@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view in Gate Item'
@Metadata.ignorePropagatedAnnotations: false
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory: #M,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define view entity ZGE_C_ITEM_REP
  as projection on ZGE_R_ITEM_REP
{
  key GateNumber,
  key ItemNumber,
//      PurchasingDoc,
//      PurchaseOrderItem,
//      @ObjectModel.text.element: [ 'MaterialDescription' ]
//      @Consumption.valueHelpDefinition: [{
//          entity.name: 'ZGE_I_Product',
//          entity.element: 'Material',
//          useForValidation: true
//       }]
      Material,
      MaterialDescription,
//      QtyOrdered,
     @Semantics.quantity.unitOfMeasure: 'Uom'
      QtyReceived,
//      TotalGeQty,
//      Meins,
      Uom,
//      Tolerance,
//      Werks,
//      QtyOut,
//      QtyIn,
//      ItemRemark,
      /* Associations */
      _Head : redirected to parent ZGE_C_HEAD_REP,
      _Mat
}
