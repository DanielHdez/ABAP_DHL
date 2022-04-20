CLASS zcl_virt_element_dhl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.   ""Tenemos que implementar esta calse para los elementos virtuales
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_VIRT_ELEMENT_DHL IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

    IF iv_entity = 'ZC_TRAVEL_DHL'.   ""Tomamos la informacion de la vista
      LOOP AT it_requested_calc_elements INTO DATA(ls_rquested).
        IF ls_rquested = 'DISSCOUNT_PRICE'.
          APPEND 'TOTALPRICE' TO et_requested_orig_elements.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~calculate.

    DATA lt_original_data type STANDARD TABLE OF zc_travel_dhl WITH DEFAULT KEY.

    lt_original_data = CORRESPONDING #( it_original_data ).

    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).
        <fs_original_data>-Disscount_Price = <fs_original_data>-TotalPrice * ( 9 / 10 )  .
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_original_data ).

  ENDMETHOD.
ENDCLASS.
