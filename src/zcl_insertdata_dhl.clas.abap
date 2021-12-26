CLASS zcl_insertdata_dhl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_insertdata_dhl IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    DATA: lt_booksupply TYPE STANDARD TABLE OF zbook_supply_dhl,
          lt_book       TYPE STANDARD TABLE OF zbooking_dhl,
          lt_travel     TYPE STANDARD TABLE OF ztravel_dhl.


    SELECT travel_id,
agency_id,
customer_id,
begin_date,
end_date,
booking_fee,
total_price,
currency_code,
description,
status AS overall_status,
createdby AS created_by,
createdat AS created_at,
lastchangedby AS last_changed_by,
lastchangedat AS last_changed_at
FROM /dmo/travel INTO CORRESPONDING FIELDS OF
TABLE @lt_travel
UP TO 50 ROWS.


    SELECT * FROM /dmo/booking
    FOR ALL ENTRIES IN @lt_travel
    WHERE travel_id EQ @lt_travel-travel_id
    INTO CORRESPONDING FIELDS OF TABLE
    @lt_book.


*    SELECT * FROM /dmo/book_suppl
*    FOR ALL ENTRIES IN @lt_book
*    WHERE travel_id EQ @lt_book-travel_id
*    AND booking_id EQ @lt_book-booking_id
*    INTO CORRESPONDING FIELDS OF TABLE
*    @lt_booksupply.


    SELECT travel_id,
           booking_id,
           booking_supplement_id,
           supplement_id,
           price,
           currency_code AS  currency
    FROM /dmo/book_suppl
    FOR ALL ENTRIES IN @lt_book
    WHERE travel_id EQ @lt_book-travel_id
    AND booking_id EQ @lt_book-booking_id
    INTO CORRESPONDING FIELDS OF TABLE
    @lt_booksupply.


    DELETE FROM: ztravel_dhl,
    zbooking_dhl,
    zbook_supply_dhl.
    INSERT: ztravel_dhl FROM TABLE @lt_travel,
    zbooking_dhl FROM TABLE @lt_book,
    zbook_supply_dhl FROM TABLE @lt_booksupply.
    out->write( 'DONE!' ).
  ENDMETHOD.
ENDCLASS.
