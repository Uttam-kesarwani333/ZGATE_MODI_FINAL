CLASS zcl_ge_type_customentity DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GE_TYPE_CUSTOMENTITY IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
   DATA : lt_type_data TYPE STANDARD TABLE OF zge_ce_typevh.

    "Fill the gate_type value
     lt_type_data = VALUE #(
                              ( gate_type = 'Purchase' )
                              ( gate_type = 'Sales' )
                              ( gate_type = 'Manual' )
                              ( gate_type = 'Gate Pass' )
                              ).

     DATA(lt_sort_element) = io_request->get_sort_elements( ).
     DATA(lt_paging) = io_request->get_paging( ).
    " Set the response data
    io_response->set_data( it_data = lt_type_data  ).
*    CATCH cx_rap_query_response_set_twic.

    " Set the total no of records
    io_response->set_total_number_of_records( iv_total_number_of_records = lines( lt_type_data ) ).
*    CATCH cx_rap_query_response_set_twic.
  ENDMETHOD.
ENDCLASS.
