@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view in Gate Header'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
define root view entity ZGE_C_HEAD_REP
  provider contract transactional_query
  as projection on ZGE_R_HEAD_REP
{
  key GateNumber,
      //      GateType,
      //      @Consumption.valueHelpDefinition: [{ entity.name: 'zge_ce_statusvh', entity.element: 'status', useForValidation: true } ]
      //      GateStatus,
      //      IsCancelled,
      OrderNo,
      VehichleNo,
      LrRrNo,
      BillOfLanding,
      VendorInvoiceNo,
      //      VendorInvoiceDt,
      //      ReportingDate,
      //      ReportingTime,
      GateInDate,
      GateInTime,
      //      GateOutDate,
      //      GateOutTime,

          //  PurchasingDoc,
      //      SalesDocument,
      @ObjectModel.text.element: [ 'SupplierName' ]
      @Consumption.valueHelpDefinition: [{ entity.name: 'I_Supplier', entity.element: 'Supplier', useForValidation: true  }]
      Supplier,
      SupplierName,
      Customer,
      CustomerName,
      //      @ObjectModel.text.element: [ 'PlantName' ]
      //      @Consumption.valueHelpDefinition: [{ entity.name: 'I_Plant', entity.element: 'Plant',useForValidation: true  }]
      Plant,
      //      PlantName,
      //      CreatedBy,
      //      CreatedOn,
      //      CreationTime,
      //      GrossWeight,
      //      TareWeight,
      //      PackingUnit,
      //      NetWeight,
      //      WeightRequired,
      //      WeightSkip,
      //      InitWtDate,
      //      InitWtTime,
      //      FinalWtDate,
      //      FinalWtTime,
      //      VendorSlip,
      //      VendorGrossWeight,
      //      VendorTareWeight,
      //      Grn,
      //      GrnYear,
      //      PreGrnQc,
      //      Purpose,
      //      PersonConcerned,
      //      PersonArrived,
      //      ContactNumber,
      //      NumberOfPerson,
      //      ReturnDate,
      //      ReturnTime,
      DriverName,
      DriverNumber,
      Transporter,
      TransporterName,
      VehicleType,
      DriverLic,
      WeighTicketNo,
      //      Remark,
      //      CancelRemark,
      //      Visitor,
      //      RefDocNumber,
      /* Associations */
      _Items : redirected to composition child ZGE_C_ITEM_REP,
      _Plant,
      _Supplier
}
