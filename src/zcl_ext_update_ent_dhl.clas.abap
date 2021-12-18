CLASS zcl_ext_update_ent_dhl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_ext_update_ent_dhl IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    MODIFY ENTITIES OF zi_travel_dhl ENTITY Travel UPDATE FIELDS ( AgencyId Description )
    WITH VALUE #( ( TravelId = '000000001'
                    AgencyId = '070012'
                    Description = ' New actualizacione externa' ) )
    FAILED DATA(failed)
    REPORTED DATA(reported).

*    READ ENTITIES OF zi_travel_dhl ENTITY Travel
*    FIELDS (  AgencyId Description )
*    WITH VALUE #( ( TravelId = '000000001') )
*    RESULT DATA(lt_travel_ext)
*    FAILED failed
*    REPORTED reported.

    IF failed IS INITIAL.
      out->write(  'Éxito' ).
    ELSE.
      out->write(  'No ha persistido' ).
    ENDIF..

    COMMIT ENTITIES.


  ENDMETHOD.

ENDCLASS.
