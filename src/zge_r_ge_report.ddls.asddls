@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root view for GE report'
@Metadata.ignorePropagatedAnnotations: false
define root view entity zge_r_ge_report
  as select from zge_i_ge_report
  //composition of target_data_source_name as _association_name
  association [0..1] to I_Plant           as _Plant   on  $projection.Plant = _Plant.Plant
  association [0..1] to zcds_i_wt_single  as _Weigh   on  $projection.GateNumber = _Weigh.GateNumber
                                                      and $projection.ItemNumber = _Weigh.ItemNumber
  association [0..1] to ZCDS_GRN_HEAD_MAX as _GRNHead on  $projection.GateNumber = _GRNHead.GateEntry
{
  key GateNumber,
  key ItemNumber,
      PurchasingDoc,
      PurchaseOrderItem,
      Matnr,
      Maktx,
      StorageLocation,
      Batch,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      QtyOrdered,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      QtyReceived,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      TotalGeQty,
      Meins,
      Uom,
      Tolerance,
      Werks,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      QtyOut,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      QtyIn,
      ItemRemark,
      GateType,
      GatePassCode,
      EntryGate,
      GatePassType,
      GateStatus,
      IsCancelled,
      VehichleNo,
      LrRrNo,
      BillOfLanding,
      VendorInvoiceNo,
      VendorInvoiceDt,
      GateInDate,
      case
      when GateInDate is initial then ''
      else concat(
                  concat( substring( GateInTime, 1, 2 ), ':' ),
                concat(  concat( substring( GateInTime, 3, 2 ), ':' ),
                   substring( GateInTime, 5, 2 ) ) )
      end              as GateInTime,
      //      GateInTime,
      GateOutDate,
      case
      when GateOutDate is initial then ''
      else concat(
                  concat( substring( GateOutTime, 1, 2 ), ':' ),
                concat(  concat( substring( GateOutTime, 3, 2 ), ':' ),
                   substring( GateOutTime, 5, 2 ) ) )
      end              as GateOutTime,
      //      GateOutTime,
      SalesDocument,
      InvoiceNumber,
      Supplier,
      SupplierName,
      Customer,
      CustomerName,
      Plant,
      _Plant.PlantName as PlantName,
      //      PlantName,
      CreatedBy,
      CreatedOn,
      case
      when CreationTime is initial then ''
      else concat(
                  concat( substring( CreationTime, 1, 2 ), ':' ),
                concat(  concat( substring( CreationTime, 3, 2 ), ':' ),
                   substring( CreationTime, 5, 2 ) ) )
      end              as CreationTime,
      //      CreationTime,
      ReportingDate,
      case
      when ReportingTime is initial then ''
      else concat(
                  concat( substring( ReportingTime, 1, 2 ), ':' ),
                concat(  concat( substring( ReportingTime, 3, 2 ), ':' ),
                   substring( ReportingTime, 5, 2 ) ) )
      end              as ReportingTime,
      //      ReportingTime,
      @Semantics.quantity.unitOfMeasure: 'PackingUnit'
      //      case ItemNumber
      //      when '00010' then GrossWeight
      //      else  cast( 0 as abap.quan( 10, 2 ) )
      //      end              as GrossWeight,
      _Weigh.GrossWeight,
      @Semantics.quantity.unitOfMeasure: 'PackingUnit'
      //      case ItemNumber
      //      when '00010' then TareWeight
      //      else  cast( 0 as abap.quan( 10, 2 ) )
      //      end              as TareWeight,
      _Weigh.TareWeight,
      PackingUnit,
      @Semantics.quantity.unitOfMeasure: 'PackingUnit'
      //      case ItemNumber
      //      when '00010' then NetWeight
      //      else  cast( 0 as abap.quan( 10, 2 ) )
      //      end              as NetWeight,
      _Weigh.NetWeight,
      WeightRequired,
      WeightSkip,
      InitWtDate,
      case
      when InitWtDate is initial then ''
      else concat(
                        concat( substring( InitWtTime, 1, 2 ), ':' ),
                      concat(  concat( substring( InitWtTime, 3, 2 ), ':' ),
                         substring( InitWtTime, 5, 2 ) ) )
            end        as InitWtTime,
      //      InitWtTime,
      FinalWtDate,
      case
      when FinalWtDate is initial then ''
      else concat(
                  concat( substring( FinalWtTime, 1, 2 ), ':' ),
                concat(  concat( substring( FinalWtTime, 3, 2 ), ':' ),
                   substring( FinalWtTime, 5, 2 ) ) )
      end              as FinalWtTime,
      //      FinalWtTime,
      VendorSlip,
      @Semantics.quantity.unitOfMeasure: 'PackingUnit'
      //      case ItemNumber
      //      when '00010' then VendorGrossWeight
      //      else  cast( 0 as abap.quan( 10, 2 ) )
      //      end              as VendorGrossWeight,
      _Weigh.VendorGrossWeight,
      @Semantics.quantity.unitOfMeasure: 'PackingUnit'
      //      case ItemNumber
      //      when '00010' then VendorTareWeight
      //      else  cast( 0 as abap.quan( 10, 2 ) )
      //      end              as VendorTareWeight,
      _Weigh.VendorTareWeight,
      case when Grn is initial
           then _GRNHead.MaterialDocument
      else Grn
      end              as Grn,
      //      Grn,
      case when Grn is initial
           then _GRNHead.MaterialDocumentYear
      else GrnYear
      end              as GrnYear,
      //      GrnYear,
      PreGrnQc,
      Purpose,
      PersonConcerned,
      PersonArrived,
      ContactNumber,
      NumberOfPerson,
      ReturnDate,
      case
      when ReturnDate is initial then ''
      else concat(
                  concat( substring( ReturnTime, 1, 2 ), ':' ),
                concat(  concat( substring( ReturnTime, 3, 2 ), ':' ),
                   substring( ReturnTime, 5, 2 ) ) )
      end              as ReturnTime,
      //      ReturnTime,
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
