CLASS lhc_header DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

*    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
*      IMPORTING keys REQUEST requested_authorizations FOR header RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE header.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE header.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE header.

    METHODS read FOR READ
      IMPORTING keys FOR READ header RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK header.

    METHODS rba_items FOR READ
      IMPORTING keys_rba FOR READ header\_items FULL result_requested RESULT result LINK association_links.

    METHODS cba_items FOR MODIFY
      IMPORTING entities_cba FOR CREATE header\_items.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR header RESULT result.

ENDCLASS.

CLASS lhc_header IMPLEMENTATION.

*  METHOD get_instance_authorizations.
*
*    LOOP AT keys INTO DATA(ls_keys).
*
*      READ ENTITIES OF zge_r_head IN LOCAL MODE
*          ENTITY header
*            FIELDS (  gatetype )
*            WITH CORRESPONDING #( keys )
*          RESULT DATA(lt_gatetype)
*          FAILED DATA(lt_failed)
*          REPORTED DATA(lt_reported).
*
*      IF requested_authorizations-%update = if_abap_behv=>mk-on AND VALUE #( lt_gatetype[ 1 ]-gatetype OPTIONAL ) = 'Gate Pass' .
*
*        AUTHORITY-CHECK OBJECT 'ZAO_GTYPE'
*         ID 'ZAF_GTYPE' FIELD 'Gate Pass'
*         ID 'ACTVT' FIELD '01'.
*
*        APPEND VALUE #( %tky = ls_keys-%tky
*                       %update = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
*                                    ELSE if_abap_behv=>auth-unauthorized ) ) TO result.
*
*        APPEND VALUE #(
*                                      %tky = keys[ 1 ]-%tky
*                                      %msg = new_message_with_text(
*                                          severity = if_abap_behv_message=>severity-error
*                                          text = 'No Authorization to create Gate Pass!!!'
*                                      )
*                      ) TO reported-header.
*
*
*      ENDIF.
*
*    ENDLOOP.
*  ENDMETHOD.

  METHOD create.

    zcl_ge_gate_api=>get_instance(  )->create_head(
      EXPORTING
        entities = entities
      CHANGING
        mapped   = mapped
        failed   = failed
        reported = reported
    ).

  ENDMETHOD.

  METHOD update.

    zcl_ge_gate_api=>get_instance(  )->update_head(
      EXPORTING
        entities = entities
      CHANGING
        mapped   = mapped
        failed   = failed
        reported = reported
    ).

  ENDMETHOD.

  METHOD delete.

    zcl_ge_gate_api=>get_instance(  )->delete_head(
      EXPORTING
        keys     = keys
      CHANGING
        mapped   = mapped
        failed   = failed
        reported = reported
    ).
  ENDMETHOD.

  METHOD read.

    zcl_ge_gate_api=>get_instance(  )->read(
      EXPORTING
        keys     = keys
      CHANGING
        result   = result
        failed   = failed
        reported = reported
    )..
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_items.
  ENDMETHOD.

  METHOD cba_items.

    zcl_ge_gate_api=>get_instance(  )->cba_item(
      EXPORTING
        entities_cba = entities_cba
      CHANGING
        mapped       = mapped
        failed       = failed
        reported     = reported
    ).
  ENDMETHOD.

  METHOD get_global_authorizations.

*    IF requested_authorizations-%create = if_abap_behv=>mk-on OR requested_authorizations-%update = if_abap_behv=>mk-on.
*
*      AUTHORITY-CHECK OBJECT 'ZAO_GTYPE'
*       ID 'ZAF_GTYPE' FIELD 'Gate Pass'
*       ID 'ACTVT' FIELD '01'.
*      IF sy-subrc <> 0.
*         zcl_ge_gate_api=>get_instance(  )->fetch_auth_gpass( im_create_fail = 'X' ).
*      ENDIF.
*
*      AUTHORITY-CHECK OBJECT 'ZAO_GTYPE'
*       ID 'ZAF_GTYPE' FIELD 'Purchase'
*       ID 'ACTVT' FIELD '01'.
*      IF sy-subrc <> 0.
*         zcl_ge_gate_api=>get_instance(  )->fetch_auth_create( im_create_fail = 'X' ).
*      ENDIF.
*    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_item DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE item.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE item.

    METHODS read FOR READ
      IMPORTING keys FOR READ item RESULT result.

    METHODS rba_head FOR READ
      IMPORTING keys_rba FOR READ item\_head FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_item IMPLEMENTATION.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_head.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zge_r_head DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS adjust_numbers REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zge_r_head IMPLEMENTATION.

  METHOD finalize.
    zcl_ge_gate_api=>get_instance(  )->finalize(
      CHANGING
        failed   = failed
        reported = reported
    ).
  ENDMETHOD.

  METHOD check_before_save.

    zcl_ge_gate_api=>get_instance(  )->check_before_save(
      CHANGING
        failed   = failed
        reported = reported
    ).
  ENDMETHOD.

  METHOD save.

    zcl_ge_gate_api=>get_instance(  )->save(
      CHANGING
        reported = reported
    ).

  ENDMETHOD.

  METHOD cleanup.

    zcl_ge_gate_api=>get_instance(  )->cleanup( ).
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

  METHOD adjust_numbers.
    zcl_ge_gate_api=>get_instance(  )->adjust_numbers(
      CHANGING
        mapped   = mapped
        reported = reported
    ).
  ENDMETHOD.

ENDCLASS.
