CLASS lhc_bookingsuplement DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS CalculateTotalSupplPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR BookingSuplement~CalculateTotalSupplPrice.

ENDCLASS.

CLASS lhc_bookingsuplement IMPLEMENTATION.

  METHOD CalculateTotalSupplPrice.
   if NOT keys is INITIAL.
    zcl_aux_determinations=>calculate_price( p_travel_id = VALUE #( for groups <booking_suppl> of booking_key in keys
                                                                    GROUP BY booking_key-TravelId  WITHOUT MEMBERS ( <booking_suppl> ) ) ).
                                                                    ""iteramos la tabla interna Keys agrupando la información por el TravelId, without members restringe el loop at group
                                                                    ""permitiendo modificar la tabla interna dentro de la iteracion
  ENDIF.

  ENDMETHOD.

ENDCLASS.
