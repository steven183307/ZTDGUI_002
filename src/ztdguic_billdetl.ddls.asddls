@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZTDGUII_BILLDETL'
@ObjectModel.semanticKey: [ 'Seq' ]
define view entity ZTDGUIC_BILLDETL

  as projection on ZTDGUII_BILLDETL
{
  key Uuidi,
  key Seq,
  Billingnum,
  Prodname,
  Quantity,
  Price,
  Memo,
  Locallastchangedat

  ,_billh : redirected to parent ZTDGUIC_BILLING
  
}
