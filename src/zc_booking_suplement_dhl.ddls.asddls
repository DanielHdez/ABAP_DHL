@EndUserText.label: 'Consumo_Suplementos'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_booking_suplement_DHL as projection on ZI_booking_suplement_DHL {
  key TravelId,
   key BookingId,
   key BookingSupplementId,
   @ObjectModel.text.element:['SupplementDescription']
   SupplementId,
   _SupplementText.Description as SupplementDescription : localized,  //Lo ponemos en funcion del idioma
   @Semantics.amount.currencyCode: 'Currency'
   Price,
   @Semantics.currencyCode: true
   Currency,
   /* Associations */
   _Travel : redirected to ZC_travel_DHL , 
   _Booking : redirected to parent ZC_booking_DHL,
   _Product,
   _SupplementText

}
