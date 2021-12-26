CLASS lhc_bookingsuplement DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS CalculateTotalSupplPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR BookingSuplement~CalculateTotalSupplPrice.

ENDCLASS.

CLASS lhc_bookingsuplement IMPLEMENTATION.

  METHOD CalculateTotalSupplPrice.
    IF NOT keys IS INITIAL.
      zcl_aux_determinations=>calculate_price( p_travel_id = VALUE #( FOR GROUPS <booking_suppl> OF booking_key IN keys
                                                                      GROUP BY booking_key-TravelId
                                                                      WITHOUT MEMBERS ( <booking_suppl> ) ) ).
      ""iteramos la tabla interna Keys agrupando la información por el TravelId, without members restringe el loop at group
      ""permitiendo modificar la tabla interna dentro de la iteracion
    ENDIF.

  ENDMETHOD.

ENDCLASS.


CLASS lsc_supplement DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PUBLIC SECTION.

    CONSTANTS: create TYPE char1 VALUE 'C',
               update TYPE char1 VALUE 'U',
               delete TYPE char1 VALUE 'D'.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_supplement IMPLEMENTATION.

  METHOD save_modified.

    DATA: lt_supplements TYPE STANDARD TABLE OF zbook_supply_dhl,
          lv_op_type     TYPE zde_flag,
          lv_updated     TYPE zde_flag.

    IF NOT create-bookingsuplement IS INITIAL.

      lt_supplements = CORRESPONDING #( create-bookingsuplement MAPPING travel_id = TravelId
                                                                        booking_id = BookingId
                                                                        booking_supplement_id = BookingSupplementId
                                                                        supplement_id = SupplementId
                                                                         ).
      lv_op_type = lsc_supplement=>create.


    ENDIF.
    IF NOT update-bookingsuplement IS INITIAL.
      lt_supplements = CORRESPONDING #( update-bookingsuplement MAPPING travel_id = TravelId
                                                                        booking_id = BookingId
                                                                        booking_supplement_id = BookingSupplementId
                                                                        supplement_id = SupplementId ).
      lv_op_type = lsc_supplement=>update.

    ENDIF.
    IF NOT delete-bookingsuplement IS INITIAL.
      lt_supplements = CORRESPONDING #( delete-bookingsuplement MAPPING travel_id = TravelId
                                                                        booking_id = BookingId
                                                                        booking_supplement_id = BookingSupplementId ).
      lv_op_type = lsc_supplement=>delete.

    ENDIF.

    if NOT lt_supplements is INITIAL.
        call FUNCTION 'ZFM_SUPPL_DHL'
          EXPORTING
            it_supplement = lt_supplements
            iv_op_type    = lv_op_type
          IMPORTING
            ev_updated    = lv_updated
          .
      if lv_updated EQ abap_true.

       APPEND VALUE #( TravelId =  lt_supplements[ 1 ]-travel_id
            %msg     = new_message( id = 'ZMENSAJES'
                                    number = '006'
                                    v1 = 'Travel'
                                    severity = if_abap_behv_message=>severity-success )
            %element-overallstatus  = if_abap_behv=>mk-on
             ) TO reported-travel.
      ENDIF.

    ENDIF.


  ENDMETHOD.

ENDCLASS.
