@EndUserText.label: 'Consumer _Travel'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_travel_DHL
provider contract transactional_query
  as projection on ZI_travel_DHL
{

  key     TravelId,
          @ObjectModel.text.element: ['AgencyName']
          AgencyId,
          _Agency.Name       as AgencyName,
          @ObjectModel.text.element: ['CustomerName']
          CustomerId,
          _Customer.LastName as CustomerName,
          BeginDate,
          EndDate,
          @Semantics.amount.currencyCode: 'CurrencyCode'
          BookingFee,
          @Semantics.amount.currencyCode: 'CurrencyCode'
          TotalPrice,
          @Semantics.currencyCode: true
          CurrencyCode,
          Description,
          OverallStatus,
          CreatedBy,
          CreatedAt,
          LastChangedBy,
          LastChangedAt,
          @Semantics.amount.currencyCode: 'CurrencyCode'
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRT_ELEMENT_DHL'
          virtual Disscount_Price : /dmo/total_price,
          /* Associations */
          _Agency,
          _Booking : redirected to composition child ZC_booking_DHL,
          _Currency,
          _Customer

}
