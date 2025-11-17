@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root view for Gate enty Weighment'
@Metadata.ignorePropagatedAnnotations: false
define root view entity zge_r_head_wt
  as select from zge_i_head
  association [0..1] to I_Plant                as _Plant    on $projection.Plant = _Plant.Plant
  association [0..1] to I_Supplier             as _Supplier on $projection.Supplier = _Supplier.Supplier
  association [0..1] to zge_i_pohead           as _PoHead   on $projection.PurchasingDoc = _PoHead.PurchasingDoc
  association [0..1] to I_InspLotUsageDecision as _Ud       on $projection.PreGrnQc = _Ud.InspectionLot
{
  key GateNumber,
      GateType,
      GatePassType,
      EntryGate,
      GateStatus,
      VehichleNo,
      LrRrNo,
      BillOfLanding,
      VendorInvoiceNo,
      VendorInvoiceDt,
      GateInDate,
      GateInTime,
      //      GateOutDate,
      //      GateOutTime,
      PurchasingDoc,
      SalesDocument,
      Supplier,
      SupplierName,
      Customer,
      Plant,
      PlantName,
      //      CreatedBy,
      //      CreatedOn,
      //      CreationTime,
      InitWeighBridgeCode,
      FinalWeighBridgeCode,
      GrossWeight,
      TareWeight,
      PackingUnit,
      NetWeight,
      WeightRequired,
      WeightSkip,
      InitWtDate,
      InitWtTime,
      FinalWtDate,
      FinalWtTime,
      VendorSlip,
      VendorGrossWeight,
      VendorTareWeight,
      //      Grn,
      PreGrnQc,
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
      Remark,
      WeighTicketNo,
      IsCancelled,
      CancelRemark,
      //      Visitor,
      // Make association public
      _Plant,
      _Supplier,
      _PoHead
}

//where
//
//(
//       GatePassType = 'Manual'
//(    and WeightRequired is not initial
//  )
//  or
//  (
//       GateStatus = 'Open'
//    or GateStatus = 'Final Weighment Pending'
//    or GateStatus = 'Gate Out Pending'
//    or GateStatus = 'Close'
//
//  )
where
  (
        GateStatus     =  'Open'
    or  GateStatus     =  'Final Weighment Pending'
    or  GateStatus     =  'Gate Out Pending'
    or  GateStatus     =  'Close'
    //    or(
    //          GateStatus = 'Gate Out Pending'
    //      and InitWtDate is not initial
    //    )
  )
  ////  and      IsCancelled                        = ''
  ////  and(
  ////           PreGrnQc                           is initial
  ////    or(
  ////           PreGrnQc                           is not initial
  ////      and(
  ////           _Ud.InspectionLotUsageDecisionCode = 'A'
  ////        or _Ud.InspectionLotUsageDecisionCode = 'AD'
  ////      )
  ////    )
  ////  )
  and(
        GateType       =  'Manual'
    and WeightRequired =  'X'
  )
  or(
        GateType       =  'Purchase'
    or  GateType       =  'Sales'
    or  GateType       =  'Gate Pass'
    and WeightRequired <> 'X'
  )  
  and GateType       <>  'Gate Pass'
