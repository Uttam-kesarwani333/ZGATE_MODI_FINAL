CLASS lhc_Header DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Header RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE Header.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE Header.

    METHODS read FOR READ
      IMPORTING keys FOR READ Header RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK Header.

    METHODS rba_Items FOR READ
      IMPORTING keys_rba FOR READ Header\_Items FULL result_requested RESULT result LINK association_links.

    METHODS cba_Items FOR MODIFY
      IMPORTING entities_cba FOR CREATE Header\_Items.

ENDCLASS.

CLASS lhc_Header IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD update.
    zcl_ge_grn_api=>get_instance( )->update_head(
      EXPORTING
        entities = entities
      CHANGING
        mapped   = mapped
        failed   = failed
        reported = reported
    )..
  ENDMETHOD.

  METHOD read.
    zcl_ge_grn_api=>get_instance( )->read(
      EXPORTING
        keys     = keys
      CHANGING
        result   = result
        failed   = failed
        reported = reported
    ).
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_items.
  ENDMETHOD.

  METHOD cba_items.
    zcl_ge_grn_api=>get_instance( )->cba_item(
      EXPORTING
        entities_cba = entities_cba
      CHANGING
        mapped       = mapped
        failed       = failed
        reported     = reported
    ).
  ENDMETHOD.

  METHOD create.
    zcl_ge_grn_api=>get_instance( )->create_head(
      EXPORTING
        entities = entities
      CHANGING
        mapped   = mapped
        failed   = failed
        reported = reported
    ).
  ENDMETHOD.

ENDCLASS.

CLASS lhc_Item DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE Item.

    METHODS read FOR READ
      IMPORTING keys FOR READ Item RESULT result.

    METHODS rba_Head FOR READ
      IMPORTING keys_rba FOR READ Item\_Head FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_Item IMPLEMENTATION.

  METHOD update.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_Head.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZGE_R_GRN_HEAD DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZGE_R_GRN_HEAD IMPLEMENTATION.

  METHOD finalize.
    zcl_ge_grn_api=>get_instance( )->finalize(
      CHANGING
        failed   = failed
        reported = reported
    ).
  ENDMETHOD.

  METHOD check_before_save.
    zcl_ge_grn_api=>get_instance( )->check_before_save(
      CHANGING
        failed   = failed
        reported = reported
    ).
  ENDMETHOD.

  METHOD save.
    zcl_ge_grn_api=>get_instance( )->save(
      CHANGING
        reported = reported
    ).

  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
