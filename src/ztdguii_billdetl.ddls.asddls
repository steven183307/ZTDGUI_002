@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '##GENERATED ZTDGUIT_BILLDETL'
define view entity ZTDGUII_BILLDETL
  as select from ztdguit_billdetl as billi
  association to parent ZTDGUII_BILLING as _billh on $projection.Billingnum = _billh.Billingnum  
{
  @EndUserText.label: 'UUID'
  key uuidi as Uuidi,
  @EndUserText.label: '項次'    
  key seq as Seq,
  billingnum as Billingnum,
  @EndUserText.label: '品名'    
  prodname as Prodname,
  @EndUserText.label: '數量'   
  quantity as Quantity,
  @EndUserText.label: '金額'    
  price as Price,
  @EndUserText.label: '總金額'  
  totalprice as Totalprice,
  @EndUserText.label: '備註'    
  memo as Memo,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  lastchangedby as Lastchangedby,
  @Semantics.systemDateTime.lastChangedAt: true
  lastchangedat as Lastchangedat,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  locallastchangedat as Locallastchangedat,
  
  _billh
  
}
