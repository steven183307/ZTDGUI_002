@EndUserText.label: 'gui parameter'
define root abstract entity ztdguia_invoice_job
{

  @Consumption.valueHelpDefinition: [ { 
    entity: { name: 'ZTDGUIC_INVOICE_TY_VH', element: 'value_low' }
             }]
    @EndUserText.label:'發票類型'
    invoice : abap.char(3);

  @Consumption.valueHelpDefinition: [ { 
    entity: { name: 'ZTDGUIC_PRINTER_VH', element: 'text' }
             }]    
    @EndUserText.label:'選擇印表機'    
    printopt : abap.char(30);    
    
    @EndUserText.label:'備註說明'    
    filedesc : abap.char(40);
}
