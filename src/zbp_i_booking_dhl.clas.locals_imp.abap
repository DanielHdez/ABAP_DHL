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
  ENDMETHOD.

ENDCLASS.
