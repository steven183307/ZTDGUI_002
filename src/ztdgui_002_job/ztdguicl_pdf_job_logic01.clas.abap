CLASS ztdguicl_pdf_job_logic01 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZTDGUICL_PDF_JOB_LOGIC01 IMPLEMENTATION.


  METHOD if_apj_dt_exec_object~get_parameters.

    " Return the supported selection parameters here
    et_parameter_def = VALUE #(
      ( selname = 'S_ID'  kind = if_apj_dt_exec_object=>select_option datatype = 'C' length = 32 param_text = 'UUID' changeable_ind = abap_true )
      ( selname = 'P_PID' kind = if_apj_dt_exec_object=>parameter datatype = 'C' length = 32 param_text = 'PDF ID' lowercase_ind = abap_true changeable_ind = abap_true )
      ( selname = 'P_FN'  kind = if_apj_dt_exec_object=>parameter datatype = 'C' length = 32 param_text = 'File Name' lowercase_ind = abap_true changeable_ind = abap_true )
      ( selname = 'P_DES' kind = if_apj_dt_exec_object=>parameter datatype = 'C' length = 32 param_text = 'Description' lowercase_ind = abap_true changeable_ind = abap_true )
      ( selname = 'P_MO1' kind = if_apj_dt_exec_object=>parameter datatype = 'C' length = 32 param_text = 'Memo1' lowercase_ind = abap_true changeable_ind = abap_true )
      ( selname = 'P_MO2' kind = if_apj_dt_exec_object=>parameter datatype = 'C' length = 32 param_text = 'Memo2' lowercase_ind = abap_true changeable_ind = abap_true )
    ).

    " Return the default parameters values here
    et_parameter_val = VALUE #(
      ( selname = 'S_ID'  kind = if_apj_dt_exec_object=>select_option sign = 'I' option = 'EQ' low = '5555' )
      ( selname = 'P_PID' kind = if_apj_dt_exec_object=>parameter sign = 'I' option = 'EQ' low = 'PID' )
      ( selname = 'P_FN'  kind = if_apj_dt_exec_object=>parameter sign = 'I' option = 'EQ' low = 'FN' )
      ( selname = 'P_DES' kind = if_apj_dt_exec_object=>parameter sign = 'I' option = 'EQ' low = 'DES' )
      ( selname = 'P_MO1' kind = if_apj_dt_exec_object=>parameter sign = 'I' option = 'EQ' low = 'Mo1' )
      ( selname = 'P_MO2' kind = if_apj_dt_exec_object=>parameter sign = 'I' option = 'EQ' low = 'Mo2' )
    ).

  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.

    DATA(n) = 0.
    DATA(n2) = 0.
    DATA l_tabix LIKE sy-tabix.

    DATA: BEGIN OF ls_uuid,
            pdf_uuid TYPE c LENGTH 32,
          END OF ls_uuid,
          lt_uuid LIKE TABLE OF ls_uuid.

    DATA: l_filename    TYPE c LENGTH 120,
          l_description TYPE c LENGTH 120,
          l_mo1         TYPE c LENGTH 32,
          l_fuuid       TYPE c LENGTH 32.

    " Getting the actual parameter values(Just for show. Not needed for the logic below)
    LOOP AT it_parameters INTO DATA(ls_parameter).

      CASE ls_parameter-selname.

        WHEN 'S_ID'.
          ls_uuid-pdf_uuid = ls_parameter-low.
          APPEND ls_uuid TO lt_uuid.

        WHEN 'P_PID'.
          l_fuuid = ls_parameter-low.

        WHEN 'P_FN'.
          l_filename = ls_parameter-low.

        WHEN 'P_DES'.
          l_description = ls_parameter-low.

        WHEN 'P_MO1'.
          l_mo1 = ls_parameter-low.

      ENDCASE.

    ENDLOOP.


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
        LOOP AT lt_uuid INTO ls_uuid.
          READ ENTITIES OF ztdguii_billing
            ENTITY billh
            ALL FIELDS WITH VALUE #( ( Billingnum = ls_uuid-pdf_uuid ) )
            RESULT DATA(lt_pdford).

          READ ENTITIES OF ztdguii_billing
            ENTITY billh
            BY \_billi
            ALL FIELDS WITH CORRESPONDING #( lt_pdford )
            RESULT DATA(lt_pdfitem).
        ENDLOOP.

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


          DATA(lp_invoice_ty) = l_filename+12(3).
          DATA(lp_filedesc)   = l_description.

          "取得PDF Form template
          DATA(ls_template) = lo_store->get_template_by_name(
            iv_get_binary     = abap_true
            iv_form_name      = 'ZTDGUI_' && lp_invoice_ty && '_PRINT' "<= form object in template store
*            iv_form_name      = 'ZTDGUI_B2B_PREVIEW' "<= form object in template store
            iv_template_name  = 'ZTDGUI_' && lp_invoice_ty && '_PRINT' "<= template (in form object) that should be used
*            iv_template_name  = 'ZTDGUI_B2B_PREVIEW' "<= template (in form object) that should be used
          ).

          "組合PDF Form和Add On Table的資料
          cl_fp_ads_util=>render_4_pq(
            EXPORTING
              iv_locale       = 'en_US'
*              iv_pq_name      = 'ZNEDEV_PRINT_QUEUE' "<= Name of the print queue where result should be stored
              iv_pq_name      = l_mo1 "<= Name of the print queue where result should be stored
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
            iv_qname = l_mo1
            iv_print_data = lv_pdf "Print document contained in xstring format
            iv_name_of_main_doc = ls_pdford-Billingnum && '發票' && lp_invoice_ty && '_PREVIEW_JOB' "Name of the main document
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
        description = l_description
        filename    = ls_pdford-Billingnum && '發票' && lp_invoice_ty && '_PREVIEW_JOB'
        attachment  = lv_pdf
        mimetype    = 'application/pdf'
        created_at  = lv_timestamp
        created_by  = sy-uname
        ) ).

        INSERT znet_pdf_store FROM TABLE @lt_input.

      CATCH cx_fp_fdp_error
            zcx_fp_tmpl_store_error
            cx_fp_ads_util INTO FINAL(l_exception_msg).

        DATA(l_error_msg) = cl_abap_conv_codepage=>create_out( )->convert( l_exception_msg->get_longtext(  ) ).
        l_date = cl_abap_context_info=>get_system_date(  ).
        l_time = cl_abap_context_info=>get_system_time(  ).
        l_znoe = cl_abap_context_info=>get_user_time_zone(  ).

        CONVERT DATE l_date TIME l_time INTO TIME STAMP lv_timestamp TIME ZONE l_znoe.

        lt_input = VALUE #( (
        pdf_file    = l_fuuid
        description = 'Exception Happened'
        filename    = 'Error_Msg.txt'
        attachment  = l_error_msg
        mimetype = 'text/plain'
        created_at  = lv_timestamp
        created_by  = sy-uname
        ) ).

        INSERT znet_pdf_store FROM TABLE @lt_input.

    ENDTRY.




  ENDMETHOD.
ENDCLASS.
