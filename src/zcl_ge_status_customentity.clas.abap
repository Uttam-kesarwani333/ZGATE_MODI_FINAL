CLASS zcl_ge_status_customentity DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_GE_STATUS_CUSTOMENTITY IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

   DATA : lt_status_data TYPE STANDARD TABLE OF zge_ce_statusvh.

    "Fill the status value
     lt_status_data = VALUE #(
                              ( status = 'Open' )
                              ( status = 'Gate In Pending' )
                              ( status = 'Final Weighment Pending' )
                              ( status = 'Gate Out Pending' )
                              ( status = 'Close' )
                              ( status = 'Cancelled' )
                              ).

     DATA(lt_sort_element) = io_request->get_sort_elements( ).
     DATA(lt_paging) = io_request->get_paging( ).
    " Set the response data
    io_response->set_data( it_data = lt_status_data  ).
*    CATCH cx_rap_query_response_set_twic.

    " Set the total no of records
    io_response->set_total_number_of_records( iv_total_number_of_records = lines( lt_status_data ) ).
*    CATCH cx_rap_query_response_set_twic.
  ENDMETHOD.
ENDCLASS.
