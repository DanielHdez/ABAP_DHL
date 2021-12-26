FUNCTION zfm_suppl_dhl.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_SUPPLEMENT) TYPE  ZTT_SUPPL_DHL
*"     REFERENCE(IV_OP_TYPE) TYPE  ZDE_FLAG
*"  EXPORTING
*"     REFERENCE(EV_UPDATED) TYPE  ZDE_FLAG
*"----------------------------------------------------------------------
  CASE iv_op_type.

    WHEN 'C'.

      INSERT zbook_supply_dhl FROM TABLE @it_supplement.
      ev_updated = 'X'.
    WHEN 'U'.
      UPDATE zbook_supply_dhl FROM TABLE @it_supplement.
      ev_updated = 'X'.
    WHEN 'D'.
      DELETE zbook_supply_dhl FROM TABLE @it_supplement.
      ev_updated = 'X'.
  ENDCASE.




ENDFUNCTION.
