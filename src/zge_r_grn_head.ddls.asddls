@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'cds root view for GRN head'
@Metadata.ignorePropagatedAnnotations: false
define root view entity zge_r_grn_head
  as select from zge_i_head

  --Composition child for header viz Item
  composition [0..*] of zge_r_grn_item as _Items

  --associations - lose coupling to get dependent data
  association [0..1] to I_Plant        as _Plant    on $projection.Plant = _Plant.Plant
  association [0..1] to I_Supplier     as _Supplier on $projection.Supplier = _Supplier.Supplier
  association [0..*] to zge_i_purchase as _PoItem   on $projection.PurchasingDoc = _PoItem.PurchasingDoc
{

  key GateNumber,
      GateType,
      GateStatus,
      VehichleNo,
      BillOfLanding,
      PurchasingDoc,
      Supplier,
      SupplierName,
      Customer,
      Plant,
      CreatedBy,
      CreatedOn,
      GrnDocDate,
      GrnPostDate,
      GrnHeaderText,
      DeliveryNote,
      Grn,
      GrnYear,
      GrnStatus,
      CancelGrn,
      PreGrnQc,
      Remark,
      _Items,
      _Plant,
      _Supplier,
      _PoItem
}
where
       zge_i_head.PurchasingDoc is not initial
  and(
       GateStatus               = 'Close'
    or GateStatus               = 'Gate Out Pending'
  )
