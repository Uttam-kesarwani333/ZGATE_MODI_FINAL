@EndUserText.label: 'TF for Gate entry Weight'
@ClientHandling.type: #CLIENT_DEPENDENT
@ClientHandling.algorithm: #SESSION_VARIABLE
@AccessControl.authorizationCheck: #NOT_REQUIRED
define table function zcds_tf_gate_wt
  //with parameters parameter_name : parameter_type
returns
{
  client            : abap.clnt;
  GateNumber        : zde_genum;
  ItemNumber        : zde_gepos;
  packingunit       : meins;
  @Semantics.quantity.unitOfMeasure: 'packingunit'
  GrossWeight       : abap.quan(10,2);
  @Semantics.quantity.unitOfMeasure: 'packingunit'
  TareWeight        : abap.quan(10,2);
  @Semantics.quantity.unitOfMeasure: 'packingunit'
  NetWeight         : abap.quan(10,2);
  @Semantics.quantity.unitOfMeasure: 'packingunit'
  VendorGrossWeight : abap.quan(10,2);
  @Semantics.quantity.unitOfMeasure: 'packingunit'
  VendorTareWeight  : abap.quan(10,2);
  row_no            : abap.char( 3 );
}
implemented by method
  zcl_tf_wt_single=>get_weight;