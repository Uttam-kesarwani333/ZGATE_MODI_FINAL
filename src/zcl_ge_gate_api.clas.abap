CLASS zcl_ge_gate_api DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.
    TYPES : tt_read_import    TYPE TABLE FOR READ IMPORT zge_r_head\\header,
            tt_read_result    TYPE TABLE FOR READ RESULT zge_r_head\\header,

            tt_fail_early     TYPE RESPONSE FOR FAILED EARLY zge_r_head,
            tt_fail_late      TYPE RESPONSE FOR FAILED LATE zge_r_head,
            tt_reported_early TYPE RESPONSE FOR REPORTED EARLY zge_r_head,
            tt_mapped_early   TYPE RESPONSE FOR MAPPED EARLY zge_r_head,

            tt_create_head    TYPE TABLE FOR CREATE zge_r_head\\header,
            tt_update_head    TYPE TABLE FOR UPDATE zge_r_head\\header,

            tt_reported_late  TYPE RESPONSE FOR REPORTED LATE zge_r_head,

            tt_delete_head    TYPE TABLE FOR DELETE zge_r_head\\header,

            tt_mapped_late    TYPE RESPONSE FOR MAPPED LATE zge_r_head,

            tt_entities_cba   TYPE TABLE FOR CREATE zge_r_head\\header\_items
            .
    " Get the instance of Class
    CLASS-METHODS : get_instance RETURNING VALUE(ro_value) TYPE REF TO zcl_ge_gate_api.

    " Instance method for RAP
    METHODS : read IMPORTING keys     TYPE tt_read_import
                   CHANGING  result   TYPE tt_read_result
                             failed   TYPE tt_fail_early
                             reported TYPE  tt_reported_early,

      create_head IMPORTING entities TYPE tt_create_head
                  CHANGING  mapped   TYPE tt_mapped_early
                            failed   TYPE tt_fail_early
                            reported TYPE tt_reported_early,
*                  RAISING
*                    cx_uuid_error,

      update_head IMPORTING entities TYPE tt_update_head
                  CHANGING  mapped   TYPE tt_mapped_early
                            failed   TYPE tt_fail_early
                            reported TYPE tt_reported_early,

      delete_head IMPORTING keys     TYPE tt_delete_head
                  CHANGING  mapped   TYPE tt_mapped_early
                            failed   TYPE tt_fail_early
                            reported TYPE tt_reported_early,

      adjust_numbers  CHANGING mapped   TYPE  tt_mapped_late
                               reported TYPE tt_reported_late,


      save        CHANGING  reported  TYPE tt_reported_late,

      "Helper methods
      set_mapped IMPORTING VALUE(it_mapped) TYPE tt_mapped_early,
      get_mapped RETURNING VALUE(rt_mapped) TYPE tt_mapped_early,
      get_new_gateid IMPORTING VALUE(lv_type)   TYPE zde_geind
                     RETURNING VALUE(rv_gateid) TYPE zge_hdr-gate_number,

      cba_item IMPORTING entities_cba TYPE tt_entities_cba
               CHANGING  mapped       TYPE tt_mapped_early
                         failed       TYPE tt_fail_early
                         reported     TYPE tt_reported_early,

      finalize  CHANGING failed   TYPE tt_fail_late
                         reported TYPE tt_reported_late,

      check_before_save CHANGING failed   TYPE tt_fail_late
                                 reported TYPE tt_reported_late,
      fetch_auth_gpass IMPORTING im_create_fail TYPE c,
      fetch_auth_create IMPORTING im_create_fail TYPE c,

      cleanup .


  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA : mo_instance    TYPE REF TO zcl_ge_gate_api,
                 gt_header      TYPE STANDARD TABLE OF zge_hdr,
                 gt_item        TYPE STANDARD TABLE OF zge_itm,
                 gr_gateid      TYPE RANGE OF zge_hdr-gate_number,
                 gv_gpass_fail  TYPE c,
                 gv_create_fail TYPE c,
                 gt_mapped_e    TYPE tt_mapped_early.
ENDCLASS.



CLASS ZCL_GE_GATE_API IMPLEMENTATION.


  METHOD adjust_numbers.

    DATA : lt_mapped_data TYPE RESPONSE FOR MAPPED EARLY zge_r_head.
*   DATA(lt_mapped_data) = get_mapped( ).
    get_mapped(
      RECEIVING
        rt_mapped = lt_mapped_data
    ).

    DATA(lv_type) = VALUE #( gt_header[ 1 ]-gate_type OPTIONAL ).

    LOOP AT lt_mapped_data-header INTO DATA(ls_mapped_data) WHERE gatenumber IS INITIAL.
      " Generate GateId
      get_new_gateid(
        EXPORTING
          lv_type   = lv_type
        RECEIVING
          rv_gateid = DATA(lv_new_gateid)
      ).
*      DATA(lv_new_gateid) = get_new_gateid( ).
      lv_new_gateid =  |{ lv_new_gateid ALPHA = IN WIDTH = 10 }|.
      "Update the buffer
      READ TABLE gt_header ASSIGNING FIELD-SYMBOL(<fs_head>) INDEX 1.
      IF <fs_head> IS ASSIGNED.
        <fs_head>-gate_number = lv_new_gateid.
        <fs_head>-client = sy-mandt.
        <fs_head>-created_by = sy-uname.
        UNASSIGN <fs_head>.
      ENDIF.

      " Filled the map parameter
      mapped = VALUE #(
                        header = VALUE #( BASE mapped-header
                                          ( %pid = ls_mapped_data-%pid
                                             gatenumber = lv_new_gateid
                                           )
                                          )
                      ).
    ENDLOOP.

    LOOP AT lt_mapped_data-item INTO DATA(ls_mapped_data_i) WHERE gatenumber IS INITIAL ##READ_WHERE_OK.
      READ TABLE gt_item ASSIGNING FIELD-SYMBOL(<fs_item>) WHERE item_number = ls_mapped_data_i-itemnumber ##READ_WHERE_OK.
      IF <fs_item> IS ASSIGNED.
        <fs_item>-gate_number = lv_new_gateid.
        <fs_item>-client = sy-mandt.
        IF <fs_item>-uom IS NOT INITIAL.
          <fs_item>-meins = <fs_item>-uom.
        ENDIF.
        UNASSIGN <fs_item>.
      ENDIF.
      " Filled the map parameter
      APPEND INITIAL LINE TO mapped-item ASSIGNING FIELD-SYMBOL(<fs_mapped_i>).
      IF <fs_mapped_i> IS ASSIGNED.
        <fs_mapped_i> = CORRESPONDING #( ls_mapped_data_i ).
        <fs_mapped_i>-%pid = ls_mapped_data_i-%pid.
        <fs_mapped_i>-gatenumber = lv_new_gateid.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD cba_item.

    DATA : max_line_id TYPE zde_gepos,
           lt_item_cba TYPE TABLE FOR CREATE zge_r_head\\header\_items.

    lt_item_cba = CORRESPONDING #( DEEP  entities_cba ).
    ""Step 1: get all the travel requests and their Item data
    READ ENTITIES OF zge_r_head
        ENTITY header BY \_items
        FROM CORRESPONDING #( entities_cba )
        LINK DATA(items).


    ""Loop at unique travel ids
    LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<item_group>) GROUP BY <item_group>-gatenumber.

      ""Step 2: get the highest item number which is already there
      LOOP AT items INTO DATA(ls_item) USING KEY entity
          WHERE source-gatenumber = <item_group>-gatenumber.
        IF max_line_id < ls_item-target-itemnumber.
          max_line_id = ls_item-target-itemnumber.
        ENDIF.
      ENDLOOP.

      ""Step 3: get the asigned Item numbers for incoming request
      LOOP AT entities_cba INTO DATA(ls_entity) USING KEY entity
          WHERE gatenumber = <item_group>-gatenumber.
        LOOP AT ls_entity-%target INTO DATA(ls_target).
          IF max_line_id < ls_target-itemnumber.
            max_line_id = ls_target-itemnumber.
          ENDIF.
        ENDLOOP.
      ENDLOOP.

      ""Step 4: loop over all the entities of travel with same travel id
      LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<fs_entiry>)
          USING KEY entity WHERE gatenumber = <item_group>-gatenumber.

        ""Step 5: assign new booking IDs to the booking entity inside each travel
        LOOP AT <fs_entiry>-%target ASSIGNING FIELD-SYMBOL(<item_wo_numbers>).
          APPEND CORRESPONDING #( <item_wo_numbers> ) TO mapped-item
          ASSIGNING FIELD-SYMBOL(<mapped_item>).
          IF <mapped_item>-itemnumber IS INITIAL.
            max_line_id += 10.
            <mapped_item>-itemnumber = max_line_id.
          ENDIF.
          IF <item_group>-gatenumber IS NOT INITIAL.
            IF <item_wo_numbers>-gatenumber IS INITIAL.
*             <item_wo_numbers>-GateNumber = <item_group>-gatenumber.
              <mapped_item>-gatenumber = <item_group>-gatenumber.
            ENDIF.
          ENDIF.
        ENDLOOP.

      ENDLOOP.
    ENDLOOP.

    " Store the record in Buffer
*    gt_item = CORRESPONDING #( entities_cba MAPPING FROM ENTITY ).
    gt_item = CORRESPONDING #( <fs_entiry>-%target MAPPING FROM ENTITY  ).

    IF <fs_entiry> IS ASSIGNED.
      IF <fs_entiry>-gatenumber IS NOT INITIAL.
        LOOP AT gt_item ASSIGNING FIELD-SYMBOL(<fs_item_i>) WHERE gate_number IS INITIAL.
          <fs_item_i>-gate_number = <fs_entiry>-gatenumber.
        ENDLOOP.
      ENDIF.
    ENDIF.

    "store the mapping
    set_mapped( it_mapped = mapped ).
  ENDMETHOD.


  METHOD check_before_save.

    DATA : lt_mapped_data TYPE RESPONSE FOR MAPPED EARLY zge_r_head.
*   DATA(lt_mapped_data) = get_mapped( ).
    get_mapped(
      RECEIVING
        rt_mapped = lt_mapped_data
    ).

    LOOP AT lt_mapped_data-header INTO DATA(ls_mapped_data) .
      " Clear State Area for message

      reported-header = VALUE #( BASE reported-header
                                ( %key = ls_mapped_data-%key
                                 %pid = ls_mapped_data-%pid
                                 %state_area = 'GATE_IN_DATE'
                                 )
                              ).

      READ TABLE gt_header ASSIGNING FIELD-SYMBOL(<fs_head>) INDEX 1.
      IF <fs_head> IS ASSIGNED.
        IF <fs_head>-gate_in_date < <fs_head>-vendor_invoice_dt.
*          APPEND VALUE #( %key = ls_mapped_data-%key
*                          %pid = ls_mapped_data-%pid
*                          %fail-cause = if_abap_behv=>cause-conflict
*                           ) TO failed-header.
*
*          APPEND VALUE #(  %key = ls_mapped_data-%key
*                         %pid = ls_mapped_data-%pid
*                         %state_area = 'GATE_IN_DATE'
*                          %msg = NEW zcx_gate(
*            textid      = zcx_gate=>gate_in_date
*            severity    = if_abap_behv_message=>severity-error
*            gate_in_data = |{ <fs_head>-gate_in_date DATE = USER }|
*            vendor_inv_date = |{ <fs_head>-vendor_invoice_dt DATE = USER }|
*
*          )
*                          %element-gateindate = if_abap_behv=>mk-on
*                          %element-vendorinvoicedt = if_abap_behv=>mk-on  )
*              TO reported-header.
        ENDIF.

        SELECT SINGLE FROM i_purchaseorderapi01
         FIELDS purchaseorderdate
         WHERE purchaseorder = @<fs_head>-ebeln
         INTO @DATA(lv_po_doc_date) PRIVILEGED ACCESS.
        IF sy-subrc = 0.
          IF <fs_head>-vendor_invoice_dt < lv_po_doc_date.

            APPEND VALUE #( %key = ls_mapped_data-%key
                            %pid = ls_mapped_data-%pid
                            %fail-cause = if_abap_behv=>cause-conflict
                             ) TO failed-header.

            APPEND VALUE #(  %key = ls_mapped_data-%key
                           %pid = ls_mapped_data-%pid
                           %state_area = 'PO_DOC_DATE'
                            %msg = NEW zcx_gate(
              textid      = zcx_gate=>po_doc_date
              severity    = if_abap_behv_message=>severity-error
              po_doc_date = |{ lv_po_doc_date DATE = USER }|
              vendor_inv_date = |{ <fs_head>-vendor_invoice_dt DATE = USER }|

            )
                            %element-vendorinvoicedt = if_abap_behv=>mk-on  )
                TO reported-header.

          ENDIF.
        ENDIF.
        """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Start Code by Pawan
        IF <fs_head>-gate_type = 'Purchase'.
          SELECT * FROM i_purchaseorderitemapi01
                   WHERE purchaseorder = @<fs_head>-ebeln
                   INTO TABLE @DATA(lt_item) PRIVILEGED ACCESS.
          IF sy-subrc EQ 0.
            LOOP AT gt_item INTO DATA(gs_item).
              READ TABLE lt_item INTO DATA(ls_item) WITH KEY material = gs_item-matnr.
              IF ls_item IS INITIAL.
                APPEND VALUE #( %key = ls_mapped_data-%key
                                            %pid = ls_mapped_data-%pid
                                            %fail-cause = if_abap_behv=>cause-conflict
                                             ) TO failed-header.


                APPEND VALUE #(  %key = ls_mapped_data-%key
  %pid = ls_mapped_data-%pid
  %state_area = 'MATNR_NUM'
   %msg = NEW zcx_gate(
textid      = zcx_gate=>matnr_num
severity    = if_abap_behv_message=>severity-error
matnr_num   = CONV #( gs_item-matnr )
)
   %element-vendorinvoicedt = if_abap_behv=>mk-on  )
TO reported-header.

              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDIF.

        IF <fs_head>-gate_type = 'Gate Pass' AND <fs_head>-gate_pass_type = 'Returnable' AND <fs_head>-gate_status = 'Open'.
          LOOP AT gt_item INTO DATA(gs1_item).
            IF gs1_item-qty_in > gs1_item-qty_out.
              APPEND VALUE #( %key = ls_mapped_data-%key
                                          %pid = ls_mapped_data-%pid
                                          %fail-cause = if_abap_behv=>cause-conflict
                                           ) TO failed-header.


              APPEND VALUE #(  %key = ls_mapped_data-%key
%pid = ls_mapped_data-%pid
%state_area = 'QTY_IN'
 %msg = NEW zcx_gate(
textid      = zcx_gate=>qty_in
severity    = if_abap_behv_message=>severity-error
qty_in   = CONV #( gs1_item-qty_in )
)
 %element-vendorinvoicedt = if_abap_behv=>mk-on  )
TO reported-header.

            ENDIF.
          ENDLOOP.
        ENDIF.



        """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" End Code by Pawan
        IF <fs_head>-gate_type = 'Sales' AND <fs_head>-invoicenumber IS NOT INITIAL.
          SELECT SINGLE FROM zge_hdr
           FIELDS gate_number,
                  invoicenumber
          WHERE invoicenumber = @<fs_head>-invoicenumber
            AND gate_number <> @<fs_head>-gate_number
            AND is_cancelled = @space
            INTO @DATA(ls_inv_exist).
          IF sy-subrc = 0.
            APPEND VALUE #( %key = ls_mapped_data-%key
                            %pid = ls_mapped_data-%pid
                            %fail-cause = if_abap_behv=>cause-conflict
                             ) TO failed-header.

            APPEND VALUE #(  %key = ls_mapped_data-%key
                           %pid = ls_mapped_data-%pid
                           %state_area = 'INV_NUM'
                            %msg = NEW zcx_gate(
              textid      = zcx_gate=>inv_exists
              severity    = if_abap_behv_message=>severity-error
              inv_num     = CONV #( <fs_head>-invoicenumber )
              gate_number = ls_inv_exist-gate_number

            )
                            %element-vendorinvoicedt = if_abap_behv=>mk-on  )
                TO reported-header.

          ENDIF.
          CLEAR : ls_inv_exist.
        ENDIF.

        IF  gv_gpass_fail = 'X' AND <fs_head>-gate_type = 'Gate Pass'.
          APPEND VALUE #( %key = ls_mapped_data-%key
                          %pid = ls_mapped_data-%pid
                          %fail-cause = if_abap_behv=>cause-conflict
                           ) TO failed-header.

          APPEND VALUE #(  %key = ls_mapped_data-%key
                         %pid = ls_mapped_data-%pid
                         %state_area = 'INV_NUM'
                          %msg = NEW zcx_gate(
            textid      = zcx_gate=>no_gpass_auth
            severity    = if_abap_behv_message=>severity-error

          )
                          %element-vendorinvoicedt = if_abap_behv=>mk-on  )
              TO reported-header.
        ENDIF.

        IF  gv_create_fail = 'X' AND <fs_head>-gate_type <> 'Gate Pass'.
          APPEND VALUE #( %key = ls_mapped_data-%key
                          %pid = ls_mapped_data-%pid
                          %fail-cause = if_abap_behv=>cause-conflict
                           ) TO failed-header.

          APPEND VALUE #(  %key = ls_mapped_data-%key
                         %pid = ls_mapped_data-%pid
                         %state_area = 'INV_NUM'
                          %msg = NEW zcx_gate(
            textid      = zcx_gate=>no_gpass_auth
            severity    = if_abap_behv_message=>severity-error

          )
                          %element-vendorinvoicedt = if_abap_behv=>mk-on  )
              TO reported-header.
        ENDIF.

        UNASSIGN <fs_head>.
      ENDIF.

    ENDLOOP.


  ENDMETHOD.


  METHOD cleanup.
    CLEAR : gt_header,gt_item,gt_mapped_e.
  ENDMETHOD.


  METHOD create_head.
    " Store the record in Buffer
    gt_header = CORRESPONDING #( entities MAPPING FROM ENTITY ).

    " Fill mapped parameter
    TRY.
        mapped = VALUE #(
                          header = VALUE #( FOR ls_keys IN entities
                                           (
                                            %key = ls_keys-%key
                                            %cid = ls_keys-%cid
                                            %pid = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( )
                                          )
                                          )
                         ).
      CATCH cx_uuid_error  ##NO_HANDLER.
        "handle exception
    ENDTRY.
    "store the mapping
    set_mapped( it_mapped = mapped ).
    DATA(ls_map_head) = VALUE #( mapped-header[ 1 ] OPTIONAL ).
    LOOP AT entities INTO DATA(ls_entity) WHERE purchasingdoc IS NOT INITIAL.

      SELECT SINGLE FROM i_purchaseorderapi01
      FIELDS releaseisnotcompleted
      WHERE purchaseorder = @ls_entity-purchasingdoc
      INTO @DATA(lv_not_released).
      IF lv_not_released = 'X'.

        APPEND VALUE #( %cid = ls_entity-%cid
                        %key = ls_entity-%key
                        %pid = ls_map_head-%pid
                        %fail-cause = if_abap_behv=>cause-conflict
                         ) TO failed-header.

        APPEND VALUE #( %cid = ls_entity-%cid
                       %key = ls_entity-%key
                       %pid = ls_map_head-%pid
                       %state_area = 'RELEASE_PO'
                        %msg = NEW zcx_gate(
          textid      = zcx_gate=>po_not_release
          severity    = if_abap_behv_message=>severity-error
          po_number   = ls_entity-purchasingdoc
        )
                        %element-gateindate = if_abap_behv=>mk-on
                        %element-vendorinvoiceno = if_abap_behv=>mk-on )
            TO reported-header.
      ENDIF.

    ENDLOOP.
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


  METHOD fetch_auth_create.
    gv_create_fail = im_create_fail.
  ENDMETHOD.


  METHOD fetch_auth_gpass.
    gv_gpass_fail = im_create_fail.
  ENDMETHOD.


  METHOD finalize.
    TYPES : t_insp TYPE c LENGTH 12.

    DATA(ls_header) = VALUE #( gt_header[ 1 ] OPTIONAL ).

    SELECT FROM i_productinsptypesetting  AS a
    INNER JOIN @gt_item AS b  ON (  a~product = b~matnr AND
                                    a~plant = b~werks )
    FIELDS a~product,
           a~plant,
           a~inspectionlottype
    WHERE inspectionlottype = '89'
    INTO TABLE @DATA(lt_prodinsptype)  PRIVILEGED ACCESS .

    IF ls_header-gate_type = 'Purchase' AND ls_header-gate_status = 'Open'.
      SELECT FROM zge_itm
        FIELDS matnr,
               werks
      WHERE gate_number = @ls_header-gate_number
      INTO TABLE @DATA(lt_item_m) PRIVILEGED ACCESS.
      IF sy-subrc = 0.
        SELECT FROM i_product AS a
        INNER JOIN zge_matkl AS b ON a~productgroup = b~material_group
        INNER JOIN @lt_item_m AS c  ON a~product = c~matnr
        FIELDS a~product,
               a~productgroup
       INTO TABLE @DATA(lt_matkl) PRIVILEGED ACCESS.
*   ## ITAB_KEY_IN_SELECT .
*        IF lt_matkl[] IS NOT INITIAL.
        IF lt_matkl[] IS INITIAL.
          READ TABLE gt_header ASSIGNING FIELD-SYMBOL(<fs_header>) INDEX 1.
          IF sy-subrc = 0 AND <fs_header> IS ASSIGNED.
            <fs_header>-gate_status = 'Gate Out Pending'.
            UNASSIGN <fs_header>.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Code Added By Pawan
*    IF ls_header-gate_type = 'Gate Pass' AND ls_header-gate_pass_type = 'Returnable' AND ls_header-gate_status = 'Open'.
*      READ TABLE gt_header ASSIGNING <fs_header> INDEX 1.
*      IF sy-subrc = 0 AND <fs_header> IS ASSIGNED.
*        <fs_header>-gate_status = 'Gate Out Pending'.
*        UNASSIGN <fs_header>.
*      ENDIF.
*    ENDIF.
    IF ls_header-gate_type = 'Gate Pass' AND ls_header-gate_pass_type = 'Returnable' AND ls_header-gate_status = 'Gate In Pending'.
      READ TABLE gt_header ASSIGNING <fs_header> INDEX 1.
      IF sy-subrc = 0 AND <fs_header> IS ASSIGNED.
        <fs_header>-gate_status = 'Gate Out Pending'.
        UNASSIGN <fs_header>.
      ENDIF.
    ENDIF.
    IF ls_header-gate_type = 'Gate Pass' AND ls_header-gate_pass_type = 'Returnable' AND ls_header-gate_status = 'Close'.
      READ TABLE gt_header ASSIGNING <fs_header> INDEX 1.
      IF sy-subrc = 0 AND <fs_header> IS ASSIGNED.
        <fs_header>-gate_status = 'Gate In Pending'.
        UNASSIGN <fs_header>.
      ENDIF.
    ENDIF.
    IF ls_header-gate_type = 'Gate Pass' AND ls_header-gate_pass_type = 'Returnable' AND ls_header-gate_status = 'Open'.
      READ TABLE gt_header ASSIGNING <fs_header> INDEX 1.
      IF sy-subrc = 0 AND <fs_header> IS ASSIGNED.
        <fs_header>-gate_status = 'Close'.
        UNASSIGN <fs_header>.
      ENDIF.
    ENDIF.
    IF ls_header-gate_type = 'Gate Pass' AND ls_header-gate_pass_type = 'Non Returnable' AND ls_header-gate_status = 'Gate In Pending'.
      READ TABLE gt_header ASSIGNING <fs_header> INDEX 1.
      IF sy-subrc = 0 AND <fs_header> IS ASSIGNED.
        <fs_header>-gate_status = 'Gate Out Pending'.
        UNASSIGN <fs_header>.
      ENDIF.
    ENDIF.
    IF ls_header-gate_type = 'Manual' AND ls_header-weight_required NE 'X' AND ls_header-gate_status = 'Open'.
      READ TABLE gt_header ASSIGNING <fs_header> INDEX 1.
      IF sy-subrc = 0 AND <fs_header> IS ASSIGNED.
        <fs_header>-gate_status = 'Gate Out Pending'.
        UNASSIGN <fs_header>.
      ENDIF.
    ENDIF.

*    IF ls_header-gate_type = 'Sales' AND ls_header-gate_status = 'Gate In Pending'.
*      SELECT SINGLE * FROM i_billingdocumentbasic
*      WHERE billingdocument = @ls_header-invoicenumber
*      INTO @DATA(ls_billing).
*      READ TABLE gt_header ASSIGNING <fs_header> INDEX 1.
*      IF sy-subrc = 0 AND <fs_header> IS ASSIGNED.
*        <fs_header>-vehichle_no = ls_billing-yy1_vehicleno_bdh.
*        <fs_header>-lr_rr_no = ls_billing-yy1_lrgcno_bdh.
*        UNASSIGN <fs_header>.
*      ENDIF.
*    ENDIF.
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" Code Ended By Pawan


    LOOP AT gt_item ASSIGNING FIELD-SYMBOL(<fs_item>).
*      IF <fs_item>-gate_number IS INITIAL AND (  <fs_item>-matnr = '000000000000000002' OR <fs_item>-matnr = '000000000000000041' ).
      IF <fs_item>-gate_number IS INITIAL AND line_exists( lt_prodinsptype[ product = <fs_item>-matnr plant = <fs_item>-werks ] )
       AND ls_header-gate_type = 'Purchase'.
        MODIFY ENTITY i_inspectionlottp_2
            CREATE FIELDS ( material batch plant inspectionlottype inspectionlotquantity )
                WITH VALUE #( (
                    %cid = 'CID_001'
                    material = <fs_item>-matnr
*                    batch = 'PREGRN' " Commented By Pawan
                    plant = <fs_item>-werks
                    inspectionlottype = '89'
                    inspectionlotquantity = <fs_item>-qty_received ) )
            MAPPED DATA(mapped_insp)
            REPORTED DATA(lt_reported_insp)
            FAILED DATA(lt_failed_insp).
        IF lt_failed_insp IS INITIAL.
          READ TABLE gt_header ASSIGNING FIELD-SYMBOL(<fs_head>) INDEX 1.
          IF <fs_head> IS ASSIGNED .
            DATA(lv_insp_lot) = mapped_insp-inspectionlot[ 1 ]-inspectionlot .
            <fs_head>-pre_grn_qc =  lv_insp_lot .
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_instance.
    mo_instance = ro_value = COND #( WHEN mo_instance IS BOUND THEN mo_instance
                                     ELSE NEW #(  ) ).
  ENDMETHOD.


  METHOD get_mapped.
    rt_mapped = gt_mapped_e.
  ENDMETHOD.


  METHOD get_new_gateid.

    DATA: gate_id_max      TYPE zde_genum,
          use_number_range TYPE abap_bool VALUE abap_true,
          lv_nr_range_nr   TYPE cl_numberrange_runtime=>nr_interval,
          lt_mapped_data   TYPE RESPONSE FOR MAPPED EARLY zge_r_head.



    IF use_number_range = abap_true.
      ""Step 2: Get the seuquence numbers from the SNRO
      IF lv_type = 'Purchase'.
        lv_nr_range_nr = 'G1'.
      ELSEIF lv_type = 'Sales'.
        lv_nr_range_nr = 'G2'.
      ELSEIF lv_type = 'Manual'.
        lv_nr_range_nr = 'G3'.
      ELSE.
        lv_nr_range_nr = 'G4'.
      ENDIF.
      TRY.
          cl_numberrange_runtime=>number_get(
            EXPORTING
              nr_range_nr       = lv_nr_range_nr"'G1'
              object            = CONV #( 'Z_NR_GATE' )
              quantity          =  1
            IMPORTING
              number            = DATA(number_range_key)
              returncode        = DATA(number_range_return_code)
              returned_quantity = DATA(number_range_returned_quantity)
          ).

        CATCH cx_number_ranges INTO DATA(lx_number_ranges).
          ""Step 3: If there is an exception, we will throw the error
*          LOOP AT lt_mapped_data-header INTO DATA(ls_mapped).
*            APPEND VALUE #( %cid = ls_mapped-%cid %key = ls_mapped-%key %msg = lx_number_ranges )
*                TO reported-header.
**            APPEND VALUE #( %cid = entity-%cid %key = entity-%key ) TO failed-header.
*          ENDLOOP.
          EXIT.
      ENDTRY.

      ""Step 6: Final check for all numbers
*      ASSERT number_range_returned_quantity = lines( entities_wo_gateid ).
      ASSERT number_range_returned_quantity = 1.

      ""Step 7: Loop over the incoming travel data and asign the numbers from number range and
      ""        return MAPPED data which will then go to RAP framework
      gate_id_max = number_range_key - number_range_returned_quantity.
      rv_gateid = gate_id_max.
    ELSE.

      " Get new Gate Number
      SELECT FROM zge_hdr
       FIELDS MAX( gate_number )
       WHERE gate_number IS NOT INITIAL
       INTO @rv_gateid.

      IF rv_gateid IS INITIAL.
        rv_gateid = '1000'.
      ENDIF.
    ENDIF.
    rv_gateid += 1.

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


    " Store the record into DB
    IF gt_header IS NOT INITIAL.

      READ TABLE gt_header ASSIGNING FIELD-SYMBOL(<fs_header>) INDEX 1.
      IF sy-subrc = 0.
        IF <fs_header>-gate_status = 'Close'.
          <fs_header>-gate_out_date = cl_abap_context_info=>get_system_date( ).
          <fs_header>-gate_out_time = xco_cp=>sy->time( xco_cp_time=>time_zone->user
                                       )->add( iv_hour = 5 iv_minute = 30 iv_second = 0
                                       )->as( xco_cp_time=>format->abap
                                       )->value.  "cl_abap_context_info=>get_system_time( ).
        ENDIF.
      ENDIF.
      MODIFY zge_hdr FROM TABLE @gt_header.

      IF gt_item IS NOT INITIAL.
        DATA(lv_gateid) = VALUE zde_genum( gt_item[ 1 ]-gate_number OPTIONAL ).

        DELETE FROM zge_itm WHERE gate_number = @lv_gateid.


        MODIFY zge_itm FROM TABLE @gt_item.

      ENDIF.

**********************************************************************


      get_mapped(
        RECEIVING
          rt_mapped = lt_mapped_data
      ).

      DATA(lv_gate_number) = VALUE #( gt_header[ 1 ]-gate_number OPTIONAL ).
      LOOP AT lt_mapped_data-header INTO DATA(ls_mapped_data) .
        " Clear State Area for message

        ls_mapped_data-%key-gatenumber = lv_gate_number.
        APPEND VALUE #(  %key = ls_mapped_data-%key
                       %pid = ls_mapped_data-%pid
                       gatenumber = lv_gate_number
                       %state_area = 'GATE_SAVE'

                        %msg = NEW zcx_gate(
          textid      = zcx_gate=>gate_save
          severity    = if_abap_behv_message=>severity-success
          gate_number = lv_gate_number

        )
          )
            TO reported-header.

      ENDLOOP.
**********************************************************************
    ENDIF.

    " Delete the record in reverse sequence Item >> Header
    IF gr_gateid[] IS NOT INITIAL.
      " Delete the Item
      DELETE FROM zge_itm WHERE gate_number IN @gr_gateid.

      "Delete Header
      DELETE FROM zge_hdr WHERE gate_number IN @gr_gateid.
    ENDIF.



  ENDMETHOD.


  METHOD set_mapped.
    DATA : lt_mapped_e TYPE tt_mapped_early.
    lt_mapped_e = VALUE #(
                           header = COND #( WHEN it_mapped-header IS NOT INITIAL THEN it_mapped-header
                                            ELSE gt_mapped_e-header  )

                           item = COND #( WHEN it_mapped-item IS NOT INITIAL THEN it_mapped-item
                                          ELSE gt_mapped_e-item
                                          )
                          )
    .
    gt_mapped_e = CORRESPONDING #( DEEP lt_mapped_e ).

  ENDMETHOD.                                             "#EC CI_VALPAR


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
                           reporting_date = ls_head_old-reporting_date
                           reporting_time = ls_head_old-reporting_time
                           init_weighbridgecode = ls_head_old-init_weighbridgecode
                           final_weighbridgecode = ls_head_old-final_weighbridgecode
                           wtticketno = ls_head_old-wtticketno
                           gross_weight = ls_head_old-gross_weight
                           tare_weight = ls_head_old-tare_weight
                           packing_unit = ls_head_old-packing_unit
                           net_weight = ls_head_old-net_weight
                           vendor_slip = ls_head_old-vendor_slip
                           vendor_gross_weight = ls_head_old-vendor_gross_weight
                           vendor_tare_weight = ls_head_old-vendor_tare_weight
                           grn = ls_head_old-grn
                           grnstatus = ls_head_old-grnstatus
                           grn_doc_date = ls_head_old-grn_doc_date
                           grn_header_text = ls_head_old-grn_header_text
                           grn_post_date = ls_head_old-grn_post_date
                           grn_year = ls_head_old-grn_year
*                           return_date = ls_head_old-return_date
*                           return_time = ls_head_old-return_time
*                           visitor = ls_head_old-visitor
                           init_wt_date = ls_head_old-init_wt_date
                           init_wt_time = ls_head_old-init_wt_time
                           final_wt_date = ls_head_old-final_wt_date
                           final_wt_time = ls_head_old-final_wt_time
*                           number_of_person = ls_head_old-number_of_person
*                           contact_number = ls_head_old-contact_number
*                           purpose = ls_head_old-purpose
*                           person_arrived = ls_head_old-person_arrived
*                           person_concerned = ls_head_old-person_concerned
                           gate_type = COND #( WHEN ls_data_x-gate_type IS NOT INITIAL THEN ls_data_u-gate_type ELSE ls_head_old-gate_type  )
                           gate_pass_type = COND #( WHEN ls_data_x-gate_pass_type IS NOT INITIAL THEN ls_data_u-gate_pass_type ELSE ls_head_old-gate_pass_type  )
                           gatepasscode = COND #( WHEN ls_data_x-gatepasscode IS NOT INITIAL THEN ls_data_u-gatepasscode ELSE ls_head_old-gatepasscode  )
                           entry_gate = COND #( WHEN ls_data_x-entry_gate IS NOT INITIAL THEN ls_data_u-entry_gate ELSE ls_head_old-entry_gate  )
                           gate_status = COND #( WHEN ls_data_x-gate_status IS NOT INITIAL THEN ls_data_u-gate_status ELSE ls_head_old-gate_status  )
                           is_cancelled = COND #( WHEN ls_data_x-is_cancelled IS NOT INITIAL THEN ls_data_u-is_cancelled ELSE ls_head_old-is_cancelled  )
                           vehichle_no = COND #( WHEN ls_data_x-vehichle_no IS NOT INITIAL THEN ls_data_u-vehichle_no ELSE ls_head_old-vehichle_no  )
                           lr_rr_no = COND #( WHEN ls_data_x-lr_rr_no IS NOT INITIAL THEN ls_data_u-lr_rr_no ELSE ls_head_old-lr_rr_no  )
                           bill_of_landing = COND #( WHEN ls_data_x-bill_of_landing IS NOT INITIAL THEN ls_data_u-bill_of_landing ELSE ls_head_old-bill_of_landing  )
                           vendor_invoice_no = COND #( WHEN ls_data_x-vendor_invoice_no IS NOT INITIAL THEN ls_data_u-vendor_invoice_no ELSE ls_head_old-vendor_invoice_no  )
                           vendor_invoice_dt = COND #( WHEN ls_data_x-vendor_invoice_dt IS NOT INITIAL THEN ls_data_u-vendor_invoice_dt ELSE ls_head_old-vendor_invoice_dt  )
                           gate_in_date = COND #( WHEN ls_data_x-gate_in_date IS NOT INITIAL THEN ls_data_u-gate_in_date ELSE ls_head_old-gate_in_date  )
                           gate_in_time = COND #( WHEN ls_data_x-gate_in_time IS NOT INITIAL THEN ls_data_u-gate_in_time ELSE ls_head_old-gate_in_time  )
                           gate_out_date = COND #( WHEN ls_data_x-gate_out_date IS NOT INITIAL THEN ls_data_u-gate_out_date ELSE ls_head_old-gate_out_date  )
                           gate_out_time = COND #( WHEN ls_data_x-gate_out_time IS NOT INITIAL THEN ls_data_u-gate_out_time ELSE ls_head_old-gate_out_time  )
                           ebeln = COND #( WHEN ls_data_x-ebeln IS NOT INITIAL THEN ls_data_u-ebeln ELSE ls_head_old-ebeln  )
                           vbeln = COND #( WHEN ls_data_x-vbeln IS NOT INITIAL THEN ls_data_u-vbeln ELSE ls_head_old-vbeln  )
                           invoicenumber = COND #( WHEN ls_data_x-invoicenumber IS NOT INITIAL THEN ls_data_u-invoicenumber ELSE ls_head_old-invoicenumber  )
                           lifnr = COND #( WHEN ls_data_x-lifnr IS NOT INITIAL THEN ls_data_u-lifnr ELSE ls_head_old-lifnr  )
                           supplier_name = COND #( WHEN ls_data_x-supplier_name IS NOT INITIAL THEN ls_data_u-supplier_name ELSE ls_head_old-supplier_name  )
                           kunnr = COND #( WHEN ls_data_x-kunnr IS NOT INITIAL THEN ls_data_u-kunnr ELSE ls_head_old-kunnr  )
                           customer_name = COND #( WHEN ls_data_x-customer_name IS NOT INITIAL THEN ls_data_u-customer_name ELSE ls_head_old-customer_name  )
                           werks = COND #( WHEN ls_data_x-werks IS NOT INITIAL THEN ls_data_u-werks ELSE ls_head_old-werks  )
                           plantname = COND #( WHEN ls_data_x-plantname IS NOT INITIAL THEN ls_data_u-plantname ELSE ls_head_old-plantname  )
*                           gross_weight = COND #( WHEN ls_data_x-gross_weight IS NOT INITIAL THEN ls_data_u-gross_weight ELSE ls_head_old-gross_weight  )
*                           tare_weight = COND #( WHEN ls_data_x-tare_weight IS NOT INITIAL THEN ls_data_u-tare_weight ELSE ls_head_old-tare_weight  )
*                           packing_unit = COND #( WHEN ls_data_x-packing_unit IS NOT INITIAL THEN ls_data_u-packing_unit ELSE ls_head_old-packing_unit  )
*                           net_weight = COND #( WHEN ls_data_x-net_weight IS NOT INITIAL THEN ls_data_u-net_weight ELSE ls_head_old-net_weight  )
                           weight_required = COND #( WHEN ls_data_x-weight_required IS NOT INITIAL THEN ls_data_u-weight_required ELSE ls_head_old-weight_required  )
                           weight_skip = COND #( WHEN ls_data_x-weight_skip IS NOT INITIAL THEN ls_data_u-weight_skip ELSE ls_head_old-weight_skip  )
*                           init_wt_date = COND #( WHEN ls_data_x-init_wt_date IS NOT INITIAL THEN ls_data_u-init_wt_date ELSE ls_head_old-init_wt_date  )
*                           init_wt_time = COND #( WHEN ls_data_x-init_wt_time IS NOT INITIAL THEN ls_data_u-init_wt_time ELSE ls_head_old-init_wt_time  )
*                           final_wt_date = COND #( WHEN ls_data_x-final_wt_date IS NOT INITIAL THEN ls_data_u-final_wt_date ELSE ls_head_old-final_wt_date  )
*                           final_wt_time = COND #( WHEN ls_data_x-final_wt_time IS NOT INITIAL THEN ls_data_u-final_wt_time ELSE ls_head_old-final_wt_time  )
*                           vendor_slip = COND #( WHEN ls_data_x-vendor_slip IS NOT INITIAL THEN ls_data_u-vendor_slip ELSE ls_head_old-vendor_slip  )
*                           vendor_gross_weight = COND #( WHEN ls_data_x-vendor_gross_weight IS NOT INITIAL THEN ls_data_u-vendor_gross_weight ELSE ls_head_old-vendor_gross_weight  )
*                           vendor_tare_weight = COND #( WHEN ls_data_x-vendor_tare_weight IS NOT INITIAL THEN ls_data_u-vendor_tare_weight ELSE ls_head_old-vendor_tare_weight  )
*                           grn = COND #( WHEN ls_data_x-grn IS NOT INITIAL THEN ls_data_u-grn ELSE ls_head_old-grn  )
*                           grn_year = COND #( WHEN ls_data_x-grn_year IS NOT INITIAL THEN ls_data_u-grn_year ELSE ls_head_old-grn_year  )
                           pre_grn_qc = COND #( WHEN ls_data_x-pre_grn_qc IS NOT INITIAL THEN ls_data_u-pre_grn_qc ELSE ls_head_old-pre_grn_qc  )
                           purpose = COND #( WHEN ls_data_x-purpose IS NOT INITIAL THEN ls_data_u-purpose ELSE ls_head_old-purpose  )
                           person_concerned = COND #( WHEN ls_data_x-person_concerned IS NOT INITIAL THEN ls_data_u-person_concerned ELSE ls_head_old-person_concerned  )
                           person_arrived = COND #( WHEN ls_data_x-person_arrived IS NOT INITIAL THEN ls_data_u-person_arrived ELSE ls_head_old-person_arrived  )
                           contact_number = COND #( WHEN ls_data_x-contact_number IS NOT INITIAL THEN ls_data_u-contact_number ELSE ls_head_old-contact_number  )
                           number_of_person = COND #( WHEN ls_data_x-number_of_person IS NOT INITIAL THEN ls_data_u-number_of_person ELSE ls_head_old-number_of_person  )
                           return_date = COND #( WHEN ls_data_x-return_date IS NOT INITIAL THEN ls_data_u-return_date ELSE ls_head_old-return_date  )
                           return_time = COND #( WHEN ls_data_x-return_time IS NOT INITIAL THEN ls_data_u-return_time ELSE ls_head_old-return_time  )
                           driver_name = COND #( WHEN ls_data_x-driver_name IS NOT INITIAL THEN ls_data_u-driver_name ELSE ls_head_old-driver_name  )
                           driver_number = COND #( WHEN ls_data_x-driver_number IS NOT INITIAL THEN ls_data_u-driver_number ELSE ls_head_old-driver_number  )
                           transporter = COND #( WHEN ls_data_x-transporter IS NOT INITIAL THEN ls_data_u-transporter ELSE ls_head_old-transporter  )
                           transporter_name = COND #( WHEN ls_data_x-transporter_name IS NOT INITIAL THEN ls_data_u-transporter_name ELSE ls_head_old-transporter_name  )
                           vehicle_type = COND #( WHEN ls_data_x-vehicle_type IS NOT INITIAL THEN ls_data_u-vehicle_type ELSE ls_head_old-vehicle_type  )
                           driver_lic = COND #( WHEN ls_data_x-driver_lic IS NOT INITIAL THEN ls_data_u-driver_lic ELSE ls_head_old-driver_lic  )
                           remark = COND #( WHEN ls_data_x-remark IS NOT INITIAL THEN ls_data_u-remark ELSE ls_head_old-remark  )
                           cancel_remark = COND #( WHEN ls_data_x-cancel_remark IS NOT INITIAL THEN ls_data_u-cancel_remark ELSE ls_head_old-cancel_remark  )
                           visitor = COND #( WHEN ls_data_x-visitor IS NOT INITIAL THEN ls_data_u-visitor ELSE ls_head_old-visitor  )
                           del_flag = COND #( WHEN ls_data_x-del_flag IS NOT INITIAL THEN ls_data_u-del_flag ELSE ls_head_old-del_flag  )
                           del_remark = COND #( WHEN ls_data_x-del_remark IS NOT INITIAL THEN ls_data_u-del_remark ELSE ls_head_old-del_remark  )
                     )
    ).



  ENDMETHOD.
ENDCLASS.
