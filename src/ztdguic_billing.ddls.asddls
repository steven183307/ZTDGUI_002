@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZTDGUII_BILLING'
@ObjectModel.semanticKey: [ 'Billingnum' ]
define root view entity ZTDGUIC_BILLING
  provider contract transactional_query
  as projection on ZTDGUII_BILLING
{
  key Billingnum,
      Sellernum,
      Sellername,
      Buyernum,
      Amount,
      Quantityall,
      Random,
      Type,
      Date01,
      Time01,

      Cmonth,
      Cyear,
      Barcode01,
      Qrcode01,
      Qrcode02,

      Locallastchangedat

  ,
      _billi : redirected to composition child ZTDGUIC_BILLDETL

}
