@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '##GENERATED ZTDGUIT_BILLING'
define root view entity ZTDGUII_BILLING
  as select from ztdguit_billing as billh
  composition [1..*] of ZTDGUII_BILLDETL as _billi
{
      @EndUserText.label: '發票號碼'
  key billingnum         as Billingnum,

      @EndUserText.label: '賣方(號碼)'
      sellernum          as Sellernum,
      @EndUserText.label: '賣方'
      sellername         as Sellername,
      @EndUserText.label: '買方'
      buyernum           as Buyernum,
      @EndUserText.label: '總計'
      amount             as Amount,
      @EndUserText.label: '總數量'
      quantityall        as Quantityall,
      @EndUserText.label: '隨機碼'
      random             as Random,
      @EndUserText.label: '格式'
      type               as Type,
      @EndUserText.label: '日期'
      date01             as Date01,
      @EndUserText.label: '時間'
      time01             as Time01,

      cmonth             as Cmonth,
      cyear              as Cyear,
      barcode01          as Barcode01,
      qrcode01           as Qrcode01,
      qrcode02           as Qrcode02,
      cdate01            as Cdate01,
      ctime01            as Ctime01,

      @Semantics.user.createdBy: true
      created_by         as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at         as CreatedAt,
      @Semantics.user.lastChangedBy: true
      lastchangedby      as Lastchangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      lastchangedat      as Lastchangedat,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      locallastchangedat as Locallastchangedat

  ,
      _billi

}
