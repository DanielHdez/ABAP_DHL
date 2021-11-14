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
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD acceptTravel.

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
             WITH value #(  FOR <key_row> IN keys ( TravelId = <key_row>-TravelId ) )"Aceptado
             RESULT DATA(lt_read_Entity_travel)
             FAILED failed
             REPORTED reported.
  """Comentamos

*    result =  VALUE #( FOR <ls_data> IN lt_create_travel INDEX INTO idx
*          ( %cid_ref = keys[ idx ]-%cid_ref
*            %key = keys[ idx ]-%key
*            %param = CORRESPONDING #( <ls_data> ) ) ).



  ENDMETHOD.

  METHOD createTravelbyTemplate.

    DATA(travelid) = keys[ 1 ]-TravelId.

*  data i type i.
*  while i = 0.
*    i = 0.
*  ENDWHILE.
    READ ENTITIES OF ZI_travel_DHL
    ENTITY Travel
    FIELDS ( TravelId AgencyId CustomerId BookingFee TotalPrice CurrencyCode )
    WITH VALUE #( FOR <row_key> IN keys ( %key = <row_key>-%key ) )
    RESULT DATA(lt_read_Entity_travel)
    FAILED failed
    REPORTED reported.

    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).
    DATA lt_create_travel TYPE TABLE FOR CREATE ZI_travel_DHL\\Travel.

    SELECT FROM ztravel_dhl FIELDS MAX( travel_id ) INTO @DATA(lv_travel_id).


    """Buscamos la tabla
    lt_create_travel = VALUE #(  FOR <result_row> IN lt_read_entity_travel INDEX INTO idx ( TravelId = lv_travel_id + idx
                                                                                            AgencyId = <result_row>-AgencyId
                                                                                            CustomerId = <result_row>-CustomerId
                                                                                            BeginDate = lv_today
                                                                                            EndDate   = lv_today + 30
                                                                                            BookingFee = <result_row>-BookingFee
                                                                                            TotalPrice = <result_row>-TotalPrice
                                                                                            Description = 'Comentarios desde las clase Travel'
                                                                                            OverallStatus = '') ).
    ""Ahora le decimos a la pantalla que va a sufir cambios para que se muestren.
    MODIFY ENTITIES OF ZI_travel_DHL
    IN LOCAL MODE ENTITY travel
    CREATE FIELDS ( TravelId
                    AgencyId
                    CustomerId
                    BeginDate
                    EndDate
                    BookingFee
                    TotalPrice
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
  ENDMETHOD.

  METHOD ValidateCustomer.
  ENDMETHOD.

  METHOD ValidateDate.
  ENDMETHOD.

  METHOD ValidateStatus.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_TRAVEL_DHL DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_TRAVEL_DHL IMPLEMENTATION.

  METHOD save_modified.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
