CREATE OR REPLACE PACKAGE BODY XXC.xxctcl_gg_filter_condition_pkg
/******************************************************************************
   NAME:       xxctcl_gg_filter_condition_pkg.pkb
   PURPOSE:   Validate india specific and posted transactions and return the count back to Golden Gate

   REVISIONS:
    Ver        Date        Author            Description
    ----      --------      -----------       ----------------------------------
    1.0        02-05-2025  WJ454(BSL)         Created this package.
    1.1        24-02-2025  AL02R              created the xxctcl_CP_CHECK function to check is p_prog_val is excluded

                                              CP or not and added the logic to compare onld value and new value
    1.2        24-02-2025  WJ454              created the xxctcl_CP_CHECK function to check whether the client is having

                                              super user access or not
    1.3        03-03-2025  UG039              Modified for performance issues

    1.4        02-06-2025  XW294              Audit Trail Solution changes Project(Commented Unused Code and Rearragned the Code)



******************************************************************************/
AS
   l_count            NUMBER := 0;
   --    l_log_seq        NUMBER;
   l_key_value        VARCHAR2 (4000);
   -- l_old_val          VARCHAR2 (4000);
   --l_new_val          VARCHAR2 (4000);
   l_status_mess      VARCHAR2 (1000) DEFAULT NULL;
   l_prog_val         VARCHAR2 (1000);
   l_start_time       DATE;
   l_parameter_mess   VARCHAR2 (1000);

   /******************************************************************************
      NAME:        xxctcl_gg_filter_condition_prc
      PURPOSE:    Validate india specific and posted transactions and return the count back to Golden Gate

      REVISIONS:
      Ver        Date        Author               Description
      ---------  ----------  ---------------      ----------------------------------
      1.0        02-05-2025  WJ454(BSL)          Created this procedure  xxctcl_gg_filter_condition_prc

      INPUT PARAMETERS:  P_TABLE_NAME,P_KEY_VALUE1,P_KEY_VALUE2,P_KEY_VALUE3

      OUTPUT PARAMETERS:   p_vc_err_buff
                           p_vc_ret_code
      INOUT PARAMETERS:

      ASSUMPTIONS:
      LIMITATIONS:
      NOTES:
   ******************************************************************************/
   PROCEDURE xxctcl_gg_filter_condition_prc (
      p_prog_val           IN     VARCHAR2 DEFAULT NULL,
      p_client_id          IN     VARCHAR2 DEFAULT NULL,
      p_event_time         IN     VARCHAR2 DEFAULT NULL,
      p_collection_time    IN     VARCHAR2 DEFAULT NULL,
      p_event              IN     VARCHAR2,
      p_table_name         IN     VARCHAR2,
      p_key_value1         IN     VARCHAR2 DEFAULT NULL,
      p_key_value2         IN     VARCHAR2 DEFAULT NULL,
      p_key_value3         IN     VARCHAR2 DEFAULT NULL,
      p_key_value4         IN     VARCHAR2 DEFAULT NULL,
      p_key_value5         IN     VARCHAR2 DEFAULT NULL,
      p_key_value6         IN     VARCHAR2 DEFAULT NULL,
      p_key_value7         IN     VARCHAR2 DEFAULT NULL,
      p_key_value8         IN     VARCHAR2 DEFAULT NULL,
      p_key_value9         IN     VARCHAR2 DEFAULT NULL,
      p_key_value10        IN     VARCHAR2 DEFAULT NULL,
      p_key_value11        IN     VARCHAR2 DEFAULT NULL,
      p_key_value12        IN     VARCHAR2 DEFAULT NULL,
      --      P_TRANS_DATE       IN DATE     DEFAULT NULL ,
      p_record_timestamp   IN     VARCHAR2 DEFAULT NULL,
      p_commit_timestamp   IN     VARCHAR2 DEFAULT NULL,
      p_count_val             OUT VARCHAR2,
      p_err_msg               OUT VARCHAR2)
   AS
      PROCEDURE xxctcl_insert_debug_log (p_log_object       VARCHAR2,
                                         p_log_key_value    VARCHAR2,
                                         p_qry_cnt          NUMBER,
                                         -- p_old_val       VARCHAR2,       --Commented by Aditya R for CHG0230549
                                         -- p_new_val       VARCHAR2,        --Commented by Aditya R for CHG0230549
                                         p_status_mess      VARCHAR2)
      AS
         PRAGMA AUTONOMOUS_TRANSACTION;
      BEGIN
         l_parameter_mess :=
            (   ' Event is '
             || p_event
             || ' , Client ID is '
             || p_client_id
             || ' , Event time is '
             || p_event_time
             || ' , Collection Time is '
             || p_collection_time
             || ' Pkg START TIME :- '
             || l_start_time
             || ' Pkg END TIME :- '
             || SYSDATE);

         INSERT INTO xxc.xxc_goldengate_log
            SELECT xxc_goldengate_seq.NEXTVAL,
                   SYSDATE,
                   p_log_object,
                   p_log_key_value,
                   p_qry_cnt,
                      'Count query ran for '
                   || p_log_object
                   || DECODE (l_parameter_mess, NULL, NULL, '|')
                   || DECODE (l_parameter_mess, NULL, NULL, l_parameter_mess)
                   || DECODE (p_err_msg, NULL, NULL, '|')
                   || DECODE (p_err_msg, NULL, NULL, p_err_msg),
                   --l_old_val,                                          --Commented by Aditya R for CHG0230549
                   --l_new_val,                                          --Commented by Aditya R for CHG0230549
                   p_status_mess
              FROM DUAL
             WHERE     1 = 1
                   AND NVL (fnd_profile.VALUE ('XXC_INDIA_AUDIT_LOG'), 'No') =
                          'Yes' /*Profile option based Debug Logging to be made available by adding and condition here*/
                               ;

         COMMIT;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_err_msg :=
                  'Error while inserting into debug table XXCTCL_INSERT_DEBUG_LOG'
               || SQLERRM;
      END;
   BEGIN
      l_start_time := SYSDATE;

      --  1. If you able pass table name from GG as Hard coded i will use 1 singel proce all 42
      --  2. Creatpage AND all 42 procedure get seperate
      --  3. 43 sepererate proceduer

      BEGIN
         SELECT                                                         --  n1
                   --  || nvl2(o1, '|' || o1, '')                   --Changed by Aditya R for CHG0230549 (Removed Old New value variables from package )
                   P_KEY_VALUE1
                || NVL2 (P_KEY_VALUE2, '|' || P_KEY_VALUE2, '')
                || NVL2 (P_KEY_VALUE3, '|' || P_KEY_VALUE3, '')
                || NVL2 (P_KEY_VALUE7, '|' || P_KEY_VALUE7, '')
                || NVL2 (P_KEY_VALUE8, '|' || P_KEY_VALUE8, '')
                || NVL2 (P_KEY_VALUE9, '|' || P_KEY_VALUE9, '')
                || NVL2 (p_event_time, '|' || p_event_time, '')
                || NVL2 (p_collection_time, '|' || p_collection_time, '')
                || NVL2 (p_prog_val, '|' || p_prog_val, '')
                || NVL2 (p_client_id, '|' || p_client_id, '')
           INTO l_key_value
           FROM DUAL;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_key_value := NULL;
      END;

      l_count := 0;
      l_status_mess := NULL;

      l_count := xxctcl_cp_check (p_prog_val, l_count); --Added by Aditya R for CHG0230549 (Removed the table-wise cp check)

      IF l_count = 1
      THEN
         IF p_event IN ('DELETE', 'INSERT')
         THEN
            IF p_client_id IS NULL
            THEN
               l_count := 1;
               l_status_mess := 'Record is ' || P_EVENT || 'ed from backend';
            ELSE
               l_count := 0;
               l_status_mess :=
                     'Record is '
                  || P_EVENT
                  || 'ed from frontend';
            END IF;
         -- update event handled by table_name

         ELSE                          --IF P_EVENT NOT IN ('INSERT','DELETE')
            -- THEN
            IF p_table_name IN ('PO_HEADERS_ALL',
                                'PO_LINES_ALL',
                                'PO_LINE_LOCATIONS_ALL',
                                'PO_DISTRIBUTIONS_ALL',
                                'PO_RELEASES_ALL',
                                'GL_BALANCES',
                                'OE_ORDER_HEADERS_ALL',
                                'OE_ORDER_LINES_ALL',
                                'WSH_DELIVERY_DETAILS')
            THEN
               l_count :=
                  xxctcl_client_superuser_access (p_client_id, l_count);

               IF l_count = 1
               THEN
                  l_status_mess :=
                     'Record is updated by backend or by superuser';
               ELSE
                  l_count := 0;
                  l_status_mess := 'Record is updated by frontend';
               END IF;
            ELSIF p_table_name IN ('BOM_COMPONENTS_B',
                                   'BOM_STRUCTURES_B',
                                   'FA_BOOK_CONTROLS',
                                   'FA_DEPRN_PERIODS',
                                   'GL_CODE_COMBINATIONS',
                                   'FND_FLEX_VALUES',
                                   'FND_FLEX_VALUES_TL',
                                   'GL_LEDGERS',
                                   'GL_PERIOD_STATUSES',
                                   'QP_LIST_LINES',
                                   'QP_LIST_HEADERS_B',
                                   'ORG_ACCT_PERIODS',
                                   'OE_TRANSACTION_TYPES_ALL',
                                   'MTL_SYSTEM_ITEMS_B',
                                   'MTL_PARAMETERS',
                                   'MTL_INTERORG_PARAMETERS',
                                   'IBY_EXTERNAL_PAYEES_ALL',
                                   'IBY_EXT_BANK_ACCOUNTS',
                                   'HZ_CUST_SITE_USES_ALL',
                                   'HZ_CUST_PROFILE_AMTS',
                                   'HZ_CUST_ACCT_SITES_ALL',
                                   'HZ_CUST_ACCOUNTS',
                                   'FA_CATEGORY_BOOKS',
                                   'FA_CATEGORIES_B',
                                   'CE_BANK_ACCOUNTS',
                                   'AP_TERMS_TL',
                                   'AP_SUPPLIERS',
                                   'AP_SUPPLIER_SITES_ALL',
                                   'AP_BANK_BRANCHES',
                                   'AP_BANK_ACCOUNTS_ALL',
                                   'AP_BANK_ACCOUNT_USES_ALL',
                                   'XLE_REGISTRATIONS',
                                   'XLE_ENTITY_PROFILES',
                                   'RA_ACCOUNT_DEFAULT_SEGMENTS',
                                   'PO_SYSTEM_PARAMETERS_ALL',
                                   'MTL_SECONDARY_INVENTORIES',
                                   'JAI_CMN_INVENTORY_ORGS',
                                   'HR_ORGANIZATION_INFORMATION',
                                   'HR_ALL_ORGANIZATION_UNITS',
                                   'GL_PERIODS',
                                   'GL_PERIOD_TYPES',
                                   'FA_METHODS',
                                   'FA_DISTRIBUTION_ACCOUNTS',
                                   'FA_CALENDAR_PERIODS',
                                   'AR_SYSTEM_PARAMETERS_ALL',
                                   'AR_RECEIVABLES_TRX_ALL',
                                   'AR_RECEIPT_METHODS',
                                   'AR_RECEIPT_CLASSES',
                                   'AP_SYSTEM_PARAMETERS_ALL',
                                   '')
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- IF l_count = 1
               --THEN
               l_status_mess := NULL;
            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            ELSIF p_table_name = 'GL_DAILY_RATES'
            THEN
               IF p_key_value1 = 'INR'                             -- o2='INR'
                                      AND p_key_value2 = 'Corporate' --o4 --> Conversion_type (need to change from id to type)
               THEN
                  l_count := 1;
               ELSE
                  l_count := 0;
                  l_status_mess :=
                     (' GL_DAILY RATE IS NOT UPDATED FOR INR CURRENCY ');
               END IF;
            ELSIF p_table_name = 'GL_JE_HEADERS'
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               IF                                            --l_count != 1 OR
                 p_key_value1 != 'P'     --o22 != 'P'        -- o22 --> status
               THEN
                  l_count := 0;
--                  l_status_mess :=
--                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
--                      || p_prog_val);
               END IF;
            ELSIF p_table_name = 'GL_JE_LINES'
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               IF                                            --l_count != 1 OR
                 p_key_value1 != 'P'
               THEN                                           -- o7 --> status
                  l_count := 0;
--                  l_status_mess :=
--                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
--                      || p_prog_val);
               END IF;
            ELSIF p_table_name = 'GL_JE_BATCHES'
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               IF                                            --l_count != 1 OR
                 p_key_value1 != 'P'     --  o3 != 'P' THEN   -- o3 --> status
               THEN
                  l_count := 0;
--                  l_status_mess :=
--                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
--                      || p_prog_val);
               END IF;
            ELSIF (p_table_name = 'XLA_AE_HEADERS')
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- o1 = AE_HEADER_ID

               --IF l_count = 1
               -- THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM apps.xla_ae_headers xah, apps.gl_ledgers gl
                           WHERE     xah.ae_header_id =
                                        TO_NUMBER (p_key_value1) -- TO_NUMBER(o1)
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND gl.ledger_id = xah.ledger_id);


            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            ELSIF (p_table_name = 'XLA_AE_LINES')
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- 01 = AE_HEADER_ID  = p_key_value1
               -- o2 = AE_LINE_NUM   = p_key_value2

               --               IF l_count = 1
               --               THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM apps.xla_ae_headers xah,
                                 apps.xla_ae_lines xal,
                                 apps.gl_ledgers gl
                           WHERE     xal.ae_header_id =
                                        TO_NUMBER (p_key_value1) -- TO_NUMBER(o1)
                                 AND xal.ae_line_num =
                                        TO_NUMBER (p_key_value2) --TO_NUMBER(o2)
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND gl.ledger_id = xah.ledger_id
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F');

            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            ELSIF (p_table_name = 'RCV_PARAMETERS')
            THEN
               --   l_count := xxctcl_cp_check (p_prog_val, l_count);
               l_count := 1;
            -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);

            ELSIF p_table_name = 'RCV_TRANSACTIONS'
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);

               -- p_key_value1 = Transaction_id
               --               IF l_count = 1
               --               THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE (   EXISTS
                             (SELECT 1
                                FROM apps.rcv_receiving_sub_ledger rrsl,
                                     apps.xla_distribution_links xdl,
                                     apps.xla_events xe,
                                     apps.xla_ae_headers xah,
                                     apps.xla_ae_lines xal,
                                     apps.gl_import_references gir,
                                     apps.gl_je_headers gjh
                               WHERE     rrsl.rcv_transaction_id =
                                            p_key_value1                  --o1
                                     AND rrsl.rcv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'RCV_RECEIVING_SUB_LEDGER'
                                     AND xdl.ae_header_id = xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_header_id = xal.ae_header_id -- Modified by UG039
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     AND xal.gl_sl_link_id =
                                            gir.gl_sl_link_id
                                     AND gir.je_header_id = gjh.je_header_id
                                     AND gjh.status = 'P'
                                     AND xal.creation_date <=
                                            TO_DATE (
                                               NVL (
                                                  TO_CHAR (
                                                     TO_TIMESTAMP (
                                                        p_collection_time,
                                                        'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                     'YYYY-MM-DD HH24:MI:SS'),
                                                  TO_CHAR (
                                                     SYSDATE,
                                                     'YYYY-MM-DD HH24:MI:SS')),
                                               'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                       )
                       OR EXISTS
                             (SELECT 1
                                FROM apps.mtl_material_transactions mmt,
                                     apps.mtl_transaction_accounts mta,
                                     apps.xla_events xe,
                                     apps.xla_distribution_links xdl,
                                     apps.xla_ae_headers xah,
                                     apps.xla_ae_lines xal,
                                     apps.gl_import_references gir,
                                     apps.gl_je_headers gjh
                               WHERE     mmt.rcv_transaction_id =
                                            p_key_value1                  --o1
                                     AND mmt.transaction_id =
                                            mta.transaction_id
                                     AND mta.inv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'MTL_TRANSACTION_ACCOUNTS'
                                     AND xdl.ae_header_id = xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_header_id = xal.ae_header_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     AND xal.gl_sl_link_id =
                                            gir.gl_sl_link_id
                                     AND gir.je_header_id = gjh.je_header_id
                                     AND gjh.status = 'P'
                                     AND xal.creation_date <=
                                            TO_DATE (
                                               NVL (
                                                  TO_CHAR (
                                                     TO_TIMESTAMP (
                                                        p_collection_time,
                                                        'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                     'YYYY-MM-DD HH24:MI:SS'),
                                                  TO_CHAR (
                                                     SYSDATE,
                                                     'YYYY-MM-DD HH24:MI:SS')),
                                               'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                       ));



            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            --Condition on DS_AVAL_UAL
            ELSIF p_table_name = 'RCV_SHIPMENT_HEADERS'
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);

               --p_key_value1 = SHIPMENT_HEADER_ID

               --               IF l_count = 1
               --               THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE (   EXISTS
                             (SELECT 1
                                FROM apps.rcv_transactions rt,
                                     apps.rcv_receiving_sub_ledger rrsl,
                                     apps.xla_distribution_links xdl,
                                     apps.xla_events xe,
                                     apps.xla_ae_headers xah,
                                     apps.xla_ae_lines xal,
                                     apps.gl_import_references gir,
                                     apps.gl_je_headers gjh
                               WHERE     rt.shipment_header_id = p_key_value1 --o1
                                     AND rt.transaction_id =
                                            rrsl.rcv_transaction_id
                                     AND rrsl.rcv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'RCV_RECEIVING_SUB_LEDGER'
                                     AND xdl.ae_header_id = xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_header_id = xal.ae_header_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     AND xal.gl_sl_link_id =
                                            gir.gl_sl_link_id
                                     AND gir.je_header_id = gjh.je_header_id
                                     AND gjh.status = 'P'
                                     AND xal.creation_date <=
                                            TO_DATE (
                                               NVL (
                                                  TO_CHAR (
                                                     TO_TIMESTAMP (
                                                        p_collection_time,
                                                        'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                     'YYYY-MM-DD HH24:MI:SS'),
                                                  TO_CHAR (
                                                     SYSDATE,
                                                     'YYYY-MM-DD HH24:MI:SS')),
                                               'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                       )
                       OR EXISTS
                             (SELECT 1
                                FROM apps.rcv_transactions rt,
                                     apps.mtl_material_transactions mmt,
                                     apps.mtl_transaction_accounts mta,
                                     apps.xla_events xe,
                                     apps.xla_distribution_links xdl,
                                     apps.xla_ae_headers xah,
                                     apps.xla_ae_lines xal,
                                     apps.gl_import_references gir,
                                     apps.gl_je_headers gjh
                               WHERE     rt.shipment_header_id = p_key_value1 --o1
                                     AND rt.transaction_id =
                                            mmt.rcv_transaction_id
                                     AND mmt.transaction_id =
                                            mta.transaction_id
                                     AND mta.inv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'MTL_TRANSACTION_ACCOUNTS'
                                     AND xdl.ae_header_id = xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_header_id = xal.ae_header_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     AND xal.gl_sl_link_id =
                                            gir.gl_sl_link_id
                                     AND gir.je_header_id = gjh.je_header_id
                                     AND gjh.status = 'P'
                                     AND xal.creation_date <=
                                            TO_DATE (
                                               NVL (
                                                  TO_CHAR (
                                                     TO_TIMESTAMP (
                                                        p_collection_time,
                                                        'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                     'YYYY-MM-DD HH24:MI:SS'),
                                                  TO_CHAR (
                                                     SYSDATE,
                                                     'YYYY-MM-DD HH24:MI:SS')),
                                               'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                       ));

            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            ELSIF p_table_name = 'RCV_SHIPMENT_LINES'
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);

               --p_key_value1 = SHIPMENT_LINE_ID

               --               IF l_count = 1
               --               THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE (   EXISTS
                             (SELECT 1
                                FROM apps.rcv_transactions rt,
                                     apps.rcv_receiving_sub_ledger rrsl,
                                     apps.xla_distribution_links xdl,
                                     apps.xla_events xe,
                                     apps.xla_ae_headers xah,
                                     apps.xla_ae_lines xal,
                                     apps.gl_import_references gir,
                                     apps.gl_je_headers gjh
                               WHERE     rt.shipment_line_id = p_key_value1 --o1
                                     AND rt.transaction_id =
                                            rrsl.rcv_transaction_id
                                     AND rrsl.rcv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'RCV_RECEIVING_SUB_LEDGER'
                                     AND xdl.ae_header_id = xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_header_id = xal.ae_header_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     AND xal.gl_sl_link_id =
                                            gir.gl_sl_link_id
                                     AND gir.je_header_id = gjh.je_header_id
                                     AND gjh.status = 'P'
                                     AND xal.creation_date <=
                                            TO_DATE (
                                               NVL (
                                                  TO_CHAR (
                                                     TO_TIMESTAMP (
                                                        p_collection_time,
                                                        'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                     'YYYY-MM-DD HH24:MI:SS'),
                                                  TO_CHAR (
                                                     SYSDATE,
                                                     'YYYY-MM-DD HH24:MI:SS')),
                                               'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                       )
                       OR EXISTS
                             (SELECT 1
                                FROM apps.rcv_transactions rt,
                                     apps.mtl_material_transactions mmt,
                                     apps.mtl_transaction_accounts mta,
                                     apps.xla_events xe,
                                     apps.xla_distribution_links xdl,
                                     apps.xla_ae_headers xah,
                                     apps.xla_ae_lines xal,
                                     apps.gl_import_references gir,
                                     apps.gl_je_headers gjh
                               WHERE     rt.shipment_line_id = p_key_value1 --o1
                                     AND rt.transaction_id =
                                            mmt.rcv_transaction_id
                                     AND mmt.transaction_id =
                                            mta.transaction_id
                                     AND mta.inv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'MTL_TRANSACTION_ACCOUNTS'
                                     AND xdl.ae_header_id = xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_header_id = xal.ae_header_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     AND xal.gl_sl_link_id =
                                            gir.gl_sl_link_id
                                     AND gir.je_header_id = gjh.je_header_id
                                     AND gjh.status = 'P'
                                     AND xal.creation_date <=
                                            TO_DATE (
                                               NVL (
                                                  TO_CHAR (
                                                     TO_TIMESTAMP (
                                                        p_collection_time,
                                                        'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                     'YYYY-MM-DD HH24:MI:SS'),
                                                  TO_CHAR (
                                                     SYSDATE,
                                                     'YYYY-MM-DD HH24:MI:SS')),
                                               'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                       ));


            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            ELSIF p_table_name = 'MTL_MATERIAL_TRANSACTIONS'
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);

               --p_key_value1 = TRANSACTION_ID


               --               IF l_count = 1
               --               THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM apps.mtl_transaction_accounts mta,
                                 apps.xla_events xe,
                                 apps.xla_distribution_links xdl,
                                 apps.xla_ae_headers xah,
                                 apps.xla_ae_lines xal,
                                 apps.gl_import_references gir,
                                 apps.gl_je_headers gjh
                           WHERE     mta.transaction_id = p_key_value1    --o1
                                 AND mta.inv_sub_ledger_id =
                                        xdl.source_distribution_id_num_1
                                 AND xdl.source_distribution_type =
                                        'MTL_TRANSACTION_ACCOUNTS'
                                 AND xdl.ae_header_id = xah.ae_header_id
                                 AND xdl.application_id = xah.application_id
                                 AND xdl.ae_header_id = xal.ae_header_id
                                 AND xdl.ae_line_num = xal.ae_line_num
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xe.entity_id = xah.entity_id
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                 AND gir.je_header_id = gjh.je_header_id
                                 AND gjh.status = 'P'
                                 AND xal.creation_date <=
                                        TO_DATE (
                                           NVL (
                                              TO_CHAR (
                                                 TO_TIMESTAMP (
                                                    p_collection_time,
                                                    'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                 'YYYY-MM-DD HH24:MI:SS'),
                                              TO_CHAR (
                                                 SYSDATE,
                                                 'YYYY-MM-DD HH24:MI:SS')),
                                           'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                   );


            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            ELSIF P_TABLE_NAME = 'RA_CUST_TRX_TYPES_ALL'
            THEN
               L_STATUS_MESS := NULL;
            ELSIF p_table_name = 'RA_CUSTOMER_TRX_ALL'
            THEN
               -- l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);


               --p_key_value1 = CUSTOMER_TRX_ID


               --               IF l_count = 1
               --               THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM apps.ra_cust_trx_line_gl_dist_all rctl,
                                 apps.xla_distribution_links xdl,
                                 apps.xla_events xe,
                                 apps.xla_ae_headers xah,
                                 apps.xla_ae_lines xal,
                                 apps.gl_import_references gir,
                                 apps.gl_je_headers gjh
                           WHERE     rctl.customer_trx_id = p_key_value1  --o1
                                 AND rctl.event_id = xe.event_id
                                 AND xe.entity_id = xah.entity_id
                                 AND xdl.source_distribution_id_num_1 =
                                        rctl.cust_trx_line_gl_dist_id
                                 AND xdl.event_id = xe.event_id
                                 AND xdl.ae_header_id = xah.ae_header_id
                                 AND xdl.event_id = xah.event_id
                                 AND xdl.ae_header_id = xal.ae_header_id
                                 AND xdl.ae_header_id = xal.ae_header_id
                                 AND xdl.ae_line_num = xal.ae_line_num
                                 AND source_distribution_type =
                                        'RA_CUST_TRX_LINE_GL_DIST_ALL'
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND gjh.status = 'P'
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                 AND gir.je_header_id = gjh.je_header_id
                                 AND xal.creation_date <=
                                        TO_DATE (
                                           NVL (
                                              TO_CHAR (
                                                 TO_TIMESTAMP (
                                                    p_collection_time,
                                                    'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                 'YYYY-MM-DD HH24:MI:SS'),
                                              TO_CHAR (
                                                 SYSDATE,
                                                 'YYYY-MM-DD HH24:MI:SS')),
                                           'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                   );

            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            ELSIF p_table_name = 'RA_CUSTOMER_TRX_LINES_ALL'
            THEN
               -- l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);

               --- p_key_value1 = CUSTOMER_TRX_LINE_ID

               --               IF l_count = 1
               --               THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM apps.ra_cust_trx_line_gl_dist_all rctl,
                                 apps.xla_distribution_links xdl,
                                 apps.xla_events xe,
                                 apps.xla_ae_headers xah,
                                 apps.xla_ae_lines xal,
                                 apps.gl_import_references gir,
                                 apps.gl_je_headers gjh
                           WHERE     rctl.customer_trx_line_id = p_key_value1 --o1
                                 AND rctl.event_id = xe.event_id
                                 AND xe.entity_id = xah.entity_id
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND gjh.status = 'P'
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xah.ae_header_id = xdl.ae_header_id
                                 AND xdl.ae_header_id = xal.ae_header_id
                                 AND xdl.ae_line_num = xal.ae_line_num
                                 AND xdl.source_distribution_type =
                                        'RA_CUST_TRX_LINE_GL_DIST_ALL'
                                 AND xdl.source_distribution_id_num_1 =
                                        rctl.cust_trx_line_gl_dist_id
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                 AND gir.je_header_id = gjh.je_header_id
                                 AND xal.creation_date <=
                                        TO_DATE (
                                           NVL (
                                              TO_CHAR (
                                                 TO_TIMESTAMP (
                                                    p_collection_time,
                                                    'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                 'YYYY-MM-DD HH24:MI:SS'),
                                              TO_CHAR (
                                                 SYSDATE,
                                                 'YYYY-MM-DD HH24:MI:SS')),
                                           'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                   );


            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            ELSIF p_table_name = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);

               --p_key_value1 = CUST_TRX_LINE_GL_DIST_ID

               --               IF l_count = 1
               --               THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM apps.xla_distribution_links xdl,
                                 apps.xla_events xe,
                                 apps.xla_ae_headers xah,
                                 apps.xla_ae_lines xal,
                                 apps.gl_import_references gir,
                                 apps.gl_je_headers gjh
                           WHERE     xdl.source_distribution_id_num_1 =
                                        p_key_value1                      --o1
                                 --CUST_TRX_LINE_GL_DIST_ID          --o1
                                 AND xe.event_id =
                                        NVL (p_key_value2, xe.event_id) -- Modified by UG039 --NVL (o2, xe.event_id)
                                 AND xe.entity_id = xah.entity_id
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND gjh.status = 'P'
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xah.ae_header_id = xdl.ae_header_id
                                 AND xdl.ae_header_id = xal.ae_header_id
                                 AND xdl.ae_line_num = xal.ae_line_num
                                 AND xdl.source_distribution_type =
                                        'RA_CUST_TRX_LINE_GL_DIST_ALL'
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                 AND xal.creation_date <=
                                        NVL (
                                           TO_DATE (p_collection_time,
                                                    'YYYY-MM-DD HH24:MI:SS'),
                                           xal.creation_date)
                                 AND gir.je_header_id = gjh.je_header_id);



            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            /* ELSIF p_table_name = 'WSH_DELIVERY_ASSIGNMENTS'
             THEN                                                 -- khaleel
                --l_count := xxctcl_cp_check (p_prog_val, l_count);

                -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);

                -- p_key_value1 = DELIVERY_DETAIL_ID

                --               IF l_count = 1
                --               THEN
                SELECT COUNT (1)
                  INTO l_count
                  FROM DUAL
                 WHERE EXISTS
                          (SELECT 1
                             FROM apps.oe_order_lines_all oola,
                                  apps.oe_order_headers_all oha,
                                  wsh_delivery_details wdd,
                                  apps.mtl_material_transactions mmt,
                                  apps.mtl_transaction_accounts mta,
                                  apps.mtl_transaction_types mtt,
                                  apps.xla_events xe,
                                  apps.xla_distribution_links xdl,
                                  apps.xla_ae_headers xah,
                                  apps.xla_ae_lines xal,
                                  apps.gl_import_references gir,
                                  apps.gl_je_headers gjh
                            WHERE     wdd.delivery_detail_id = p_key_value1 --o1    -- DELIVERY_DETAIL_ID is PK
                                  AND oola.header_id = oha.header_id
                                  AND oha.header_id = wdd.source_header_id
                                  AND oola.line_id = wdd.source_line_id
                                  AND wdd.delivery_detail_id =
                                         mmt.picking_line_id
                                  AND wdd.source_line_id =
                                         mmt.trx_source_line_id
                                  AND mtt.transaction_type_id =
                                         mmt.transaction_type_id
                                  AND mtt.transaction_action_id =
                                         mmt.transaction_action_id
                                  AND mmt.transaction_id =
                                         mta.transaction_id
                                  AND mta.inv_sub_ledger_id =
                                         xdl.source_distribution_id_num_1
                                  AND xdl.source_distribution_type =
                                         'MTL_TRANSACTION_ACCOUNTS'
                                  AND xdl.ae_header_id = xah.ae_header_id
                                  AND xdl.application_id =
                                         xah.application_id
                                  AND xdl.ae_header_id = xal.ae_header_id
                                  AND xdl.ae_line_num = xal.ae_line_num
                                  AND xe.event_status_code = 'P'
                                  AND xe.process_status_code = 'P'
                                  AND xah.gl_transfer_status_code = 'Y'
                                  AND xah.accounting_entry_status_code =
                                         'F'
                                  AND xe.entity_id = xah.entity_id
                                  AND xah.ae_header_id = xal.ae_header_id
                                  AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                  AND gir.je_header_id = gjh.je_header_id
                                  AND gjh.status = 'P'
                                  AND xal.creation_date <=
                                         TO_DATE (
                                            NVL (
                                               TO_CHAR (
                                                  TO_TIMESTAMP (
                                                     p_collection_time,
                                                     'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                  'YYYY-MM-DD HH24:MI:SS'),
                                               TO_CHAR (
                                                  SYSDATE,
                                                  'YYYY-MM-DD HH24:MI:SS')),
                                            'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                    );
             --               ELSE
             --                  l_status_mess :=
             --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
             --                      || p_prog_val);
             --               END IF;
             */
            /*   ELSIF p_table_name = 'WSH_DELIVERY_DETAILS' THEN
                   l_count := xxctcl_cp_check(p_prog_val, l_count);
                   -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);
                   IF l_count = 1 THEN
                       SELECT
                           COUNT(1)
                       INTO l_count
                       FROM
                           dual
                       WHERE
                           EXISTS (
                               SELECT
                                   1
                               FROM
                                   apps.mtl_material_transactions mmt,
                                   apps.mtl_transaction_accounts  mta,
                                   apps.mtl_transaction_types     mtt,
                                   apps.xla_events                xe,
                                   apps.xla_distribution_links    xdl,
                                   apps.xla_ae_headers            xah,
                                   apps.xla_ae_lines              xal,
                                   apps.gl_import_references      gir,
                                   apps.gl_je_headers             gjh
                               WHERE
                                       mmt.picking_line_id = o1    -- DELIVERY_DETAIL_ID is pk1
                                   AND mmt.trx_source_line_id = nvl(o2, mmt.trx_source_line_id)    -- source_line_id     is pk2


                                   AND mtt.transaction_type_id = mmt.transaction_type_id
                                   AND mtt.transaction_action_id = mmt.transaction_action_id
                                   AND mmt.transaction_id = mta.transaction_id
                                   AND mta.inv_sub_ledger_id = xdl.source_distribution_id_num_1
                                   AND xdl.source_distribution_type = 'MTL_TRANSACTION_ACCOUNTS'
                                   AND xdl.ae_header_id = xah.ae_header_id
                                   AND xdl.application_id = xah.application_id
                                   AND xdl.ae_header_id = xal.ae_header_id
                                   AND xdl.ae_line_num = xal.ae_line_num
                                   AND xe.event_status_code = 'P'
                                   AND xe.process_status_code = 'P'
                                   AND xah.gl_transfer_status_code = 'Y'
                                   AND xah.accounting_entry_status_code = 'F'
                                   AND xe.entity_id = xah.entity_id
                                   AND xah.ae_header_id = xal.ae_header_id
                                   AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                   AND gir.je_header_id = gjh.je_header_id
                                   AND gjh.status = 'P'
                                   AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                   ),
                                                                                'YYYY-MM-DD HH24:MI:SS'),
                                                                        to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
       'YYYY-MM-DD HH24:MI:SS')        -- Modified by UG039


                           );

                   ELSE
                       l_status_mess := ( 'Program is either a concurrent program or run by the Concurrent Manager Program is := '
                                          || p_prog_val );
                   END IF; */

            /* ELSIF p_table_name = 'WSH_NEW_DELIVERIES'
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);

               --p_key_value1 = delivery_id

               --               IF l_count = 1
               --               THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM apps.oe_order_lines_all oola,
                                 apps.oe_order_headers_all oha,
                                 wsh_delivery_details wdd,
                                 wsh_delivery_assignments wda,
                                 apps.mtl_material_transactions mmt,
                                 apps.mtl_transaction_accounts mta,
                                 apps.mtl_transaction_types mtt,
                                 apps.xla_events xe,
                                 apps.xla_distribution_links xdl,
                                 apps.xla_ae_headers xah,
                                 apps.xla_ae_lines xal,
                                 apps.gl_import_references gir,
                                 apps.gl_je_headers gjh
                           WHERE     wda.delivery_id = p_key_value1    --o1
                                 AND oola.header_id = oha.header_id
                                 AND oha.header_id = wdd.source_header_id
                                 AND oola.line_id = wdd.source_line_id
                                 --AND WND.DELIVERY_ID                 = WDA.DELIVERY_ID
                                 AND wda.delivery_detail_id =
                                        wdd.delivery_detail_id
                                 AND wdd.delivery_detail_id =
                                        mmt.picking_line_id
                                 AND wdd.source_line_id =
                                        mmt.trx_source_line_id
                                 AND mtt.transaction_type_id =
                                        mmt.transaction_type_id
                                 AND mtt.transaction_action_id =
                                        mmt.transaction_action_id
                                 AND mmt.transaction_id =
                                        mta.transaction_id
                                 AND mta.inv_sub_ledger_id =
                                        xdl.source_distribution_id_num_1
                                 AND xdl.source_distribution_type =
                                        'MTL_TRANSACTION_ACCOUNTS'
                                 AND xdl.ae_header_id = xah.ae_header_id
                                 AND xdl.application_id =
                                        xah.application_id
                                 AND xdl.ae_header_id = xal.ae_header_id
                                 AND xdl.ae_line_num = xal.ae_line_num
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code =
                                        'F'
                                 AND xe.entity_id = xah.entity_id
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                 AND gir.je_header_id = gjh.je_header_id
                                 AND gjh.status = 'P'
                                 AND xal.creation_date <=
                                        TO_DATE (
                                           NVL (
                                              TO_CHAR (
                                                 TO_TIMESTAMP (
                                                    p_collection_time,
                                                    'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                 'YYYY-MM-DD HH24:MI:SS'),
                                              TO_CHAR (
                                                 SYSDATE,
                                                 'YYYY-MM-DD HH24:MI:SS')),
                                           'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                   );
            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
             */
            ELSIF p_table_name = 'AR_PAYMENT_SCHEDULES_ALL'
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);
               --               IF l_count = 1
               --               THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM apps.ar_receivable_applications_all ara,
                                 apps.ra_cust_trx_line_gl_dist_all rctl,
                                 apps.xla_distribution_links xdl,
                                 apps.xla_events xe,
                                 apps.xla_ae_headers xah,
                                 apps.xla_ae_lines xal,
                                 apps.gl_import_references gir,
                                 apps.gl_je_headers gjh
                           WHERE     ara.payment_schedule_id = p_key_value1 -- o1    --PAYMENT_SCHEDULE_ID
                                 AND ara.event_id = xe.event_id
                                 AND xe.entity_id = xah.entity_id
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND gjh.status = 'P'
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND rctl.customer_trx_id =
                                        ara.customer_trx_id
                                 AND xah.ae_header_id = xdl.ae_header_id
                                 AND xdl.ae_header_id = xal.ae_header_id
                                 AND xdl.ae_line_num = xal.ae_line_num
                                 AND xdl.source_distribution_type =
                                        'RA_CUST_TRX_LINE_GL_DIST_ALL'
                                 AND xdl.source_distribution_id_num_1 =
                                        rctl.cust_trx_line_gl_dist_id
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                 AND gir.je_header_id = gjh.je_header_id
                                 AND xal.creation_date <=
                                        TO_DATE (
                                           NVL (
                                              TO_CHAR (
                                                 TO_TIMESTAMP (
                                                    p_collection_time,
                                                    'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                 'YYYY-MM-DD HH24:MI:SS'),
                                              TO_CHAR (
                                                 SYSDATE,
                                                 'YYYY-MM-DD HH24:MI:SS')),
                                           'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                   --  AND APSA.PAYMENT_SCHEDULE_ID = ARA.PAYMENT_SCHEDULE_ID
                      );



            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            ELSIF p_table_name = 'AR_CASH_RECEIPTS_ALL'
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);
               --               IF l_count = 1
               --               THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM apps.ar_cash_receipt_history_all arch,
                                 apps.xla_distribution_links xdl,
                                 apps.ar_distributions_all ada,
                                 apps.xla_events xe,
                                 apps.xla_ae_headers xah,
                                 apps.xla_ae_lines xal,
                                 apps.gl_import_references gir,
                                 apps.gl_je_headers gjh
                           WHERE     arch.cash_receipt_id = p_key_value1 -- o1   --CASH_RECEIPT_ID
                                 AND arch.event_id = xe.event_id
                                 --   AND ARCH.CASH_RECEIPT_ID       = ACRA.CASH_RECEIPT_ID
                                 AND ada.source_id =
                                        arch.cash_receipt_history_id
                                 AND ada.source_table = 'CRH'
                                 AND xe.entity_id = xah.entity_id
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND gjh.status = 'P'
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xah.ae_header_id = xdl.ae_header_id
                                 AND xdl.ae_header_id = xal.ae_header_id
                                 AND xdl.ae_line_num = xal.ae_line_num
                                 AND xdl.source_distribution_type =
                                        'AR_DISTRIBUTIONS_ALL'
                                 AND xdl.source_distribution_id_num_1 =
                                        ada.line_id
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                 AND gir.je_header_id = gjh.je_header_id
                                 AND xal.creation_date <=
                                        TO_DATE (
                                           NVL (
                                              TO_CHAR (
                                                 TO_TIMESTAMP (
                                                    p_collection_time,
                                                    'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                 'YYYY-MM-DD HH24:MI:SS'),
                                              TO_CHAR (
                                                 SYSDATE,
                                                 'YYYY-MM-DD HH24:MI:SS')),
                                           'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                   );


            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            ELSIF p_table_name = 'AR_RECEIVABLE_APPLICATIONS_ALL'
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);

               --p_key_value1 = RECEIVABLE_APPLICATION_ID,
               -- p_key_value2 = EVENT_ID,
               -- p_key_value3 = CUSTOMER_TRX_ID,
               --  p_key_value4 = GL_DATE

               --               IF l_count = 1
               --               THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE (   EXISTS
                             (SELECT 1
                                FROM apps.ra_cust_trx_line_gl_dist_all rctl,
                                     apps.xla_distribution_links xdl,
                                     apps.xla_events xe,
                                     apps.xla_ae_headers xah,
                                     apps.xla_ae_lines xal,
                                     apps.gl_import_references gir,
                                     apps.gl_je_headers gjh
                               WHERE     xe.event_id =
                                            NVL (p_key_value2, xe.event_id)
                                     AND rctl.customer_trx_id =
                                            NVL (p_key_value3,
                                                 rctl.customer_trx_id)
                                     AND xe.entity_id = xah.entity_id
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND gjh.status = 'P'
                                     AND xah.ae_header_id = xal.ae_header_id
                                     AND xah.ae_header_id = xdl.ae_header_id
                                     AND xdl.ae_header_id = xal.ae_header_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xdl.source_distribution_type =
                                            'RA_CUST_TRX_LINE_GL_DIST_ALL'
                                     AND xdl.source_distribution_id_num_1 =
                                            rctl.cust_trx_line_gl_dist_id
                                     AND xal.gl_sl_link_id =
                                            gir.gl_sl_link_id
                                     AND gir.je_header_id = gjh.je_header_id
                                     AND xal.creation_date <=
                                            TO_DATE (
                                               NVL (
                                                  TO_CHAR (
                                                     TO_TIMESTAMP (
                                                        p_collection_time,
                                                        'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                     'YYYY-MM-DD HH24:MI:SS'),
                                                  TO_CHAR (
                                                     SYSDATE,
                                                     'YYYY-MM-DD HH24:MI:SS')),
                                               'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                       )
                       OR EXISTS
                             (SELECT 1
                                FROM apps.ar_distributions_all ada,
                                     apps.xla_distribution_links xdl,
                                     apps.xla_events xe,
                                     apps.xla_ae_headers xah,
                                     apps.xla_ae_lines xal,
                                     apps.gl_import_references gir,
                                     apps.gl_je_headers gjh
                               WHERE     xe.event_id =
                                            NVL (p_key_value2, xe.event_id)
                                     AND ada.source_id = p_key_value1 -- RECEIVABLE_APPLICATION_ID is PK1
                                     AND ada.source_table = 'RA'
                                     AND xe.entity_id = xah.entity_id
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND gjh.status = 'P'
                                     AND xah.ae_header_id = xal.ae_header_id
                                     AND xah.ae_header_id = xdl.ae_header_id
                                     AND xdl.ae_header_id = xal.ae_header_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xdl.source_distribution_type =
                                            'AR_DISTRIBUTIONS_ALL'
                                     AND xdl.source_distribution_id_num_1 =
                                            ada.line_id
                                     AND xal.gl_sl_link_id =
                                            gir.gl_sl_link_id
                                     AND gir.je_header_id = gjh.je_header_id
                                     AND xal.creation_date <=
                                            TO_DATE (
                                               NVL (
                                                  TO_CHAR (
                                                     TO_TIMESTAMP (
                                                        p_collection_time,
                                                        'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                     'YYYY-MM-DD HH24:MI:SS'),
                                                  TO_CHAR (
                                                     SYSDATE,
                                                     'YYYY-MM-DD HH24:MI:SS')),
                                               'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                       ));



            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            ELSIF p_table_name = 'AR_CASH_RECEIPT_HISTORY_ALL'
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);
               --               IF l_count = 1
               --               THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM apps.xla_distribution_links xdl,
                                 apps.ar_distributions_all ard,
                                 apps.xla_events xe,
                                 apps.xla_ae_headers xah,
                                 apps.xla_ae_lines xal,
                                 apps.gl_import_references gir,
                                 apps.gl_je_headers gjh
                           WHERE     ard.source_id = p_key_value1 -- o1    -- CASH_RECEIPT_HISTORY_ID is pk1
                                 AND ard.source_table = 'CRH'
                                 AND xe.entity_id = xah.entity_id
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND gjh.status = 'P'
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xah.ae_header_id = xdl.ae_header_id
                                 AND xdl.ae_header_id = xal.ae_header_id
                                 AND xdl.ae_line_num = xal.ae_line_num
                                 AND xdl.source_distribution_type =
                                        'AR_DISTRIBUTIONS_ALL'
                                 AND xdl.source_distribution_id_num_1 =
                                        ard.line_id
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                 AND gir.je_header_id = gjh.je_header_id
                                 AND xal.creation_date <=
                                        TO_DATE (
                                           NVL (
                                              TO_CHAR (
                                                 TO_TIMESTAMP (
                                                    p_collection_time,
                                                    'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                 'YYYY-MM-DD HH24:MI:SS'),
                                              TO_CHAR (
                                                 SYSDATE,
                                                 'YYYY-MM-DD HH24:MI:SS')),
                                           'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                   );


            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            ELSIF p_table_name = 'AR_REVENUE_ADJUSTMENTS_ALL'
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);
               --               IF l_count = 1
               --               THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM apps.xla_events xe,
                                 apps.xla_distribution_links xdl,
                                 apps.xla_ae_headers xah,
                                 apps.xla_ae_lines xal,
                                 apps.gl_import_references gir,
                                 apps.gl_je_headers gjh,
                                 apps.ra_customer_trx_lines_all rctl,
                                 apps.ra_cust_trx_line_gl_dist_all ragl
                           WHERE     ragl.customer_trx_id = p_key_value1 -- o1
                                 AND rctl.customer_trx_line_id =
                                        NVL (p_key_value2,
                                             rctl.customer_trx_line_id)
                                 AND ragl.event_id = xe.event_id
                                 AND xe.entity_id = xah.entity_id
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND gjh.status = 'P'
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                 AND gir.je_header_id = gjh.je_header_id
                                 AND xah.ae_header_id = xdl.ae_header_id
                                 AND xdl.ae_line_num = xal.ae_line_num
                                 AND xdl.source_distribution_type =
                                        'RA_CUST_TRX_LINE_GL_DIST_ALL'
                                 AND xdl.source_distribution_id_num_1 =
                                        ragl.cust_trx_line_gl_dist_id
                                 AND rctl.customer_trx_line_id =
                                        ragl.customer_trx_line_id
                                 AND xal.creation_date <=
                                        TO_DATE (
                                           NVL (
                                              TO_CHAR (
                                                 TO_TIMESTAMP (
                                                    p_collection_time,
                                                    'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                 'YYYY-MM-DD HH24:MI:SS'),
                                              TO_CHAR (
                                                 SYSDATE,
                                                 'YYYY-MM-DD HH24:MI:SS')),
                                           'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                   );


            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            ELSIF p_table_name = 'AR_DEFERRED_LINES_ALL'
            THEN
               --               l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);
               --               IF l_count = 1
               --               THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM apps.xla_events xe,
                                 apps.xla_distribution_links xdl,
                                 apps.xla_ae_headers xah,
                                 apps.xla_ae_lines xal,
                                 apps.gl_import_references gir,
                                 apps.gl_je_headers gjh,
                                 apps.ra_customer_trx_lines_all rctl,
                                 apps.ra_cust_trx_line_gl_dist_all ragl
                           WHERE     rctl.customer_trx_line_id = p_key_value1 --o1   --CUSTOMER_TRX_LINE_ID
                                 AND ragl.event_id = xe.event_id
                                 AND xe.entity_id = xah.entity_id
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND gjh.status = 'P'
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xah.ae_header_id = xdl.ae_header_id
                                 AND xdl.ae_header_id = xal.ae_header_id
                                 AND xdl.ae_line_num = xal.ae_line_num
                                 AND xdl.source_distribution_type =
                                        'RA_CUST_TRX_LINE_GL_DIST_ALL'
                                 AND xdl.source_distribution_id_num_1 =
                                        ragl.cust_trx_line_gl_dist_id
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                 AND gir.je_header_id = gjh.je_header_id
                                 AND rctl.customer_trx_line_id =
                                        ragl.customer_trx_line_id
                                 AND xal.creation_date <=
                                        TO_DATE (
                                           NVL (
                                              TO_CHAR (
                                                 TO_TIMESTAMP (
                                                    p_collection_time,
                                                    'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                 'YYYY-MM-DD HH24:MI:SS'),
                                              TO_CHAR (
                                                 SYSDATE,
                                                 'YYYY-MM-DD HH24:MI:SS')),
                                           'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                   );


            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            ELSIF p_table_name = 'AR_ADJUSTMENTS_ALL'
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);
               --               IF l_count = 1
               --               THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM apps.xla_events xe,
                                 apps.xla_ae_headers xah,
                                 apps.xla_distribution_links xdl,
                                 apps.ar_distributions_all adda,
                                 apps.xla_ae_lines xal,
                                 apps.gl_import_references gir,
                                 apps.gl_je_headers gjh
                           WHERE     xe.event_id = p_key_value1 -- o1   --EVENT_ID
                                 AND xe.entity_id = xah.entity_id
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND gjh.status = 'P'
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xah.ae_header_id = xdl.ae_header_id
                                 AND xdl.ae_header_id = xal.ae_header_id
                                 AND xdl.ae_line_num = xal.ae_line_num
                                 AND xdl.source_distribution_type =
                                        'AR_DISTRIBUTIONS_ALL'
                                 AND xdl.source_distribution_id_num_1 =
                                        adda.line_id
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                 AND gir.je_header_id = gjh.je_header_id
                                 AND xal.creation_date <=
                                        TO_DATE (
                                           NVL (
                                              TO_CHAR (
                                                 TO_TIMESTAMP (
                                                    p_collection_time,
                                                    'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                 'YYYY-MM-DD HH24:MI:SS'),
                                              TO_CHAR (
                                                 SYSDATE,
                                                 'YYYY-MM-DD HH24:MI:SS')),
                                           'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                   );


            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;



            ELSIF p_table_name = 'AP_INVOICES_ALL'
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);
               --               IF l_count = 1
               --               THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM apps.ap_invoice_lines_all aila,
                                 apps.ap_invoice_distributions_all aida,
                                 apps.xla_events xe,
                                 apps.xla_distribution_links xdl,
                                 apps.xla_ae_headers xah,
                                 apps.xla_ae_lines xal,
                                 apps.gl_import_references gir,
                                 apps.gl_je_headers gjh
                           WHERE     aila.invoice_id = p_key_value1 ----o1  --INVOICE_ID
                                 AND aila.invoice_id = aida.invoice_id
                                 AND aila.line_number =
                                        aida.invoice_line_number
                                 AND aida.invoice_distribution_id =
                                        xdl.source_distribution_id_num_1
                                 AND xdl.source_distribution_type =
                                        'AP_INV_DIST'
                                 AND xdl.ae_header_id = xah.ae_header_id
                                 AND xdl.application_id = xah.application_id
                                 AND xdl.ae_header_id = xal.ae_header_id
                                 AND xdl.ae_line_num = xal.ae_line_num
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xe.entity_id = xah.entity_id
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                 AND gir.je_header_id = gjh.je_header_id
                                 AND gjh.status = 'P'
                                 AND xal.creation_date <=
                                        TO_DATE (
                                           NVL (
                                              TO_CHAR (
                                                 TO_TIMESTAMP (
                                                    p_collection_time,
                                                    'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                 'YYYY-MM-DD HH24:MI:SS'),
                                              TO_CHAR (
                                                 SYSDATE,
                                                 'YYYY-MM-DD HH24:MI:SS')),
                                           'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                   );


            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            ELSIF p_table_name = 'AP_INVOICE_LINES_ALL'
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);
               --               IF l_count = 1
               --               THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM apps.ap_invoice_distributions_all aida,
                                 apps.xla_events xe,
                                 apps.xla_distribution_links xdl,
                                 apps.xla_ae_headers xah,
                                 apps.xla_ae_lines xal,
                                 apps.gl_import_references gir,
                                 apps.gl_je_headers gjh
                           WHERE     aida.invoice_id = p_key_value1 -- o1 --INVOICE_ID
                                 AND aida.invoice_line_number =
                                        NVL (p_key_value2,
                                             aida.invoice_line_number) --o2 -- LINE_NUMBER
                                 AND aida.invoice_distribution_id =
                                        xdl.source_distribution_id_num_1
                                 AND xdl.source_distribution_type =
                                        'AP_INV_DIST'
                                 AND xdl.ae_header_id = xah.ae_header_id
                                 AND xdl.application_id = xah.application_id
                                 AND xdl.ae_header_id = xal.ae_header_id -- modified by UG039
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xe.entity_id = xah.entity_id
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xdl.ae_line_num = xal.ae_line_num
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                 AND gir.je_header_id = gjh.je_header_id
                                 AND gjh.status = 'P'
                                 AND xal.creation_date <=
                                        TO_DATE (
                                           NVL (
                                              TO_CHAR (
                                                 TO_TIMESTAMP (
                                                    p_collection_time,
                                                    'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                 'YYYY-MM-DD HH24:MI:SS'),
                                              TO_CHAR (
                                                 SYSDATE,
                                                 'YYYY-MM-DD HH24:MI:SS')),
                                           'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                   );


            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            ELSIF p_table_name = 'AP_INVOICE_DISTRIBUTIONS_ALL'
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);
               --               IF l_count = 1
               --               THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM apps.xla_events xe,
                                 apps.xla_distribution_links xdl,
                                 apps.xla_ae_headers xah,
                                 apps.xla_ae_lines xal,
                                 apps.gl_import_references gir,
                                 apps.gl_je_headers gjh
                           WHERE     xdl.source_distribution_id_num_1 =
                                        p_key_value1 -- o1  --INVOICE_DISTRIBUTION_ID
                                 AND xdl.source_distribution_type =
                                        'AP_INV_DIST'
                                 AND xdl.ae_header_id = xah.ae_header_id
                                 AND xdl.application_id = xah.application_id
                                 AND xdl.ae_header_id = xal.ae_header_id
                                 AND xdl.ae_line_num = xal.ae_line_num
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xe.entity_id = xah.entity_id
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                 AND gir.je_header_id = gjh.je_header_id
                                 AND gjh.status = 'P'
                                 AND xal.creation_date <=
                                        TO_DATE (
                                           NVL (
                                              TO_CHAR (
                                                 TO_TIMESTAMP (
                                                    p_collection_time,
                                                    'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                 'YYYY-MM-DD HH24:MI:SS'),
                                              TO_CHAR (
                                                 SYSDATE,
                                                 'YYYY-MM-DD HH24:MI:SS')),
                                           'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                   );



            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            ELSIF p_table_name = 'AP_PAYMENT_SCHEDULES_ALL'
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);
               --               IF l_count = 1
               --               THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM apps.ap_invoice_payments_all aipa,
                                 apps.xla_events xe,
                                 apps.xla_ae_headers xah,
                                 apps.xla_ae_lines xal,
                                 apps.gl_import_references gir,
                                 apps.gl_je_headers gjh
                           WHERE     aipa.invoice_id = p_key_value1 -- o1 = invoice_id
                                 AND aipa.payment_num =
                                        NVL (p_key_value2, aipa.payment_num) -- payment_num
                                 AND aipa.accounting_event_id = xe.event_id
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xe.entity_id = xah.entity_id
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                 AND gir.je_header_id = gjh.je_header_id
                                 AND gjh.status = 'P'
                                 AND xal.creation_date <=
                                        TO_DATE (
                                           NVL (
                                              TO_CHAR (
                                                 TO_TIMESTAMP (
                                                    p_collection_time,
                                                    'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                 'YYYY-MM-DD HH24:MI:SS'),
                                              TO_CHAR (
                                                 SYSDATE,
                                                 'YYYY-MM-DD HH24:MI:SS')),
                                           'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                   );



            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            ELSIF p_table_name = 'AP_INVOICE_PAYMENTS_ALL'
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);
               --               IF l_count = 1
               --               THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM apps.xla_events xe,
                                 apps.xla_ae_headers xah,
                                 apps.xla_ae_lines xal,
                                 apps.gl_import_references gir,
                                 apps.gl_je_headers gjh
                           WHERE     xe.event_id = p_key_value1 --o1      -- event_id is pk1
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xe.entity_id = xah.entity_id
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                 AND gir.je_header_id = gjh.je_header_id
                                 AND gjh.status = 'P'
                                 AND xal.creation_date <=
                                        TO_DATE (
                                           NVL (
                                              TO_CHAR (
                                                 TO_TIMESTAMP (
                                                    p_collection_time,
                                                    'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                 'YYYY-MM-DD HH24:MI:SS'),
                                              TO_CHAR (
                                                 SYSDATE,
                                                 'YYYY-MM-DD HH24:MI:SS')),
                                           'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                   );


            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            ELSIF p_table_name = 'AP_CHECKS_ALL'
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);
               --               IF l_count = 1
               --               THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM apps.ap_invoice_payments_all aipa,
                                 apps.xla_events xe,
                                 apps.xla_ae_headers xah,
                                 apps.xla_ae_lines xal,
                                 apps.gl_import_references gir,
                                 apps.gl_je_headers gjh
                           WHERE     aipa.check_id = p_key_value1 -- o1 -- check_id
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xe.entity_id = xah.entity_id
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                 AND gir.je_header_id = gjh.je_header_id
                                 AND gjh.status = 'P'
                                 AND xal.creation_date <=
                                        TO_DATE (
                                           NVL (
                                              TO_CHAR (
                                                 TO_TIMESTAMP (
                                                    p_collection_time,
                                                    'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                 'YYYY-MM-DD HH24:MI:SS'),
                                              TO_CHAR (
                                                 SYSDATE,
                                                 'YYYY-MM-DD HH24:MI:SS')),
                                           'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                   );


            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            ELSIF p_table_name = 'AP_PAYMENT_HISTORY_ALL'
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);
               --               IF l_count = 1
               --               THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM apps.xla_events xe,
                                 apps.xla_ae_headers xah,
                                 apps.xla_ae_lines xal,
                                 apps.gl_import_references gir,
                                 apps.gl_je_headers gjh
                           WHERE     xe.event_id = p_key_value1 --o1   -- ACCOUNTING_EVENT_ID is pk1
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xe.entity_id = xah.entity_id
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                 AND gir.je_header_id = gjh.je_header_id
                                 AND gjh.status = 'P'
                                 AND xal.creation_date <=
                                        TO_DATE (
                                           NVL (
                                              TO_CHAR (
                                                 TO_TIMESTAMP (
                                                    p_collection_time,
                                                    'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                 'YYYY-MM-DD HH24:MI:SS'),
                                              TO_CHAR (
                                                 SYSDATE,
                                                 'YYYY-MM-DD HH24:MI:SS')),
                                           'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                   );


            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            /*
            ELSIF p_table_name = 'OE_PRICE_ADJUSTMENTS'
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);
               --               IF l_count = 1
               --               THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE (   EXISTS
                             (SELECT 1
                                FROM apps.oe_order_headers_all oha,
                                     apps.oe_order_lines_all oola,
                                     wsh_delivery_details wdd,
                                     apps.mtl_material_transactions mmt,
                                     apps.mtl_transaction_accounts mta,
                                     apps.mtl_transaction_types mtt,
                                     apps.xla_events xe,
                                     apps.xla_distribution_links xdl,
                                     apps.xla_ae_headers xah,
                                     apps.xla_ae_lines xal,
                                     apps.gl_import_references gir,
                                     apps.gl_je_headers gjh
                               WHERE     oha.header_id = p_key_value1 --o1 -- header_id
                                     AND oola.line_id =
                                            NVL (p_key_value2,
                                                 oola.line_id)   -- line_id
                                     AND oha.header_id = oola.header_id
                                     AND oha.header_id =
                                            wdd.source_header_id
                                     AND wdd.delivery_detail_id =
                                            mmt.picking_line_id
                                     AND wdd.source_line_id =
                                            mmt.trx_source_line_id
                                     AND mtt.transaction_type_id =
                                            mmt.transaction_type_id
                                     AND mtt.transaction_action_id =
                                            mmt.transaction_action_id
                                     AND mmt.transaction_id =
                                            mta.transaction_id
                                     AND mta.inv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'MTL_TRANSACTION_ACCOUNTS'
                                     AND xdl.ae_header_id =
                                            xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_header_id =
                                            xal.ae_header_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id =
                                            xal.ae_header_id
                                     AND xal.gl_sl_link_id =
                                            gir.gl_sl_link_id
                                     AND gir.je_header_id =
                                            gjh.je_header_id
                                     AND gjh.status = 'P'
                                     AND xal.creation_date <=
                                            TO_DATE (
                                               NVL (
                                                  TO_CHAR (
                                                     TO_TIMESTAMP (
                                                        p_collection_time,
                                                        'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                     'YYYY-MM-DD HH24:MI:SS'),
                                                  TO_CHAR (
                                                     SYSDATE,
                                                     'YYYY-MM-DD HH24:MI:SS')),
                                               'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                       )
                       OR EXISTS
                             (SELECT 1
                                FROM apps.oe_order_headers_all oha,
                                     apps.oe_order_lines_all oola,
                                     apps.rcv_shipment_lines rsl,
                                     apps.rcv_transactions rt,
                                     apps.mtl_material_transactions mmt,
                                     apps.mtl_transaction_accounts mta,
                                     apps.xla_events xe,
                                     apps.xla_distribution_links xdl,
                                     apps.xla_ae_headers xah,
                                     apps.xla_ae_lines xal,
                                     apps.gl_import_references gir,
                                     apps.gl_je_headers gjh
                               WHERE     oha.header_id = p_key_value1 -- o1  -- header_id
                                     AND oola.line_id =
                                            NVL (p_key_value2,
                                                 oola.line_id)   -- line_id
                                     AND oha.header_id = oola.header_id
                                     AND oha.header_id =
                                            rsl.oe_order_header_id
                                     AND oola.line_id =
                                            rsl.oe_order_line_id
                                     AND rsl.shipment_line_id =
                                            rt.shipment_line_id
                                     AND rt.transaction_type = 'DELIVER'
                                     AND rt.transaction_id =
                                            mmt.rcv_transaction_id
                                     AND mmt.transaction_id =
                                            mta.transaction_id
                                     AND mta.inv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'MTL_TRANSACTION_ACCOUNTS'
                                     AND xdl.ae_header_id =
                                            xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_header_id =
                                            xal.ae_header_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id =
                                            xal.ae_header_id
                                     AND xal.gl_sl_link_id =
                                            gir.gl_sl_link_id
                                     AND gir.je_header_id =
                                            gjh.je_header_id
                                     AND gjh.status = 'P'
                                     AND xal.creation_date <=
                                            TO_DATE (
                                               NVL (
                                                  TO_CHAR (
                                                     TO_TIMESTAMP (
                                                        p_collection_time,
                                                        'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                     'YYYY-MM-DD HH24:MI:SS'),
                                                  TO_CHAR (
                                                     SYSDATE,
                                                     'YYYY-MM-DD HH24:MI:SS')),
                                               'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                       )
                       OR EXISTS
                             (SELECT 1
                                FROM apps.oe_order_headers_all oha,
                                     apps.oe_order_lines_all oola,
                                     apps.oe_drop_ship_sources odss,
                                     apps.rcv_shipment_lines rsl,
                                     apps.rcv_transactions rt,
                                     apps.mtl_material_transactions mmt,
                                     apps.mtl_transaction_accounts mta,
                                     apps.xla_events xe,
                                     apps.xla_distribution_links xdl,
                                     apps.xla_ae_headers xah,
                                     apps.xla_ae_lines xal,
                                     apps.gl_import_references gir,
                                     apps.gl_je_headers gjh
                               WHERE     oha.header_id = p_key_value1 -- header_id
                                     AND oola.line_id =
                                            NVL (p_key_value2,
                                                 oola.line_id)    --line_id
                                     AND oha.header_id = oola.header_id
                                     AND oha.header_id = odss.header_id
                                     AND odss.line_id = oola.line_id
                                     AND odss.po_header_id =
                                            rsl.po_header_id
                                     AND odss.po_line_id = rsl.po_line_id
                                     AND odss.po_release_id =
                                            rsl.po_release_id
                                     AND odss.line_location_id =
                                            rsl.po_line_location_id
                                     AND rsl.shipment_line_id =
                                            rt.shipment_line_id
                                     AND rt.transaction_type = 'DELIVER'
                                     AND rt.transaction_id =
                                            mmt.rcv_transaction_id
                                     AND mmt.transaction_id =
                                            mta.transaction_id
                                     AND mta.inv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'MTL_TRANSACTION_ACCOUNTS'
                                     AND xdl.ae_header_id =
                                            xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_header_id =
                                            xal.ae_header_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id =
                                            xal.ae_header_id
                                     AND xal.gl_sl_link_id =
                                            gir.gl_sl_link_id
                                     AND gir.je_header_id =
                                            gjh.je_header_id
                                     AND gjh.status = 'P'
                                     AND xal.creation_date <=
                                            TO_DATE (
                                               NVL (
                                                  TO_CHAR (
                                                     TO_TIMESTAMP (
                                                        p_collection_time,
                                                        'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                     'YYYY-MM-DD HH24:MI:SS'),
                                                  TO_CHAR (
                                                     SYSDATE,
                                                     'YYYY-MM-DD HH24:MI:SS')),
                                               'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                       ));
            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            */
            /*        ELSIF p_table_name = 'OE_ORDER_HEADERS_ALL' THEN
                        l_count := xxctcl_cp_check(p_prog_val, l_count);
                        -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);
                        IF l_count = 1 THEN
                            SELECT
                                COUNT(1)
                            INTO l_count
                            FROM
                                dual
                            WHERE
                                ( EXISTS (
                                    SELECT
                                        1
                                    FROM
                                        wsh_delivery_details           wdd,
                                        apps.mtl_material_transactions mmt,
                                        apps.mtl_transaction_accounts  mta,
                                        apps.mtl_transaction_types     mtt,
                                        apps.xla_events                xe,
                                        apps.xla_distribution_links    xdl,
                                        apps.xla_ae_headers            xah,
                                        apps.xla_ae_lines              xal,
                                        apps.gl_import_references      gir,
                                        apps.gl_je_headers             gjh
                                    WHERE
                                            wdd.source_header_id = o1 -- header_id
                                        AND wdd.delivery_detail_id = mmt.picking_line_id
                                        AND wdd.source_line_id = mmt.trx_source_line_id
                                        AND mtt.transaction_type_id = mmt.transaction_type_id
                                        AND mtt.transaction_action_id = mmt.transaction_action_id
                                        AND mmt.transaction_id = mta.transaction_id
                                        AND mta.inv_sub_ledger_id = xdl.source_distribution_id_num_1
                                        AND xdl.source_distribution_type = 'MTL_TRANSACTION_ACCOUNTS'
                                        AND xdl.ae_header_id = xah.ae_header_id
                                        AND xdl.application_id = xah.application_id
                                        AND xdl.ae_header_id = xal.ae_header_id
                                        AND xdl.ae_line_num = xal.ae_line_num
                                        AND xe.event_status_code = 'P'
                                        AND xe.process_status_code = 'P'
                                        AND xah.gl_transfer_status_code = 'Y'
                                        AND xah.accounting_entry_status_code = 'F'
                                        AND xe.entity_id = xah.entity_id
                                        AND xah.ae_header_id = xal.ae_header_id
                                        AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                        AND gir.je_header_id = gjh.je_header_id
                                        AND gjh.status = 'P'
                                        AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                        ),
                                                                                     'YYYY-MM-DD HH24:MI:SS'),
                                                                             to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
            'YYYY-MM-DD HH24:MI:SS')        -- Modified by UG039


                                )
                                  OR EXISTS (
                                    SELECT
                                        1
                                    FROM
                                        apps.rcv_shipment_lines        rsl,
                                        apps.rcv_transactions          rt,
                                        apps.mtl_material_transactions mmt,
                                        apps.mtl_transaction_accounts  mta,
                                        apps.xla_events                xe,
                                        apps.xla_distribution_links    xdl,
                                        apps.xla_ae_headers            xah,
                                        apps.xla_ae_lines              xal,
                                        apps.gl_import_references      gir,
                                        apps.gl_je_headers             gjh
                                    WHERE
                                            rsl.oe_order_header_id = o1 -- header_id
                                        AND rsl.shipment_line_id = rt.shipment_line_id
                                        AND rt.transaction_type = 'DELIVER'
                                        AND rt.transaction_id = mmt.rcv_transaction_id
                                        AND mmt.transaction_id = mta.transaction_id
                                        AND mta.inv_sub_ledger_id = xdl.source_distribution_id_num_1
                                        AND xdl.source_distribution_type = 'MTL_TRANSACTION_ACCOUNTS'
                                        AND xdl.ae_header_id = xah.ae_header_id
                                        AND xdl.application_id = xah.application_id
                                        AND xdl.ae_header_id = xal.ae_header_id
                                        AND xdl.ae_line_num = xal.ae_line_num
                                        AND xe.event_status_code = 'P'
                                        AND xe.process_status_code = 'P'
                                        AND xah.gl_transfer_status_code = 'Y'
                                        AND xah.accounting_entry_status_code = 'F'
                                        AND xe.entity_id = xah.entity_id
                                        AND xah.ae_header_id = xal.ae_header_id
                                        AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                        AND gir.je_header_id = gjh.je_header_id
                                        AND gjh.status = 'P'
                                        AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                        ),
                                                                                     'YYYY-MM-DD HH24:MI:SS'),
                                                                             to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
            'YYYY-MM-DD HH24:MI:SS')        -- Modified by UG039


                                )
                                  OR EXISTS (
                                    SELECT
                                        1
                                    FROM
                                        apps.oe_drop_ship_sources      odss,
                                        apps.rcv_shipment_lines        rsl,
                                        apps.rcv_transactions          rt,
                                        apps.mtl_material_transactions mmt,
                                        apps.mtl_transaction_accounts  mta,
                                        apps.xla_events                xe,
                                        apps.xla_distribution_links    xdl,
                                        apps.xla_ae_headers            xah,
                                        apps.xla_ae_lines              xal,
                                        apps.gl_import_references      gir,
                                        apps.gl_je_headers             gjh
                                    WHERE
                                            odss.header_id = o1 -- header_id
                                        AND odss.po_header_id = rsl.po_header_id
                                        AND odss.po_line_id = rsl.po_line_id
                                        AND odss.po_release_id = rsl.po_release_id
                                        AND odss.line_location_id = rsl.po_line_location_id
                                        AND rsl.shipment_line_id = rt.shipment_line_id
                                        AND rt.transaction_type = 'DELIVER'
                                        AND rt.transaction_id = mmt.rcv_transaction_id
                                        AND mmt.transaction_id = mta.transaction_id
                                        AND mta.inv_sub_ledger_id = xdl.source_distribution_id_num_1
                                        AND xdl.source_distribution_type = 'MTL_TRANSACTION_ACCOUNTS'
                                        AND xdl.ae_header_id = xah.ae_header_id
                                        AND xdl.application_id = xah.application_id
                                        AND xdl.ae_header_id = xal.ae_header_id
                                        AND xdl.ae_line_num = xal.ae_line_num
                                        AND xe.event_status_code = 'P'
                                        AND xe.process_status_code = 'P'
                                        AND xah.gl_transfer_status_code = 'Y'
                                        AND xah.accounting_entry_status_code = 'F'
                                        AND xe.entity_id = xah.entity_id
                                        AND xah.ae_header_id = xal.ae_header_id
                                        AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                        AND gir.je_header_id = gjh.je_header_id
                                        AND gjh.status = 'P'
                                        AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                        ),
                                                                                     'YYYY-MM-DD HH24:MI:SS'),
                                                                             to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
            'YYYY-MM-DD HH24:MI:SS')        -- Modified by UG039


                                ) );

                        ELSE
                            l_status_mess := ( 'Program is either a concurrent program or run by the Concurrent Manager Program is := '
                                               || p_prog_val );
                        END IF;

                    ELSIF p_table_name = 'OE_ORDER_LINES_ALL' THEN
                        l_count := xxctcl_cp_check(p_prog_val, l_count);
                        -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);
                        IF l_count = 1 THEN
                            SELECT
                                COUNT(1)
                            INTO l_count
                            FROM
                                dual
                            WHERE
                                ( EXISTS (
                                    SELECT
                                        1
                                    FROM
                                        apps.oe_order_headers_all      oha,
                                        wsh_delivery_details           wdd,
                                        apps.mtl_material_transactions mmt,
                                        apps.mtl_transaction_accounts  mta,
                                        apps.mtl_transaction_types     mtt,
                                        apps.xla_events                xe,
                                        apps.xla_distribution_links    xdl,
                                        apps.xla_ae_headers            xah,
                                        apps.xla_ae_lines              xal,
                                        apps.gl_import_references      gir,
                                        apps.gl_je_headers             gjh
                                    WHERE
                                            wdd.source_line_id = o1 -- line_id
                                        AND oha.header_id = wdd.source_header_id
                                        AND wdd.delivery_detail_id = mmt.picking_line_id
                                        AND wdd.source_line_id = mmt.trx_source_line_id
                                        AND mtt.transaction_type_id = mmt.transaction_type_id
                                        AND mtt.transaction_action_id = mmt.transaction_action_id
                                        AND mmt.transaction_id = mta.transaction_id
                                        AND mta.inv_sub_ledger_id = xdl.source_distribution_id_num_1
                                        AND xdl.source_distribution_type = 'MTL_TRANSACTION_ACCOUNTS'
                                        AND xdl.ae_header_id = xah.ae_header_id
                                        AND xdl.application_id = xah.application_id
                                        AND xdl.ae_header_id = xal.ae_header_id
                                        AND xdl.ae_line_num = xal.ae_line_num
                                        AND xe.event_status_code = 'P'
                                        AND xe.process_status_code = 'P'
                                        AND xah.gl_transfer_status_code = 'Y'
                                        AND xah.accounting_entry_status_code = 'F'
                                        AND xe.entity_id = xah.entity_id
                                        AND xah.ae_header_id = xal.ae_header_id
                                        AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                        AND gir.je_header_id = gjh.je_header_id
                                        AND gjh.status = 'P'
                                        AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                        ),
                                                                                     'YYYY-MM-DD HH24:MI:SS'),
                                                                             to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
            'YYYY-MM-DD HH24:MI:SS')        -- Modified by UG039


                                )
                                  OR EXISTS (
                                    SELECT
                                        1
                                    FROM
                                        apps.oe_order_headers_all      oha,
                                        apps.rcv_shipment_lines        rsl,
                                        apps.rcv_transactions          rt,
                                        apps.mtl_material_transactions mmt,
                                        apps.mtl_transaction_accounts  mta,
                                        apps.xla_events                xe,
                                        apps.xla_distribution_links    xdl,
                                        apps.xla_ae_headers            xah,
                                        apps.xla_ae_lines              xal,
                                        apps.gl_import_references      gir,
                                        apps.gl_je_headers             gjh
                                    WHERE
                                            rsl.oe_order_line_id =o1 -- line_id
                                        AND oha.header_id = rsl.oe_order_header_id
                                        AND rsl.shipment_line_id = rt.shipment_line_id
                                        AND rt.transaction_type = 'DELIVER'
                                        AND rt.transaction_id = mmt.rcv_transaction_id
                                        AND mmt.transaction_id = mta.transaction_id
                                        AND mta.inv_sub_ledger_id = xdl.source_distribution_id_num_1
                                        AND xdl.source_distribution_type = 'MTL_TRANSACTION_ACCOUNTS'
                                        AND xdl.ae_header_id = xah.ae_header_id
                                        AND xdl.application_id = xah.application_id
                                        AND xdl.ae_header_id = xal.ae_header_id
                                        AND xdl.ae_line_num = xal.ae_line_num
                                        AND xe.event_status_code = 'P'
                                        AND xe.process_status_code = 'P'
                                        AND xah.gl_transfer_status_code = 'Y'
                                        AND xah.accounting_entry_status_code = 'F'
                                        AND xe.entity_id = xah.entity_id
                                        AND xah.ae_header_id = xal.ae_header_id
                                        AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                        AND gir.je_header_id = gjh.je_header_id
                                        AND gjh.status = 'P'
                                        AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                        ),
                                                                                     'YYYY-MM-DD HH24:MI:SS'),
                                                                             to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
            'YYYY-MM-DD HH24:MI:SS')        -- Modified by UG039


                                )
                                  OR EXISTS (
                                    SELECT
                                        1
                                    FROM
                                        apps.oe_order_lines_all        oola,
                                        apps.oe_order_headers_all      oha,
                                        apps.oe_drop_ship_sources      odss,
                                        apps.rcv_shipment_lines        rsl,
                                        apps.rcv_transactions          rt,
                                        apps.mtl_material_transactions mmt,
                                        apps.mtl_transaction_accounts  mta,
                                        apps.xla_events                xe,
                                        apps.xla_distribution_links    xdl,
                                        apps.xla_ae_headers            xah,
                                        apps.xla_ae_lines              xal,
                                        apps.gl_import_references      gir,
                                        apps.gl_je_headers             gjh
                                    WHERE
                                            odss.line_id = o1
                                        AND oha.header_id = odss.header_id
                                        AND odss.po_header_id = rsl.po_header_id
                                        AND odss.po_line_id = rsl.po_line_id
                                        AND odss.po_release_id = rsl.po_release_id
                                        AND odss.line_location_id = rsl.po_line_location_id
                                        AND rsl.shipment_line_id = rt.shipment_line_id
                                        AND rt.transaction_type = 'DELIVER'
                                        AND rt.transaction_id = mmt.rcv_transaction_id
                                        AND mmt.transaction_id = mta.transaction_id
                                        AND mta.inv_sub_ledger_id = xdl.source_distribution_id_num_1
                                        AND xdl.source_distribution_type = 'MTL_TRANSACTION_ACCOUNTS'
                                        AND xdl.ae_header_id = xah.ae_header_id
                                        AND xdl.application_id = xah.application_id
                                        AND xdl.ae_header_id = xal.ae_header_id
                                        AND xdl.ae_line_num = xal.ae_line_num
                                        AND xe.event_status_code = 'P'
                                        AND xe.process_status_code = 'P'
                                        AND xah.gl_transfer_status_code = 'Y'
                                        AND xah.accounting_entry_status_code = 'F'
                                        AND xe.entity_id = xah.entity_id
                                        AND xah.ae_header_id = xal.ae_header_id
                                        AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                        AND gir.je_header_id = gjh.je_header_id
                                        AND gjh.status = 'P'
                                        AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                        ),
                                                                                     'YYYY-MM-DD HH24:MI:SS'),
                                                                             to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
            'YYYY-MM-DD HH24:MI:SS')        -- Modified by UG039


                                ) );

                        ELSE
                            l_status_mess := ( 'Program is either a concurrent program or run by the Concurrent Manager Program is := '
                                               || p_prog_val );
                        END IF; */

            ELSIF p_table_name = 'FA_ADJUSTMENTS'
            THEN
               -- l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);

               --               IF l_count = 1
               --               THEN
               l_status_mess := NULL;
                       /* SELECT
                            COUNT(1)
                        INTO l_count
                        FROM
                            dual
                        WHERE
                            EXISTS (
                                SELECT
                                    1
                                FROM
                                    apps.fa_adjustments         fadj,
                                    apps.xla_events             xle,
                                    apps.xla_ae_headers         xah,
                                    apps.xla_distribution_links xdl,
                                    apps.xla_ae_lines           xal,
                                    apps.gl_je_headers          gjh,
                                    apps.gl_import_references   gir,
                                    apps.gl_ledgers             gl
                                WHERE
                                        xdl.source_distribution_id_num_1 = TO_NUMBER(o1)
                                    AND fadj.adjustment_line_id = xdl.source_distribution_id_num_2
                                    AND xdl.application_id = 140
                                    AND xdl.event_id = xle.event_id
                                    AND xle.event_type_code = 'ADDITIONS'
                                    AND xdl.ae_header_id = xah.ae_header_id
                                    AND xah.ledger_id = gl.ledger_id
                                    AND xdl.ae_header_id = xal.ae_header_id
                                    AND xdl.ae_line_num = xal.ae_line_num
                                    AND xal.application_id = 140


                                    AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                    AND gir.gl_sl_link_table = 'XLAJEL'
--                               AND gjh.je_header_id = gje.je_header_id
                                    AND gjh.status = 'P'
                                    AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                    ),
                                                                                 'YYYY-MM-DD HH24:MI:SS'),
                                                                         to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
        'YYYY-MM-DD HH24:MI:SS')        -- Modified by UG039


                            ); */

            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            --ELSIF p_table_name = 'FA_DISTRIBUTION_ACCOUNTS'
            --THEN
            --l_count := xxctcl_cp_check (p_prog_val, l_count);

            -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);

            --               IF l_count = 1
            --               THEN
            --l_status_mess := NULL;
            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            ELSIF p_table_name = 'FA_ADDITIONS_B'
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);

               --               IF l_count = 1
               --               THEN
               l_status_mess := NULL;
            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            ELSIF p_table_name = 'FA_ASSET_HISTORY'
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);
               --               IF l_count = 1
               --               THEN
               l_status_mess := NULL;
            /*
                SELECT
                    COUNT(1)
                INTO l_count
                FROM
                    dual
                WHERE
                    EXISTS (
                        SELECT
                            1
                        FROM
                            apps.fa_transaction_headers   fth,
                            apps.fa_adjustments           fa,
                            apps.xla_events               xev,
                            apps.xla_ae_headers           xah,
                            apps.xla_distribution_links   xdl,
                            apps.xla_ae_lines             xal,
                            apps.gl_je_headers            gjh,
                            apps.gl_import_references     gir,
                            apps.xla_transaction_entities xte
                        WHERE
                                fth.asset_id = o1
                            AND fth.transaction_header_id = nvl(o2, fth.transaction_header_id)        -- TRANSACTION_HEADER_ID_IN is pk2
                            AND fth.transaction_header_id = fa.transaction_header_id


                            AND fth.event_id = xah.event_id
                            AND xah.event_id = xev.event_id
                            AND xev.entity_id = xte.entity_id
                            AND xah.ae_header_id = xal.ae_header_id
                            AND xah.ae_header_id = xdl.ae_header_id
                            AND xdl.ae_header_id = xal.ae_header_id
                            AND xdl.ae_line_num = xal.ae_line_num
                            AND xdl.event_id = xah.event_id
                            AND xdl.source_distribution_id_num_1 = fth.transaction_header_id
                            AND xah.gl_transfer_status_code = 'Y'
                            AND xal.gl_sl_link_id = gir.gl_sl_link_id
                            AND gjh.je_header_id = gir.je_header_id
                            AND gjh.status = 'P'
                            AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                            ),
                                                                         'YYYY-MM-DD HH24:MI:SS'),
                                                                 to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
'YYYY-MM-DD HH24:MI:SS')        -- Modified by UG039


                    ); */

            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            ELSIF p_table_name = 'FA_BOOKS'
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);
               --               IF l_count = 1
               --               THEN
               l_status_mess := NULL;
               /* SELECT
                    COUNT(1)
                INTO l_count
                FROM
                    dual
                WHERE
                    EXISTS (
                        SELECT
                            1
                        FROM
                            apps.fa_transaction_headers   fth,
                            apps.fa_adjustments           fa,
                            apps.xla_events               xev,
                            apps.xla_ae_headers           xah,
                            apps.xla_distribution_links   xdl,
                            apps.xla_ae_lines             xal,
                            apps.gl_je_headers            gjh,
                            apps.gl_import_references     gir,
                            apps.xla_transaction_entities xte
                        WHERE
                                fth.transaction_header_id = o1
                            AND fth.transaction_header_id = fa.transaction_header_id
                            AND fth.event_id = xah.event_id
                            AND xah.event_id = xev.event_id
                            AND xev.entity_id = xte.entity_id
                            AND xah.ae_header_id = xal.ae_header_id
                            AND xah.ae_header_id = xdl.ae_header_id
                            AND xdl.ae_line_num = xal.ae_line_num
                            AND xdl.event_id = xah.event_id
                            AND xdl.source_distribution_id_num_1 = fth.transaction_header_id
                            AND xah.gl_transfer_status_code = 'Y'
                            AND xal.gl_sl_link_id = gir.gl_sl_link_id
                            AND gjh.je_header_id = gir.je_header_id
                            AND gjh.status = 'P'
                            AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                            ),
                                                                         'YYYY-MM-DD HH24:MI:SS'),
                                                                 to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
'YYYY-MM-DD HH24:MI:SS')        -- Modified by UG039


                    ); */

            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;


            ELSIF p_table_name = 'FA_DEPRN_DETAIL'
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);
               --               IF l_count = 1
               --               THEN
               l_status_mess := NULL;
            /*
                SELECT
                    COUNT(1)
                INTO l_count
                FROM
                    dual
                WHERE
                    EXISTS (
                        SELECT
                            1
                        FROM
                            apps.fa_deprn_detail          fds,
                            apps.xla_events               xev,
                            apps.xla_ae_headers           xah,
                            apps.xla_distribution_links   xdl,
                            apps.xla_ae_lines             xal,
                            apps.gl_je_headers            gjh,
                            apps.gl_import_references     gir,
                            apps.xla_transaction_entities xte
                        WHERE
                                xdl.source_distribution_id_char_4 = o1       --BOOK_TYPE_CODE  as pk1
                            AND xdl.source_distribution_id_num_1 = nvl(o2, xdl.source_distribution_id_num_1)      --ASSET_ID   as pk2
                            AND xdl.source_distribution_id_num_2 = o3      -- PERIOD_COUNTER as pk3
                            AND fds.distribution_id = o4
                            AND xdl.source_distribution_id_char_4 = fds.book_type_code
                            AND xdl.source_distribution_id_num_1 = fds.asset_id
                            AND xdl.source_distribution_id_num_2 = fds.period_counter
                            AND xah.event_id = xev.event_id
                            AND xev.entity_id = xte.entity_id
                            AND xte.entity_code = 'DEPRECIATION'
                            AND xdl.ae_line_num = xal.ae_line_num
                            AND xah.ae_header_id = xal.ae_header_id
                            AND xah.ae_header_id = xdl.ae_header_id
                            AND xdl.ae_header_id = xal.ae_header_id
                            AND xdl.ae_line_num = xal.ae_line_num
                            AND xdl.event_id = xah.event_id
                            AND xdl.event_id = fds.event_id    -- Added by UG039



                            AND xah.gl_transfer_status_code = 'Y'
                            AND xal.gl_sl_link_id = gir.gl_sl_link_id
                            AND gjh.je_header_id = gir.je_header_id
                            AND gjh.status = 'P'
                            AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                            ),
                                                                         'YYYY-MM-DD HH24:MI:SS'),
                                                                 to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
'YYYY-MM-DD HH24:MI:SS')        -- Modified by UG039


                    ); */

            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;


            ELSIF P_TABLE_NAME = 'FA_ASSET_HISTORY'
            THEN
               SELECT COUNT (1)
                 INTO L_COUNT
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM --   apps.FA_TRANSACTION_HEADERS FTH,
                                 apps.fa_adjustments fa,
                                 apps.xla_events xev,
                                 apps.xla_ae_headers xah,
                                 apps.xla_distribution_links xdl,
                                 apps.xla_ae_lines xal,
                                 apps.gl_je_headers gjh,
                                 apps.gl_import_references gir,
                                 apps.xla_transaction_entities xte
                           WHERE     fa.transaction_header_id = P_KEY_VALUE1
                                 AND xah.event_id =
                                        NVL (P_KEY_VALUE2, xah.event_id)
                                 AND xah.event_id = xev.event_id
                                 AND xev.entity_id = xte.entity_id
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xah.ae_header_id = xdl.ae_header_id
                                 AND xdl.ae_line_num = xal.ae_line_num
                                 AND xdl.event_id = xah.event_id
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                 AND gjh.je_header_id = gir.je_header_id
                                 AND gjh.status = 'P'
                                 AND xal.creation_date <=
                                        TO_DATE (
                                           NVL (
                                              TO_CHAR (
                                                 TO_TIMESTAMP (
                                                    p_collection_time,
                                                    'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                 'YYYY-MM-DD HH24:MI:SS'),
                                              TO_CHAR (
                                                 SYSDATE,
                                                 'YYYY-MM-DD HH24:MI:SS')),
                                           'YYYY-MM-DD HH24:MI:SS'));



            ELSIF p_table_name = 'FA_DISTRIBUTION_HISTORY'
            THEN
               -- l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);
               --               IF l_count = 1
               --               THEN
               l_status_mess := NULL;
            /*
                                    SELECT
                                        COUNT(1)
                                    INTO l_count
                                    FROM
                                        dual
                                    WHERE
                                        ( EXISTS (
                                            SELECT
                                                1
                                            FROM
                                                apps.fa_transaction_headers   fth,
                                                apps.fa_adjustments           fa,
                                                apps.xla_events               xev,
                                                apps.xla_ae_headers           xah,
                                                apps.xla_distribution_links   xdl,
                                                apps.xla_ae_lines             xal,
                                                apps.gl_je_headers            gjh,
                                                apps.gl_import_references     gir,
                                                apps.xla_transaction_entities xte
                                            WHERE
                                                    fth.transaction_header_id = o1              --  TRANSACTION_HEADER_ID_IN as pk1

                                                AND fth.transaction_header_id = fa.transaction_header_id
                                                AND fth.event_id = xah.event_id
                                                AND xah.event_id = xev.event_id
                                                AND xev.entity_id = xte.entity_id
                                                AND xte.source_id_int_1 = fth.transaction_header_id
                                                AND xah.ae_header_id = xal.ae_header_id
                                                AND xah.ae_header_id = xdl.ae_header_id
                                                AND xdl.ae_line_num = xal.ae_line_num
                                                AND xdl.event_id = xah.event_id
                                                AND xdl.source_distribution_id_num_1 = fth.transaction_header_id
                                                AND xah.gl_transfer_status_code = 'Y'
                                                AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                                AND gjh.je_header_id = gir.je_header_id
                                                AND gjh.status = 'P'
                                                AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                                ),
                                                                                             'YYYY-MM-DD HH24:MI:SS'),
                                                                                     to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
                    'YYYY-MM-DD HH24:MI:SS')        -- Modified by UG039


                                        )
                                          OR EXISTS (
                                            SELECT
                                                1
                                            FROM
                                                apps.fa_transaction_headers   fth,
                                                apps.fa_adjustments           fa,
                                                apps.xla_events               xev,
                                                apps.xla_ae_headers           xah,
                                                apps.xla_distribution_links   xdl,
                                                apps.xla_ae_lines             xal,
                                                apps.gl_je_headers            gjh,
                                                apps.gl_import_references     gir,
                                                apps.xla_transaction_entities xte
                                            WHERE
                                                    fth.transaction_header_id = nvl(o2, fth.transaction_header_id)      --  TRANSACTION_HEADER_ID_OUT as pk2

                                                AND fth.transaction_header_id = fa.transaction_header_id
                                                AND fth.event_id = xah.event_id
                                                AND xah.event_id = xev.event_id
                                                AND xev.entity_id = xte.entity_id
                                                AND xte.source_id_int_1 = fth.transaction_header_id
                                                AND xah.ae_header_id = xal.ae_header_id
                                                AND xah.ae_header_id = xdl.ae_header_id
                                                AND xdl.ae_line_num = xal.ae_line_num
                                                AND xdl.event_id = xah.event_id
                                                AND xdl.source_distribution_id_num_1 = fth.transaction_header_id
                                                AND xah.gl_transfer_status_code = 'Y'
                                                AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                                AND gjh.je_header_id = gir.je_header_id
                                                AND gjh.status = 'P'
                                                AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                                ),
                                                                                             'YYYY-MM-DD HH24:MI:SS'),
                                                                                     to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
                    'YYYY-MM-DD HH24:MI:SS')        -- Modified by UG039


                                        ) ); */

            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            ELSIF p_table_name = 'FA_RETIREMENTS'
            THEN
               -- l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);
               --               IF l_count = 1
               --               THEN
               l_status_mess := NULL;
                /*

                SELECT
                    COUNT(1)
                INTO l_count
                FROM
                    dual
                WHERE
                    ( EXISTS (
                        SELECT
                            1
                        FROM
                            apps.fa_transaction_headers   fth,
                            apps.fa_adjustments           fa,
                            apps.xla_events               xev,
                            apps.xla_ae_headers           xah,
                            apps.xla_distribution_links   xdl,
                            apps.xla_ae_lines             xal,
                            apps.gl_je_headers            gjh,
                            apps.gl_import_references     gir,
                            apps.xla_transaction_entities xte
                        WHERE
                                fth.transaction_header_id = o1     -- TRANSACTION_HEADER_ID_IN as pk1

                            AND fth.transaction_header_id = fa.transaction_header_id
                            AND fth.event_id = xah.event_id
                            AND xah.event_id = xev.event_id
                            AND xev.entity_id = xte.entity_id
                            AND xah.ae_header_id = xal.ae_header_id
                            AND xah.ae_header_id = xdl.ae_header_id
                            AND xdl.ae_line_num = xal.ae_line_num
                            AND xdl.event_id = xah.event_id
                            AND xdl.source_distribution_id_num_1 = fth.transaction_header_id
                            AND xah.gl_transfer_status_code = 'Y'
                            AND xal.gl_sl_link_id = gir.gl_sl_link_id
                            AND gjh.je_header_id = gir.je_header_id
                            AND gjh.status = 'P'
                            AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                            ),
                                                                         'YYYY-MM-DD HH24:MI:SS'),
                                                                 to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
'YYYY-MM-DD HH24:MI:SS')        -- Modified by UG039


                    )
                      OR EXISTS (
                        SELECT
                            1
                        FROM
                            apps.fa_retirements           fr,
                            apps.fa_transaction_headers   fth,
                            apps.fa_adjustments           fa,
                            apps.xla_events               xev,
                            apps.xla_ae_headers           xah,
                            apps.xla_distribution_links   xdl,
                            apps.xla_ae_lines             xal,
                            apps.gl_je_headers            gjh,
                            apps.gl_import_references     gir,
                            apps.xla_transaction_entities xte
                        WHERE
                                fth.transaction_header_id = nvl(o2, fth.transaction_header_id)        -- TRANSACTION_HEADER_ID_OUT as pk2

                            AND fth.transaction_header_id = fa.transaction_header_id
                            AND fth.event_id = xah.event_id
                            AND xah.event_id = xev.event_id
                            AND xev.entity_id = xte.entity_id
                            AND xah.ae_header_id = xal.ae_header_id
                            AND xah.ae_header_id = xdl.ae_header_id
                            AND xdl.ae_line_num = xal.ae_line_num
                            AND xdl.event_id = xah.event_id
                            AND xdl.source_distribution_id_num_1 = fth.transaction_header_id
                            AND xah.gl_transfer_status_code = 'Y'
                            AND xal.gl_sl_link_id = gir.gl_sl_link_id
                            AND gjh.je_header_id = gir.je_header_id
                            AND gjh.status = 'P'
                            AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                            ),
                                                                         'YYYY-MM-DD HH24:MI:SS'),
                                                                 to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
'YYYY-MM-DD HH24:MI:SS')        -- Modified by UG039


                    ) ); */

            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            ELSIF p_table_name = 'FA_TRANSACTION_HEADERS'
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);
               --               IF l_count = 1
               --               THEN
               l_status_mess := NULL;
            /*
                                    SELECT
                                        COUNT(1)
                                    INTO l_count
                                    FROM
                                        dual
                                    WHERE
                                        EXISTS (
                                            SELECT
                                                1
                                            FROM
                                     --   apps.FA_TRANSACTION_HEADERS FTH,
                                                apps.fa_adjustments           fa,
                                                apps.xla_events               xev,
                                                apps.xla_ae_headers           xah,
                                                apps.xla_distribution_links   xdl,
                                                apps.xla_ae_lines             xal,
                                                apps.gl_je_headers            gjh,
                                                apps.gl_import_references     gir,
                                                apps.xla_transaction_entities xte
                                            WHERE
                                                    fa.transaction_header_id = o1
                                                AND xah.event_id = nvl(o2, xah.event_id)


                                                AND xah.event_id = xev.event_id
                                                AND xev.entity_id = xte.entity_id
                                                AND xah.ae_header_id = xal.ae_header_id
                                                AND xah.ae_header_id = xdl.ae_header_id
                                                AND xdl.ae_line_num = xal.ae_line_num
                                                AND xdl.event_id = xah.event_id

                                                AND xah.gl_transfer_status_code = 'Y'
                                                AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                                AND gjh.je_header_id = gir.je_header_id
                                                AND gjh.status = 'P'
                                                AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                                ),
                                                                                             'YYYY-MM-DD HH24:MI:SS'),
                                                                                     to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
                    'YYYY-MM-DD HH24:MI:SS')        -- Modified by UG039


                                        ); */

            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            /*
            ELSIF p_table_name = 'FA_DEPRN_SUMMARY'
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);
               --               IF l_count = 1
               --               THEN
               l_status_mess := NULL;
            */
            /*
                                    SELECT
                                        COUNT(1)
                                    INTO l_count
                                    FROM
                                        dual
                                    WHERE
                                        EXISTS (
                                            SELECT
                                                1
                                            FROM
                                                apps.xla_events               xev,
                                                apps.xla_ae_headers           xah,
                                                apps.xla_distribution_links   xdl,
                                                apps.xla_ae_lines             xal,
                                                apps.gl_je_headers            gjh,
                                                apps.gl_import_references     gir,
                                                apps.xla_transaction_entities xte
                                            WHERE
                                                    xdl.source_distribution_id_char_4 = o1
                                                AND xdl.source_distribution_id_num_1 = nvl(o2, xdl.source_distribution_id_num_1)
                                                AND xdl.source_distribution_id_num_2 = nvl(o3, xdl.source_distribution_id_num_2)

                                                AND xah.event_id = xev.event_id
                                                AND xev.entity_id = xte.entity_id
                                                AND xte.entity_code = 'DEPRECIATION'
                                                AND xah.ae_header_id = xal.ae_header_id
                                                AND xah.ae_header_id = xdl.ae_header_id
                                                AND xdl.ae_line_num = xal.ae_line_num
                                                AND xdl.event_id = xah.event_id




                                                AND xah.gl_transfer_status_code = 'Y'
                                                AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                                AND gjh.je_header_id = gir.je_header_id
                                                AND gjh.status = 'P'
                                                AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                                ),
                                                                                             'YYYY-MM-DD HH24:MI:SS'),
                                                                                     to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
                    'YYYY-MM-DD HH24:MI:SS')        -- Modified by UG039


                                        ); */

            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            /*ELSIF p_table_name = 'TCL_NSD_HEADERS'
            THEN                                                  --khaleel
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);
               --               IF l_count = 1
               --               THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE (   EXISTS
                             (SELECT 1
                                FROM tcl_apps.tcl_nsd_headers tnh,
                                     apps.org_organization_definitions org,
                                     apps.oe_order_headers_all oha,
                                     wsh_delivery_details wdd,
                                     apps.mtl_material_transactions mmt,
                                     apps.mtl_transaction_accounts mta,
                                     apps.mtl_transaction_types mtt,
                                     apps.xla_events xe,
                                     apps.xla_distribution_links xdl,
                                     apps.xla_ae_headers xah,
                                     apps.xla_ae_lines xal,
                                     apps.gl_import_references gir,
                                     apps.gl_je_headers gjh
                               WHERE     tnh.ref_no = p_key_value1 --o1 --REF_NO
                                     AND tnh.organization_id =
                                            org.organization_code
                                     AND tnh.ref_sales_order =
                                            oha.order_number
                                     AND tnh.despatch_transaction =
                                            'Sales Order'
                                     AND oha.org_id = org.operating_unit
                                     AND oha.header_id =
                                            wdd.source_header_id
                                     AND wdd.delivery_detail_id =
                                            mmt.picking_line_id
                                     AND wdd.source_line_id =
                                            mmt.trx_source_line_id
                                     AND mtt.transaction_type_id =
                                            mmt.transaction_type_id
                                     AND mtt.transaction_action_id =
                                            mmt.transaction_action_id
                                     AND mmt.transaction_id =
                                            mta.transaction_id
                                     AND mta.inv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'MTL_TRANSACTION_ACCOUNTS'
                                     AND xdl.ae_header_id =
                                            xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id =
                                            xal.ae_header_id
                                     AND xal.gl_sl_link_id =
                                            gir.gl_sl_link_id
                                     AND gir.je_header_id =
                                            gjh.je_header_id
                                     AND gjh.status = 'P'
                                     AND xal.creation_date <=
                                            TO_DATE (
                                               NVL (
                                                  TO_CHAR (
                                                     TO_TIMESTAMP (
                                                        p_collection_time,
                                                        'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                     'YYYY-MM-DD HH24:MI:SS'),
                                                  TO_CHAR (
                                                     SYSDATE,
                                                     'YYYY-MM-DD HH24:MI:SS')),
                                               'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                       )
                       OR EXISTS
                             (SELECT 1
                                FROM tcl_apps.tcl_nsd_headers tnh,
                                     apps.org_organization_definitions org,
                                     apps.po_requisition_headers_all prha,
                                     apps.po_requisition_lines_all prla,
                                     apps.rcv_shipment_lines rsl,
                                     apps.rcv_transactions rt,
                                     apps.rcv_receiving_sub_ledger rrsl,
                                     apps.xla_distribution_links xdl,
                                     apps.xla_events xe,
                                     apps.xla_ae_headers xah,
                                     apps.xla_ae_lines xal,
                                     apps.gl_import_references gir,
                                     apps.gl_je_headers gjh
                               WHERE     tnh.ref_no = p_key_value1 --o1 -- REF_NO
                                     AND tnh.organization_id =
                                            org.organization_code
                                     AND prha.segment1 =
                                            tnh.ref_sales_order
                                     AND tnh.despatch_transaction =
                                            'IR-ISO'
                                     AND prha.org_id = org.operating_unit
                                     AND prha.requisition_header_id =
                                            prla.requisition_header_id
                                     AND prla.requisition_line_id =
                                            rsl.requisition_line_id
                                     AND rt.shipment_line_id =
                                            rsl.shipment_line_id
                                     AND rt.transaction_id =
                                            rrsl.rcv_transaction_id
                                     AND rrsl.rcv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'RCV_RECEIVING_SUB_LEDGER'
                                     AND xdl.ae_header_id =
                                            xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id =
                                            xal.ae_header_id
                                     AND xal.gl_sl_link_id =
                                            gir.gl_sl_link_id
                                     AND gir.je_header_id =
                                            gjh.je_header_id
                                     AND gjh.status = 'P'
                                     AND xal.creation_date <=
                                            TO_DATE (
                                               NVL (
                                                  TO_CHAR (
                                                     TO_TIMESTAMP (
                                                        p_collection_time,
                                                        'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                     'YYYY-MM-DD HH24:MI:SS'),
                                                  TO_CHAR (
                                                     SYSDATE,
                                                     'YYYY-MM-DD HH24:MI:SS')),
                                               'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                       )
                       OR EXISTS
                             (SELECT 1
                                FROM tcl_apps.tcl_nsd_headers tnh,
                                     apps.org_organization_definitions org,
                                     apps.mtl_txn_request_headers mtrh,
                                     apps.mtl_txn_request_lines mtrl,
                                     apps.mtl_material_transactions mmt,
                                     apps.mtl_transaction_accounts mta,
                                     apps.mtl_transaction_types mtt,
                                     apps.xla_events xe,
                                     apps.xla_distribution_links xdl,
                                     apps.xla_ae_headers xah,
                                     apps.xla_ae_lines xal,
                                     apps.gl_import_references gir,
                                     apps.gl_je_headers gjh
                               WHERE     tnh.ref_no = p_key_value1 -- o1 -- REF_NO
                                     AND tnh.organization_id =
                                            org.organization_code
                                     AND mtrh.request_number =
                                            tnh.ref_sales_order
                                     AND tnh.despatch_transaction IN ('Move Order Transfer',
                                                                      'Move Order Issue')
                                     AND mtrh.organization_id =
                                            org.organization_id
                                     AND mtrh.header_id = mtrl.header_id
                                     AND mtrl.line_id =
                                            mmt.move_order_line_id
                                     AND mtrl.organization_id =
                                            mmt.organization_id
                                     AND mtt.transaction_type_id =
                                            mmt.transaction_type_id
                                     AND mtt.transaction_action_id =
                                            mmt.transaction_action_id
                                     AND mmt.transaction_id =
                                            mta.transaction_id
                                     AND mta.inv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'MTL_TRANSACTION_ACCOUNTS'
                                     AND xdl.ae_header_id =
                                            xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id =
                                            xal.ae_header_id
                                     AND xal.gl_sl_link_id =
                                            gir.gl_sl_link_id
                                     AND gir.je_header_id =
                                            gjh.je_header_id
                                     AND gjh.status = 'P'
                                     AND xal.creation_date <=
                                            TO_DATE (
                                               NVL (
                                                  TO_CHAR (
                                                     TO_TIMESTAMP (
                                                        p_collection_time,
                                                        'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                     'YYYY-MM-DD HH24:MI:SS'),
                                                  TO_CHAR (
                                                     SYSDATE,
                                                     'YYYY-MM-DD HH24:MI:SS')),
                                               'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                       )
                       OR EXISTS
                             (SELECT 1
                                FROM tcl_apps.tcl_nsd_headers tnh,
                                     apps.org_organization_definitions org,
                                     apps.mtl_txn_request_headers mtrh,
                                     apps.rcv_transactions rt,
                                     apps.mtl_txn_request_lines mtrl,
                                     apps.mtl_material_transactions mmt,
                                     apps.mtl_transaction_accounts mta,
                                     apps.mtl_transaction_types mtt,
                                     apps.xla_events xe,
                                     apps.xla_distribution_links xdl,
                                     apps.xla_ae_headers xah,
                                     apps.xla_ae_lines xal,
                                     apps.gl_import_references gir,
                                     apps.gl_je_headers gjh
                               WHERE     tnh.ref_no = p_key_value1 -- o1 -- ref_no
                                     AND tnh.organization_id =
                                            org.organization_code
                                     AND mtrh.request_number =
                                            tnh.ref_sales_order
                                     AND tnh.despatch_transaction IN ('Move Order Transfer',
                                                                      'Move Order Issue')
                                     AND mtrh.organization_id =
                                            org.organization_id
                                     AND mtrh.header_id = mtrl.header_id
                                     AND (   (    rt.shipment_line_id =
                                                     mtrl.reference_id
                                              AND mtrl.reference =
                                                     'SHIPMENT_LINE_ID')
                                          OR (    rt.po_line_location_id =
                                                     mtrl.reference_id
                                              AND mtrl.reference =
                                                     'PO_LINE_LOCATION_ID'))
                                     AND rt.transaction_type = 'DELIVER'
                                     AND rt.transaction_id =
                                            mmt.rcv_transaction_id
                                     AND mtt.transaction_type_id =
                                            mmt.transaction_type_id
                                     AND mtt.transaction_action_id =
                                            mmt.transaction_action_id
                                     AND mmt.transaction_id =
                                            mta.transaction_id
                                     AND mta.inv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'MTL_TRANSACTION_ACCOUNTS'
                                     AND xdl.ae_header_id =
                                            xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id =
                                            xal.ae_header_id
                                     AND xal.gl_sl_link_id =
                                            gir.gl_sl_link_id
                                     AND gir.je_header_id =
                                            gjh.je_header_id
                                     AND gjh.status = 'P'
                                     AND xal.creation_date <=
                                            TO_DATE (
                                               NVL (
                                                  TO_CHAR (
                                                     TO_TIMESTAMP (
                                                        p_collection_time,
                                                        'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                     'YYYY-MM-DD HH24:MI:SS'),
                                                  TO_CHAR (
                                                     SYSDATE,
                                                     'YYYY-MM-DD HH24:MI:SS')),
                                               'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                       )
                       OR EXISTS
                             (SELECT 1
                                FROM tcl_apps.tcl_nsd_headers tnh,
                                     apps.org_organization_definitions org,
                                     apps.mtl_txn_request_headers mtrh,
                                     apps.mtl_txn_request_lines mtrl,
                                     apps.mtl_material_transactions mmt,
                                     apps.mtl_transaction_accounts mta,
                                     apps.xla_events xe,
                                     apps.xla_distribution_links xdl,
                                     apps.xla_ae_headers xah,
                                     apps.xla_ae_lines xal,
                                     apps.gl_import_references gir,
                                     apps.gl_je_headers gjh
                               WHERE     tnh.ref_no = p_key_value1 -- o1 -- ref_no
                                     AND tnh.organization_id =
                                            org.organization_code
                                     AND mtrh.request_number =
                                            tnh.ref_sales_order
                                     AND tnh.despatch_transaction IN ('Move Order Transfer',
                                                                      'Move Order Issue')
                                     AND mtrh.organization_id =
                                            org.organization_id
                                     AND mtrh.header_id = mtrl.header_id
                                     AND mtrl.reference = 'ORDER_LINE_ID'
                                     AND mtrl.reference_id =
                                            mmt.trx_source_line_id
                                     AND mtrl.organization_id =
                                            mmt.organization_id
                                     AND mmt.transaction_type_id = 15
                                     AND mmt.transaction_source_type_id =
                                            12
                                     AND mmt.transaction_id =
                                            mta.transaction_id
                                     AND mta.inv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'MTL_TRANSACTION_ACCOUNTS'
                                     AND xdl.ae_header_id =
                                            xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id =
                                            xal.ae_header_id
                                     AND xal.gl_sl_link_id =
                                            gir.gl_sl_link_id
                                     AND gir.je_header_id =
                                            gjh.je_header_id
                                     AND gjh.status = 'P'
                                     AND xal.creation_date <=
                                            TO_DATE (
                                               NVL (
                                                  TO_CHAR (
                                                     TO_TIMESTAMP (
                                                        p_collection_time,
                                                        'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                     'YYYY-MM-DD HH24:MI:SS'),
                                                  TO_CHAR (
                                                     SYSDATE,
                                                     'YYYY-MM-DD HH24:MI:SS')),
                                               'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                       ));
            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            */
            /*ELSIF p_table_name = 'TCL_NSD_LINES'
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);
               --               IF l_count = 1
               --               THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE (   EXISTS
                             (SELECT 1
                                FROM apps.oe_order_headers_all oha,
                                     tcl_apps.tcl_nsd_headers tnh,
                                     apps.org_organization_definitions org,
                                     wsh_delivery_details wdd,
                                     apps.mtl_material_transactions mmt,
                                     apps.mtl_transaction_accounts mta,
                                     apps.mtl_transaction_types mtt,
                                     apps.xla_events xe,
                                     apps.xla_distribution_links xdl,
                                     apps.xla_ae_headers xah,
                                     apps.xla_ae_lines xal,
                                     apps.gl_import_references gir,
                                     apps.gl_je_headers gjh
                               WHERE     tnh.ref_no = p_key_value1 --  o1 --ref_No
                                     AND tnh.ref_sales_order =
                                            oha.order_number
                                     AND tnh.organization_id =
                                            org.organization_code
                                     AND tnh.despatch_transaction =
                                            'Sales Order'
                                     AND oha.org_id = org.operating_unit
                                     AND oha.header_id =
                                            wdd.source_header_id
                                     AND wdd.delivery_detail_id =
                                            mmt.picking_line_id
                                     AND wdd.source_line_id =
                                            mmt.trx_source_line_id
                                     AND mtt.transaction_type_id =
                                            mmt.transaction_type_id
                                     AND mtt.transaction_action_id =
                                            mmt.transaction_action_id
                                     AND mmt.transaction_id =
                                            mta.transaction_id
                                     AND mta.inv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'MTL_TRANSACTION_ACCOUNTS'
                                     AND xdl.ae_header_id =
                                            xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id =
                                            xal.ae_header_id
                                     AND xal.gl_sl_link_id =
                                            gir.gl_sl_link_id
                                     AND gir.je_header_id =
                                            gjh.je_header_id
                                     AND gjh.status = 'P'
                                     AND xal.creation_date <=
                                            TO_DATE (
                                               NVL (
                                                  TO_CHAR (
                                                     TO_TIMESTAMP (
                                                        p_collection_time,
                                                        'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                     'YYYY-MM-DD HH24:MI:SS'),
                                                  TO_CHAR (
                                                     SYSDATE,
                                                     'YYYY-MM-DD HH24:MI:SS')),
                                               'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                       )
                       OR EXISTS
                             (SELECT 1
                                FROM apps.po_requisition_headers_all prha,
                                     tcl_apps.tcl_nsd_headers tnh,
                                     apps.org_organization_definitions org,
                                     apps.po_requisition_lines_all prla,
                                     apps.rcv_shipment_lines rsl,
                                     apps.rcv_transactions rt,
                                     apps.rcv_receiving_sub_ledger rrsl,
                                     apps.xla_distribution_links xdl,
                                     apps.xla_events xe,
                                     apps.xla_ae_headers xah,
                                     apps.xla_ae_lines xal,
                                     apps.gl_import_references gir,
                                     apps.gl_je_headers gjh
                               WHERE     tnh.ref_no = p_key_value1 -- o1 -- ref_no
                                     --        AND TNL.REF_NO                           = TNH.REF_NO
                                     AND prha.segment1 =
                                            tnh.ref_sales_order
                                     AND tnh.organization_id =
                                            org.organization_code
                                     AND tnh.despatch_transaction =
                                            'IR-ISO'
                                     AND prha.org_id = org.operating_unit
                                     AND prha.requisition_header_id =
                                            prla.requisition_header_id
                                     AND prla.requisition_line_id =
                                            rsl.requisition_line_id
                                     AND rt.shipment_line_id =
                                            rsl.shipment_line_id
                                     AND rt.transaction_id =
                                            rrsl.rcv_transaction_id
                                     AND rrsl.rcv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'RCV_RECEIVING_SUB_LEDGER'
                                     AND xdl.ae_header_id =
                                            xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id =
                                            xal.ae_header_id
                                     AND xal.gl_sl_link_id =
                                            gir.gl_sl_link_id
                                     AND gir.je_header_id =
                                            gjh.je_header_id
                                     AND gjh.status = 'P'
                                     AND xal.creation_date <=
                                            TO_DATE (
                                               NVL (
                                                  TO_CHAR (
                                                     TO_TIMESTAMP (
                                                        p_collection_time,
                                                        'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                     'YYYY-MM-DD HH24:MI:SS'),
                                                  TO_CHAR (
                                                     SYSDATE,
                                                     'YYYY-MM-DD HH24:MI:SS')),
                                               'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                       )
                       OR EXISTS
                             (SELECT 1
                                FROM apps.po_requisition_headers_all prha,
                                     tcl_apps.tcl_nsd_headers tnh,
                                     apps.org_organization_definitions org,
                                     apps.po_requisition_lines_all prla,
                                     apps.rcv_shipment_lines rsl,
                                     apps.rcv_transactions rt,
                                     apps.mtl_material_transactions mmt,
                                     apps.mtl_transaction_accounts mta,
                                     apps.xla_events xe,
                                     apps.xla_distribution_links xdl,
                                     apps.xla_ae_headers xah,
                                     apps.xla_ae_lines xal,
                                     apps.gl_import_references gir,
                                     apps.gl_je_headers gjh
                               WHERE     tnh.ref_no = p_key_value1 -- o1 -- ref_No
                                     AND prha.segment1 =
                                            tnh.ref_sales_order
                                     AND tnh.organization_id =
                                            org.organization_code
                                     AND tnh.despatch_transaction =
                                            'IR-ISO'
                                     AND prha.org_id = org.operating_unit
                                     AND prha.requisition_header_id =
                                            prla.requisition_header_id
                                     AND prla.requisition_line_id =
                                            rsl.requisition_line_id
                                     AND rt.shipment_header_id =
                                            rsl.shipment_header_id
                                     AND rt.transaction_id =
                                            mmt.rcv_transaction_id
                                     AND mmt.transaction_id =
                                            mta.transaction_id
                                     AND mta.inv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'MTL_TRANSACTION_ACCOUNTS'
                                     AND xdl.ae_header_id =
                                            xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id =
                                            xal.ae_header_id
                                     AND xal.gl_sl_link_id =
                                            gir.gl_sl_link_id
                                     AND gir.je_header_id =
                                            gjh.je_header_id
                                     AND gjh.status = 'P'
                                     AND xal.creation_date <=
                                            TO_DATE (
                                               NVL (
                                                  TO_CHAR (
                                                     TO_TIMESTAMP (
                                                        p_collection_time,
                                                        'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                     'YYYY-MM-DD HH24:MI:SS'),
                                                  TO_CHAR (
                                                     SYSDATE,
                                                     'YYYY-MM-DD HH24:MI:SS')),
                                               'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                       )
                       OR EXISTS
                             (SELECT 1
                                FROM apps.mtl_txn_request_headers mtrh,
                                     tcl_apps.tcl_nsd_headers tnh,
                                     apps.org_organization_definitions org,
                                     apps.mtl_txn_request_lines mtrl,
                                     apps.mtl_material_transactions mmt,
                                     apps.mtl_transaction_accounts mta,
                                     apps.mtl_transaction_types mtt,
                                     apps.xla_events xe,
                                     apps.xla_distribution_links xdl,
                                     apps.xla_ae_headers xah,
                                     apps.xla_ae_lines xal,
                                     apps.gl_import_references gir,
                                     apps.gl_je_headers gjh
                               WHERE     tnh.ref_no = p_key_value1 --o1 -- ref_No
                                     --      AND TNL.REF_NO                            = TNH.REF_NO
                                     AND mtrh.request_number =
                                            tnh.ref_sales_order
                                     AND tnh.organization_id =
                                            org.organization_code
                                     AND tnh.despatch_transaction IN ('Move Order Transfer',
                                                                      'Move Order Issue')
                                     AND mtrh.organization_id =
                                            org.organization_id
                                     AND mtrh.header_id = mtrl.header_id
                                     AND mtrl.line_id =
                                            mmt.move_order_line_id
                                     AND mtrl.organization_id =
                                            mmt.organization_id
                                     AND mtt.transaction_type_id =
                                            mmt.transaction_type_id
                                     AND mtt.transaction_action_id =
                                            mmt.transaction_action_id
                                     AND mmt.transaction_id =
                                            mta.transaction_id
                                     AND mta.inv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'MTL_TRANSACTION_ACCOUNTS'
                                     AND xdl.ae_header_id =
                                            xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id =
                                            xal.ae_header_id
                                     AND xal.gl_sl_link_id =
                                            gir.gl_sl_link_id
                                     AND gir.je_header_id =
                                            gjh.je_header_id
                                     AND gjh.status = 'P'
                                     AND xal.creation_date <=
                                            TO_DATE (
                                               NVL (
                                                  TO_CHAR (
                                                     TO_TIMESTAMP (
                                                        p_collection_time,
                                                        'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                     'YYYY-MM-DD HH24:MI:SS'),
                                                  TO_CHAR (
                                                     SYSDATE,
                                                     'YYYY-MM-DD HH24:MI:SS')),
                                               'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                       )
                       OR EXISTS
                             (SELECT 1
                                FROM apps.mtl_txn_request_headers mtrh,
                                     tcl_apps.tcl_nsd_headers tnh,
                                     apps.org_organization_definitions org,
                                     apps.rcv_transactions rt,
                                     apps.mtl_txn_request_lines mtrl,
                                     apps.mtl_material_transactions mmt,
                                     apps.mtl_transaction_accounts mta,
                                     apps.mtl_transaction_types mtt,
                                     apps.xla_events xe,
                                     apps.xla_distribution_links xdl,
                                     apps.xla_ae_headers xah,
                                     apps.xla_ae_lines xal,
                                     apps.gl_import_references gir,
                                     apps.gl_je_headers gjh
                               WHERE     tnh.ref_no = p_key_value1 -- o1 -- ref_No
                                     --     AND TNL.REF_NO                            = TNH.REF_NO
                                     AND mtrh.request_number =
                                            tnh.ref_sales_order
                                     AND tnh.organization_id =
                                            org.organization_code
                                     AND tnh.despatch_transaction IN ('Move Order Transfer',
                                                                      'Move Order Issue')
                                     AND mtrh.organization_id =
                                            org.organization_id
                                     AND mtrh.header_id = mtrl.header_id
                                     AND (   (    rt.shipment_line_id =
                                                     mtrl.reference_id
                                              AND mtrl.reference =
                                                     'SHIPMENT_LINE_ID')
                                          OR (    rt.po_line_location_id =
                                                     mtrl.reference_id
                                              AND mtrl.reference =
                                                     'PO_LINE_LOCATION_ID'))
                                     AND rt.transaction_type = 'DELIVER'
                                     AND rt.transaction_id =
                                            mmt.rcv_transaction_id
                                     AND mtt.transaction_type_id =
                                            mmt.transaction_type_id
                                     AND mtt.transaction_action_id =
                                            mmt.transaction_action_id
                                     AND mmt.transaction_id =
                                            mta.transaction_id
                                     AND mta.inv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'MTL_TRANSACTION_ACCOUNTS'
                                     AND xdl.ae_header_id =
                                            xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id =
                                            xal.ae_header_id
                                     AND xal.gl_sl_link_id =
                                            gir.gl_sl_link_id
                                     AND gir.je_header_id =
                                            gjh.je_header_id
                                     AND gjh.status = 'P'
                                     AND xal.creation_date <=
                                            TO_DATE (
                                               NVL (
                                                  TO_CHAR (
                                                     TO_TIMESTAMP (
                                                        p_collection_time,
                                                        'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                     'YYYY-MM-DD HH24:MI:SS'),
                                                  TO_CHAR (
                                                     SYSDATE,
                                                     'YYYY-MM-DD HH24:MI:SS')),
                                               'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                       )
                       OR EXISTS
                             (SELECT 1
                                FROM apps.mtl_txn_request_headers mtrh,
                                     tcl_apps.tcl_nsd_headers tnh,
                                     apps.org_organization_definitions org,
                                     apps.mtl_txn_request_lines mtrl,
                                     apps.mtl_material_transactions mmt,
                                     apps.mtl_transaction_accounts mta,
                                     apps.xla_events xe,
                                     apps.xla_distribution_links xdl,
                                     apps.xla_ae_headers xah,
                                     apps.xla_ae_lines xal,
                                     apps.gl_import_references gir,
                                     apps.gl_je_headers gjh
                               WHERE     tnh.ref_no = p_key_value1 -- o1 -- ref_no
                                     --     AND TNL.REF_NO                            = TNH.REF_NO
                                     AND mtrh.request_number =
                                            tnh.ref_sales_order
                                     AND tnh.organization_id =
                                            org.organization_code
                                     AND tnh.despatch_transaction IN ('Move Order Transfer',
                                                                      'Move Order Issue')
                                     AND mtrh.organization_id =
                                            org.organization_id
                                     AND mtrh.header_id = mtrl.header_id
                                     AND mtrl.reference = 'ORDER_LINE_ID'
                                     AND mtrl.reference_id =
                                            mmt.trx_source_line_id
                                     AND mtrl.organization_id =
                                            mmt.organization_id
                                     AND mmt.transaction_type_id = 15
                                     AND mmt.transaction_source_type_id =
                                            12
                                     AND mmt.transaction_id =
                                            mta.transaction_id
                                     AND mta.inv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'MTL_TRANSACTION_ACCOUNTS'
                                     AND xdl.ae_header_id =
                                            xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id =
                                            xal.ae_header_id
                                     AND xal.gl_sl_link_id =
                                            gir.gl_sl_link_id
                                     AND gir.je_header_id =
                                            gjh.je_header_id
                                     AND gjh.status = 'P'
                                     AND xal.creation_date <=
                                            TO_DATE (
                                               NVL (
                                                  TO_CHAR (
                                                     TO_TIMESTAMP (
                                                        p_collection_time,
                                                        'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                     'YYYY-MM-DD HH24:MI:SS'),
                                                  TO_CHAR (
                                                     SYSDATE,
                                                     'YYYY-MM-DD HH24:MI:SS')),
                                               'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                       ));
            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            */
            ELSIF p_table_name = 'AR_DISTRIBUTIONS_ALL'
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);
               --               IF l_count = 1
               --               THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM apps.xla_events xe,
                                 apps.xla_ae_headers xah,
                                 apps.xla_distribution_links xdl,
                                 apps.xla_ae_lines xal,
                                 apps.gl_import_references gir,
                                 apps.gl_je_headers gjh
                           WHERE     xdl.source_distribution_id_num_1 =
                                        p_key_value1           --o1 -- line_Id
                                 AND xdl.source_distribution_type =
                                        'AR_DISTRIBUTIONS_ALL'
                                 AND xah.ae_header_id = xdl.ae_header_id
                                 AND xdl.ae_line_num = xdl.ae_line_num
                                 AND xe.entity_id = xah.entity_id
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND gjh.status = 'P'
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                 AND gir.je_header_id = gjh.je_header_id
                                 AND xal.creation_date <=
                                        TO_DATE (
                                           NVL (
                                              TO_CHAR (
                                                 TO_TIMESTAMP (
                                                    p_collection_time,
                                                    'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                 'YYYY-MM-DD HH24:MI:SS'),
                                              TO_CHAR (
                                                 SYSDATE,
                                                 'YYYY-MM-DD HH24:MI:SS')),
                                           'YYYY-MM-DD HH24:MI:SS') -- Modified by UG039
                                                                   );


            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            ELSIF p_table_name = 'XLA_DISTRIBUTION_LINKS'
            THEN
               --l_count := xxctcl_cp_check (p_prog_val, l_count);

               -- l_count := xxctcl_client_superuser_access(p_client_id, l_count);
               --               IF l_count = 1
               --               THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM apps.xla_ae_headers xah,
                                 apps.xla_ae_lines xal
                           WHERE     xah.ae_header_id = xal.ae_header_id
                                 AND xah.ae_header_id = p_key_value1 -- o1  --AE_HEADER_ID
                                 AND xal.ae_line_num =
                                        NVL (p_key_value2, xal.ae_line_num) --o2 -- ae_line_Num
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F');


            --               ELSE
            --                  l_status_mess :=
            --                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                      || p_prog_val);
            --               END IF;
            ELSE
               l_count := 1;
               L_STATUS_MESS := P_TABLE_NAME || ' TABLE NOT FOUND.';
            END IF;
         --ELSE
         --  l_status_mess := ('No Change in the Values.');
         -- END IF;
         --         ELSE
         --            l_status_mess :=
         --               (' EVENT IS OUT OF SCOPE.');
         END IF;
      ELSE
         l_status_mess :=
            (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
             || p_prog_val);
      ---  To check change is occured for inscope column or not
      END IF;



      IF (l_count = 0 AND l_status_mess IS NULL)
      THEN
         l_status_mess := 'UNPOSTED TRANSACTION, HENCE IGNORING RECORD';
      ELSIF l_count = 1 AND l_status_mess IS NULL
      THEN
         l_status_mess := 'RECORD IS ELIGIBLE WILL GET CAPTURED IN GG';
      END IF;

      --END IF;

      COMMIT;
      xxctcl_insert_debug_log (p_table_name,
                               l_key_value,
                               l_count,              --l_old_val, --l_new_val,
                               l_status_mess);
      p_count_val := l_count;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_count := 0;
         p_count_val := l_count;
         p_err_msg :=
               'Error encountered for '
            || p_table_name
            || ' AND p_key_value1, p_key_value2 , p_key_value3 are  '
            || p_key_value1
            || ' , '
            || p_key_value2
            || ' , '
            || p_key_value3
            || ' resptly -->'
            || SQLERRM;

         l_status_mess :=
            (   'Error occured '
             || DBMS_UTILITY.format_error_backtrace
             || 'And  Error says -->'
             || SQLERRM);
         xxctcl_insert_debug_log (p_table_name,
                                  l_key_value,
                                  l_count,           --l_old_val, --l_new_val,
                                  l_status_mess);
   END xxctcl_gg_filter_condition_prc;


   -- Function is to check whether the client is having super user access or it

   FUNCTION xxctcl_client_superuser_access (p_client_id    VARCHAR2,
                                            p_qry_cnt      NUMBER)
      RETURN NUMBER
   AS
      l_su_access   NUMBER;
   BEGIN
      l_su_access := p_qry_cnt;

      SELECT COUNT (1)
        INTO l_su_access
        FROM DUAL
       WHERE     1 = 1
             AND (   EXISTS
                        (SELECT 1
                           FROM apps.fnd_profile_options fpo,
                                apps.fnd_profile_option_values fpov,
                                apps.fnd_user fu,
                                apps.fnd_profile_options fpo1,
                                apps.fnd_profile_option_values fpov1
                          WHERE     1 = 1
                                AND fpo.profile_option_name = 'DIAGNOSTICS'
                                AND fpov.profile_option_value = 'Y'
                                AND fpo1.profile_option_name =
                                       'FND_HIDE_DIAGNOSTICS'
                                AND fpov1.profile_option_value = 'N'
                                AND fpo.profile_option_id =
                                       fpov.profile_option_id
                                AND fpov.level_value = fu.user_id
                                AND fpo1.profile_option_id =
                                       fpov1.profile_option_id
                                AND fu.user_id = fpov1.level_value
                                AND fu.user_name =
                                       NVL (p_client_id, fu.user_name))
                  OR EXISTS
                        (SELECT 1
                           FROM apps.fnd_user_resp_groups_direct a,
                                apps.fnd_user b,
                                apps.fnd_responsibility_vl c,
                                apps.fnd_application fa,
                                apps.fnd_application_tl ftl
                          WHERE     a.user_id = b.user_id
                                AND a.responsibility_id = c.responsibility_id
                                AND fa.application_id =
                                       a.responsibility_application_id
                                AND fa.application_id = ftl.application_id
                                AND ftl.language = USERENV ('LANG')
                                AND SYSDATE BETWEEN a.start_date
                                                AND NVL (a.end_date,
                                                         SYSDATE + 1)
                                AND SYSDATE BETWEEN b.start_date
                                                AND NVL (b.end_date,
                                                         SYSDATE + 1)
                                AND SYSDATE BETWEEN c.start_date
                                                AND NVL (c.end_date,
                                                         SYSDATE + 1)
                                AND b.user_name =
                                       NVL (p_client_id, b.user_name)
                                AND c.responsibility_name =
                                       'Common Error Framework [7888]'
                         UNION ALL
                         SELECT 1
                           FROM apps.fnd_user_resp_groups_indirect a,
                                apps.fnd_user b,
                                apps.fnd_responsibility_vl c,
                                apps.fnd_application fa,
                                apps.fnd_application_tl ftl
                          WHERE     a.user_id = b.user_id
                                AND a.responsibility_id = c.responsibility_id
                                AND fa.application_id =
                                       a.responsibility_application_id
                                AND fa.application_id = ftl.application_id
                                AND ftl.language = USERENV ('LANG')
                                AND SYSDATE BETWEEN a.start_date
                                                AND NVL (a.end_date,
                                                         SYSDATE + 1)
                                AND SYSDATE BETWEEN b.start_date
                                                AND NVL (b.end_date,
                                                         SYSDATE + 1)
                                AND SYSDATE BETWEEN c.start_date
                                                AND NVL (c.end_date,
                                                         SYSDATE + 1)
                                AND b.user_name =
                                       NVL (p_client_id, b.user_name)
                                AND c.responsibility_name =
                                       'Common Error Framework [7888]'));

      RETURN l_su_access;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_su_access := 0;
         RETURN l_su_access;
   END xxctcl_client_superuser_access;

   ---- Function is to check the p_prog_val is excluded CP or not            --1.1 changes start

   FUNCTION xxctcl_cp_check (p_prog_val VARCHAR2, p_qry_cnt NUMBER)
      RETURN NUMBER
   IS
   BEGIN
      l_prog_val := p_prog_val;
      l_count := p_qry_cnt;

      SELECT COUNT (1)
        INTO l_count
        FROM DUAL
       WHERE NOT EXISTS
                    (SELECT 1
                       FROM fnd_concurrent_programs fcp,
                            apps.fnd_concurrent_queues fcq,
                            (SELECT SUBSTR (p_prog_val,
                                            1,
                                            (INSTR (p_prog_val, '@') - 1))
                                       AS program
                               FROM DUAL) cp_check
                      WHERE    program = fcp.concurrent_program_name
                            OR program = fcq.concurrent_queue_name);

      RETURN l_count;
   END xxctcl_cp_check;                                      --1.1 changes end
END xxctcl_gg_filter_condition_pkg;
/
