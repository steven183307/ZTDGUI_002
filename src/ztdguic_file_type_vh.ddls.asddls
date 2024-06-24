@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'file type'

@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZTDGUIC_FILE_TYPE_VH 
  as select from ztdguit_filety
{
  @UI.hidden: true
  key ruuid,
  key type as typeName
}
