CLASS zcl_tf_wt_single DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_amdp_marker_hdb .
    CLASS-METHODS : get_weight FOR TABLE FUNCTION zcds_tf_gate_wt.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_TF_WT_SINGLE IMPLEMENTATION.


  METHOD get_weight BY DATABASE FUNCTION FOR HDB LANGUAGE SQLSCRIPT
                    OPTIONS READ-ONLY USING zge_i_ge_report.

    lt_weight = select gatenumber,
                       itemnumber,
                       packingunit,
                       grossweight,
                       tareweight,
                       netweight,
                       vendorgrossweight,
                       vendortareweight,
                      ROW_NUMBER( ) OVER( PARTITION BY gatenumber ORDER BY gatenumber,itemnumber  ) AS row_no
                      FROM zge_i_ge_report;

        RETURN select '100' as client,
                       gatenumber,
                       itemnumber,
                       packingunit,
                       grossweight,
                       tareweight,
                       netweight,
                       vendorgrossweight,
                       vendortareweight,
                       row_no
                       FROM :lt_weight
                       WHERE row_no = 1;



  ENDMETHOD.
ENDCLASS.
