@AbapCatalog.sqlViewName: 'ZV_BOOK_SUP'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Suplementos a los viajes'
define view ZI_booking_suplement_DHL
  as select from zbook_supply_dhl as booksuple
  association to parent ZI_booking_DHL as _Booking on 
  $projection.TravelId = _Booking.TravelId and
  $projection.BookingId = _Booking.BookingId
  association [1..1] to ZI_travel_DHL as _Travel on $projection.TravelId = _Travel.TravelId
  association [1..1] to /DMO/I_Supplement as  _Product on $projection.SupplementId = _Product.SupplementID
  association [1..*] to /DMO/I_SupplementText as _SupplementText on $projection.SupplementId = _SupplementText.SupplementID
{
  key travel_id             as TravelId,
  key booking_id            as BookingId,
  key booking_supplement_id as BookingSupplementId,
      supplement_id         as SupplementId,
      price                 as Price,
      currency              as Currency,
      last_changed_at       as LastChangeAt,
      _Booking,
      _Travel,
      _Product,
      _SupplementText 

}
