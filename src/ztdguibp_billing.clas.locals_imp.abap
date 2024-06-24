CLASS lhc_billh DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS
      get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR billh RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR billh RESULT result.

    METHODS createbilling FOR MODIFY
      IMPORTING keys FOR ACTION billh~createbilling.

    METHODS generatexml FOR MODIFY
      IMPORTING keys FOR ACTION billh~generatexml.

    METHODS createbillingjob FOR MODIFY
      IMPORTING keys FOR ACTION billh~createbillingjob.

ENDCLASS.

CLASS lhc_billh IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.

  ENDMETHOD.

  METHOD createBilling.

    DATA l_tabix LIKE sy-tabix.

    READ ENTITIES OF ztdguii_billing IN LOCAL MODE
      ENTITY billh
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_pdford).

    READ ENTITIES OF ztdguii_billing IN LOCAL MODE
      ENTITY billh
      BY \_billi
      ALL FIELDS WITH CORRESPONDING #( lt_pdford )
      RESULT DATA(lt_pdfitem).

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    TRY.
        DATA(lo_store) = NEW zcl_fp_tmpl_store_client(
          iv_name = 'ZNE_ADS_SRV'
          iv_service_instance_name = 'SAP_COM_0276'
        ).

*""""""Create UUID"""""""""""""""""""""""""""""
        DATA: lo_uuid TYPE REF TO if_system_uuid,
              l_uuid  TYPE sysuuid_x16.

        lo_uuid = cl_uuid_factory=>create_system_uuid(  ).
        l_uuid = lo_uuid->create_uuid_x16(  ).
*""""""""""""""""""""""""""""""""""""""""""""""
        LOOP AT lt_pdford INTO DATA(ls_pdford).

          ls_pdford-Cyear = ls_pdford-Date01(4) - 1911.
          ls_pdford-Cmonth = '01-02'.
          ls_pdford-Cdate01 = ls_pdford-Date01(4)   && '-' &&
                              ls_pdford-Date01+4(2) && '-' &&
                              ls_pdford-Date01+6(2) .
          ls_pdford-Ctime01 = ls_pdford-Time01(2)   && ':' &&
                              ls_pdford-Time01+2(2) && ':' &&
                              ls_pdford-Time01+4(2).

          ls_pdford-Barcode01 = '9876543215'.
          ls_pdford-Qrcode01 = ls_pdford-Billingnum && ls_pdford-Date01.
          ls_pdford-Qrcode02 = '992234567855'.


          DATA: l_price_total TYPE int4.
          l_price_total = ls_pdford-Amount.

          DATA: l_billnum TYPE c LENGTH 11.
          l_billnum = ls_pdford-Billingnum(2) && '-' &&
                      ls_pdford-Billingnum+2(8).

          DATA(lv_xml_raw) =
                |<?xml version="1.0" encoding="utf-8"?>| &&
                |<asx:abap version="1.0" xmlns:asx="http://www.sap.com/abapxml">| &&
                |<asx:values>| &&
                |<LT_A>|.

          "create xml string
          lv_xml_raw = lv_xml_raw &&

          |<item>| &&

          |<INCLUDE>| &&
          |<CLIENT>| && |</CLIENT>| &&
          |<BILLINGNUM>|  && l_billnum             && |</BILLINGNUM>| &&
          |<SELLERNUM>|   && ls_pdford-Sellernum   && |</SELLERNUM>| &&
          |<SELLERNAME>|  && ls_pdford-Sellername  && |</SELLERNAME>| &&
          |<BUYERNUM>|    && ls_pdford-Buyernum    && |</BUYERNUM>| &&
          |<AMOUNT>|      && l_price_total         && |</AMOUNT>| &&
          |<QUANTITYALL>| && ls_pdford-Quantityall && |</QUANTITYALL>| &&
          |<RANDOM>|      && ls_pdford-Random      && |</RANDOM>| &&
          |<TYPE>|        && ls_pdford-Type        && |</TYPE>| &&
          |<DATE01>|      && ls_pdford-Date01      && |</DATE01>| &&
          |<CDATE01>|     && ls_pdford-CDate01     && |</CDATE01>| &&
          |<TIME01>|      && ls_pdford-Time01      && |</TIME01>| &&
          |<CTIME01>|     && ls_pdford-Ctime01     && |</CTIME01>|   &&
          |<CMONTH>|      && ls_pdford-Cmonth      && |</CMONTH>|    &&
          |<CYEAR>|       && ls_pdford-Cyear       && |</CYEAR>|     &&
          |<BARCODE01>|   && ls_pdford-Barcode01   && |</BARCODE01>| &&
          |<QRCODE01>|    && ls_pdford-Qrcode01    && |</QRCODE01>|  &&
          |<QRCODE02>|    && ls_pdford-Qrcode02    && |</QRCODE02>|  &&
          |<CREATED_AT>|         &&   |</CREATED_AT>|         &&
          |<LASTCHANGEDBY>|      &&   |</LASTCHANGEDBY>|      &&
          |<LASTCHANGEDAT>|      &&   |</LASTCHANGEDAT>|      &&
          |<LOCALLASTCHANGEDAT>| &&   |</LOCALLASTCHANGEDAT>| &&
          |</INCLUDE>| &&

          |<INNER>|.

          SORT lt_pdfitem BY Seq ASCENDING.
          LOOP AT lt_pdfitem INTO DATA(ls_pdfitem).
            l_tabix = sy-tabix.

            DATA: l_price     TYPE int4,
                  l_price_cal TYPE int4.
            l_price     = ls_pdfitem-Price.
            l_price_cal = ls_pdfitem-Totalprice.

            IF ls_pdfitem-Billingnum = ls_pdford-Billingnum.

              lv_xml_raw = lv_xml_raw &&

              |<item>| &&
              |<INCLUDE>| &&
              |<SEQ>|        && ls_pdfitem-Seq      && |</SEQ>| &&
              |<PRODNAME>|   && ls_pdfitem-Prodname && |</PRODNAME>| &&
              |<QUANTITY>|   && ls_pdfitem-Quantity && |</QUANTITY>| &&
              |<PRICE>|      && l_price             && |</PRICE>| &&
              |<TOTALPRICE>| && l_price_cal         && |</TOTALPRICE>| &&
              |<MEMO>|       && ls_pdfitem-Memo     && |</MEMO>| &&
              |</INCLUDE>|   &&
              |</item>|.

              DELETE lt_pdfitem INDEX l_tabix.

            ENDIF.
          ENDLOOP.

          lv_xml_raw = lv_xml_raw &&
            |</INNER>| &&
            |</item>| &&
            |</LT_A>| &&
            |</asx:values>| &&
            |</asx:abap>|.

          DATA(lv_xml_self) = cl_abap_conv_codepage=>create_out(
             )->convert( lv_xml_raw ).


          DATA(lp_invoice_ty) = keys[ 1 ]-%param-invoice.
          DATA(lp_filedesc)   = keys[ 1 ]-%param-filedesc.

              "取得PDF Form template
              DATA(ls_template) = lo_store->get_template_by_name(
                iv_get_binary     = abap_true
                iv_form_name      = 'ZTDGUI_' && lp_invoice_ty && '_PREVIEW' "<= form object in template store
                iv_template_name  = 'ZTDGUI_' && lp_invoice_ty && '_PREVIEW' "<= template (in form object) that should be used
              ).

          "組合PDF Form和Add On Table的資料
          cl_fp_ads_util=>render_4_pq(
            EXPORTING
              iv_locale       = 'en_US'
              iv_pq_name      = 'ZNEDEV_PRINT_QUEUE' "<= Name of the print queue where result should be stored
              iv_xml_data     = lv_xml_self
              iv_xdp_layout   = ls_template-xdp_template
              is_options      = VALUE #(
              trace_level     = 4 "Use 0 in production environment
              )
            IMPORTING
              ev_trace_string = DATA(lv_trace)
              ev_pdl          = DATA(lv_pdf)
          ).

        ENDLOOP.

        "命名上一動生成的PDF Form資料
        cl_print_queue_utils=>create_queue_item_by_data(
            "Name of the print queue where result should be stored
            iv_qname = 'ZNEDEV_PRINT_QUEUE'
            iv_print_data = lv_pdf "Print document contained in xstring format
            iv_name_of_main_doc = ls_pdford-Billingnum && '發票' && lp_invoice_ty && '_PREVIEW' "Name of the main document
*            iv_number_of_copies = '5' "Number of copies
*            iv_pages = '2' "Number of pages
        ).

        "Upload the xstring to z table, so the content can be viewed with RAP generated report
        DATA: lt_input TYPE STANDARD TABLE OF znet_pdf_store.
        DATA(l_date) = cl_abap_context_info=>get_system_date(  ).
        DATA(l_time) = cl_abap_context_info=>get_system_time(  ).
        DATA(l_znoe) = cl_abap_context_info=>get_user_time_zone(  ).

        CONVERT DATE l_date TIME l_time INTO TIME STAMP DATA(lv_timestamp) TIME ZONE l_znoe.

        lt_input = VALUE #( (
        pdf_file    = l_uuid
        description = '發票pdf生成測試:' && lp_filedesc
        filename    = ls_pdford-Billingnum && '發票' && lp_invoice_ty && '_PREVIEW'
        attachment  = lv_pdf
        mimetype    = 'application/pdf'
        created_at  = lv_timestamp
        created_by  = sy-uname
        ) ).

        INSERT znet_pdf_store FROM TABLE @lt_input.

        IF sy-subrc <> 0.
          INSERT VALUE #(
                    %msg = new_message_with_text(
                       severity = if_abap_behv_message=>severity-information
                       text     = |建立PDF失敗。|
                       )
             ) INTO TABLE reported-billh.
        ELSE.
          INSERT VALUE #(
                    %msg = new_message_with_text(
                       severity = if_abap_behv_message=>severity-information
                       text     = |建立PDF成功 File ID:| && l_uuid
                       )
             ) INTO TABLE reported-billh.
        ENDIF.

      CATCH cx_fp_fdp_error
            zcx_fp_tmpl_store_error
            cx_fp_ads_util INTO FINAL(l_exception_msg).
        INSERT VALUE #(
                  %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-information
                     text     = |Exception:| && l_exception_msg->get_text( )
                     )
           ) INTO TABLE reported-billh.
    ENDTRY.

  ENDMETHOD.

  METHOD generateXml.

    DATA l_uuid TYPE string.
    "生成一個Excel 空檔
    DATA(lo_write_access) = xco_cp_xlsx=>document->empty( )->write_access( ).
    "建立Excel 頁籤
    DATA(lo_worksheet) = lo_write_access->get_workbook(
      )->worksheet->at_position( 1 ).
    DATA: descript TYPE string.
    DATA l_tabix TYPE i.
    DATA: l_column TYPE i.
    DATA: lw_tab_ref        TYPE REF TO data.
    DATA: lo_tablestructure TYPE REF TO cl_abap_structdescr.
    DATA: ls_file TYPE STRUCTURE FOR CREATE zchi_file,
          lt_file TYPE TABLE FOR CREATE zchi_file.
    DATA: l_msg TYPE string.
    "檔案名
    DATA l_filename TYPE string.
    DATA: lv_json   TYPE /ui2/cl_json=>json.
    DATA: l_type         TYPE string,
          l_mintype(128),
          l_attachment   TYPE xstring,
          l_longString   TYPE string.
*    DATA(lv_file_content) = lo_write_access->get_file_content( ).

    " A selection pattern that was obtained via XCO_CP_XLSX_SELECTION=>PATTERN_BUILDER.
    DATA(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).

    IF keys[ 1 ]-%param-filename IS INITIAL OR keys[ 1 ]-%param-typeName IS INITIAL.

      l_msg = '檔案名稱 or TypeName不能為空'.
      INSERT VALUE #(
       %msg = new_message_with_text(
                                     severity = if_abap_behv_message=>severity-warning
                                     text     = l_msg )
  ) INTO TABLE reported-billh.

    ELSE.

      "計算當前筆數 用於排列序號
      SELECT COUNT( * )
      FROM zcht_file INTO @DATA(l_count).
      IF l_count IS INITIAL.
        l_count = 1.
      ELSE.
        l_count += 1.
      ENDIF.
      "讀取所選的欄位資料
    READ ENTITIES OF ztdguii_billing IN LOCAL MODE
      ENTITY billh
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

      CREATE DATA lw_tab_ref LIKE LINE OF lt_result.
      "將lw_tab_ref 描述寫入 lo_tablestructure 為了得到欄位name
      lo_tablestructure ?= cl_abap_typedescr=>describe_by_data_ref( lw_tab_ref ).

      "寫入 Field Value
      LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<ls_result4>).

        IF sy-tabix = 1.
          "寫入 Field Name
          LOOP AT  lo_tablestructure->components ASSIGNING FIELD-SYMBOL(<ls_tab1>) .

            IF sy-tabix = 1.
              descript = <ls_tab1>-name.
            ELSE.
              descript = descript &&  | \t | &&  <ls_tab1>-name.
            ENDIF.

            AT LAST.
              descript = descript && | \n |.
            ENDAT.

          ENDLOOP.
        ENDIF.

        CLEAR l_column.

        "讀取structure 欄位value 謝入對應的Field Name
        LOOP AT lo_tablestructure->components REFERENCE INTO DATA(lo_component1).

          l_column = l_column + 1.

          ASSIGN COMPONENT lo_component1->name OF STRUCTURE <ls_result4> TO FIELD-SYMBOL(<lfs_value4>).

          IF sy-subrc = 0.
            IF l_column = 1.
              descript = descript && <lfs_value4>.
            ELSE.
              descript = descript &&  | \t | && <lfs_value4>.
            ENDIF.

          ENDIF.

          AT LAST.
            descript = descript && | \n |.
          ENDAT.
        ENDLOOP.

      ENDLOOP.

      CASE  keys[ 1 ]-%param-typeName.

        WHEN 'JSON'.

          l_type = '.json'.
          l_mintype = 'application/json'.
          " serialize table lt_flight into JSON, skipping initial fields and converting ABAP field names into camelCase
          lv_json = /ui2/cl_json=>serialize( data          = lt_result
                                             pretty_name   = /ui2/cl_json=>pretty_mode-camel_case
                                             compress      = abap_true
                                            ).
          l_longstring = lv_json.
          DATA(lxstring) =  xco_cp=>string( lv_json )->as_xstring( xco_cp_character=>code_page->utf_8
                           )->value.
          TRY.
              DATA(xstring) = cl_abap_conv_codepage=>create_out( )->convert( lv_json ).
            CATCH cx_sy_conversion_codepage INTO DATA(ex).
          ENDTRY.

          l_longstring = descript.
          l_attachment = lxstring.

        WHEN 'XLSX'.

          l_type = '.xlsx'.
          l_mintype = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'.

          " serialize table lt_flight into JSON, skipping initial fields and converting ABAP field names into camelCase
          lv_json = /ui2/cl_json=>serialize( data          = lt_result
                                             pretty_name   = /ui2/cl_json=>pretty_mode-camel_case
                                             compress      = abap_true
                                            ).
          l_longstring = lv_json.

          "建立格式
          lo_worksheet->select( lo_selection_pattern
            )->row_stream(
            )->operation->write_from( REF #( lt_result )
            )->execute( ).

          "將lw_tab_ref 描述寫入 lo_tablestructure 為了得到欄位name
          lo_tablestructure ?= cl_abap_typedescr=>describe_by_data_ref( lw_tab_ref ).

          "宣告開始寫入位置
          DATA(lo_cursor) = lo_worksheet->cursor(
               io_column = xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )
               io_row    = xco_cp_xlsx=>coordinate->for_numeric_value( 1 )
              ).

          "寫入 Field Name
          LOOP AT  lo_tablestructure->components ASSIGNING FIELD-SYMBOL(<ls_tab>) .

            IF sy-tabix = 1.
              lo_cursor->get_cell( )->value->write_from( <ls_tab>-name ).

            ELSE.
              lo_cursor->move_right( )->get_cell( )->value->write_from( <ls_tab>-name ).

            ENDIF.

          ENDLOOP.

          "寫入 Field Value
          LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<ls_result2>).

            l_tabix = sy-tabix + 1.

            CLEAR l_column.

            DATA(lo_cursor2) = lo_worksheet->cursor(
              io_column = xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )
              io_row    = xco_cp_xlsx=>coordinate->for_numeric_value( l_tabix )
            ).
            "讀取structure 欄位value 謝入對應的Field Name
            LOOP AT lo_tablestructure->components REFERENCE INTO DATA(lo_component).

              l_column = l_column + 1.

              ASSIGN COMPONENT lo_component->name OF STRUCTURE <ls_result2> TO FIELD-SYMBOL(<lfs_value>).

              IF sy-subrc = 0.
                IF l_column = 1.
                  lo_cursor2->get_cell( )->value->write_from( <lfs_value> ).
                ELSE.
                  lo_cursor2->move_right( )->get_cell( )->value->write_from( <lfs_value> ).
                ENDIF.
              ENDIF.

            ENDLOOP.

          ENDLOOP.

          l_attachment =  lo_write_access->get_file_content( ).

        WHEN 'TEXT'.
          l_type = '.txt'.
          l_mintype = 'text/plain'.

          DATA(lxstring2) =  xco_cp=>string( descript )->as_xstring( xco_cp_character=>code_page->utf_8
                           )->value.
          TRY.
              DATA(xstring2) = cl_abap_conv_codepage=>create_out( )->convert( descript ).
            CATCH cx_sy_conversion_codepage INTO DATA(ex2).
          ENDTRY.

          l_longstring = descript.
          l_attachment = lxstring2.

        WHEN 'XML'.

          l_type = '.xml'.
          l_mintype = 'text/xml'.

          CALL TRANSFORMATION id SOURCE lt_a = lt_result
                                 RESULT XML FINAL(xml_xstring).

          l_longstring = descript.
          l_attachment = xml_xstring.

      ENDCASE.

      l_filename = keys[ 1 ]-%param-filename && l_type.

      ls_file = VALUE #( %cid = '3'
                        FileNO = l_count
                        Attachment = l_attachment
                        mimetype = l_mintype
                        filename = l_filename
                        longString = l_longString
                        %control-Attachment = if_abap_behv=>mk-on
                        %control-mimetype = if_abap_behv=>mk-on
                        %control-filename = if_abap_behv=>mk-on
                        %control-longString = if_abap_behv=>mk-on
                        %control-FileNO = if_abap_behv=>mk-on
                        ).

      APPEND ls_file TO lt_file.

    MODIFY ENTITIES OF zchi_file
       ENTITY zchi_file
         CREATE FROM lt_file
         MAPPED DATA(mapped3)
         FAILED DATA(Failed1)
         REPORTED DATA(report3).

      LOOP AT mapped3-zchi_file ASSIGNING FIELD-SYMBOL(<ls_map>).
        DATA(lv_result) = <ls_map>-ruuid.
      ENDLOOP.

      l_uuid = lv_result.

      IF failed IS INITIAL.
        l_filename = l_filename && ' 建立成功'.
        l_msg = 'FileNO : ' && l_count  && |\n 檔案: | && l_filename && |\n UUID: | && l_uuid .
        INSERT VALUE #(
         %msg = new_message_with_text(
                                       severity = if_abap_behv_message=>severity-success
                                       text     = l_msg )
    ) INTO TABLE reported-billh.
      ENDIF.

    ENDIF.

  ENDMETHOD.

  METHOD createBillingjob.

    DATA l_tabix LIKE sy-tabix.

    DATA job_template_name TYPE cl_apj_rt_api=>ty_template_name VALUE 'ZTDGUIJT_PDF_JOB_LOGIC02'.
    DATA job_start_info TYPE cl_apj_rt_api=>ty_start_info.
    DATA job_parameters TYPE cl_apj_rt_api=>tt_job_parameter_value.
    DATA job_name TYPE cl_apj_rt_api=>ty_jobname.
    DATA job_count TYPE cl_apj_rt_api=>ty_jobcount.

    READ ENTITIES OF ztdguii_billing IN LOCAL MODE
      ENTITY billh
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_pdford).

    READ ENTITIES OF ztdguii_billing IN LOCAL MODE
      ENTITY billh
      BY \_billi
      ALL FIELDS WITH CORRESPONDING #( lt_pdford )
      RESULT DATA(lt_pdfitem).

    LOOP AT lt_pdford INTO DATA(ls_pdford).
      l_tabix = sy-tabix.

      DATA job_parameter TYPE cl_apj_rt_api=>ty_job_parameter_value.
      job_parameter-name = 'S_ID'.
      job_parameter-t_value = VALUE #( ( low    = ls_pdford-Billingnum
                                         sign   = 'I'
                                         option = 'EQ'
                                         high   = '' ) ).
      APPEND job_parameter TO job_parameters.

      IF l_tabix = 1.

        DATA: lo_uuid TYPE REF TO if_system_uuid,
              l_uuid  TYPE sysuuid_x16.

        lo_uuid = cl_uuid_factory=>create_system_uuid(  ).
        l_uuid = lo_uuid->create_uuid_x16(  ).

        job_parameter-name = 'P_PID'.
        job_parameter-t_value = VALUE #( ( low    = l_uuid
                                           sign   = 'I'
                                           option = 'EQ' ) ).
        APPEND job_parameter TO job_parameters.

        DATA l_filename TYPE string.
        l_filename = ls_pdford-Billingnum && '發票' && keys[ l_tabix ]-%param-invoice && '_PREVIEW_JOB' && '.pdf'.
        job_parameter-name = 'P_FN'.
        job_parameter-t_value = VALUE #( ( low    = l_filename
                                           sign   = 'I'
                                           option = 'EQ' ) ).
        APPEND job_parameter TO job_parameters.

        DATA l_description TYPE string.
        l_description = '發票pdf生成測試:' && keys[ l_tabix ]-%param-filedesc.
        job_parameter-name = 'P_DES'.
        job_parameter-t_value = VALUE #( ( low    = l_description
                                           sign   = 'I'
                                           option = 'EQ' ) ).
        APPEND job_parameter TO job_parameters.

        DATA l_priter TYPE string.
        l_priter = keys[ l_tabix ]-%param-printopt.
        job_parameter-name = 'P_MO1'.
        job_parameter-t_value = VALUE #( ( low    = l_priter
                                           sign   = 'I'
                                           option = 'EQ' ) ).
        APPEND job_parameter TO job_parameters.

      ENDIF.

    ENDLOOP.

    GET TIME STAMP FIELD DATA(start_time_of_job).
    job_start_info-start_immediately = abap_true.
    job_start_info-timestamp = start_time_of_job.

    cl_apj_rt_api=>schedule_job(
        EXPORTING
        iv_job_template_name = job_template_name
        iv_job_text = |PDF Generated - Neil|
        is_start_info = job_start_info
        it_job_parameter_value = job_parameters
        IMPORTING
        ev_jobname  = job_name
        ev_jobcount = job_count
        ).

    INSERT VALUE #(
              %msg = new_message_with_text(
                 severity = if_abap_behv_message=>severity-information
                 text     = |PDF排程建立成功 File ID:| && l_uuid
                 )
       ) INTO TABLE reported-billh.

 ENDMETHOD.

ENDCLASS.
