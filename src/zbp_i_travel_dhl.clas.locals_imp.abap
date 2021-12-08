CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result.

    METHODS CreateTravelbyTemplate FOR MODIFY
      IMPORTING keys FOR ACTION Travel~CreateTravelbyTemplate RESULT result.

    METHODS rejectTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~rejectTravel RESULT result.

    METHODS ValidateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~ValidateCustomer.

    METHODS ValidateDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~ValidateDate.

    METHODS ValidateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~ValidateStatus.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF zi_travel_dhl IN LOCAL MODE
    ENTITY Travel
    FIELDS ( TravelId
             OverallStatus )
    WITH VALUE #(  FOR <key_row> IN keys
                (  %key = <key_row>-TravelId ) )
    RESULT DATA(lt_travel_result).

    result = VALUE #( FOR <ls_travel> IN lt_travel_result INDEX INTO idx
                    ( %key = <ls_travel>-%key
                      %field-TravelId      =  if_abap_behv=>fc-f-read_only
                      %field-OverallStatus =  if_abap_behv=>fc-f-read_only
                      %assoc-_Booking      =  if_abap_behv=>fc-o-enabled
                      %action-acceptTravel =  COND #(  WHEN <ls_travel>-OverallStatus = 'A'
                                              THEN if_abap_behv=>fc-o-disabled
                                              ELSE if_abap_behv=>fc-o-enabled )
                      %action-rejectTravel =  COND #(  WHEN <ls_travel>-OverallStatus = 'X'
                                              THEN if_abap_behv=>fc-o-disabled
                                               ELSE if_abap_behv=>fc-o-enabled ) ) ).


  ENDMETHOD.

  METHOD get_instance_authorizations.

    DATA(lv_auth) = COND #( WHEN cl_abap_context_info=>get_user_technical_name( ) EQ 'CB9980000376'
                            THEN if_abap_behv=>auth-allowed
                            ELSE if_abap_behv=>auth-unauthorized ).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_key>).
      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<fs_result>).
      <fs_result> = VALUE #(  %key = <fs_key>-%key
                              %op-%delete                    = lv_auth
                              %op-%update                    = lv_auth
                              %delete                        = lv_auth
                              %action-acceptTravel           = lv_auth
                              %action-createTravelbyTemplate = lv_auth
                              %action-rejectTravel           = lv_auth
                              %assoc-_Booking                = lv_auth
                              %update                        = lv_auth ).
    ENDLOOP.

  ENDMETHOD.

  METHOD acceptTravel.
    " Las modificaciones no son relevantes para la autorizaciones locla mode

    MODIFY ENTITIES OF ZI_travel_DHL IN LOCAL MODE
    ENTITY Travel
    UPDATE FIELDS (  OverallStatus )
    WITH VALUE #( FOR <ls_data> IN keys ( TravelId = <ls_data>-TravelId
                                          OverallStatus = 'A'
                                          ) ) "Aceptado
    FAILED failed
    REPORTED reported.

    READ ENTITIES OF  ZI_travel_DHL IN LOCAL MODE
    ENTITY Travel
    FIELDS ( TravelId
             AgencyId
             CustomerId
             BeginDate
             EndDate
             BookingFee
             TotalPrice
             CurrencyCode
             Description
             OverallStatus
             CreatedAt
             CreatedBy
             LastChangedAt
             LastChangedBy )
             WITH VALUE #(  FOR <key_row> IN keys ( TravelId = <key_row>-TravelId ) )"Aceptado
             RESULT DATA(lt_read_Entity_travel)
             FAILED failed
             REPORTED reported.
    """Comentamos

    result =  VALUE #( FOR <ls_data1> IN lt_read_Entity_travel INDEX INTO idx
          ( %cid_ref = keys[ idx ]-%cid_ref
            %key = keys[ idx ]-%key
            %param = CORRESPONDING #( <ls_data1> ) ) ).

    LOOP AT lt_read_Entity_travel ASSIGNING FIELD-SYMBOL(<fs_symbol>).
      DATA(lv_travelid) = <fs_symbol>-TravelId.
      SHIFT lv_travelid LEFT DELETING LEADING '0'.
      APPEND VALUE #( TravelId = <fs_symbol>-TravelId
            %msg     = new_message( id = 'ZMENSAJES'
                                    number = '006'
                                    v1 = lv_travelid
                                    severity = if_abap_behv_message=>severity-success )
            %element-overallstatus  = if_abap_behv=>mk-on
             ) TO reported-travel.

    ENDLOOP.



  ENDMETHOD.

  METHOD createTravelbyTemplate.

    DATA(travelid) = keys[ 1 ]-TravelId.

    READ ENTITIES OF ZI_travel_DHL
    ENTITY Travel
    FIELDS ( TravelId AgencyId CustomerId BookingFee TotalPrice CurrencyCode )
    WITH VALUE #( FOR row_key IN keys ( %key = row_key-%key ) )
    RESULT DATA(lt_read_Entity_travel)
    FAILED failed
    REPORTED reported.

    CHECK failed IS INITIAL.

    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).
    DATA lt_create_travel TYPE TABLE FOR CREATE ZI_travel_DHL\\Travel.

    SELECT MAX( travel_id ) FROM ztravel_dhl INTO @DATA(lv_travel_id).
*    SELECT FROM ztravel_dhl FIELDS MAX( travel_id ) INTO @DATA(lv_travel_id).


    """Buscamos la tabla
    lt_create_travel = VALUE #(  FOR <result_row> IN lt_read_entity_travel INDEX INTO idx ( TravelId = lv_travel_id + idx
                                                                                            AgencyId = <result_row>-AgencyId
                                                                                            CustomerId = <result_row>-CustomerId
                                                                                            BeginDate = lv_today
                                                                                            EndDate   = lv_today + 30
                                                                                            BookingFee = <result_row>-BookingFee
                                                                                            TotalPrice = <result_row>-TotalPrice
                                                                                            CurrencyCode = <result_row>-CurrencyCode
                                                                                            Description = 'Comentarios desde las clase Travel'
                                                                                            OverallStatus = '') ).
    ""Ahora le decimos a la pantalla que va a sufir cambios para que se muestren.
    MODIFY ENTITIES OF ZI_travel_DHL
    IN LOCAL MODE ENTITY Travel
    CREATE FIELDS ( TravelId
                    AgencyId
                    CustomerId
                    BeginDate
                    EndDate
                    BookingFee
                    TotalPrice
                    CurrencyCode
                    Description
                    OverallStatus )
                    WITH lt_create_travel
                    MAPPED mapped
                    FAILED failed
                    REPORTED reported.




    result = VALUE #( FOR <ls_data> IN lt_create_travel INDEX INTO idx
          ( %cid_ref = keys[ idx ]-%cid_ref
            %key = keys[ idx ]-%key
            %param = CORRESPONDING #( <ls_data> ) ) ).



  ENDMETHOD.

  METHOD rejectTravel.

    " Las modificaciones no son relevantes para la autorizaciones locla mode

    MODIFY ENTITIES OF ZI_travel_DHL IN LOCAL MODE
    ENTITY Travel
    UPDATE FIELDS (  OverallStatus )
    WITH VALUE #( FOR <ls_data> IN keys ( TravelId = <ls_data>-TravelId
                                          OverallStatus = 'X'
                                          ) ) "Rechazado
    FAILED failed
    REPORTED reported.

    READ ENTITIES OF  ZI_travel_DHL IN LOCAL MODE
    ENTITY Travel
    FIELDS ( TravelId
             AgencyId
             CustomerId
             BeginDate
             EndDate
             BookingFee
             TotalPrice
             CurrencyCode
             Description
             OverallStatus
             CreatedAt
             CreatedBy
             LastChangedAt
             LastChangedBy )
             WITH VALUE #(  FOR <key_row> IN keys ( TravelId = <key_row>-TravelId ) )"Aceptado
             RESULT DATA(lt_read_Entity_travel)
             FAILED failed
             REPORTED reported.
    """Comentamos

    result =  VALUE #( FOR <ls_data1> IN lt_read_Entity_travel INDEX INTO idx
          ( %cid_ref = keys[ idx ]-%cid_ref
            %key = keys[ idx ]-%key
            %param = CORRESPONDING #( <ls_data1> ) ) ).

    LOOP AT lt_read_Entity_travel ASSIGNING FIELD-SYMBOL(<fs_symbol>).
      DATA(lv_travelid) = <fs_symbol>-TravelId.
      SHIFT lv_travelid LEFT DELETING LEADING '0'.
      APPEND VALUE #( TravelId = <fs_symbol>-TravelId
            %msg     = new_message( id = 'ZMENSAJES'
                                    number = '007'
                                    v1 = lv_travelid
                                    severity = if_abap_behv_message=>severity-success )
            %element-overallstatus  = if_abap_behv=>mk-on
             ) TO reported-travel.

    ENDLOOP.


  ENDMETHOD.

  METHOD ValidateCustomer.

    READ ENTITIES OF zi_travel_dhl IN LOCAL MODE
     ENTITY Travel
     FIELDS ( CustomerId )
     WITH CORRESPONDING #(  keys )
     RESULT DATA(lt_customer).

    DATA lt_customers TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.
    lt_customers = CORRESPONDING #( lt_customer DISCARDING DUPLICATES MAPPING customer_id = CustomerId EXCEPT * ).
    DELETE lt_customers WHERE customer_id IS INITIAL.

    SELECT FROM /dmo/customer FIELDS customer_id
    FOR ALL ENTRIES IN @lt_customers
    WHERE customer_id = @lt_customers-customer_id
    INTO TABLE @DATA(lt_customer_db).

    LOOP AT lt_customer ASSIGNING FIELD-SYMBOL(<fs_customer>).

      IF <fs_customer>-CustomerId IS INITIAL OR NOT
      line_exists( lt_customer_db[ customer_id = <fs_customer>-CustomerId ] ).
        APPEND VALUE #( TravelId = <fs_customer>-TravelId ) TO failed-travel.
        APPEND VALUE #( TravelId = <fs_customer>-TravelId
                        %msg     = new_message( id = 'ZMENSAJES'
                                                number = '001'
                                                v1 = <fs_customer>-CustomerId
                                                severity = if_abap_behv_message=>severity-error  )
                        %element-customerid  = if_abap_behv=>mk-on
                         ) TO reported-travel.
      ENDIF.

    ENDLOOP.


  ENDMETHOD.

  METHOD ValidateDate.
    READ ENTITY ZI_travel_DHL\\Travel
    FIELDS ( BeginDate EndDate )
    WITH VALUE #( FOR <ls_keys> IN keys ( %key = <ls_keys>-%key ) )
    RESULT DATA(lt_travel_result).

    LOOP AT lt_travel_result ASSIGNING FIELD-SYMBOL(<fs_travel_result>).

      IF <fs_travel_result>-BeginDate LE cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #( travelid = <fs_travel_result>-TravelId ) TO failed-travel.
        APPEND VALUE #( travelid = <fs_travel_result>-TravelId
                       %msg               = new_message(  id       = 'ZMENSAJES'
                                                          number  = '003'
                                                          v1      = <fs_travel_result>-BeginDate
                                                          severity = if_abap_behv_message=>severity-error )
                       %element-begindate = if_abap_behv=>mk-on
                       ) TO reported-travel.
      ELSEIF <fs_travel_result>-EndDate LE cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #( travelid = <fs_travel_result>-TravelId ) TO failed-travel.
        APPEND VALUE #( travelid = <fs_travel_result>-TravelId
                       %msg               = new_message(  id       = 'ZMENSAJES'
                                                          number  = '003'
                                                          v1      = <fs_travel_result>-EndDate
                                                          severity = if_abap_behv_message=>severity-error )
                       %element-enddate = if_abap_behv=>mk-on
                       ) TO reported-travel.
      ELSEIF <fs_travel_result>-BeginDate GT <fs_travel_result>-EndDate.
        APPEND VALUE #( travelid = <fs_travel_result>-TravelId ) TO failed-travel.
        APPEND VALUE #( travelid = <fs_travel_result>-TravelId
                        %msg               = new_message(  id       = 'ZMENSAJES'
                                                           number  = '002'
                                                           v1      = <fs_travel_result>-BeginDate
                                                           v2      = <fs_travel_result>-EndDate
                                                           severity = if_abap_behv_message=>severity-error )
                        %element-begindate = if_abap_behv=>mk-on
                        %element-enddate   = if_abap_behv=>mk-on
                        ) TO reported-travel.

      ENDIF.

    ENDLOOP.


  ENDMETHOD.

  METHOD ValidateStatus.

    READ ENTITY ZI_travel_DHL\\Travel
    FIELDS ( OverallStatus )
    WITH VALUE #( FOR <ls_keys> IN keys ( %key = <ls_keys>-%key ) )
    RESULT DATA(lt_travel_result).
    LOOP AT lt_travel_result ASSIGNING FIELD-SYMBOL(<fs_travel_result>).
      CASE <fs_travel_result>-OverallStatus.

        WHEN 'O'.
        WHEN 'A'.
        WHEN 'D'.
        WHEN OTHERS.
          APPEND VALUE #( travelid = <fs_travel_result>-TravelId ) TO failed-travel.
          APPEND VALUE #( travelid = <fs_travel_result>-TravelId
                         %msg               = new_message(  id       = 'ZMENSAJES'
                                                            number  = '004'
                                                            v1      = <fs_travel_result>-OverallStatus
                                                            severity = if_abap_behv_message=>severity-error )
                         %element-overallstatus = if_abap_behv=>mk-on
                         ) TO reported-travel.
      ENDCASE.

    ENDLOOP.


  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_TRAVEL_DHL DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PUBLIC SECTION.
    CONSTANTS: create TYPE string VALUE 'CREATE',
               update TYPE string VALUE 'UPDATE',
               delete TYPE string VALUE 'DELETE'.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_TRAVEL_DHL IMPLEMENTATION.

  METHOD save_modified.
    DATA: ls_components TYPE abap_compdescr.
    FIELD-SYMBOLS <fs_structure> TYPE any.
    FIELD-SYMBOLS <fs_update> TYPE any.
    DATA: lo_strucdescr TYPE REF TO cl_abap_structdescr.
    DATA lt_travel_log TYPE STANDARD TABLE OF Zlog_DHL.
    DATA lt_travel_log_u TYPE STANDARD TABLE OF Zlog_DHL.
    IF NOT create-travel IS INITIAL.
      lt_travel_log = CORRESPONDING #( create-travel MAPPING travel_id = TravelId EXCEPT * ).
      LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<fs_travel_log>).
        UNASSIGN: <fs_structure>, <fs_update>.
        GET TIME STAMP FIELD <fs_travel_log>-created_at.
        <fs_travel_log>-changing_operation = lsc_ZI_TRAVEL_DHL=>create.
        READ TABLE create-travel  WITH TABLE KEY entity COMPONENTS TravelId = <fs_travel_log>-travel_id
        INTO DATA(ls_create_travel).
        IF sy-subrc EQ 0.
          lo_strucdescr ?= cl_abap_typedescr=>describe_by_data( ls_create_travel-%control ).
          LOOP AT lo_strucdescr->components INTO ls_components.
            ASSIGN COMPONENT ls_components-name OF STRUCTURE ls_create_travel TO <fs_structure>.
            ASSIGN COMPONENT ls_components-name OF STRUCTURE ls_create_travel-%control TO <fs_update>.
            IF <fs_update> EQ cl_abap_behv=>flag_changed.
              <fs_travel_log>-user_mod = cl_abap_context_info=>get_user_technical_name( ).
              <fs_travel_log>-changed_field_name = ls_components-name.
              <fs_travel_log>-changed_value      = <fs_structure>.
              TRY.
                  <fs_travel_log>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
                CATCH cx_uuid_error.

              ENDTRY.
              APPEND <fs_travel_log> TO lt_travel_log_u.

            ENDIF.
          ENDLOOP.
        ENDIF.

      ENDLOOP.
    ENDIF.
    IF NOT update-travel IS INITIAL.
         lt_travel_log = CORRESPONDING #( update-travel MAPPING travel_id = TravelId EXCEPT * ).
      LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<fs_travel_log_up>).
        UNASSIGN: <fs_structure>, <fs_update>.
        GET TIME STAMP FIELD <fs_travel_log_up>-created_at.
        <fs_travel_log_up>-changing_operation = lsc_ZI_TRAVEL_DHL=>update.
        READ TABLE update-travel  WITH TABLE KEY entity COMPONENTS TravelId = <fs_travel_log_up>-travel_id
        INTO DATA(ls_create_travel_up).
        IF sy-subrc EQ 0.
          lo_strucdescr ?= cl_abap_typedescr=>describe_by_data( ls_create_travel_up-%control ).
          LOOP AT lo_strucdescr->components INTO ls_components.
          if ls_components-name EQ 'LASTCHANGEDAT' or ls_components-name EQ 'LASTCHANGEDBY'.
           CONTINUE.
          ENDIF.
            ASSIGN COMPONENT ls_components-name OF STRUCTURE ls_create_travel_up TO <fs_structure>.
            ASSIGN COMPONENT ls_components-name OF STRUCTURE ls_create_travel_up-%control TO <fs_update>.
            IF <fs_update> EQ cl_abap_behv=>flag_changed.
              <fs_travel_log_up>-user_mod = cl_abap_context_info=>get_user_technical_name( ).
              <fs_travel_log_up>-changed_field_name = ls_components-name.
              <fs_travel_log_up>-changed_value      = <fs_structure>.
              TRY.
                  <fs_travel_log_up>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
                CATCH cx_uuid_error.

              ENDTRY.
              APPEND <fs_travel_log_up> TO lt_travel_log_u.

            ENDIF.
          ENDLOOP.
        ENDIF.

      ENDLOOP.
    ENDIF.
    IF NOT delete-travel IS INITIAL.
      lt_travel_log = CORRESPONDING #( delete-travel MAPPING travel_id = TravelId EXCEPT * ).
      LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<fs_travel_log_del>).
        GET TIME STAMP FIELD <fs_travel_log_del>-created_at.
        <fs_travel_log_del>-changing_operation = lsc_ZI_TRAVEL_DHL=>delete.
        <fs_travel_log_del>-user_mod = cl_abap_context_info=>get_user_technical_name( ).
        TRY.
            <fs_travel_log_del>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
          CATCH cx_uuid_error.

        ENDTRY.
        APPEND <fs_travel_log_del> TO lt_travel_log_u.

      ENDLOOP.


    ENDIF.


    IF NOT create-bookingsuplement IS INITIAL.

    ENDIF.

    if lt_travel_log_u is NOT INITIAL.
        INSERT Zlog_dhl from TABLE @lt_travel_log_u.
    ENDIF.

  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
