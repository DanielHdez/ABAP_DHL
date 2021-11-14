@AbapCatalog.sqlViewName: 'ZV_RESERVAS'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Reservas'
define view ZI_booking_DHL
  as select from zbooking_dhl as Booking
  composition [0..*] of ZI_booking_suplement_DHL as _BookingSuple
  association to parent ZI_travel_DHL as _Travel on $projection.TravelId = _Travel.TravelId
  association [1..1] to /DMO/I_Customer as _Customer on $projection.CustomerId = _Customer.CustomerID
  association [1..1] to /dmo/carrier as _Carrier on $projection.CarrierId =_Carrier.carrier_id
  association [1..*] to /dmo/connection as _Connection on $projection.ConnectionId = _Connection.connection_id 
  {
  key travel_id      as TravelId,
  key booking_id     as BookingId,
      booking_date   as BookingDate,
      customer_id    as CustomerId,
      carrier_id     as CarrierId,
      connection_id  as ConnectionId,
      flight_date    as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price   as FlightPrice,
      @Semantics.currencyCode: true
      currency_code  as CurrencyCode,
      booking_status as BookingStatus,
      last_change_at as LastChangeAt,
      _Travel,
      _BookingSuple,
      _Customer,
      _Carrier,
      _Connection
}


