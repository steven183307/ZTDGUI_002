@EndUserText.label: 'gui parameter'
define abstract entity ztdguia_invoice_preview
{

  @Consumption.valueHelpDefinition: [
  { entity:  { name: 'ZTDGUIC_INVOICE_TY_VH', element: 'value_low' }
             }]
    @EndUserText.label:'發票類型'
    invoice : abap.char(3);
    @EndUserText.label:'備註說明'    
    filedesc : abap.char(40);
}
