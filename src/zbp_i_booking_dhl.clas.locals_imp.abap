CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS CalculateTotalFlightPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~CalculateTotalFlightPrice.

    METHODS ValidateBookinStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~ValidateBookinStatus.

ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.

  METHOD CalculateTotalFlightPrice.
  ENDMETHOD.

  METHOD ValidateBookinStatus.

    READ ENTITY ZI_travel_DHL\\Booking
    FIELDS ( BookingStatus )
    WITH VALUE #( FOR <ls_keys> IN keys ( %key = <ls_keys>-%key ) )
    RESULT DATA(lt_booking_result).
    LOOP AT lt_booking_result ASSIGNING FIELD-SYMBOL(<fs_booking_result>).
      CASE <fs_booking_result>-BookingStatus.

        WHEN 'N'.
        WHEN 'X'.
        WHEN 'V'.
        WHEN OTHERS.
          APPEND VALUE #( %key                  = <fs_booking_result>-%key ) TO failed-booking.
          APPEND VALUE #( %key                  = <fs_booking_result>-%key
                          %msg                  = new_message(  id       = 'ZMENSAJES'
                                                                number   = '008'
                                                                v1       = <fs_booking_result>-BookingStatus
                                                                severity = if_abap_behv_message=>severity-error )
                         %element-bookingstatus = if_abap_behv=>mk-on
                         ) TO reported-booking.
      ENDCASE.

    ENDLOOP.


  ENDMETHOD.

ENDCLASS.
