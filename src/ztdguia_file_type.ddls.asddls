@EndUserText.label: 'file name'
define abstract entity ztdguia_file_type
//  with parameters parameter_name : parameter_type
{
  @Consumption.valueHelpDefinition: [
  { entity:  { name: 'ZTDGUIC_FILE_TYPE_VH', element: 'typeName' }
             }]
    @EndUserText.label:'檔案類型'    
    typeName           : abap.char(10);

    @EndUserText.label:'檔案名稱'    
    filename           : abap.char(128);

}
