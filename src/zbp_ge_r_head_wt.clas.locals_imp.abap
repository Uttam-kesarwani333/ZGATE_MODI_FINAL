CLASS lhc_Weight DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Weight RESULT result.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE Weight.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE Weight.

    METHODS read FOR READ
      IMPORTING keys FOR READ Weight RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK Weight.

ENDCLASS.

CLASS lhc_Weight IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD update.
     zcl_ge_gate_wt_api=>get_instance( )->update_head(
       EXPORTING
         entities = entities
       CHANGING
         mapped   = mapped
         failed   = failed
         reported = reported
     )..
  ENDMETHOD.

  METHOD delete.
    zcl_ge_gate_wt_api=>get_instance( )->delete_head(
      EXPORTING
        keys     = keys
      CHANGING
        mapped   = mapped
        failed   = failed
        reported = reported
    ).
  ENDMETHOD.

  METHOD read.

    zcl_ge_gate_wt_api=>get_instance( )->read(
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

ENDCLASS.

CLASS lsc_ZGE_R_HEAD_WT DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZGE_R_HEAD_WT IMPLEMENTATION.

  METHOD finalize.
   zcl_ge_gate_wt_api=>get_instance( )->finalize(
     CHANGING
       failed   = failed
       reported = reported
   ).
  ENDMETHOD.

  METHOD check_before_save.

    zcl_ge_gate_wt_api=>get_instance( )->check_before_save(
      CHANGING
        failed   = failed
        reported = reported
    ).
  ENDMETHOD.

  METHOD save.

    zcl_ge_gate_wt_api=>get_instance( )->save(
      CHANGING
        reported = reported
    ).
  ENDMETHOD.

  METHOD cleanup.
   zcl_ge_gate_wt_api=>get_instance( )->cleanup( ).
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
