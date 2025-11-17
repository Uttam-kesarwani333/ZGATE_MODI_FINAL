CLASS lhc_formula DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR formula RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE formula.

ENDCLASS.

CLASS lhc_formula IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
    SELECT MAX( sno ) FROM zqmt_qc_formula INTO @DATA(lv_max_sno). "#EC CI_NOWHERE

    lv_max_sno += 1.

    mapped-formula = VALUE #( FOR ls_travel IN entities
                              ( %cid = ls_travel-%cid
                                sno = lv_max_sno ) ).
  ENDMETHOD.

ENDCLASS.
