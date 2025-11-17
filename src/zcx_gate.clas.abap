CLASS zcx_gate DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.


    INTERFACES if_abap_behv_message .
    INTERFACES if_t100_dyn_msg .
    INTERFACES if_t100_message .

    CONSTANTS: BEGIN OF po_not_release,
                 msgid TYPE symsgid VALUE 'ZGATE_MSG',
                 msgno TYPE symsgno VALUE '001',
                 attr1 TYPE scx_attrname VALUE 'MV_PO_NUMBER',
                 attr2 TYPE scx_attrname VALUE '',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF po_not_release,

               BEGIN OF gate_in_date,
                 msgid TYPE symsgid VALUE 'ZGATE_MSG',
                 msgno TYPE symsgno VALUE '002',
                 attr1 TYPE scx_attrname VALUE 'MV_GATEINDATE',
                 attr2 TYPE scx_attrname VALUE 'MV_VENDOR_INV_DATE',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF gate_in_date,

               BEGIN OF gate_save,
                 msgid TYPE symsgid VALUE 'ZGATE_MSG',
                 msgno TYPE symsgno VALUE '003',
                 attr1 TYPE scx_attrname VALUE 'MV_GATE_NUMBE',
                 attr2 TYPE scx_attrname VALUE '',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF gate_save,

               BEGIN OF po_doc_date,
                 msgid TYPE symsgid VALUE 'ZGATE_MSG',
                 msgno TYPE symsgno VALUE '004',
                 attr1 TYPE scx_attrname VALUE 'MV_VENDOR_INV_DATE',
                 attr2 TYPE scx_attrname VALUE 'MV_PO_DOC_DATE',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF po_doc_date,

               BEGIN OF grn_doc_date,
                 msgid TYPE symsgid VALUE 'ZGATE_MSG',
                 msgno TYPE symsgno VALUE '005',
                 attr1 TYPE scx_attrname VALUE '',
                 attr2 TYPE scx_attrname VALUE '',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF grn_doc_date,

               BEGIN OF grn_post_date,
                 msgid TYPE symsgid VALUE 'ZGATE_MSG',
                 msgno TYPE symsgno VALUE '006',
                 attr1 TYPE scx_attrname VALUE '',
                 attr2 TYPE scx_attrname VALUE '',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF grn_post_date,

               BEGIN OF grn_gate_date,
                 msgid TYPE symsgid VALUE 'ZGATE_MSG',
                 msgno TYPE symsgno VALUE '007',
                 attr1 TYPE scx_attrname VALUE 'MV_GRNDATE',
                 attr2 TYPE scx_attrname VALUE 'MV_GATEINDATE',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF grn_gate_date,

               BEGIN OF inv_exists,
                 msgid TYPE symsgid VALUE 'ZGATE_MSG',
                 msgno TYPE symsgno VALUE '008',
                 attr1 TYPE scx_attrname VALUE 'MV_INVNUM',
                 attr2 TYPE scx_attrname VALUE 'MV_GATE_NUMBER',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF inv_exists,

               BEGIN OF grn_exists,
                 msgid TYPE symsgid VALUE 'ZGATE_MSG',
                 msgno TYPE symsgno VALUE '009',
                 attr1 TYPE scx_attrname VALUE 'MV_GRN',
                 attr2 TYPE scx_attrname VALUE 'MV_GATE_NUMBER',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF grn_exists,

               BEGIN OF no_gpass_auth,
                 msgid TYPE symsgid VALUE 'ZGATE_MSG',
                 msgno TYPE symsgno VALUE '010',
                 attr1 TYPE scx_attrname VALUE '',
                 attr2 TYPE scx_attrname VALUE '',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF no_gpass_auth,

               BEGIN OF matnr_num,
                 msgid TYPE symsgid VALUE 'ZGATE_MSG',
                 msgno TYPE symsgno VALUE '011',
                 attr1 TYPE scx_attrname VALUE '',
                 attr2 TYPE scx_attrname VALUE '',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF matnr_num,

               BEGIN OF qty_in,
                 msgid TYPE symsgid VALUE 'ZGATE_MSG',
                 msgno TYPE symsgno VALUE '012',
                 attr1 TYPE scx_attrname VALUE '',
                 attr2 TYPE scx_attrname VALUE '',
                 attr3 TYPE scx_attrname VALUE '',
                 attr4 TYPE scx_attrname VALUE '',
               END OF qty_in.
*
*               BEGIN OF number_range_depleted,
*                 msgid TYPE symsgid VALUE 'ZGATE_MSG',
*                 msgno TYPE symsgno VALUE '019',
*                 attr1 TYPE scx_attrname VALUE '',
*                 attr2 TYPE scx_attrname VALUE '',
*                 attr3 TYPE scx_attrname VALUE '',
*                 attr4 TYPE scx_attrname VALUE '',
*               END OF number_range_depleted.

    DATA:
      mv_attr1           TYPE string,
      mv_attr2           TYPE string,
      mv_attr3           TYPE string,
      mv_attr4           TYPE string,
      mv_gateindate      TYPE string,
      mv_grndate         TYPE string,
      mv_vendor_inv_date TYPE string,
      mv_po_doc_date     TYPE string,
      mv_invnum          TYPE string,
      mv_po_number       TYPE ebeln,
      mv_grn             TYPE mblnr,
      mv_gate_number     TYPE zge_hdr-gate_number,
      mv_matnr           TYPE string,
      mv_qty_in           TYPE string.

    METHODS : constructor IMPORTING textid          LIKE if_t100_message=>t100key OPTIONAL
                                    attr1           TYPE string OPTIONAL
                                    attr2           TYPE string OPTIONAL
                                    attr3           TYPE string OPTIONAL
                                    attr4           TYPE string OPTIONAL
                                    severity        TYPE if_abap_behv_message=>t_severity  DEFAULT if_abap_behv_message=>severity-error
                                    previous        TYPE REF TO cx_root OPTIONAL
                                    po_number       TYPE ebeln OPTIONAL
                                    gate_in_data    TYPE string OPTIONAL
                                    grn_data        TYPE string OPTIONAL
                                    vendor_inv_date TYPE string OPTIONAL
                                    po_doc_date     TYPE string OPTIONAL
                                    inv_num         TYPE string OPTIONAL
                                    grn_num         TYPE string OPTIONAL
                                    gate_number     TYPE zge_hdr-gate_number OPTIONAL
                                    matnr_num       TYPE string OPTIONAL
                                    qty_in          TYPE string OPTIONAL.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCX_GATE IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor( ).

    me->mv_attr1                 = attr1.
    me->mv_attr2                 = attr2.
    me->mv_attr3                 = attr3.
    me->mv_attr4                 = attr4.
    me->mv_po_number             = po_number.
    me->mv_gate_number           = gate_number.
    me->mv_gateindate            = gate_in_data.
    me->mv_vendor_inv_date       = vendor_inv_date.
    me->mv_po_doc_date           = po_doc_date.
    me->mv_grndate               = grn_data.
    me->mv_invnum               = grn_data.
    me->mv_grn                   = grn_num.
    me->mv_matnr                = matnr_num.
    me->mv_qty_in                = qty_in.


    if_abap_behv_message~m_severity = severity.

    CLEAR : me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.


  ENDMETHOD.
ENDCLASS.
