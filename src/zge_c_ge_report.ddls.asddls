@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for GE report'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
define root view entity zge_c_ge_report
  provider contract transactional_query
  as projection on zge_r_ge_report
{
  key GateNumber,
  key ItemNumber,
      PurchasingDoc,
      PurchaseOrderItem,
      Matnr,
      Maktx,
      StorageLocation,
      Batch,
      @Aggregation.default: #SUM
      QtyOrdered,
      @Aggregation.default: #SUM
      QtyReceived,
      @Aggregation.default: #SUM
      TotalGeQty,
      Meins,
      Uom,
      Tolerance,
      Werks,
      @Aggregation.default: #SUM
      QtyOut,
      @Aggregation.default: #SUM
      QtyIn,
      ItemRemark,
      GateType,
      GateStatus,
      GatePassCode,
      GatePassType,
      EntryGate,
      IsCancelled,
      VehichleNo,
      LrRrNo,
      BillOfLanding,
      VendorInvoiceNo,
      VendorInvoiceDt,
      GateInDate,
      GateInTime,
      GateOutDate,
      GateOutTime,
      SalesDocument,
      InvoiceNumber,
      Supplier,
      SupplierName,
      Customer,
      CustomerName,
      Plant,
      PlantName,
      CreatedBy,
      CreatedOn,
      CreationTime,
      ReportingDate,
      ReportingTime,
      @Aggregation.default: #SUM
      GrossWeight,
      @Aggregation.default: #SUM
      TareWeight,
      PackingUnit,
      @Aggregation.default: #SUM
      NetWeight,
      WeightRequired,
      WeightSkip,
      InitWtDate,
      InitWtTime,
      FinalWtDate,
      FinalWtTime,
      VendorSlip,
      @Aggregation.default: #SUM
      VendorGrossWeight,
      @Aggregation.default: #SUM
      VendorTareWeight,
      Grn,
      GrnYear,
      PreGrnQc,
      Purpose,
      PersonConcerned,
      PersonArrived,
      ContactNumber,
      NumberOfPerson,
      ReturnDate,
      ReturnTime,
      DriverName,
      DriverNumber,
      Transporter,
      TransporterName,
      VehicleType,
      DriverLic,
      Remark,
      CancelRemark,
      Visitor,
      RefDocNumber,
      WeighTicketNo,
      InitWeighBridgeCode,
      FinalWeighBridgeCode
}
