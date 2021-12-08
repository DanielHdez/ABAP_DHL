CLASS zcl_aux_determinations DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: tt_travel_reported       TYPE TABLE FOR REPORTED zi_travel_dhl,
           tt_booking_reported      TYPE TABLE FOR REPORTED zi_booking_dhl,
           tt_booking_supl_reported TYPE TABLE FOR REPORTED zi_booking_suplement_dhl.

    TYPES: tt_travel_id TYPE TABLE OF /dmo/travel_id.

    CLASS-METHODS  calculate_price IMPORTING p_travel_id TYPE tt_travel_id
                                   EXPORTING p_report_travel TYPE tt_travel_reported.
  protected SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_aux_determinations IMPLEMENTATION.


  METHOD calculate_price.
    DATA: lv_total_price       TYPE /dmo/total_price,
          lv_total_suple_price TYPE /dmo/total_price.
    IF p_travel_id  IS INITIAL.
      RETURN.
    ENDIF.
    READ ENTITIES OF zi_travel_dhl
    ENTITY Travel
    FIELDS (  TravelId CurrencyCode )
    WITH VALUE #(  FOR lv_travel_id IN p_travel_id (  TravelId = lv_travel_id ) )
    RESULT DATA(lt_read_travel).

    READ ENTITIES OF zi_travel_dhl
    ENTITY Travel BY \_Booking
    FROM VALUE #(  FOR lv_travel_id IN p_travel_id (  TravelId = lv_travel_id
                                                      %control-FlightPrice = if_abap_behv=>mk-on    """La estructura control nos dice si se ha actualizado
                                                      %control-CurrencyCode = if_abap_behv=>mk-on
                                                      ) )
    RESULT DATA(lt_read_booking).

    LOOP AT lt_read_booking INTO DATA(ls_read_booking) GROUP BY ls_read_booking-TravelId INTO DATA(lv_travel_key).

      ASSIGN lt_read_travel[ KEY entity COMPONENTS TravelId = lv_travel_key ] TO FIELD-SYMBOL(<fs_travel>).

      LOOP AT GROUP lv_travel_key INTO DATA(ls_booking_result) GROUP BY ls_booking_result-CurrencyCode INTO DATA(lv_currency).

        lv_total_price = 0.

        LOOP AT GROUP lv_currency INTO DATA(ls_booking_line).
          lv_total_price += ls_booking_line-FlightPrice.
        ENDLOOP.

        IF lv_currency EQ <fs_travel>-CurrencyCode.

          <fs_travel>-TotalPrice += lv_total_price.

        ELSE.

          ""Realizamos una conversion de la moneda
          /dmo/cl_flight_amdp=>convert_currency(
            EXPORTING
              iv_amount               = lv_total_price  "importe
              iv_currency_code_source = lv_currency     "moneda a la que está el precio
              iv_currency_code_target = <fs_travel>-CurrencyCode ""Moneda a la que se quiere cambiar la del viaje
              iv_exchange_rate_date   = cl_abap_context_info=>get_system_date( )  "Fecha de cambio
            IMPORTING
              ev_amount               = DATA(lv_amount_converted)
          ).
          <fs_travel>-TotalPrice += lv_amount_converted.

        ENDIF.

      ENDLOOP.

    ENDLOOP.
    "Leemos la entidad para el cálculo del precio de los suplementos
    READ ENTITIES OF zi_travel_dhl
    ENTITY Booking BY \_BookingSuple
    FIELDS ( TravelId Currency )
    WITH VALUE #(  FOR ls_travel IN lt_read_booking (  TravelId = ls_travel-TravelId  ""Tenemos que en este caso poner ambas keys
                                                       BookingId = ls_travel-BookingId
                                                      %control-Price = if_abap_behv=>mk-on    """La estructura control nos dice si se ha actualizado
                                                      %control-Currency = if_abap_behv=>mk-on
                                                      ) )
    RESULT DATA(lt_read_supplement).

    LOOP AT lt_read_supplement INTO DATA(ls_supplement) GROUP BY ls_supplement-TravelId INTO DATA(lv_travel_key1).

      ASSIGN lt_read_travel[ KEY entity COMPONENTS TravelId = lv_travel_key ] TO FIELD-SYMBOL(<fs_travel1>).

      LOOP AT GROUP lv_travel_key1 INTO DATA(ls_supplements_result) GROUP BY ls_supplements_result-Currency INTO DATA(lv_curr).
        lv_total_suple_price = 0.

        LOOP AT GROUP lv_curr INTO DATA(ls_suplement_line).
          lv_total_suple_price += ls_suplement_line-Price.
        ENDLOOP.


        IF lv_curr EQ <fs_travel>-CurrencyCode.

          <fs_travel>-TotalPrice += lv_total_suple_price.

        ELSE.

          ""Realizamos una conversion de la moneda
          /dmo/cl_flight_amdp=>convert_currency(
            EXPORTING
              iv_amount               = lv_total_suple_price  "importe
              iv_currency_code_source = lv_curr     "moneda a la que está el precio
              iv_currency_code_target = <fs_travel>-CurrencyCode ""Moneda a la que se quiere cambiar la del viaje
              iv_exchange_rate_date   = cl_abap_context_info=>get_system_date( )  "Fecha de cambio
            IMPORTING
              ev_amount               = DATA(lv_amount_converted1)
          ).
          <fs_travel>-TotalPrice += lv_amount_converted1.

        ENDIF.
      ENDLOOP.

    ENDLOOP.

    """"Ahora modificamos el objeto de negocio para tener en cuenta los cambios.

    MODIFY ENTITIES OF ZI_travel_DHL
      ENTITY Travel
      UPDATE FROM VALUE #( FOR ls_read_travel IN lt_read_travel ( TravelId = ls_read_travel-TravelId
                                                                  TotalPrice = ls_read_travel-TotalPrice
                                                                  %control-TotalPrice = cl_abap_behv=>flag_changed ) ).



  ENDMETHOD.

ENDCLASS.
