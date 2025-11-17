CLASS zcl_ge_grn_api DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.
    TYPES : tt_read_import    TYPE TABLE FOR READ IMPORT zge_r_grn_head\\header,
            tt_read_result    TYPE TABLE FOR READ RESULT zge_r_grn_head\\header,

            tt_fail_early     TYPE RESPONSE FOR FAILED EARLY zge_r_grn_head,
            tt_fail_late      TYPE RESPONSE FOR FAILED LATE  zge_r_grn_head,
            tt_reported_early TYPE RESPONSE FOR REPORTED EARLY zge_r_grn_head,
            tt_mapped_early   TYPE RESPONSE FOR MAPPED EARLY zge_r_grn_head,

            tt_update_head    TYPE TABLE FOR UPDATE  zge_r_grn_head\\header,

            tt_create         TYPE  TABLE FOR CREATE zge_r_grn_head\\header,

            tt_reported_late  TYPE RESPONSE FOR REPORTED LATE  zge_r_grn_head,

            tt_mapped_late    TYPE RESPONSE FOR MAPPED LATE  zge_r_grn_head,

            tt_entities_cba   TYPE TABLE FOR CREATE  zge_r_grn_head\\header\_items
            .
    " Get the instance of Class
    CLASS-METHODS : get_instance RETURNING VALUE(ro_value) TYPE REF TO zcl_ge_grn_api.

    " Instance method for RAP
    METHODS : read IMPORTING keys     TYPE tt_read_import
                   CHANGING  result   TYPE tt_read_result
                             failed   TYPE tt_fail_early
                             reported TYPE  tt_reported_early,

      create_head IMPORTING entities TYPE tt_create
                  CHANGING  mapped   TYPE tt_mapped_early
                            failed   TYPE tt_fail_early
                            reported TYPE tt_reported_early,

      update_head IMPORTING entities TYPE tt_update_head
                  CHANGING  mapped   TYPE tt_mapped_early
                            failed   TYPE tt_fail_early
                            reported TYPE tt_reported_early,


      save        CHANGING  reported  TYPE tt_reported_late,

      "Helper methods

      cba_item IMPORTING entities_cba TYPE tt_entities_cba
               CHANGING  mapped       TYPE tt_mapped_early
                         failed       TYPE tt_fail_early
                         reported     TYPE tt_reported_early,

      finalize  CHANGING failed   TYPE tt_fail_late
                         reported TYPE tt_reported_late,

      check_before_save CHANGING failed   TYPE tt_fail_late
                                 reported TYPE tt_reported_late,

      cleanup .


  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA : mo_instance     TYPE REF TO zcl_ge_grn_api,
                 gt_header       TYPE STANDARD TABLE OF zge_hdr,
                 gt_item         TYPE STANDARD TABLE OF zge_itm,
                 gr_gateid       TYPE RANGE OF zge_hdr-gate_number,
                 gv_pid_matdoc   TYPE abp_behv_pid,
                 gv_cancel_mblnr TYPE mblnr,
                 gt_mapped_e     TYPE tt_mapped_early.
ENDCLASS.



CLASS ZCL_GE_GRN_API IMPLEMENTATION.


  METHOD cba_item.

    DATA : max_line_id TYPE zde_gepos,
           lt_item_cba TYPE TABLE FOR CREATE zge_r_head\\header\_items.

    lt_item_cba = CORRESPONDING #( DEEP  entities_cba ).


    DATA(ls_item_cba) = VALUE #( entities_cba[ 1 ] OPTIONAL ).

    LOOP AT ls_item_cba-%target INTO DATA(ls_item).
      APPEND INITIAL LINE TO gt_item ASSIGNING FIELD-SYMBOL(<fs_item>).
      IF <fs_item> IS ASSIGNED.
        <fs_item>-batch = ls_item-batch.
        <fs_item>-ebeln = ls_item-purchasingdoc.
        <fs_item>-ebelp = ls_item-purchaseorderitem.
        <fs_item>-item_number = ls_item-itemnumber.
        <fs_item>-maktx = ls_item-materialdescription.
        <fs_item>-matnr = ls_item-material.
        <fs_item>-meins = ls_item-meins.
        <fs_item>-qty_ordered = ls_item-qtyordered.
        <fs_item>-qty_received = ls_item-qtyreceived.
        <fs_item>-storage_location = ls_item-storagelocation.
        <fs_item>-tolerance = ls_item-tolerance.
        <fs_item>-total_ge_qty = ls_item-totalgeqty.
        <fs_item>-werks = ls_item-werks.
        <fs_item>-uom = ls_item-uom.
        <fs_item>-gate_number = ls_item_cba-gatenumber.
        <fs_item>-client = sy-mandt.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD check_before_save.

    DATA(ls_header) = VALUE #( gt_header[ 1 ] OPTIONAL ).
    IF ls_header IS NOT INITIAL.
      IF ls_header-grn_doc_date IS INITIAL.
        APPEND VALUE #( gatenumber = ls_header-gate_number
                        %fail-cause = if_abap_behv=>cause-conflict
                         ) TO failed-header.

        APPEND VALUE #(  gatenumber = ls_header-gate_number
                        %state_area = 'GRN_DOC_DATE'
                        %msg = NEW zcx_gate(
          textid      = zcx_gate=>grn_doc_date
          severity    = if_abap_behv_message=>severity-error

        )
                        %element-grndocdate = if_abap_behv=>mk-on  )
            TO reported-header.
      ENDIF.

      IF ls_header-grn_post_date IS INITIAL.
        APPEND VALUE #( gatenumber = ls_header-gate_number
                        %fail-cause = if_abap_behv=>cause-conflict
                         ) TO failed-header.

        APPEND VALUE #(  gatenumber = ls_header-gate_number
                        %state_area = 'GRN_POST_DATE'
                        %msg = NEW zcx_gate(
          textid      = zcx_gate=>grn_post_date
          severity    = if_abap_behv_message=>severity-error

        )
                        %element-grnpostdate = if_abap_behv=>mk-on  )
            TO reported-header.
      ENDIF.

      IF ls_header-grn_post_date < ls_header-gate_in_date.
        APPEND VALUE #( gatenumber = ls_header-gate_number
                        %fail-cause = if_abap_behv=>cause-conflict
                         ) TO failed-header.

        APPEND VALUE #(  gatenumber = ls_header-gate_number
                        %state_area = 'GRN_GATE_DATE'
                        %msg = NEW zcx_gate(
          textid      = zcx_gate=>grn_gate_date
          severity    = if_abap_behv_message=>severity-error
          grn_data = |{ ls_header-grn_post_date DATE = USER }|
          gate_in_data = |{ ls_header-gate_in_date DATE = USER }|
        )
                        %element-grnpostdate = if_abap_behv=>mk-on  )
            TO reported-header.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD cleanup.
    CLEAR : gt_header,gt_item,gt_mapped_e.
  ENDMETHOD.


  METHOD create_head.

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
                           client = sy-mandt
                           gate_number = ls_head_old-gate_number
                           created_by = ls_head_old-created_by
                           created_on = ls_head_old-created_on
                           creation_time = ls_head_old-creation_time
                           is_cancelled = ls_head_old-is_cancelled
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
                           supplier_name = ls_head_old-supplier_name
                           kunnr = ls_head_old-kunnr
                           customer_name = ls_head_old-customer_name
                           werks = ls_head_old-werks
                           plantname = ls_head_old-plantname
                           pre_grn_qc = ls_head_old-pre_grn_qc
                           vehicle_type = ls_head_old-vehicle_type
                           vehichle_no = ls_head_old-vehichle_no
                           gate_type = ls_head_old-gate_type
                           gatepasscode = ls_head_old-gatepasscode
                           lr_rr_no = ls_head_old-lr_rr_no
                           gate_in_date = ls_head_old-gate_in_date
                           gate_in_time = ls_head_old-gate_in_time
                           vendor_invoice_no = ls_head_old-vendor_invoice_no
                           vendor_invoice_dt = ls_head_old-vendor_invoice_dt
                           cancel_remark = ls_head_old-cancel_remark
                           remark = ls_head_old-remark
                           gate_status = ls_head_old-gate_status
                           reporting_date = ls_head_old-reporting_date
                           reporting_time = ls_head_old-reporting_time
                           gate_pass_type = ls_head_old-gate_pass_type
                           entry_gate = ls_head_old-entry_gate
                           init_weighbridgecode = ls_head_old-init_weighbridgecode
                           init_wt_date = ls_head_old-init_wt_date
                           init_wt_time = ls_head_old-init_wt_time
                           final_weighbridgecode = ls_head_old-final_weighbridgecode
                           final_wt_date = ls_head_old-final_wt_date
                           final_wt_time = ls_head_old-init_wt_time
                           vendor_slip = ls_head_old-vendor_slip
                           vendor_gross_weight = ls_head_old-vendor_gross_weight
                           vendor_tare_weight = ls_head_old-vendor_tare_weight
                           weight_required = ls_head_old-weight_required
                           weight_skip = ls_head_old-weight_skip
                           net_weight = ls_head_old-net_weight
                           gross_weight = ls_head_old-gross_weight
                           tare_weight = ls_head_old-tare_weight
                           ref_doc_number = ls_head_old-ref_doc_number
                           wtticketno = ls_head_old-wtticketno
*                           invoicenumber = ls_head_old-invoicenumber
                           bill_of_landing = COND #( WHEN ls_data_x-bill_of_landing IS NOT INITIAL THEN ls_data_u-bill_of_landing ELSE ls_head_old-bill_of_landing  )
                           grn = COND #( WHEN ls_data_x-grn IS NOT INITIAL THEN ls_data_u-grn ELSE ls_head_old-grn  )
                           grn_year = COND #( WHEN ls_data_x-grn_year IS NOT INITIAL THEN ls_data_u-grn_year ELSE ls_head_old-grn_year  )
*                           remark = COND #( WHEN ls_data_x-remark IS NOT INITIAL THEN ls_data_u-remark ELSE ls_head_old-remark  )
                           grn_doc_date = COND #( WHEN ls_data_x-grn_doc_date IS NOT INITIAL THEN ls_data_u-grn_doc_date ELSE ls_head_old-grn_doc_date  )
                           grnstatus = COND #( WHEN ls_data_x-grnstatus IS NOT INITIAL THEN ls_data_u-grnstatus ELSE ls_head_old-grnstatus  )
                           grn_post_date = COND #( WHEN ls_data_x-grn_post_date IS NOT INITIAL THEN ls_data_u-grn_post_date ELSE ls_head_old-grn_post_date  )
                           grn_header_text = COND #( WHEN ls_data_x-grn_header_text IS NOT INITIAL THEN ls_data_u-grn_header_text ELSE ls_head_old-grn_header_text  )
                           delivery_note = COND #( WHEN ls_data_x-delivery_note IS NOT INITIAL THEN ls_data_u-delivery_note ELSE ls_head_old-delivery_note  )

                     )
    ).
  ENDMETHOD.


  METHOD finalize.
*   DATA : lt_mat_item TYPE TABLE FOR CREATE  I_MaterialDocumentTP\\MaterialDocument\_MaterialDocumentItem.
    DATA : lt_mat_item   TYPE TABLE FOR CREATE  i_materialdocumenttp\_materialdocumentitem,
           lt_cancel_hdr TYPE TABLE FOR ACTION IMPORT i_materialdocumenttp\\materialdocument~cancel.

    DATA(ls_final) = VALUE #( gt_header[ 1 ] OPTIONAL ).

    IF ls_final IS NOT INITIAL AND gt_item IS NOT INITIAL.

      MODIFY ENTITIES OF i_materialdocumenttp
      ENTITY materialdocument
      CREATE FROM VALUE #( ( %cid = 'CID_001'
      goodsmovementcode = '01'
      materialdocumentheadertext = ls_final-grn_header_text
      referencedocument = ls_final-delivery_note
      postingdate = ls_final-grn_post_date"cl_abap_context_info=>get_system_date( )
      documentdate = ls_final-grn_doc_date"cl_abap_context_info=>get_system_date( )
      %control-goodsmovementcode = cl_abap_behv=>flag_changed
      %control-postingdate = cl_abap_behv=>flag_changed
      %control-documentdate = cl_abap_behv=>flag_changed
      %control-materialdocumentheadertext = cl_abap_behv=>flag_changed
      %control-referencedocument = cl_abap_behv=>flag_changed
      ) )
      ENTITY materialdocument
      CREATE BY \_materialdocumentitem
      FROM VALUE #( FOR ls_item IN gt_item
         (
      %cid_ref = 'CID_001'
      %target = VALUE #( ( %cid = |CID_ITM_{ ls_item-item_number }|
      plant = ls_final-werks
      material = |{ ls_item-matnr ALPHA = IN WIDTH = 18 }|
      goodsmovementtype = '101' "'103'  "
      storagelocation = ls_item-storage_location
      quantityinentryunit = ls_item-qty_received
      entryunit = ls_item-uom
*      purchaseorder = '4500000054'
      purchaseorder = |{ ls_item-ebeln ALPHA = IN WIDTH = 10 }|
      purchaseorderitem = ls_item-ebelp
      goodsmovementrefdoctype = 'B'
      %control-plant = cl_abap_behv=>flag_changed
      %control-material = cl_abap_behv=>flag_changed
      %control-goodsmovementtype = cl_abap_behv=>flag_changed
      %control-storagelocation = cl_abap_behv=>flag_changed
      %control-quantityinentryunit = cl_abap_behv=>flag_changed
      %control-entryunit = cl_abap_behv=>flag_changed
      %control-purchaseorder = cl_abap_behv=>flag_changed
      %control-purchaseorderitem = cl_abap_behv=>flag_changed
      %control-goodsmovementrefdoctype = cl_abap_behv=>flag_changed
      ) )


      ) )
      MAPPED DATA(ls_create_mapped)
      FAILED DATA(ls_create_failed)
      REPORTED DATA(ls_create_reported).

      IF ls_create_mapped IS NOT INITIAL.
        LOOP AT ls_create_mapped-materialdocument INTO DATA(ls_matdoc).
          IF ls_matdoc-%pid IS NOT INITIAL.
            gv_pid_matdoc = ls_matdoc-%pid.
          ENDIF.
        ENDLOOP.
      ENDIF.
*      COMMIT ENTITIES BEGIN
*     RESPONSE OF i_materialdocumenttp
*      FAILED DATA(commit_failed)
*      REPORTED DATA(commit_reported).

*      COMMIT ENTITIES END.

    ENDIF.

    IF ls_final-grnstatus = 'Cancelled'.


      lt_cancel_hdr = VALUE #( ( " %cid_ref  = 'CID_CAN_001'
                      %key-materialdocument = ls_final-grn
                      %key-materialdocumentyear = ls_final-grn_year
                      %param-postingdate = cl_abap_context_info=>get_system_date( )  ) ).

      MODIFY ENTITY i_materialdocumenttp\\materialdocument
      EXECUTE cancel FROM lt_cancel_hdr
      RESULT DATA(lt_result_cancel)
      MAPPED DATA(lt_mapped_cancel)
      FAILED DATA(lt_failed_cancel)
      REPORTED DATA(lt_reported_cancel).

      IF lt_failed_cancel IS INITIAL.
        DATA(ls_result_cancel) = VALUE #( lt_result_cancel[ 1 ] OPTIONAL ).
        IF ls_result_cancel-%param-materialdocument IS NOT INITIAL.
          gv_cancel_mblnr = ls_result_cancel-%param-materialdocument. " 5000000077
        ENDIF.
      ELSE.
        LOOP AT lt_failed_cancel-materialdocument INTO DATA(ls_failed_cancel).
          APPEND VALUE #( gatenumber = ls_final-gate_number
                          %fail-cause = if_abap_behv=>cause-conflict
                           ) TO failed-header.
        ENDLOOP.

        LOOP AT lt_reported_cancel-materialdocument INTO DATA(ls_reported_cancel).
          APPEND VALUE #(  gatenumber = ls_final-gate_number
                          %state_area = 'GRN'
                          %msg = ls_reported_cancel-%msg )
              TO reported-header.
        ENDLOOP.


      ENDIF.
    ENDIF.
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
      INTO TABLE @DATA(lt_header).

*    Populate data to result
      result = CORRESPONDING #( lt_header MAPPING TO ENTITY ).

    ENDIF.
  ENDMETHOD.


  METHOD save.
    DATA : lt_mapped_data TYPE RESPONSE FOR MAPPED EARLY zge_r_head.

    IF gv_pid_matdoc IS NOT INITIAL.

      READ ENTITIES OF i_materialdocumenttp
      ENTITY materialdocument
      FIELDS ( materialdocument materialdocumentyear )
      WITH VALUE #( ( %pid = gv_pid_matdoc ) )
      RESULT DATA(lt_result)
      FAILED DATA(lt_failed)
      REPORTED DATA(lt_reported).

      IF lt_result IS NOT INITIAL.
        DATA(ls_result) = VALUE #( lt_result[ 1 ] OPTIONAL ).
        IF ls_result-materialdocument IS NOT INITIAL.
          READ TABLE gt_header ASSIGNING FIELD-SYMBOL(<fs_header>) INDEX 1.
          IF <fs_header> IS ASSIGNED.
            <fs_header>-grn = ls_result-materialdocument.
            <fs_header>-grnstatus = 'Created'.
            <fs_header>-grn_year = ls_result-materialdocumentyear.
            UNASSIGN <fs_header>.
          ENDIF.
        ENDIF.
      ENDIF.
      " Store the record into DB
      IF gt_header IS NOT INITIAL.
        MODIFY zge_hdr FROM TABLE @gt_header.

        IF gt_item IS NOT INITIAL.
          DATA(lv_gateid) = VALUE zde_genum( gt_item[ 1 ]-gate_number OPTIONAL ).

          DELETE FROM zge_itm WHERE gate_number = @lv_gateid.


          MODIFY zge_itm FROM TABLE @gt_item.

        ENDIF.

      ENDIF.
    ENDIF.

*    For cancelation
    IF gv_cancel_mblnr IS NOT INITIAL.
      READ TABLE gt_header ASSIGNING FIELD-SYMBOL(<fs_header_1>) INDEX 1.
      IF <fs_header_1> IS ASSIGNED.
        <fs_header_1>-cancelgrn = gv_cancel_mblnr.
        UNASSIGN <fs_header_1>.
      ENDIF.

      IF gt_header IS NOT INITIAL.
        MODIFY zge_hdr FROM TABLE @gt_header.
      ENDIF.
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
                           client = sy-mandt
                           gate_number = ls_head_old-gate_number
                           created_by = ls_head_old-created_by
                           created_on = ls_head_old-created_on
                           creation_time = ls_head_old-creation_time
                           is_cancelled = ls_head_old-is_cancelled
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
                           supplier_name = ls_head_old-supplier_name
                           kunnr = ls_head_old-kunnr
                           customer_name = ls_head_old-customer_name
                           werks = ls_head_old-werks
                           plantname = ls_head_old-plantname
                           pre_grn_qc = ls_head_old-pre_grn_qc
                           vehicle_type = ls_head_old-vehicle_type
                           vehichle_no = ls_head_old-vehichle_no
                           gate_type = ls_head_old-gate_type
                           gatepasscode = ls_head_old-gatepasscode
                           lr_rr_no = ls_head_old-lr_rr_no
                           gate_in_date = ls_head_old-gate_in_date
                           gate_in_time = ls_head_old-gate_in_time
                           vendor_invoice_no = ls_head_old-vendor_invoice_no
                           vendor_invoice_dt = ls_head_old-vendor_invoice_dt
                           cancel_remark = ls_head_old-cancel_remark
                           remark = ls_head_old-remark
                           gate_status = ls_head_old-gate_status
                           reporting_date = ls_head_old-reporting_date
                           reporting_time = ls_head_old-reporting_time
                           gate_pass_type = ls_head_old-gate_pass_type
                           entry_gate = ls_head_old-entry_gate
                           init_weighbridgecode = ls_head_old-init_weighbridgecode
                           init_wt_date = ls_head_old-init_wt_date
                           init_wt_time = ls_head_old-init_wt_time
                           final_weighbridgecode = ls_head_old-final_weighbridgecode
                           final_wt_date = ls_head_old-final_wt_date
                           final_wt_time = ls_head_old-init_wt_time
                           vendor_slip = ls_head_old-vendor_slip
                           vendor_gross_weight = ls_head_old-vendor_gross_weight
                           vendor_tare_weight = ls_head_old-vendor_tare_weight
                           weight_required = ls_head_old-weight_required
                           weight_skip = ls_head_old-weight_skip
                           net_weight = ls_head_old-net_weight
                           gross_weight = ls_head_old-gross_weight
                           tare_weight = ls_head_old-tare_weight
                           ref_doc_number = ls_head_old-ref_doc_number
                           wtticketno = ls_head_old-wtticketno
*                           invoicenumber = ls_head_old-invoicenumber
                           bill_of_landing = COND #( WHEN ls_data_x-bill_of_landing IS NOT INITIAL THEN ls_data_u-bill_of_landing ELSE ls_head_old-bill_of_landing  )
                           grn = COND #( WHEN ls_data_x-grn IS NOT INITIAL THEN ls_data_u-grn ELSE ls_head_old-grn  )
                           cancelgrn = COND #( WHEN ls_data_x-cancelgrn IS NOT INITIAL THEN ls_data_u-cancelgrn ELSE ls_head_old-cancelgrn  )
                           grn_year = COND #( WHEN ls_data_x-grn_year IS NOT INITIAL THEN ls_data_u-grn_year ELSE ls_head_old-grn_year  )
                           grnstatus = COND #( WHEN ls_data_x-grnstatus IS NOT INITIAL THEN ls_data_u-grnstatus ELSE ls_head_old-grnstatus  )
                           grn_doc_date = COND #( WHEN ls_data_x-grn_doc_date IS NOT INITIAL THEN ls_data_u-grn_doc_date ELSE ls_head_old-grn_doc_date  )
                           grn_post_date = COND #( WHEN ls_data_x-grn_post_date IS NOT INITIAL THEN ls_data_u-grn_post_date ELSE ls_head_old-grn_post_date  )
                           grn_header_text = COND #( WHEN ls_data_x-grn_header_text IS NOT INITIAL THEN ls_data_u-grn_header_text ELSE ls_head_old-grn_header_text  )
                           delivery_note = COND #( WHEN ls_data_x-delivery_note IS NOT INITIAL THEN ls_data_u-delivery_note ELSE ls_head_old-delivery_note  )

                     )
    ).



  ENDMETHOD.
ENDCLASS.
