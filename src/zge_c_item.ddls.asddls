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
define view entity zge_c_item
  as projection on zge_r_item
{
  key GateNumber,
  key ItemNumber,
      PurchasingDoc,
      PurchaseOrderItem,
      @ObjectModel.text.element: [ 'MaterialDescription' ]
      @Consumption.valueHelpDefinition: [{
          entity.name: 'ZGE_I_Product',
          entity.element: 'Material',
          useForValidation: true
       }]
      Material,
      MaterialDescription,
      QtyOrdered,
      QtyReceived,
      TotalGeQty,
      Meins,
      Uom,
      Tolerance,
      Werks,
      QtyOut,
      QtyIn,
      ItemRemark,
      /* Associations */
      _Head : redirected to parent zge_c_head,
      _Mat
}
