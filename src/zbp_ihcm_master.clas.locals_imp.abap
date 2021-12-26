
CLASS lcl_buffer DEFINITION.  ""Clase que actua como intercambio entre las otras ds clases
  PUBLIC SECTION.
    CONSTANTS: create TYPE c LENGTH 1 VALUE 'C',
               update TYPE c LENGTH 1 VALUE 'U',
               delete TYPE c LENGTH 1 VALUE 'D'.
    TYPES: BEGIN OF ty_buffer_master.
             INCLUDE TYPE zhcm_master AS data.
    TYPES:   flag TYPE c LENGTH 1,
           END OF ty_buffer_master.

    TYPES: tt_buffer_master TYPE SORTED TABLE OF ty_buffer_master WITH  UNIQUE KEY e_number.

    CLASS-DATA mt_buffer_entity TYPE tt_buffer_master.

ENDCLASS.


CLASS lhc_HCMMASTER DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.


    METHODS: create FOR MODIFY IMPORTING entities FOR CREATE hcmmaster,
      update FOR MODIFY IMPORTING entities FOR UPDATE hcmmaster,
      delete FOR MODIFY IMPORTING keys     FOR DELETE hcmmaster.


    METHODS: get_instance_authorizations FOR INSTANCE AUTHORIZATION IMPORTING keys REQUEST requested_authorizations FOR hcmmaster RESULT result,
      read FOR READ IMPORTING keys FOR READ hcmmaster RESULT result,
      lock FOR LOCK IMPORTING keys FOR LOCK hcmmaster.

ENDCLASS.

CLASS lhc_HCMMASTER IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.
    GET TIME STAMP FIELD DATA(lv_timestamp).
    SELECT MAX( e_number )  FROM zhcm_master INTO @DATA(lv_maxe_number).
    LOOP AT entities INTO DATA(ls_entities).

      ls_entities-%data-crea_date_time = lv_timestamp.
      ls_entities-%data-crea_uname     = sy-uname.
      ls_entities-%data-e_number = lv_maxe_number + 1.


*      lcl_buffer=>mt_buffer_entity
      """ lo pasamos a un buffer para er tratado en la siguiente clase.
      INSERT VALUE #( flag = lcl_buffer=>create
                      data = CORRESPONDING #( ls_entities-%data )  ) INTO TABLE  lcl_buffer=>mt_buffer_entity.
      """" Avisamos al standard que estamos tratando este %CID y employee number
      IF ls_entities-%cid IS NOT INITIAL.
        INSERT VALUE #( %cid = ls_entities-%cid
                        e_number = ls_entities-e_name ) INTO TABLE mapped-hcmmaster.
      ENDIF.


    ENDLOOP.
  ENDMETHOD.

  METHOD update.

    DATA: ls_components TYPE abap_compdescr.
    FIELD-SYMBOLS <fs_structure> TYPE any.
    FIELD-SYMBOLS <fs_structure_ddbb> TYPE any.
    FIELD-SYMBOLS <fs_update> TYPE any.
    DATA: lo_strucdescr TYPE REF TO cl_abap_structdescr.
    GET TIME STAMP FIELD DATA(lv_timestamp).

    LOOP AT entities INTO DATA(ls_entities).
      SELECT SINGLE *  FROM zhcm_master WHERE e_number = @ls_entities-e_number INTO @DATA(ls_ddbb) .
      ls_entities-%data-lchg_date_time = lv_timestamp.
      ls_entities-%data-lchg_uname    = sy-uname.
      lo_strucdescr ?= cl_abap_typedescr=>describe_by_data( ls_entities-%control ).
      LOOP AT lo_strucdescr->components INTO ls_components." where name NE 'E_NUMBER'.
        ASSIGN COMPONENT ls_components-name OF STRUCTURE ls_entities-%data TO <fs_structure>.
        ASSIGN COMPONENT ls_components-name OF STRUCTURE ls_entities-%control TO <fs_update>.
        ASSIGN COMPONENT ls_components-name OF STRUCTURE ls_ddbb TO <fs_structure_ddbb>.
        IF <fs_update> EQ cl_abap_behv=>flag_changed.
          <fs_structure_ddbb> = <fs_structure>.        " Si se actualiza metemos el dao
        ENDIF.
      ENDLOOP.

      INSERT VALUE #( flag = lcl_buffer=>update
                      data  = CORRESPONDING #( ls_ddbb ) ) INTO TABLE  lcl_buffer=>mt_buffer_entity.

**      """ lo pasamos a un buffer para er tratado en la siguiente clase.
**
**      INSERT VALUE #( flag = lcl_buffer=>update
**                      data = VALUE #( e_name =     COND #( WHEN ls_entities-%control-e_name EQ if_abap_behv=>mk-on
**                                                       THEN ls_entities-%data-e_name
**                                                       ELSE ls_ddbb-e_name )
**                                   e_departament =  COND #( WHEN ls_entities-%control-e_departament EQ if_abap_behv=>mk-on
**                                                       THEN ls_entities-%data-e_departament
**                                                       ELSE ls_ddbb-e_departament )
**                                   status =        COND #( WHEN ls_entities-%control-status EQ if_abap_behv=>mk-on
**                                                       THEN ls_entities-%data-status
**                                                       ELSE ls_ddbb-status )
**                                   job_title =     COND #( WHEN ls_entities-%control-job_title EQ if_abap_behv=>mk-on
**                                                       THEN ls_entities-%data-job_title
**                                                       ELSE ls_ddbb-job_title )
**                                   start_date =    COND #( WHEN ls_entities-%control-start_date EQ if_abap_behv=>mk-on
**                                                       THEN ls_entities-%data-start_date
**                                                       ELSE ls_ddbb-start_date )
**                                   end_date =      COND #( WHEN ls_entities-%control-end_date EQ if_abap_behv=>mk-on
**                                                       THEN ls_entities-%data-end_date
**                                                       ELSE ls_ddbb-end_date )
**                                   email =         COND #( WHEN ls_entities-%control-email EQ if_abap_behv=>mk-on
**                                                       THEN ls_entities-%data-email
**                                                       ELSE ls_ddbb-email )
**                                   m_number =      COND #( WHEN ls_entities-%control-m_number EQ if_abap_behv=>mk-on
**                                                       THEN ls_entities-%data-m_number
**                                                       ELSE ls_ddbb-m_number )
**                                   m_name =        COND #( WHEN ls_entities-%control-m_name EQ if_abap_behv=>mk-on
**                                                       THEN ls_entities-%data-m_name
**                                                       ELSE ls_ddbb-m_name )
**                                   m_departament = COND #( WHEN ls_entities-%control-m_departament EQ if_abap_behv=>mk-on
**                                                       THEN ls_entities-%data-m_departament
**                                                       ELSE ls_ddbb-m_departament )
**                                      crea_date_time =  ls_ddbb-crea_date_time
**                                      crea_uname     = ls_ddbb-crea_uname )  ) INTO TABLE  lcl_buffer=>mt_buffer_entity.
**      """" Avisamos al standard que estamos tratando este %CID y employee number
      IF ls_entities-%cid_ref IS NOT INITIAL.
        INSERT VALUE #( %cid = ls_entities-%cid_ref
                        e_number = ls_entities-e_name ) INTO TABLE mapped-hcmmaster.
      ENDIF.
*
*
    ENDLOOP.

  ENDMETHOD.

  METHOD delete.

    DATA(lv_s_number) = keys[ 1 ]-%key-e_number.
   LOOP AT keys INTO data(ls_keys).
    INSERT VALUE #( flag = lcl_buffer=>delete
                    data  = VALUE #( e_number = ls_keys-e_number ) ) INTO TABLE  lcl_buffer=>mt_buffer_entity.


    IF  ls_keys-%cid_ref IS NOT INITIAL.

      INSERT VALUE #( %cid = ls_keys-%cid_ref
                      e_number = lv_s_number ) INTO TABLE mapped-hcmmaster.
    ENDIF.
   ENDLOOP.

  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

ENDCLASS.


CLASS lsc_ZIHCM_MASTER DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.            "Después de guardar los datos

    METHODS check_before_save REDEFINITION.   "Antes de guardar los datos

    METHODS save REDEFINITION.                "Guarda los datos

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZIHCM_MASTER IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    DATA lt_data_create TYPE STANDARD TABLE OF zhcm_master.
    DATA lt_data_update TYPE STANDARD TABLE OF zhcm_master.
    DATA lt_data_delete TYPE STANDARD TABLE OF zhcm_master.

    lt_data_create = VALUE #( FOR <row> IN lcl_buffer=>mt_buffer_entity
                              WHERE ( flag = lcl_buffer=>create ) ( <row>-data ) ).

    lt_data_update = VALUE #( FOR <row> IN lcl_buffer=>mt_buffer_entity
                              WHERE ( flag = lcl_buffer=>update ) ( <row>-data ) ).

    lt_data_delete = VALUE #( FOR <row> IN lcl_buffer=>mt_buffer_entity
                              WHERE ( flag = lcl_buffer=>delete ) ( <row>-data ) ).

    IF lt_data_create IS NOT INITIAL.
      INSERT zhcm_master FROM TABLE @lt_data_create.
    ENDIF.
    IF lt_data_update IS NOT INITIAL.
      UPDATE zhcm_master FROM TABLE @lt_data_update.
    ENDIF.
    IF lt_data_delete IS NOT INITIAL.
      DELETE zhcm_master FROM TABLE @lt_data_delete.
    ENDIF.

  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
