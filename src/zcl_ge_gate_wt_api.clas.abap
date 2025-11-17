CLASS zcl_ge_gate_wt_api DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.
    TYPES : tt_read_import    TYPE TABLE FOR READ IMPORT zge_r_head_wt\\weight,
            tt_read_result    TYPE TABLE FOR READ RESULT zge_r_head_wt\\weight,

            tt_fail_early     TYPE RESPONSE FOR FAILED EARLY zge_r_head_wt,
            tt_fail_late      TYPE RESPONSE FOR FAILED LATE zge_r_head_wt,
            tt_reported_early TYPE RESPONSE FOR REPORTED EARLY zge_r_head_wt,
            tt_mapped_early   TYPE RESPONSE FOR MAPPED EARLY zge_r_head_wt,

            tt_update_head    TYPE TABLE FOR UPDATE zge_r_head_wt\\weight,

            tt_reported_late  TYPE RESPONSE FOR REPORTED LATE zge_r_head_wt,

            tt_delete_head    TYPE TABLE FOR DELETE zge_r_head_wt\\weight,

            tt_mapped_late    TYPE RESPONSE FOR MAPPED LATE zge_r_head_wt
            .
    " Get the instance of Class
    CLASS-METHODS : get_instance RETURNING VALUE(ro_value) TYPE REF TO zcl_ge_gate_wt_api.

    " Instance method for RAP
    METHODS : read IMPORTING keys     TYPE tt_read_import
                   CHANGING  result   TYPE tt_read_result
                             failed   TYPE tt_fail_early
                             reported TYPE  tt_reported_early,

      update_head IMPORTING entities TYPE tt_update_head
                  CHANGING  mapped   TYPE tt_mapped_early
                            failed   TYPE tt_fail_early
                            reported TYPE tt_reported_early,

      delete_head IMPORTING keys     TYPE tt_delete_head
                  CHANGING  mapped   TYPE tt_mapped_early
                            failed   TYPE tt_fail_early
                            reported TYPE tt_reported_early,


      save        CHANGING  reported  TYPE tt_reported_late,

      "Helper methods
*      set_mapped IMPORTING VALUE(it_mapped) TYPE tt_mapped_early,
*      get_mapped RETURNING VALUE(rt_mapped) TYPE tt_mapped_early,

      finalize  CHANGING failed   TYPE tt_fail_late
                         reported TYPE tt_reported_late,

      check_before_save CHANGING failed   TYPE tt_fail_late
                                 reported TYPE tt_reported_late,

      cleanup .


  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA : mo_instance TYPE REF TO zcl_ge_gate_wt_api,
                 gt_header   TYPE STANDARD TABLE OF zge_hdr,
                 gr_gateid   TYPE RANGE OF zge_hdr-gate_number,
                 gt_mapped_e TYPE tt_mapped_early.
ENDCLASS.



CLASS ZCL_GE_GATE_WT_API IMPLEMENTATION.


  METHOD check_before_save.
    DATA(ls_header) = VALUE #( gt_header[ 1 ] OPTIONAL ).
    IF ls_header-grn IS NOT INITIAL.
      SELECT SINGLE @abap_true
       FROM i_materialdocumentitem_2
       WHERE  reversedmaterialdocumentyear = @ls_header-grn_year
         AND reversedmaterialdocument = @ls_header-grn
         INTO @DATA(lv_grn_cancel) PRIVILEGED ACCESS.
      IF lv_grn_cancel = abap_false.
        CLEAR : lv_grn_cancel.

        SELECT SINGLE @abap_true
         FROM i_materialdocumentitem_2 AS a
         WHERE  a~referencedocumentfiscalyear = @ls_header-grn_year
           AND a~invtrymgmtreferencedocument = @ls_header-grn
           AND a~invtrymgmtreferencedocument <> a~materialdocument
           INTO @DATA(lv_grn_invtry_cancel) PRIVILEGED ACCESS.
        IF lv_grn_invtry_cancel = abap_false.
          CLEAR : lv_grn_invtry_cancel.
          APPEND VALUE #( gatenumber = ls_header-gate_number
                          %fail-cause = if_abap_behv=>cause-conflict
                           ) TO failed-weight.
          APPEND VALUE #( gatenumber = ls_header-gate_number
                          %state_area = 'GRN_NUMBER'
                           %msg = NEW zcx_gate(
            textid          = zcx_gate=>grn_exists
            severity        = if_abap_behv_message=>severity-error
            grn_num         = CONV string( ls_header-grn )
            gate_number     = ls_header-gate_number
          )
            %element-gatenumber = if_abap_behv=>mk-on
                         ) TO reported-weight.
        ENDIF.
      ENDIF.
      CLEAR : lv_grn_cancel,lv_grn_invtry_cancel.
    ENDIF.
  ENDMETHOD.


  METHOD cleanup.
    CLEAR : gt_header,gt_mapped_e.
  ENDMETHOD.


  METHOD delete_head.

*    IF gr_gateid IS NOT INITIAL.
*      DELETE FROM zge_hdr WHERE gate_number IN @gr_gateid.
*    ENDIF.

    " Populate the range parameter for deletion
    gr_gateid = VALUE #( FOR ls_key IN keys
                           sign = 'I'
                           option = 'EQ'
                          (  low = ls_key-gatenumber ) ).

  ENDMETHOD.


  METHOD finalize.

  ENDMETHOD.


  METHOD get_instance.
    mo_instance = ro_value = COND #( WHEN mo_instance IS BOUND THEN mo_instance
                                     ELSE NEW #(  ) ).
  ENDMETHOD.


  METHOD read.

    IF keys[] IS NOT INITIAL.
      SELECT *
      FROM zge_hdr
      FOR ALL ENTRIES IN @keys
      WHERE gate_number = @keys-gatenumber
        AND gate_status IN ( 'Open', 'Weighment Pending' )
      INTO TABLE @DATA(lt_header).

*    Populate data to result
      result = CORRESPONDING #( lt_header MAPPING TO ENTITY ).

    ENDIF.
  ENDMETHOD.


  METHOD save.

    " Store the record into DB
    IF gt_header IS NOT INITIAL.
      MODIFY zge_hdr FROM TABLE @gt_header.

    ENDIF.


    IF gr_gateid[] IS NOT INITIAL.
      "Delete Header
      "   DELETE FROM zge_hdr WHERE gate_number IN @gr_gateid.
    ENDIF.

  ENDMETHOD.


  METHOD update_head.
    DATA : lt_head_x  TYPE STANDARD TABLE OF zge_s_hdr_x.

    " Fill Buffer data
    gt_header = CORRESPONDING #( entities MAPPING FROM ENTITY ).

    lt_head_x = CORRESPONDING #( entities MAPPING FROM ENTITY USING CONTROL ).
    DATA(ls_data_u) = VALUE #( gt_header[ 1 ] OPTIONAL ).
    DATA(ls_data_x) = VALUE #( lt_head_x[ 1 ] OPTIONAL ).

    SELECT SINGLE FROM zge_hdr
     FIELDS *
    WHERE gate_number = @ls_data_u-gate_number
    INTO @DATA(ls_head_old).

    gt_header = VALUE #(
                     (
                           gate_number = ls_head_old-gate_number
                           created_by = ls_head_old-created_by
                           created_on = ls_head_old-created_on
                           creation_time = ls_head_old-creation_time
*                           is_cancelled = ls_head_old-is_cancelled
                           grn = ls_head_old-grn
                           grn_year = ls_head_old-grn_year
                           gate_out_date = ls_head_old-gate_out_date
                           gate_out_time = ls_head_old-gate_out_time
                           driver_name = ls_head_old-driver_name
                           driver_lic = ls_head_old-driver_lic
                           driver_number = ls_head_old-driver_number
                           transporter = ls_head_old-transporter
                           transporter_name = ls_head_old-transporter_name
                           ebeln = ls_head_old-ebeln
                           vbeln = ls_head_old-vbeln
                           lifnr = ls_head_old-lifnr
                           supplier_name = ls_head_old-supplier_name "#EC CI_VALPAR
                           kunnr = ls_head_old-kunnr
                           customer_name = ls_head_old-customer_name
                           werks = ls_head_old-werks
                           plantname = ls_head_old-plantname
                           pre_grn_qc = ls_head_old-pre_grn_qc
*                           vehicle_type = ls_head_old-vehicle_type
                           vehichle_no = ls_head_old-vehichle_no
                           gate_type = ls_head_old-gate_type
                           lr_rr_no = ls_head_old-lr_rr_no
                           bill_of_landing = ls_head_old-bill_of_landing
                           gate_in_date = ls_head_old-gate_in_date
                           gate_in_time = ls_head_old-gate_in_time
                           vendor_invoice_no = ls_head_old-vendor_invoice_no
                           vendor_invoice_dt = ls_head_old-vendor_invoice_dt
*                           cancel_remark = ls_head_old-cancel_remark
                           reporting_date = ls_head_old-reporting_date
                           reporting_time = ls_head_old-reporting_time
                           vehicle_type = ls_head_old-vehicle_type
                           remark = ls_head_old-remark
                           gatepasscode = ls_head_old-gatepasscode
                           entry_gate = ls_head_old-entry_gate
                           gate_pass_type = ls_head_old-gate_pass_type
                           invoicenumber = ls_head_old-invoicenumber
                           cancel_remark = COND #( WHEN ls_data_x-cancel_remark IS NOT INITIAL THEN ls_data_u-cancel_remark ELSE ls_head_old-cancel_remark  )
                           is_cancelled = COND #( WHEN ls_data_x-is_cancelled IS NOT INITIAL THEN ls_data_u-is_cancelled ELSE ls_head_old-is_cancelled  )
                           gate_status = COND #( WHEN ls_data_x-gate_status IS NOT INITIAL THEN ls_data_u-gate_status ELSE ls_head_old-gate_status  )
                           gross_weight = COND #( WHEN ls_data_x-gross_weight IS NOT INITIAL THEN ls_data_u-gross_weight ELSE ls_head_old-gross_weight  )
                           tare_weight = COND #( WHEN ls_data_x-tare_weight IS NOT INITIAL THEN ls_data_u-tare_weight ELSE ls_head_old-tare_weight  )
                           packing_unit = COND #( WHEN ls_data_x-packing_unit IS NOT INITIAL THEN ls_data_u-packing_unit ELSE ls_head_old-packing_unit  )
                           net_weight = COND #( WHEN ls_data_x-net_weight IS NOT INITIAL THEN ls_data_u-net_weight ELSE ls_head_old-net_weight  )
                           weight_required = COND #( WHEN ls_data_x-weight_required IS NOT INITIAL THEN ls_data_u-weight_required ELSE ls_head_old-weight_required  )
                           weight_skip = COND #( WHEN ls_data_x-weight_skip IS NOT INITIAL THEN ls_data_u-weight_skip ELSE ls_head_old-weight_skip  )
                           init_wt_date = COND #( WHEN ls_data_x-init_wt_date IS NOT INITIAL THEN ls_data_u-init_wt_date ELSE ls_head_old-init_wt_date  )
                           init_wt_time = COND #( WHEN ls_data_x-init_wt_time IS NOT INITIAL THEN ls_data_u-init_wt_time ELSE ls_head_old-init_wt_time  )
                           final_wt_date = COND #( WHEN ls_data_x-final_wt_date IS NOT INITIAL THEN ls_data_u-final_wt_date ELSE ls_head_old-final_wt_date  )
                           final_wt_time = COND #( WHEN ls_data_x-final_wt_time IS NOT INITIAL THEN ls_data_u-final_wt_time ELSE ls_head_old-final_wt_time  )
                           vendor_slip = COND #( WHEN ls_data_x-vendor_slip IS NOT INITIAL THEN ls_data_u-vendor_slip ELSE ls_head_old-vendor_slip  )
                           vendor_gross_weight = COND #( WHEN ls_data_x-vendor_gross_weight IS NOT INITIAL THEN ls_data_u-vendor_gross_weight ELSE ls_head_old-vendor_gross_weight  )
                           vendor_tare_weight = COND #( WHEN ls_data_x-vendor_tare_weight IS NOT INITIAL THEN ls_data_u-vendor_tare_weight ELSE ls_head_old-vendor_tare_weight  )
*                           gate_pass_type = COND #( WHEN ls_data_x-gate_pass_type IS NOT INITIAL THEN ls_data_u-gate_pass_type ELSE ls_head_old-gate_pass_type  )
*                           gatepasscode = COND #( WHEN ls_data_x-gatepasscode IS NOT INITIAL THEN ls_data_u-gatepasscode ELSE ls_head_old-gatepasscode  )
*                           entry_gate = COND #( WHEN ls_data_x-entry_gate IS NOT INITIAL THEN ls_data_u-entry_gate ELSE ls_head_old-entry_gate  )
                           init_weighbridgecode = COND #( WHEN ls_data_x-init_weighbridgecode IS NOT INITIAL THEN ls_data_u-init_weighbridgecode ELSE ls_head_old-init_weighbridgecode  )
                           wtticketno = COND #( WHEN ls_data_x-wtticketno IS NOT INITIAL THEN ls_data_u-wtticketno ELSE ls_head_old-wtticketno  )
                           final_weighbridgecode = COND #( WHEN ls_data_x-final_weighbridgecode IS NOT INITIAL THEN ls_data_u-final_weighbridgecode ELSE ls_head_old-final_weighbridgecode  )
*                           visitor = COND #( WHEN ls_data_x-visitor IS NOT INITIAL THEN ls_data_u-visitor ELSE ls_head_old-visitor  )
                     )
    ).



  ENDMETHOD.
ENDCLASS.
