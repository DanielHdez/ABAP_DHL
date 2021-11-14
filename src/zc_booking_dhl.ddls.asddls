@EndUserText.label: 'Consumer_ REservas'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_booking_DHL
  as projection on ZI_booking_DHL
{

  key TravelId,
  key BookingId,
      BookingDate,
      CustomerId,
      _Customer.FirstName,
      @ObjectModel.text.element: ['CarrierName']
      CarrierId,
      _Carrier.name as CarrierName,
      ConnectionId,
      FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
      @Semantics.currencyCode: true
      CurrencyCode,
      BookingStatus,
      LastChangeAt,
      /* Associations */
      _Travel       : redirected to parent ZC_travel_DHL,
      _BookingSuple : redirected to composition child ZC_booking_suplement_DHL,
      _Carrier,
      _Connection,
      _Customer

}
