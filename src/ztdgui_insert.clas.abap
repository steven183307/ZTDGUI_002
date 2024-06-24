CLASS ztdgui_insert DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
      INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS ZTDGUI_INSERT IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

  DATA H TYPE ztdguit_filety.
DATA: lo_uuid TYPE REF TO if_system_uuid,
      l_uuid  TYPE sysuuid_x16.

lo_uuid = cl_uuid_factory=>create_system_uuid(  ).
l_uuid = lo_uuid->create_uuid_x16(  ).
  H-ruuid = l_uuid.
  H-type = 'XLSX'.

 INSERT INTO  ztdguit_filety
VALUES @H.
*DELETE FROM  ztdguit_filety WHERE TYPE = 'JSON'.

  ENDMETHOD.
ENDCLASS.
