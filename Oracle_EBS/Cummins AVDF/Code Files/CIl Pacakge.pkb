CREATE OR REPLACE PACKAGE BODY APPS.xxccil_gg_filter_condition_pkg
/******************************************************************************
   NAME:       xxccil_gg_filter_condition_pkg.pkb
   PURPOSE:   Validate india specific and posted transactions and return the count back to Golden Gate

   REVISIONS:
    Ver        Date        Author            Description                            Reviewed By           Reviewed Date
    ----      --------      -----------       ----------------------------------     ----------------      -------------
    1.0        02-05-2025  WJ454(BSL)        Created this package.                                    DD-MM-RRRR
    1.1        24-02-2025  AL02R            created the xxccil_CP_CHECK function
                                            to check is p_prog_val is excluded
                                        CP or not and added the logic to
                                        compare onld value and new value
    1.2        24-02-2025  WJ454            created the xxccil_CP_CHECK function
                                        to check whether the client is having
                                        super user access or not
    1.3       17-06-2025  XW294             Changed the flow as per new requirement,
                                            Removed unused tables.Commented old/new values.
                                            (CHG0230785)
   1.4        22-Aug-2025  XW294           Changed the CP_check function and client_id Null
                                           conditions.(CHG0250599)
   ASSUMPTIONS:
   LIMITATIONS:
   ALGORITHM:
   NOTES:
******************************************************************************/
AS
   l_count            NUMBER := 0;
   l_key_value        VARCHAR2 (4000);
   -- l_old_val          VARCHAR2 (4000);
   -- l_new_val          VARCHAR2 (4000);
   --l_erro_mess        VARCHAR2 (4000);
   l_status_mess      VARCHAR2 (1000) DEFAULT NULL;
   l_prog_val         VARCHAR2 (1000);
   l_start_time       DATE;
   l_parameter_mess   VARCHAR2 (1000);

   /******************************************************************************
      NAME:        xxccil_gg_filter_condition_prc
      PURPOSE:    Validate india specific and posted transactions and return the count back to Golden Gate

      REVISIONS:
      Ver        Date        Author               Description
      ---------  ----------  ---------------      ----------------------------------
      1.0        02-05-2025  WJ454(BSL)          Created this procedure  xxccil_gg_filter_condition_prc
      1.1       17-06-2025   XW294               Removed old-new values and added new l_key_value message(CHG0230785)

      INPUT PARAMETERS:  P_TABLE_NAME,P_KEY_VALUE1,P_KEY_VALUE2,P_KEY_VALUE3

      OUTPUT PARAMETERS:   p_vc_err_buff
                           p_vc_ret_code
      INOUT PARAMETERS:

      ASSUMPTIONS:
      LIMITATIONS:
      NOTES:
   ******************************************************************************/
   PROCEDURE xxccil_gg_filter_condition_prc (
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
      --    P_TRANS_DATE IN DATE     DEFAULT NULL ,

      --      o1                   IN     VARCHAR2 DEFAULT NULL,
      --      o2                   IN     VARCHAR2 DEFAULT NULL,
      --      o3                   IN     VARCHAR2 DEFAULT NULL,
      --      o4                   IN     VARCHAR2 DEFAULT NULL,
      --      o5                   IN     VARCHAR2 DEFAULT NULL,
      --      o6                   IN     VARCHAR2 DEFAULT NULL,
      --      o7                   IN     VARCHAR2 DEFAULT NULL,
      --      o8                   IN     VARCHAR2 DEFAULT NULL,
      --      o9                   IN     VARCHAR2 DEFAULT NULL,
      --      o10                  IN     VARCHAR2 DEFAULT NULL,
      --      o11                  IN     VARCHAR2 DEFAULT NULL,
      --      o12                  IN     VARCHAR2 DEFAULT NULL,
      --      o13                  IN     VARCHAR2 DEFAULT NULL,
      --      o14                  IN     VARCHAR2 DEFAULT NULL,
      --      o15                  IN     VARCHAR2 DEFAULT NULL,
      --      o16                  IN     VARCHAR2 DEFAULT NULL,
      --      o17                  IN     VARCHAR2 DEFAULT NULL,
      --      o18                  IN     VARCHAR2 DEFAULT NULL,
      --      o19                  IN     VARCHAR2 DEFAULT NULL,
      --      o20                  IN     VARCHAR2 DEFAULT NULL,
      --      o21                  IN     VARCHAR2 DEFAULT NULL,
      --      o22                  IN     VARCHAR2 DEFAULT NULL,
      --      o23                  IN     VARCHAR2 DEFAULT NULL,
      --      o24                  IN     VARCHAR2 DEFAULT NULL,
      --      o25                  IN     VARCHAR2 DEFAULT NULL,
      --      o26                  IN     VARCHAR2 DEFAULT NULL,
      --      o27                  IN     VARCHAR2 DEFAULT NULL,
      --      o28                  IN     VARCHAR2 DEFAULT NULL,
      --      o29                  IN     VARCHAR2 DEFAULT NULL,
      --      o30                  IN     VARCHAR2 DEFAULT NULL,
      --      n1                   IN     VARCHAR2 DEFAULT NULL,
      --      n2                   IN     VARCHAR2 DEFAULT NULL,
      --      n3                   IN     VARCHAR2 DEFAULT NULL,
      --      n4                   IN     VARCHAR2 DEFAULT NULL,
      --      n5                   IN     VARCHAR2 DEFAULT NULL,
      --      n6                   IN     VARCHAR2 DEFAULT NULL,
      --      n7                   IN     VARCHAR2 DEFAULT NULL,
      --      n8                   IN     VARCHAR2 DEFAULT NULL,
      --      n9                   IN     VARCHAR2 DEFAULT NULL,
      --      n10                  IN     VARCHAR2 DEFAULT NULL,
      --      n11                  IN     VARCHAR2 DEFAULT NULL,
      --      n12                  IN     VARCHAR2 DEFAULT NULL,
      --      n13                  IN     VARCHAR2 DEFAULT NULL,
      --      n14                  IN     VARCHAR2 DEFAULT NULL,
      --      n15                  IN     VARCHAR2 DEFAULT NULL,
      --      n16                  IN     VARCHAR2 DEFAULT NULL,
      --      n17                  IN     VARCHAR2 DEFAULT NULL,
      --      n18                  IN     VARCHAR2 DEFAULT NULL,
      --      n19                  IN     VARCHAR2 DEFAULT NULL,
      --      n20                  IN     VARCHAR2 DEFAULT NULL,
      --      n21                  IN     VARCHAR2 DEFAULT NULL,
      --      n22                  IN     VARCHAR2 DEFAULT NULL,
      --      n23                  IN     VARCHAR2 DEFAULT NULL,
      --      n24                  IN     VARCHAR2 DEFAULT NULL,
      --      n25                  IN     VARCHAR2 DEFAULT NULL,
      --      n26                  IN     VARCHAR2 DEFAULT NULL,
      --      n27                  IN     VARCHAR2 DEFAULT NULL,
      --      n28                  IN     VARCHAR2 DEFAULT NULL,
      --      n29                  IN     VARCHAR2 DEFAULT NULL,
      --      n30                  IN     VARCHAR2 DEFAULT NULL,
      p_record_timestamp   IN     VARCHAR2 DEFAULT NULL,
      p_commit_timestamp   IN     VARCHAR2 DEFAULT NULL,
      p_count_val             OUT VARCHAR2,
      p_err_msg               OUT VARCHAR2)
   AS
      -- ln_count number;
      -- ln_log_seq number;
      -- lc_key_value varchar2(100);

      PROCEDURE xxccil_insert_debug_log (p_log_object       VARCHAR2,
                                         p_log_key_value    VARCHAR2,
                                         p_qry_cnt          NUMBER,
                                         -- p_old_val          VARCHAR2,       --Commented by Aditya R on 17-Jun-2025 CRQ CHG0230785
                                         -- p_new_val          VARCHAR2,       --Commented by Aditya R on 17-Jun-2025 CRQ CHG0230785
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
            SELECT xxc.xxc_goldengate_seq.NEXTVAL,
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
                   -- l_old_val,                                              --Commented by Aditya R on 17-Jun-2025 CRQ CHG0230785
                   -- l_new_val,                                              --Commented by Aditya R on 17-Jun-2025 CRQ CHG0230785
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
                  'Error while inserting into debug table XXC_GOLDENGATE_LOG'
               || SQLERRM;
      END;
   BEGIN
      l_start_time := SYSDATE;

      --  1. If you able pass table name from GG as Hard coded i will use 1 singel proce all 42
      -- 2. Creatpage AND all 42 procedure get seperate
      -- 3. 43 sepererate proceduer

      BEGIN
         SELECT                                                        --   n1
                   --                || NVL2 (o1, '|' || o1, '')                    --Commented by Aditya R on 17-Jun-2025 CRQ CHG0230785
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

      --Commented by Aditya R on 17-Jun-2025 CRQ CHG0230785
      -- Concatenating all the new values in to a single string.

      --        BEGIN
      --             l_new_val := n1 || ','|| n2 || ',' || n3 || ',' || n4 || ',' || n5 || ',' || n6 || ',' || n7 || ','|| n8 || ',' || n9 || ',' || n10 || ',' || n11 || ',' || n12 || ','  || n13 || ','  || n14 || ','  || n15 || ','  || n16 || ','  || n17  || ',' || n18 || ','  || n19 || ','  || n20 || ','  || n21 || ','  || n22 || ','  || n23 || ','  || n24 || ','  || n25 || ','  || n26 || ','  || n27 || ','  || n28 || ','  || n29 || ','  || n30;
      --        EXCEPTION
      --            WHEN others THEN
      --             l_new_val := SUBSTR(n1 || n2 || n3 || n4 || n5 || n6 || n7 || n8 || n9 || n10 || n11 || n12 || n13 || n14 || n15 || n16 || n17 || n18 || n19 || n20 || n21 || n22 || n23 || n24 || n25 || n26 || n27 || n28 || n29 || n30, 1, 4000);
      --        END;
      --
      --
      --  -- Concatenating all the old values in to a single string.
      --        BEGIN
      --             l_old_val := o1 || ','|| o2 || ',' || o3 || ',' || o4 || ',' || o5 || ',' || o6 || ',' || o7 || ','|| o8 || ',' || o9 || ',' || o10 || ',' || o11 || ',' || o12 || ','  || o13 || ','  || o14 || ','  || o15 || ','  || o16 || ','  || o17  || ',' || o18 || ','  || o19 || ','  || o20 || ','  || o21 || ','  || o22 || ','  || o23 || ','  || o24 || ','  || o25 || ','  || o26 || ','  || o27 || ','  || o28 || ','  || o29 || ','  || o30;
      --        EXCEPTION
      --            WHEN others THEN
      --             l_old_val := SUBSTR(o1 || o2 || o3 || o4 || o5 || o6 || o7 || o8 || o9 || o10 || o11 || o12 || o13 || o14 || o15 || o16 || o17 || o18 || o19 || o20 || o21 || o22 || o23 || o24 || o25 || o26 || o27 || o28 || o29 || o30, 1, 4000);
      --        END;

      l_count := 0;
      l_status_mess := NULL;

      --- Concurrent Program Check
      l_count := xxccil_cp_check (p_prog_val, l_count,p_client_id); --Added by Aditya R on 17-Jun-2025 for CRQ CHG0230785


      IF l_count = 1
      THEN
         IF p_event IN ('DELETE', 'INSERT')
         THEN
            IF p_client_id IS NULL --AND (p_prog_val NOT LIKE 'frmweb%' OR p_prog_val != 'JDBC Thin Client')
            THEN
               l_count := 1;
               l_status_mess := 'Record is ' || P_EVENT || 'ed from backend';
            ELSE
               l_count := 0;
               l_status_mess :=
                     'Record is '
                  || P_EVENT
                  || 'ed from frontend.';
            END IF;
         --        ELSIF length(l_new_val) > 29 THEN
         --            IF ( l_old_val != l_new_val ) THEN                                                --1.1 changes start
         --                l_count := 1;
         --            END IF;

         --1.1 changes end

         --                       IF l_count = 1 THEN
         ELSE
            IF p_table_name IN ('PO_HEADERS_ALL',
                                'PO_LINES_ALL',
                                'PO_LINE_LOCATIONS_ALL',
                                'PO_DISTRIBUTIONS_ALL',
                                'PO_RELEASES_ALL',
                                --'GL_BALANCES',
                                'OE_ORDER_HEADERS_ALL',
                                'OE_ORDER_LINES_ALL',
                                'WSH_DELIVERY_DETAILS')
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --         IF l_count = 1
               --         THEN

--               IF p_client_id IS NULL AND (p_prog_val LIKE 'frmweb%' OR p_prog_val = 'JDBC Thin Client')
--               THEN
               l_count := xxccil_client_superuser_access (p_client_id, l_count);

               IF l_count = 1
               THEN
                  l_status_mess :=
                     'Record is updated by backend or by superuser';
               ELSE
                  --l_count := 0;
                  l_status_mess := 'Record is updated by frontend';
               END IF;
               --END IF;
            --         ELSE
            --            l_status_mess :=
            --               (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            -- Added remaining tables
            ELSIF P_TABLE_NAME IN ('RCV_PARAMETERS',
                                   'RA_CUST_TRX_TYPES_ALL',
                                   'RA_ACCOUNT_DEFAULT_SEGMENTS',
                                   'QP_LIST_LINES',
                                   'QP_LIST_HEADERS_B',
                                   'PO_SYSTEM_PARAMETERS_ALL',
                                   'ORG_ACCT_PERIODS',
                                   'OE_TRANSACTION_TYPES_ALL',
                                   'MTL_SYSTEM_ITEMS_B',
                                   'MTL_SECONDARY_INVENTORIES',
                                   'MTL_PARAMETERS',
                                   'MTL_INTERORG_PARAMETERS',
                                   'IBY_EXTERNAL_PAYEES_ALL',
                                   'HZ_CUST_SITE_USES_ALL',
                                   'HZ_CUST_PROFILE_AMTS',
                                   'HZ_CUST_ACCT_SITES_ALL',
                                   'HZ_CUST_ACCOUNTS',
                                   'GL_PERIODS',
                                   'GL_PERIOD_TYPES',
                                   'GL_PERIOD_STATUSES',
                                   'GL_LEDGERS',
                                   'FND_FLEX_VALUES_TL',
                                   'FND_FLEX_VALUES',
                                   'BOM_STRUCTURES_B',
                                   'BOM_COMPONENTS_B',
                                   'AR_SYSTEM_PARAMETERS_ALL',
                                   'AR_RECEIVABLES_TRX_ALL',
                                   'AP_SYSTEM_PARAMETERS_ALL',
                                   'AP_SUPPLIERS',
                                   'AP_BANK_BRANCHES')
            THEN
               l_status_mess := NULL;
            ELSIF p_table_name = 'GL_DAILY_RATES'
            THEN
               IF p_key_value1 = 'INR' AND p_key_value2 = 'Corporate'
               THEN
                  l_count := 1;
               ELSE
                  l_count := 0;
                  l_status_mess :=
                     (' GL_DAILY RATE IS NOT UPDATED FOR INR CURRENCY ');
               END IF;
            /*
            ELSIF p_table_name = 'GL_JE_HEADERS'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               IF                                            --l_count != 1 OR
                 p_key_value1 != 'P'
               THEN                                          -- o22 --> status
                  l_count := 0;
--                  l_status_mess :=
--                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
--                      || p_prog_val);
               END IF;
            ELSIF p_table_name = 'GL_JE_LINES'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

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
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               IF                                            --l_count != 1 OR
                 p_key_value1 != 'P'
               THEN                                           -- o3 --> status
                  l_count := 0;
--                  l_status_mess :=
--                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
--                      || p_prog_val);
               END IF; */
            -- Commented GL_JE tables as per requiremnt by Aditya R on 17-Jun-2025 CRQ CHG0230785
            ELSIF (p_table_name = 'XLA_AE_HEADERS')
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               -- o1 = AE_HEADER_ID

               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM apps.xla_ae_headers XAH, apps.gl_ledgers gl
                           WHERE     xah.ae_header_id =
                                        TO_NUMBER (p_key_value1)
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND gl.ledger_id = xah.ledger_id);
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            ELSIF (p_table_name = 'XLA_AE_LINES')
            THEN
               -- l_count := xxccil_cp_check (p_prog_val, l_count);

               -- 01 = AE_HEADER_ID
               -- o2 = AE_LINE_NUM

               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM apps.xla_ae_headers xah,
                                 apps.xla_ae_lines xal,
                                 apps.gl_ledgers gl
                           WHERE     xal.ae_header_id =
                                        TO_NUMBER (p_key_value1)
                                 AND xal.ae_line_num =
                                        TO_NUMBER (p_key_value2)
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND gl.ledger_id = xah.ledger_id
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F');
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            ELSIF p_table_name = 'RCV_TRANSACTIONS'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE (   EXISTS
                             (SELECT 1
                                FROM rcv_receiving_sub_ledger rrsl,
                                     xla_distribution_links xdl,
                                     xla_events xe,
                                     xla_ae_headers xah,
                                     xla_ae_lines xal
                               WHERE     rrsl.rcv_transaction_id =
                                            p_key_value1 --o1 -- TRANSACTION_ID is PK1
                                     AND rrsl.rcv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'RCV_RECEIVING_SUB_LEDGER'
                                     AND xdl.ae_header_id = xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     -- to check for p_collection_time greater than xla posted date


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
                                               'YYYY-MM-DD HH24:MI:SS'))
                       OR EXISTS
                             (SELECT 1
                                FROM mtl_material_transactions mmt,
                                     mtl_transaction_accounts mta,
                                     xla_events xe,
                                     xla_distribution_links xdl,
                                     xla_ae_headers xah,
                                     xla_ae_lines xal
                               WHERE     mmt.rcv_transaction_id =
                                            p_key_value1 --o1 -- TRANSACTION_ID is PK1
                                     AND mmt.transaction_id =
                                            mta.transaction_id
                                     AND mta.inv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'MTL_TRANSACTION_ACCOUNTS'
                                     AND xdl.ae_header_id = xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     -- to check for p_collection_time greater than xla posted date


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
                                               'YYYY-MM-DD HH24:MI:SS')));
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            --Condition on DS_AVAL_UAL
            ELSIF p_table_name = 'RCV_SHIPMENT_HEADERS'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE (   EXISTS
                             (SELECT 1
                                FROM rcv_transactions rt,
                                     rcv_receiving_sub_ledger rrsl,
                                     xla_distribution_links xdl,
                                     xla_events xe,
                                     xla_ae_headers xah,
                                     xla_ae_lines xal
                               WHERE     rt.shipment_header_id = p_key_value1 --o1 --SHIPMENT_HEADER_ID is PK1
                                     AND rt.transaction_id =
                                            rrsl.rcv_transaction_id
                                     AND rrsl.rcv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'RCV_RECEIVING_SUB_LEDGER'
                                     AND xdl.ae_header_id = xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     -- to check for p_collection_time greater than xla posted date


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
                                               'YYYY-MM-DD HH24:MI:SS'))
                       OR EXISTS
                             (SELECT 1
                                FROM rcv_transactions rt,
                                     mtl_material_transactions mmt,
                                     mtl_transaction_accounts mta,
                                     xla_events xe,
                                     xla_distribution_links xdl,
                                     xla_ae_headers xah,
                                     xla_ae_lines xal
                               WHERE     rt.shipment_header_id = p_key_value1 --o1 --SHIPMENT_HEADER_ID is PK1
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
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     -- to check for p_collection_time greater than xla posted date


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
                                               'YYYY-MM-DD HH24:MI:SS')));
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            ELSIF p_table_name = 'RCV_SHIPMENT_LINES'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE (   EXISTS
                             (SELECT 1
                                FROM rcv_transactions rt,
                                     rcv_receiving_sub_ledger rrsl,
                                     xla_distribution_links xdl,
                                     xla_events xe,
                                     xla_ae_headers xah,
                                     xla_ae_lines xal
                               WHERE     rt.shipment_line_id = p_key_value1 --o1 --SHIPMENT_LINE_ID is PK1
                                     AND rt.transaction_id =
                                            rrsl.rcv_transaction_id
                                     AND rrsl.rcv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'RCV_RECEIVING_SUB_LEDGER'
                                     AND xdl.ae_header_id = xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     -- to check for p_collection_time greater than xla posted date


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
                                               'YYYY-MM-DD HH24:MI:SS'))
                       OR EXISTS
                             (SELECT 1
                                FROM rcv_transactions rt,
                                     mtl_material_transactions mmt,
                                     mtl_transaction_accounts mta,
                                     xla_events xe,
                                     xla_distribution_links xdl,
                                     xla_ae_headers xah,
                                     xla_ae_lines xal
                               WHERE     rt.shipment_line_id = p_key_value1 --o1 -- --SHIPMENT_LINE_ID is PK1
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
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     -- to check for p_collection_time greater than xla posted date


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
                                               'YYYY-MM-DD HH24:MI:SS')));
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            ELSIF p_table_name = 'MTL_MATERIAL_TRANSACTIONS'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM mtl_material_transactions mmt,
                                 mtl_transaction_accounts mta,
                                 xla_events xe,
                                 xla_distribution_links xdl,
                                 xla_ae_headers xah,
                                 xla_ae_lines xal
                           WHERE     mmt.transaction_id = p_key_value1 --o1 --transaction_id is PK1
                                 AND mmt.transaction_id = mta.transaction_id
                                 AND mta.inv_sub_ledger_id =
                                        xdl.source_distribution_id_num_1
                                 AND xdl.source_distribution_type =
                                        'MTL_TRANSACTION_ACCOUNTS'
                                 AND xdl.ae_header_id = xah.ae_header_id
                                 AND xdl.application_id = xah.application_id
                                 AND xdl.ae_line_num = xal.ae_line_num
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xe.entity_id = xah.entity_id
                                 AND xah.ae_header_id = xal.ae_header_id
                                 -- to check for p_collection_time greater than xla posted date


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
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            ELSIF p_table_name = 'RA_CUSTOMER_TRX_ALL'
            THEN
               --                l_count := xxccil_cp_check(p_prog_val, l_count);
               --                --l_count := xxccil_client_superuser_access(p_client_id, l_count);



               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM ra_cust_trx_line_gl_dist_all rctl,
                                 xla_distribution_links xdl,
                                 xla_events xe,
                                 xla_ae_headers xah,
                                 xla_ae_lines xal
                           WHERE     rctl.customer_trx_id = p_key_value1 -- o1 --CUSTOMER_TRX_ID is PK1
                                 AND rctl.event_id = xe.event_id
                                 AND xe.entity_id = xah.entity_id
                                 AND xdl.source_distribution_id_num_1 =
                                        rctl.cust_trx_line_gl_dist_id
                                 AND xdl.event_id = xe.event_id
                                 AND xdl.ae_header_id = xah.ae_header_id
                                 AND xdl.event_id = xah.event_id
                                 AND xdl.ae_header_id = xal.ae_header_id
                                 AND xdl.ae_line_num = xal.ae_line_num
                                 AND source_distribution_type =
                                        'RA_CUST_TRX_LINE_GL_DIST_ALL'
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xah.ae_header_id = xal.ae_header_id
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
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            ELSIF p_table_name = 'RA_CUSTOMER_TRX_LINES_ALL'
            THEN
               -- l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM ra_cust_trx_line_gl_dist_all rctl,
                                 xla_distribution_links xdl,
                                 xla_events xe,
                                 xla_ae_headers xah,
                                 xla_ae_lines xal
                           WHERE     rctl.customer_trx_line_id = p_key_value1 --o1
                                 AND rctl.event_id = xe.event_id
                                 AND xe.entity_id = xah.entity_id
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xah.ae_header_id = xdl.ae_header_id
                                 AND xdl.ae_line_num = xdl.ae_line_num
                                 AND xdl.source_distribution_type =
                                        'RA_CUST_TRX_LINE_GL_DIST_ALL'
                                 AND xdl.source_distribution_id_num_1 =
                                        rctl.cust_trx_line_gl_dist_id
                                 -- to check for p_collection_time greater than xla posted date

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
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            ELSIF p_table_name = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM xla_distribution_links xdl,
                                 xla_events xe,
                                 xla_ae_headers xah,
                                 xla_ae_lines xal
                           WHERE     xdl.source_distribution_id_num_1 =
                                        p_key_value1 -- o1 --CUST_TRX_LINE_GL_DIST_ID is pk1
                                 AND xe.event_id = p_key_value2 --o2       -- event_id is pk2
                                 AND xe.entity_id = xah.entity_id
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xah.ae_header_id = xdl.ae_header_id
                                 AND xdl.ae_line_num = xdl.ae_line_num
                                 AND xdl.source_distribution_type =
                                        'RA_CUST_TRX_LINE_GL_DIST_ALL'
                                 -- to check for p_collection_time greater than xla posted date
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
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            /*
            ELSIF p_table_name = 'WSH_DELIVERY_ASSIGNMENTS'
            THEN                                                    -- khaleel
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
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
                           WHERE     wdd.delivery_detail_id = p_key_value1 --o1 -- DELIVERY_DETAIL_ID is PK
                                 AND oola.header_id = oha.header_id
                                 AND oha.header_id = wdd.source_header_id
                                 AND oola.line_id = wdd.source_line_id
                                 --   AND wda.DELIVERY_DETAIL_ID                 = wdd.DELIVERY_DETAIL_ID
                                 AND wdd.delivery_detail_id =
                                        mmt.picking_line_id
                                 AND wdd.source_line_id =
                                        mmt.trx_source_line_id
                                 AND mtt.transaction_type_id =
                                        mmt.transaction_type_id
                                 AND mtt.transaction_action_id =
                                        mmt.transaction_action_id
                                 AND mmt.transaction_id = mta.transaction_id
                                 AND mta.inv_sub_ledger_id =
                                        xdl.source_distribution_id_num_1
                                 AND xdl.source_distribution_type =
                                        'MTL_TRANSACTION_ACCOUNTS'
                                 AND xdl.ae_header_id = xah.ae_header_id
                                 AND xdl.application_id = xah.application_id
                                 AND xdl.ae_line_num = xal.ae_line_num
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xe.entity_id = xah.entity_id
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
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
                                           'YYYY-MM-DD HH24:MI:SS')
                                 AND gir.je_header_id = gjh.je_header_id
                                 AND gjh.status = 'P');
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF; */
            /*   ELSIF p_table_name = 'WSH_DELIVERY_DETAILS' THEN
                   l_count := xxccil_cp_check(p_prog_val, l_count);
           --l_count := xxccil_client_superuser_access(p_client_id, l_count);
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
                                   AND mmt.trx_source_line_id = o2    -- source_line_id     is pk2
       --    AND wdd.DELIVERY_DETAIL_ID            = MMT.PICKING_LINE_ID
       --    AND wdd.source_line_id                = mmt.TRX_SOURCE_LINE_ID
                                   AND mtt.transaction_type_id = mmt.transaction_type_id
                                   AND mtt.transaction_action_id = mmt.transaction_action_id
                                   AND mmt.transaction_id = mta.transaction_id
                                   AND mta.inv_sub_ledger_id = xdl.source_distribution_id_num_1
                                   AND xdl.source_distribution_type = 'MTL_TRANSACTION_ACCOUNTS'
                                   AND xdl.ae_header_id = xah.ae_header_id
                                   AND xdl.application_id = xah.application_id

                                   AND xdl.ae_line_num = xal.ae_line_num
                                   AND xe.event_status_code = 'P'
                                   AND xe.process_status_code = 'P'
                                   AND xah.gl_transfer_status_code = 'Y'
                                   AND xah.accounting_entry_status_code = 'F'
                                   AND xe.entity_id = xah.entity_id
                                   AND xah.ae_header_id = xal.ae_header_id
                                   AND xal.gl_sl_link_id = gir.gl_sl_link_id


                                   AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                   ),
                                                                                'YYYY-MM-DD HH24:MI:SS'),
                                                                        to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
       'YYYY-MM-DD HH24:MI:SS')
                                   AND gir.je_header_id = gjh.je_header_id
                                   AND gjh.status = 'P'
                           );

                   ELSE
                       l_status_mess := ( '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
                                          || p_prog_val );
                   END IF; */
            /*
            ELSIF p_table_name = 'WSH_NEW_DELIVERIES'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
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
                           WHERE     wda.delivery_id = p_key_value1 --o1
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
                                 AND mmt.transaction_id = mta.transaction_id
                                 AND mta.inv_sub_ledger_id =
                                        xdl.source_distribution_id_num_1
                                 AND xdl.source_distribution_type =
                                        'MTL_TRANSACTION_ACCOUNTS'
                                 AND xdl.ae_header_id = xah.ae_header_id
                                 AND xdl.application_id = xah.application_id
                                 AND xdl.ae_line_num = xal.ae_line_num
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xe.entity_id = xah.entity_id
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
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
                                           'YYYY-MM-DD HH24:MI:SS')
                                 AND gir.je_header_id = gjh.je_header_id
                                 AND gjh.status = 'P');
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            */
            ELSIF p_table_name = 'AR_PAYMENT_SCHEDULES_ALL'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM ar_receivable_applications_all ara,
                                 ra_cust_trx_line_gl_dist_all rctl,
                                 xla_distribution_links xdl,
                                 xla_events xe,
                                 xla_ae_headers xah,
                                 xla_ae_lines xal
                           WHERE     ara.payment_schedule_id = p_key_value1 -- o1
                                 AND ara.event_id = xe.event_id
                                 AND xe.entity_id = xah.entity_id
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND rctl.customer_trx_id =
                                        ara.customer_trx_id
                                 AND xah.ae_header_id = xdl.ae_header_id
                                 AND xdl.ae_line_num = xdl.ae_line_num
                                 AND xdl.source_distribution_type =
                                        'RA_CUST_TRX_LINE_GL_DIST_ALL'
                                 AND xdl.source_distribution_id_num_1 =
                                        rctl.cust_trx_line_gl_dist_id
                                 --  AND APSA.PAYMENT_SCHEDULE_ID = ARA.PAYMENT_SCHEDULE_ID
                                 -- to check for p_collection_time greater than xla posted date
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
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            /*
            ELSIF p_table_name = 'AR_CASH_RECEIPTS_ALL'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
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
                           WHERE     arch.cash_receipt_id = p_key_value1 --o1
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
                                 AND xdl.ae_line_num = xdl.ae_line_num
                                 AND xdl.source_distribution_type =
                                        'AR_DISTRIBUTIONS_ALL'
                                 AND xdl.source_distribution_id_num_1 =
                                        ada.line_id
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
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
                                           'YYYY-MM-DD HH24:MI:SS')
                                 AND gir.je_header_id = gjh.je_header_id);
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            */
            /*
            ELSIF p_table_name = 'AR_RECEIVABLE_APPLICATIONS_ALL'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE (   EXISTS
                             (SELECT 1
                                FROM ra_cust_trx_line_gl_dist_all rctl,
                                     xla_distribution_links xdl,
                                     xla_events xe,
                                     xla_ae_headers xah,
                                     xla_ae_lines xal
                               WHERE     xe.event_id = p_key_value2
                                     AND rctl.customer_trx_id = p_key_value3
                                     --  AND ARA.EVENT_ID                   = XE.EVENT_ID
                                     --  AND ARA.CUSTOMER_TRX_ID            = RCTL.CUSTOMER_TRX_ID
                                     AND xe.entity_id = xah.entity_id
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xah.ae_header_id = xal.ae_header_id
                                     AND xah.ae_header_id = xdl.ae_header_id
                                     AND xdl.ae_line_num = xdl.ae_line_num
                                     AND xdl.source_distribution_type =
                                            'RA_CUST_TRX_LINE_GL_DIST_ALL'
                                     AND xdl.source_distribution_id_num_1 =
                                            rctl.cust_trx_line_gl_dist_id
                                     -- to check for p_collection_time greater than xla posted date

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
                                               'YYYY-MM-DD HH24:MI:SS'))
                       OR EXISTS
                             (SELECT 1
                                FROM ar_distributions_all ada,
                                     xla_distribution_links xdl,
                                     xla_events xe,
                                     xla_ae_headers xah,
                                     xla_ae_lines xal
                               WHERE     xe.event_id = p_key_value2
                                     AND ada.source_id =  p_key_value1 --o1-- RECEIVABLE_APPLICATION_ID is PK1
                                     --      AND ARA.EVENT_ID                    = XE.EVENT_ID
                                     --    and ADA.SOURCE_ID                   = ARA.RECEIVABLE_APPLICATION_ID
                                     AND ada.source_table = 'RA'
                                     AND xe.entity_id = xah.entity_id
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xah.ae_header_id = xal.ae_header_id
                                     AND xah.ae_header_id = xdl.ae_header_id
                                     AND xdl.ae_line_num = xdl.ae_line_num
                                     AND xdl.source_distribution_type =
                                            'AR_DISTRIBUTIONS_ALL'
                                     AND xdl.source_distribution_id_num_1 =
                                            ada.line_id
                                     -- to check for p_collection_time greater than xla posted date

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
                                               'YYYY-MM-DD HH24:MI:SS')));
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            */
            /*
            ELSIF p_table_name = 'AR_CASH_RECEIPT_HISTORY_ALL'
            THEN
               -- l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
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
                           WHERE     ard.source_id = p_key_value1 --o1 -- CASH_RECEIPT_HISTORY_ID is pk1
                                 --      AND acra.EVENT_ID                   = XE.EVENT_ID
                                 --    AND ACRA.CASH_RECEIPT_HISTORY_ID    = ARD.SOURCE_ID
                                 AND ard.source_table = 'CRH'
                                 AND xe.entity_id = xah.entity_id
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND gjh.status = 'P'
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xah.ae_header_id = xdl.ae_header_id
                                 AND xdl.ae_line_num = xdl.ae_line_num
                                 AND xdl.source_distribution_type =
                                        'AR_DISTRIBUTIONS_ALL'
                                 AND xdl.source_distribution_id_num_1 =
                                        ard.line_id
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
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
                                           'YYYY-MM-DD HH24:MI:SS')
                                 AND gir.je_header_id = gjh.je_header_id);
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            */
            ELSIF p_table_name = 'AR_REVENUE_ADJUSTMENTS_ALL'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM xla_events xe,
                                 xla_distribution_links xdl,
                                 xla_ae_headers xah,
                                 xla_ae_lines xal,
                                 ra_customer_trx_lines_all rctl,
                                 ra_cust_trx_line_gl_dist_all ragl
                           WHERE     ragl.customer_trx_id = p_key_value1 --o1 -- CUSTOMER_TRX_ID is PK1
                                 AND rctl.customer_trx_line_id = p_key_value2 --o2 -- FROM_CUST_TRX_LINE_ID is PK2
                                 AND ragl.event_id = xe.event_id
                                 --   AND ARAA.CUSTOMER_TRX_ID                            = RAGL.CUSTOMER_TRX_ID
                                 AND xe.entity_id = xah.entity_id
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xah.ae_header_id = xdl.ae_header_id
                                 AND xdl.ae_line_num = xdl.ae_line_num
                                 AND xdl.source_distribution_type =
                                        'RA_CUST_TRX_LINE_GL_DIST_ALL'
                                 AND xdl.source_distribution_id_num_1 =
                                        ragl.cust_trx_line_gl_dist_id
                                 --     AND ARAA.FROM_CUST_TRX_LINE_ID                      = RCTL.CUSTOMER_TRX_LINE_ID
                                 AND rctl.customer_trx_line_id =
                                        ragl.customer_trx_line_id
                                 -- to check for p_collection_time greater than xla posted date
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
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            ELSIF p_table_name = 'AR_DEFERRED_LINES_ALL'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM xla_events xe,
                                 xla_distribution_links xdl,
                                 xla_ae_headers xah,
                                 xla_ae_lines xal,
                                 ra_customer_trx_lines_all rctl,
                                 ra_cust_trx_line_gl_dist_all ragl
                           WHERE     rctl.customer_trx_line_id = p_key_value1 --o1 --CUSTOMER_TRX_LINE_ID is PK1
                                 AND ragl.event_id = xe.event_id
                                 AND xe.entity_id = xah.entity_id
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xah.ae_header_id = xdl.ae_header_id
                                 AND xdl.ae_line_num = xdl.ae_line_num
                                 AND xdl.source_distribution_type =
                                        'RA_CUST_TRX_LINE_GL_DIST_ALL'
                                 AND xdl.source_distribution_id_num_1 =
                                        ragl.cust_trx_line_gl_dist_id
                                 --  AND ADLA.CUSTOMER_TRX_LINE_ID            = RCTL.CUSTOMER_TRX_LINE_ID

                                 AND rctl.customer_trx_line_id =
                                        ragl.customer_trx_line_id
                                 -- to check for p_collection_time greater than xla posted date
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
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            /*
            ELSIF p_table_name = 'AR_ADJUSTMENTS_ALL'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
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
                           WHERE     xe.event_id = p_key_value1 --o1
                                 --          AND ADA.EVENT_ID                  = XE.EVENT_ID
                                 AND xe.entity_id = xah.entity_id
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND gjh.status = 'P'
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xah.ae_header_id = xdl.ae_header_id
                                 AND xdl.ae_line_num = xdl.ae_line_num
                                 AND xdl.source_distribution_type =
                                        'AR_DISTRIBUTIONS_ALL'
                                 AND xdl.source_distribution_id_num_1 =
                                        adda.line_id
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
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
                                           'YYYY-MM-DD HH24:MI:SS')
                                 AND gir.je_header_id = gjh.je_header_id);
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            */
            ELSIF p_table_name = 'AP_SUPPLIER_SITES_ALL'
            THEN                                              --NEED TO UPDATE
               l_count := 1;
            /*
            ELSIF p_table_name = 'AP_INVOICES_ALL'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
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
                           WHERE     aila.invoice_id = p_key_value1 --o1       --p_key_value1
                                 --        and AIA.INVOICE_ID                 = AILA.INVOICE_ID
                                 AND aila.invoice_id = aida.invoice_id
                                 AND aila.line_number =
                                        aida.invoice_line_number
                                 AND aida.invoice_distribution_id =
                                        xdl.source_distribution_id_num_1
                                 AND xdl.source_distribution_type =
                                        'AP_INV_DIST'
                                 AND xdl.ae_header_id = xah.ae_header_id
                                 AND xdl.application_id = xah.application_id
                                 AND xdl.ae_line_num = xal.ae_line_num
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xe.entity_id = xah.entity_id
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                 --AND xal.creation_date <= nvl(TO_DATE(p_collection_time, 'YYYY-MM-DD HH24:MI:SS'),
                                 --                                     xal.creation_date)



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
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            ELSIF p_table_name = 'AP_INVOICE_LINES_ALL'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
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
                           WHERE     aida.invoice_id = p_key_value1 --o1
                                 AND aida.invoice_line_number = p_key_value2 --o2
                                 --            and AILA.INVOICE_ID                   = AIDA.INVOICE_ID
                                 --          and AILA.LINE_NUMBER                  = AIDA.INVOICE_LINE_NUMBER
                                 AND aida.invoice_distribution_id =
                                        xdl.source_distribution_id_num_1
                                 AND xdl.source_distribution_type =
                                        'AP_INV_DIST'
                                 AND xdl.ae_header_id = xah.ae_header_id
                                 AND xdl.application_id = xah.application_id
                                 AND xdl.ae_line_num = xal.ae_line_num
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xe.entity_id = xah.entity_id
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                 --                                AND xal.creation_date <= nvl(TO_DATE(p_collection_time, 'YYYY-MM-DD HH24:MI:SS'),
                                 --                                                                xal.creation_date)

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
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            ELSIF p_table_name = 'AP_INVOICE_DISTRIBUTIONS_ALL'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
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
                           WHERE     xdl.source_distribution_id_num_1 = p_key_value1 --o1 -- INVOICE_DISTRIBUTION_ID is pk1
                                 --        AND AIDA.INVOICE_DISTRIBUTION_ID        = XDL.SOURCE_DISTRIBUTION_ID_NUM_1

                                 AND xdl.source_distribution_type =
                                        'AP_INV_DIST'
                                 AND xdl.ae_header_id = xah.ae_header_id
                                 AND xdl.application_id = xah.application_id
                                 AND xdl.ae_line_num = xal.ae_line_num
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xe.entity_id = xah.entity_id
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
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
                                           'YYYY-MM-DD HH24:MI:SS')
                                 AND gir.je_header_id = gjh.je_header_id
                                 AND gjh.status = 'P');
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;

            ELSIF p_table_name = 'AP_PAYMENT_SCHEDULES_ALL'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM ap_invoice_payments_all aipa,
                                 xla_events xe,
                                 xla_ae_headers xah,
                                 xla_ae_lines xal
                           WHERE     aipa.invoice_id = p_key_value1 --o1
                                 AND aipa.payment_num = p_key_value2 --o2
                                 AND aipa.accounting_event_id = xe.event_id
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xe.entity_id = xah.entity_id
                                 AND xah.ae_header_id = xal.ae_header_id
                                 -- to check for p_collection_time greater than xla posted date


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
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            ELSIF p_table_name = 'AP_INVOICE_PAYMENTS_ALL'
            THEN
               -- l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM xla_events xe,
                                 xla_ae_headers xah,
                                 xla_ae_lines xal
                           WHERE     xe.event_id = p_key_value1 --o1 -- ACCOUNTING_EVENT_ID is pk1
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xe.entity_id = xah.entity_id
                                 AND xah.ae_header_id = xal.ae_header_id
                                 -- to check for p_collection_time greater than xla posted date


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
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
                        ELSIF p_table_name = 'AP_CHECKS_ALL'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM ap_invoice_payments_all aipa,
                                 xla_events xe,
                                 xla_ae_headers xah,
                                 xla_ae_lines xal
                           WHERE     aipa.check_id = p_key_value1 --o1
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xe.entity_id = xah.entity_id
                                 AND xah.ae_header_id = xal.ae_header_id
                                 -- to check for p_collection_time greater than xla posted date


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
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            ELSIF p_table_name = 'AP_PAYMENT_HISTORY_ALL'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM xla_events xe,
                                 xla_ae_headers xah,
                                 xla_ae_lines xal
                           WHERE     xe.event_id = p_key_value1 --o1 -- ACCOUNTING_EVENT_ID is pk1
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xe.entity_id = xah.entity_id
                                 AND xah.ae_header_id = xal.ae_header_id
                                 -- to check for p_collection_time greater than xla posted date


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
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;

            ELSIF p_table_name = 'OE_PRICE_ADJUSTMENTS'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
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
                               WHERE     oha.header_id = p_key_value1--- o1
                                     AND oola.line_id = p_key_value2 --o2
                                     AND oha.header_id = oola.header_id
                                     --        AND OPA.HEADER_ID                   = OHA.HEADER_ID
                                     --        AND OPA.LINE_ID                     = OOLA.LINE_ID
                                     AND oha.header_id = wdd.source_header_id
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
                                               'YYYY-MM-DD HH24:MI:SS')
                                     AND gir.je_header_id = gjh.je_header_id
                                     AND gjh.status = 'P')
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
                               WHERE     oha.header_id = p_key_value1 --o1
                                     AND oola.line_id = p_key_value2 --o2
                                     AND oha.header_id = oola.header_id
                                     --        AND OPA.HEADER_ID                   = OHA.HEADER_ID
                                     --        AND OPA.LINE_ID                     = OOLA.LINE_ID
                                     AND oha.header_id =
                                            rsl.oe_order_header_id
                                     AND oola.line_id = rsl.oe_order_line_id
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
                                     AND xdl.ae_header_id = xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
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
                                               'YYYY-MM-DD HH24:MI:SS')
                                     AND gir.je_header_id = gjh.je_header_id
                                     AND gjh.status = 'P')
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
                               WHERE     oha.header_id = p_key_value1 --o1
                                     AND oola.line_id = p_key_value2 --o2
                                     AND oha.header_id = oola.header_id
                                     --    AND OPA.HEADER_ID                          = OHA.HEADER_ID
                                     --    AND OPA.LINE_ID                            = OOLA.LINE_ID
                                     AND oha.header_id = odss.header_id
                                     AND odss.line_id = oola.line_id
                                     AND odss.po_header_id = rsl.po_header_id
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
                                     AND xdl.ae_header_id = xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
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
                                               'YYYY-MM-DD HH24:MI:SS')
                                     AND gir.je_header_id = gjh.je_header_id
                                     AND gjh.status = 'P'));
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            */
            /*     ELSIF p_table_name = 'OE_ORDER_HEADERS_ALL' THEN
                     l_count := xxccil_cp_check(p_prog_val, l_count);
             --l_count := xxccil_client_superuser_access(p_client_id, l_count);
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
                                         wdd.source_header_id = o1
                                     AND wdd.delivery_detail_id = mmt.picking_line_id
                                     AND wdd.source_line_id = mmt.trx_source_line_id
                                     AND mtt.transaction_type_id = mmt.transaction_type_id
                                     AND mtt.transaction_action_id = mmt.transaction_action_id
                                     AND mmt.transaction_id = mta.transaction_id
                                     AND mta.inv_sub_ledger_id = xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type = 'MTL_TRANSACTION_ACCOUNTS'
                                     AND xdl.ae_header_id = xah.ae_header_id
                                     AND xdl.application_id = xah.application_id

                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code = 'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     AND xal.gl_sl_link_id = gir.gl_sl_link_id


                                     AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                     ),
                                                                                  'YYYY-MM-DD HH24:MI:SS'),
                                                                          to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
         'YYYY-MM-DD HH24:MI:SS')
                                     AND gir.je_header_id = gjh.je_header_id
                                     AND gjh.status = 'P'
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
                                         rsl.oe_order_header_id = o1
                                     AND rsl.shipment_line_id = rt.shipment_line_id
                                     AND rt.transaction_type = 'DELIVER'
                                     AND rt.transaction_id = mmt.rcv_transaction_id
                                     AND mmt.transaction_id = mta.transaction_id
                                     AND mta.inv_sub_ledger_id = xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type = 'MTL_TRANSACTION_ACCOUNTS'
                                     AND xdl.ae_header_id = xah.ae_header_id
                                     AND xdl.application_id = xah.application_id

                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code = 'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     AND xal.gl_sl_link_id = gir.gl_sl_link_id


                                     AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                     ),
                                                                                  'YYYY-MM-DD HH24:MI:SS'),
                                                                          to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
         'YYYY-MM-DD HH24:MI:SS')
                                     AND gir.je_header_id = gjh.je_header_id
                                     AND gjh.status = 'P'
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
                                         odss.header_id = o1
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

                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code = 'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     AND xal.gl_sl_link_id = gir.gl_sl_link_id


                                     AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                     ),
                                                                                  'YYYY-MM-DD HH24:MI:SS'),
                                                                          to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
         'YYYY-MM-DD HH24:MI:SS')
                                     AND gir.je_header_id = gjh.je_header_id
                                     AND gjh.status = 'P'
                             ) );

                     ELSE
                         l_status_mess := ( '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
                                            || p_prog_val );
                     END IF;
 /*
                 ELSIF p_table_name = 'OE_ORDER_LINES_ALL' THEN
                     l_count := xxccil_cp_check(p_prog_val, l_count);
             --l_count := xxccil_client_superuser_access(p_client_id, l_count);
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
                                         wdd.source_line_id = o1
                               --      AND OOLA.HEADER_ID                 = OHA.HEADER_ID
                                     AND oha.header_id = wdd.source_header_id
                             --        AND OOLA.LINE_ID                   = WDD.SOURCE_LINE_ID
                                     AND wdd.delivery_detail_id = mmt.picking_line_id
                                     AND wdd.source_line_id = mmt.trx_source_line_id
                                     AND mtt.transaction_type_id = mmt.transaction_type_id
                                     AND mtt.transaction_action_id = mmt.transaction_action_id
                                     AND mmt.transaction_id = mta.transaction_id
                                     AND mta.inv_sub_ledger_id = xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type = 'MTL_TRANSACTION_ACCOUNTS'
                                     AND xdl.ae_header_id = xah.ae_header_id
                                     AND xdl.application_id = xah.application_id

                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code = 'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     AND xal.gl_sl_link_id = gir.gl_sl_link_id


                                     AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                     ),
                                                                                  'YYYY-MM-DD HH24:MI:SS'),
                                                                          to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
         'YYYY-MM-DD HH24:MI:SS')
                                     AND gir.je_header_id = gjh.je_header_id
                                     AND gjh.status = 'P'
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
                                         rsl.oe_order_line_id = o1
                                 --    AND OOLA.HEADER_ID                  = OHA.HEADER_ID
                                     AND oha.header_id = rsl.oe_order_header_id
                                 --    AND OOLA.LINE_ID                    = RSL.OE_ORDER_LINE_ID
                                     AND rsl.shipment_line_id = rt.shipment_line_id
                                     AND rt.transaction_type = 'DELIVER'
                                     AND rt.transaction_id = mmt.rcv_transaction_id
                                     AND mmt.transaction_id = mta.transaction_id
                                     AND mta.inv_sub_ledger_id = xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type = 'MTL_TRANSACTION_ACCOUNTS'
                                     AND xdl.ae_header_id = xah.ae_header_id
                                     AND xdl.application_id = xah.application_id

                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code = 'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     AND xal.gl_sl_link_id = gir.gl_sl_link_id


                                     AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                     ),
                                                                                  'YYYY-MM-DD HH24:MI:SS'),
                                                                          to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
         'YYYY-MM-DD HH24:MI:SS')
                                     AND gir.je_header_id = gjh.je_header_id
                                     AND gjh.status = 'P'
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
                               --      AND OOLA.HEADER_ID                  = OHA.HEADER_ID
                                     AND oha.header_id = odss.header_id
                                 --    AND ODSS.LINE_ID                    = OOLA.LINE_ID
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

                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code = 'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     AND xal.gl_sl_link_id = gir.gl_sl_link_id


                                     AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                     ),
                                                                                  'YYYY-MM-DD HH24:MI:SS'),
                                                                          to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
         'YYYY-MM-DD HH24:MI:SS')
                                     AND gir.je_header_id = gjh.je_header_id
                                     AND gjh.status = 'P'
                             ) );

                     ELSE
                         l_status_mess := ( '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
                                            || p_prog_val );
                     END IF;
 */
            /*
                       ELSIF p_table_name = 'FA_ADJUSTMENTS'
                       THEN
                          --l_count := xxccil_cp_check (p_prog_val, l_count);

                          --l_count := xxccil_client_superuser_access(p_client_id, l_count);

                          --         IF l_count = 1
                          --         THEN
                          SELECT COUNT (1)
                            INTO l_count
                            FROM DUAL
                           WHERE EXISTS
                                    (SELECT 1
                                       FROM apps.fa_transaction_headers fth,
                                            apps.xla_events xev,
                                            apps.xla_ae_headers xah,
                                            apps.xla_distribution_links xdl,
                                            apps.xla_ae_lines xal,
                                            apps.gl_je_headers gjh,
                                            apps.gl_import_references gir,
                                            apps.xla_transaction_entities xte
                                      WHERE     fth.transaction_header_id = p_key_value1 --o1
                                            AND fth.event_id = xah.event_id
                                            AND xah.event_id = xev.event_id
                                            AND xev.entity_id = xte.entity_id
                                            AND xte.source_id_int_1 =
                                                   fth.transaction_header_id
                                            AND xah.ae_header_id = xal.ae_header_id
                                            AND xah.ae_header_id = xdl.ae_header_id
                                            AND xdl.ae_line_num = xal.ae_line_num
                                            AND xdl.event_id = xah.event_id
                                            AND xdl.source_distribution_id_num_1 =
                                                   fth.transaction_header_id
                                            AND xah.gl_transfer_status_code = 'Y'
                                            AND xal.gl_sl_link_id = gir.gl_sl_link_id
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
                                                      'YYYY-MM-DD HH24:MI:SS')
                                            AND gjh.je_header_id = gir.je_header_id
                                            AND gjh.status = 'P');
                       --         ELSE
                       --            l_status_mess :=
                       --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
                       --                || p_prog_val);
                       --         END IF;
                       ELSIF p_table_name = 'FA_ASSET_HISTORY'
                       THEN
                          --l_count := xxccil_cp_check (p_prog_val, l_count);

                          --l_count := xxccil_client_superuser_access(p_client_id, l_count);

                          --         IF l_count = 1
                          --         THEN
                          SELECT COUNT (1)
                            INTO l_count
                            FROM DUAL
                           WHERE EXISTS
                                    (SELECT 1
                                       FROM apps.fa_transaction_headers fth,
                                            apps.fa_adjustments fa,
                                            apps.xla_events xev,
                                            apps.xla_ae_headers xah,
                                            apps.xla_distribution_links xdl,
                                            apps.xla_ae_lines xal,
                                            apps.gl_je_headers gjh,
                                            apps.gl_import_references gir,
                                            apps.xla_transaction_entities xte
                                      WHERE     fth.asset_id = p_key_value1 --o1
                                            AND fth.transaction_header_id = p_key_value2 --o2 -- TRANSACTION_HEADER_ID_IN is pk2
                                            AND fth.transaction_header_id =
                                                   fa.transaction_header_id
                                            --        AND FTH.TRANSACTION_HEADER_ID        = FAH.TRANSACTION_HEADER_ID_IN
                                            --        AND FAH.ASSET_ID                     = FTH.ASSET_ID
                                            AND fth.event_id = xah.event_id
                                            AND xah.event_id = xev.event_id
                                            AND xev.entity_id = xte.entity_id
                                            AND xah.ae_header_id = xal.ae_header_id
                                            AND xah.ae_header_id = xdl.ae_header_id
                                            AND xdl.ae_line_num = xal.ae_line_num
                                            AND xdl.event_id = xah.event_id
                                            AND xdl.source_distribution_id_num_1 =
                                                   fth.transaction_header_id
                                            AND xah.gl_transfer_status_code = 'Y'
                                            AND xal.gl_sl_link_id = gir.gl_sl_link_id
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
                                                      'YYYY-MM-DD HH24:MI:SS')
                                            AND gjh.je_header_id = gir.je_header_id
                                            AND gjh.status = 'P');
                       --         ELSE
                       --            l_status_mess :=
                       --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
                       --                || p_prog_val);
                       --         END IF;
                       ELSIF p_table_name = 'FA_BOOKS'
                       THEN
                          --l_count := xxccil_cp_check (p_prog_val, l_count);

                          --l_count := xxccil_client_superuser_access(p_client_id, l_count);
                          --         IF l_count = 1
                          --         THEN
                          SELECT COUNT (1)
                            INTO l_count
                            FROM DUAL
                           WHERE EXISTS
                                    (SELECT 1
                                       FROM apps.fa_transaction_headers fth,
                                            apps.fa_adjustments fa,
                                            apps.xla_events xev,
                                            apps.xla_ae_headers xah,
                                            apps.xla_distribution_links xdl,
                                            apps.xla_ae_lines xal,
                                            apps.gl_je_headers gjh,
                                            apps.gl_import_references gir,
                                            apps.xla_transaction_entities xte
                                      WHERE     fth.transaction_header_id = p_key_value1 --o1
                                            AND fth.transaction_header_id =
                                                   fa.transaction_header_id
                                            AND fth.event_id = xah.event_id
                                            AND xah.event_id = xev.event_id
                                            AND xev.entity_id = xte.entity_id
                                            AND xah.ae_header_id = xal.ae_header_id
                                            AND xah.ae_header_id = xdl.ae_header_id
                                            AND xdl.ae_line_num = xal.ae_line_num
                                            AND xdl.event_id = xah.event_id
                                            AND xdl.source_distribution_id_num_1 =
                                                   fth.transaction_header_id
                                            AND xah.gl_transfer_status_code = 'Y'
                                            AND xal.gl_sl_link_id = gir.gl_sl_link_id
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
                                                      'YYYY-MM-DD HH24:MI:SS')
                                            AND gjh.je_header_id = gir.je_header_id
                                            AND gjh.status = 'P');
                       --         ELSE
                       --            l_status_mess :=
                       --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
                       --                || p_prog_val);
                       --         END IF;
                       ELSIF p_table_name = 'FA_DEPRN_DETAIL'
                       THEN
                          --l_count := xxccil_cp_check (p_prog_val, l_count);

                          --l_count := xxccil_client_superuser_access(p_client_id, l_count);
                          --         IF l_count = 1
                          --         THEN
                          SELECT COUNT (1)
                            INTO l_count
                            FROM DUAL
                           WHERE EXISTS
                                    (SELECT 1
                                       FROM apps.fa_deprn_detail fds,
                                            apps.xla_events xev,
                                            apps.xla_ae_headers xah,
                                            apps.xla_distribution_links xdl,
                                            apps.xla_ae_lines xal,
                                            apps.gl_je_headers gjh,
                                            apps.gl_import_references gir,
                                            apps.xla_transaction_entities xte
                                      WHERE     xdl.source_distribution_id_char_4 = p_key_value1 --o1 --BOOK_TYPE_CODE  as pk1
                                            AND xdl.source_distribution_id_num_1 = p_key_value2 --o2 --ASSET_ID   as pk2
                                            AND xdl.source_distribution_id_num_2 = p_key_value3 --o3 -- PERIOD_COUNTER as pk3
                                            --     AND FDS.EVENT_ID                     = XAH.EVENT_ID



                                            AND xah.event_id = xev.event_id
                                            AND xev.entity_id = xte.entity_id
                                            AND xte.entity_code = 'DEPRECIATION'
                                            AND xah.ae_header_id = xal.ae_header_id
                                            AND xah.ae_header_id = xdl.ae_header_id
                                            AND xdl.ae_line_num = xal.ae_line_num
                                            AND xdl.event_id = xah.event_id
                                            --    AND XDL.SOURCE_DISTRIBUTION_ID_NUM_1 = FDS.ASSET_ID
                                            --    AND XDL.SOURCE_DISTRIBUTION_ID_CHAR_4 = FDS.BOOK_TYPE_CODE
                                            --    AND XDL.SOURCE_DISTRIBUTION_ID_NUM_2 = FDS.PERIOD_COUNTER
                                            --    AND XDL.SOURCE_DISTRIBUTION_ID_NUM_3 = FDS.DEPRN_RUN_ID
                                            AND xah.gl_transfer_status_code = 'Y'
                                            AND xal.gl_sl_link_id = gir.gl_sl_link_id
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
                                                      'YYYY-MM-DD HH24:MI:SS')
                                            AND gjh.je_header_id = gir.je_header_id
                                            AND gjh.status = 'P');
                       --         ELSE
                       --            l_status_mess :=
                       --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
                       --                || p_prog_val);
                       --         END IF;
                       ELSIF p_table_name = 'FA_DISTRIBUTION_HISTORY'
                       THEN
                          --l_count := xxccil_cp_check (p_prog_val, l_count);

                          --l_count := xxccil_client_superuser_access(p_client_id, l_count);
                          --         IF l_count = 1
                          --         THEN
                          SELECT COUNT (1)
                            INTO l_count
                            FROM DUAL
                           WHERE (   EXISTS
                                        (SELECT 1
                                           FROM apps.fa_transaction_headers fth,
                                                apps.fa_adjustments fa,
                                                apps.xla_events xev,
                                                apps.xla_ae_headers xah,
                                                apps.xla_distribution_links xdl,
                                                apps.xla_ae_lines xal,
                                                apps.gl_je_headers gjh,
                                                apps.gl_import_references gir,
                                                apps.xla_transaction_entities xte
                                          WHERE     fth.transaction_header_id = p_key_value1 --o1 --  TRANSACTION_HEADER_ID_IN as pk1
                                                --      AND FDH.TRANSACTION_HEADER_ID_IN     = FTH.TRANSACTION_HEADER_ID
                                                AND fth.transaction_header_id =
                                                       fa.transaction_header_id
                                                AND fth.event_id = xah.event_id
                                                AND xah.event_id = xev.event_id
                                                AND xev.entity_id = xte.entity_id
                                                AND xte.source_id_int_1 =
                                                       fth.transaction_header_id
                                                AND xah.ae_header_id = xal.ae_header_id
                                                AND xah.ae_header_id = xdl.ae_header_id
                                                AND xdl.ae_line_num = xal.ae_line_num
                                                AND xdl.event_id = xah.event_id
                                                AND xdl.source_distribution_id_num_1 =
                                                       fth.transaction_header_id
                                                AND xah.gl_transfer_status_code = 'Y'
                                                AND xal.gl_sl_link_id =
                                                       gir.gl_sl_link_id
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
                                                          'YYYY-MM-DD HH24:MI:SS')
                                                AND gjh.je_header_id = gir.je_header_id
                                                AND gjh.status = 'P')
                                  OR EXISTS
                                        (SELECT 1
                                           FROM apps.fa_transaction_headers fth,
                                                apps.fa_adjustments fa,
                                                apps.xla_events xev,
                                                apps.xla_ae_headers xah,
                                                apps.xla_distribution_links xdl,
                                                apps.xla_ae_lines xal,
                                                apps.gl_je_headers gjh,
                                                apps.gl_import_references gir,
                                                apps.xla_transaction_entities xte
                                          WHERE     fth.transaction_header_id = p_key_value2 --o2 --  TRANSACTION_HEADER_ID_OUT as pk2
                                                --        AND FDH.TRANSACTION_HEADER_ID_OUT        = FTH.TRANSACTION_HEADER_ID
                                                AND fth.transaction_header_id =
                                                       fa.transaction_header_id
                                                AND fth.event_id = xah.event_id
                                                AND xah.event_id = xev.event_id
                                                AND xev.entity_id = xte.entity_id
                                                AND xte.source_id_int_1 =
                                                       fth.transaction_header_id
                                                AND xah.ae_header_id = xal.ae_header_id
                                                AND xah.ae_header_id = xdl.ae_header_id
                                                AND xdl.ae_line_num = xal.ae_line_num
                                                AND xdl.event_id = xah.event_id
                                                AND xdl.source_distribution_id_num_1 =
                                                       fth.transaction_header_id
                                                AND xah.gl_transfer_status_code = 'Y'
                                                AND xal.gl_sl_link_id =
                                                       gir.gl_sl_link_id
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
                                                          'YYYY-MM-DD HH24:MI:SS')
                                                AND gjh.je_header_id = gir.je_header_id
                                                AND gjh.status = 'P'));
                       --         ELSE
                       --            l_status_mess :=
                       --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
                       --                || p_prog_val);
                       --         END IF;
                       ELSIF p_table_name = 'FA_RETIREMENTS'
                       THEN
                          --l_count := xxccil_cp_check (p_prog_val, l_count);

                          --l_count := xxccil_client_superuser_access(p_client_id, l_count);
                          --         IF l_count = 1
                          --         THEN
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
                                                     --    AND FR.TRANSACTION_HEADER_ID_IN     = FTH.TRANSACTION_HEADER_ID
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


                                                         AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                                         ),
                                                                                                      'YYYY-MM-DD HH24:MI:SS'),
                                                                                              to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
                             'YYYY-MM-DD HH24:MI:SS')
                                                         AND gjh.je_header_id = gir.je_header_id
                                                         AND gjh.status = 'P'
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
                                                             fth.transaction_header_id = o2        -- TRANSACTION_HEADER_ID_OUT as pk2
                                                   --      AND FR.TRANSACTION_HEADER_ID_OUT    = FTH.TRANSACTION_HEADER_ID
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


                                                         AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                                         ),
                                                                                                      'YYYY-MM-DD HH24:MI:SS'),
                                                                                              to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
                             'YYYY-MM-DD HH24:MI:SS')
                                                         AND gjh.je_header_id = gir.je_header_id
                                                         AND gjh.status = 'P'
                                                 ) );*/

            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            /*
            ELSIF p_table_name = 'FA_TRANSACTION_HEADERS'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
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
                                              AND xah.event_id = o2
                              --    AND FTH.TRANSACTION_HEADER_ID       = FA.TRANSACTION_HEADER_ID
                              --    AND FTH.EVENT_ID                    = XAH.EVENT_ID
                                              AND xah.event_id = xev.event_id
                                              AND xev.entity_id = xte.entity_id
                                              AND xah.ae_header_id = xal.ae_header_id
                                              AND xah.ae_header_id = xdl.ae_header_id
                                              AND xdl.ae_line_num = xal.ae_line_num
                                              AND xdl.event_id = xah.event_id
                              --    AND XDL.SOURCE_DISTRIBUTION_ID_NUM_1 = FTH.TRANSACTION_HEADER_ID
                                              AND xah.gl_transfer_status_code = 'Y'
                                              AND xal.gl_sl_link_id = gir.gl_sl_link_id


                                              AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                              ),
                                                                                           'YYYY-MM-DD HH24:MI:SS'),
                                                                                   to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
                  'YYYY-MM-DD HH24:MI:SS')
                                              AND gjh.je_header_id = gir.je_header_id
                                              AND gjh.status = 'P'
                                      ); */

            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            /*
            ELSIF p_table_name = 'FA_DEPRN_SUMMARY'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
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
                                                 apps.xla_events               xev,
                                                 apps.xla_ae_headers           xah,
                                                 apps.xla_distribution_links   xdl,
                                                 apps.xla_ae_lines             xal,
                                                 apps.gl_je_headers            gjh,
                                                 apps.gl_import_references     gir,
                                                 apps.xla_transaction_entities xte
                                             WHERE
                                                     xdl.source_distribution_id_char_4 = o1
                                                 AND xdl.source_distribution_id_num_1 = o2
                                                 AND xdl.source_distribution_id_num_2 = o3
                                 --    AND FDS.EVENT_ID                        = XAH.EVENT_ID
                                                 AND xah.event_id = xev.event_id
                                                 AND xev.entity_id = xte.entity_id
                                                 AND xte.entity_code = 'DEPRECIATION'
                                                 AND xah.ae_header_id = xal.ae_header_id
                                                 AND xah.ae_header_id = xdl.ae_header_id
                                                 AND xdl.ae_line_num = xal.ae_line_num
                                                 AND xdl.event_id = xah.event_id
                                 --    AND XDL.SOURCE_DISTRIBUTION_ID_NUM_1    = FDS.ASSET_ID
                                 --    AND XDL.SOURCE_DISTRIBUTION_ID_CHAR_4   = FDS.BOOK_TYPE_CODE
                                 --    AND XDL.SOURCE_DISTRIBUTION_ID_NUM_2    = FDS.PERIOD_COUNTER
                                 --    AND XDL.SOURCE_DISTRIBUTION_ID_NUM_3    = FDS.DEPRN_RUN_ID
                                                 AND xah.gl_transfer_status_code = 'Y'
                                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id


                                                 AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                                 ),
                                                                                              'YYYY-MM-DD HH24:MI:SS'),
                                                                                      to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
                     'YYYY-MM-DD HH24:MI:SS')
                                                 AND gjh.je_header_id = gir.je_header_id
                                                 AND gjh.status = 'P'
                                         ); */

            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            ELSIF p_table_name = 'AR_DISTRIBUTIONS_ALL'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM xla_events xe,
                                 xla_ae_headers xah,
                                 xla_distribution_links xdl,
                                 xla_ae_lines xal
                           WHERE     xdl.source_distribution_id_num_1 =
                                        p_key_value1    -- o1 --LINE_ID is PK1
                                 AND xdl.source_distribution_type =
                                        'AR_DISTRIBUTIONS_ALL'
                                 AND xah.ae_header_id = xdl.ae_header_id
                                 AND xdl.ae_line_num = xdl.ae_line_num
                                 AND xe.entity_id = xah.entity_id
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xah.ae_header_id = xal.ae_header_id
                                 -- to check for p_collection_time greater than xla posted date


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
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            ELSIF p_table_name = 'XLA_DISTRIBUTION_LINKS'
            THEN
               -- l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM xla_ae_headers xah, xla_ae_lines xal
                           WHERE     xah.ae_header_id = xal.ae_header_id
                                 AND xah.ae_header_id = p_key_value1 --o1 -- AE_HEADER_ID is pk1
                                 AND xal.ae_line_num = p_key_value2 --o2 --AE_LINE_NUM is pk2
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 -- to check for p_collection_time greater than xla posted date



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
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            -----changes start for gia spacific table
            /*
            ELSIF p_table_name = 'XLA_EVENTS'
            THEN                                                        --Giea
               --  l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM xla_events xe,
                                 xla_ae_headers xah,
                                 xla_ae_lines xal,
                                 xla_distribution_links xdl
                           WHERE     xe.event_id = p_key_value1--o1       -- EVENT_ID is pk1
                                 AND xe.entity_id = xah.entity_id
                                 AND xe.event_id = xah.event_id
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xdl.ae_header_id = xah.ae_header_id
                                 AND xdl.ae_line_num = xal.ae_line_num
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 -- to check for p_collection_time greater than xla posted date
                                 AND xal.last_update_date <=
                                        NVL (
                                           TO_DATE (p_collection_time,
                                                    'YYYY-MM-DD HH24:MI:SS'),
                                           xal.last_update_date));
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            */
            ELSIF p_table_name = 'XLA_AE_LINES'
            THEN                                                        --Giea
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM xla_ae_lines xal, xla_ae_headers xah
                           WHERE     xal.ae_header_id = p_key_value1 --o1 -- AE_HEADER_ID is pk1
                                 AND xal.ae_line_num = p_key_value2 --o2 --AE_LINE_NUM    is pk2
                                 AND xal.ae_header_id = xah.ae_header_id
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 -- to check for p_collection_time greater than xla posted date



                                 AND xal.last_update_date <=
                                        NVL (
                                           TO_DATE (p_collection_time,
                                                    'YYYY-MM-DD HH24:MI:SS'),
                                           xal.last_update_date));
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            -- Commented Below tables as per requirement by Aditya R on 17-Jun-2025 CRQ  CHG0230785
            /*ELSIF p_table_name = 'XXC10679_IMP_BOE_HDR'
            THEN                                                        --Giea
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE (   EXISTS
                             (SELECT 1
                                FROM xxc10679_imp_boe_inv xibi,
                                     xxc10584_imp_inv_hdr xiih,
                                     rcv_transactions rt,
                                     rcv_receiving_sub_ledger rrsl,
                                     xla_distribution_links xdl,
                                     xla_events xe,
                                     xla_ae_headers xah,
                                     xla_ae_lines xal
                               WHERE     xibi.jobno = o1       -- JOBNO is pk1
                                     AND xibi.org_id = o2    -- ORG_ID  is pk2
                                     AND xiih.invnosupl = xibi.invnosupl
                                     AND rt.shipment_header_id =
                                            xiih.shipment_header_id
                                     AND rt.transaction_id =
                                            rrsl.rcv_transaction_id
                                     AND rrsl.rcv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'RCV_RECEIVING_SUB_LEDGER'
                                     AND xdl.ae_header_id = xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     -- to check for p_collection_time greater than xla posted date


                                     AND xal.last_update_date <=
                                            NVL (
                                               TO_DATE (
                                                  p_collection_time,
                                                  'YYYY-MM-DD HH24:MI:SS'),
                                               xal.last_update_date))
                       OR EXISTS
                             (SELECT 1
                                FROM xxc10679_imp_boe_inv xibi,
                                     xxc10584_imp_inv_hdr xiih,
                                     rcv_transactions rt,
                                     mtl_material_transactions mmt,
                                     mtl_transaction_accounts mta,
                                     xla_transaction_entities xte,
                                     xla_events xe,
                                     xla_distribution_links xdl,
                                     xla_ae_headers xah,
                                     xla_ae_lines xal
                               WHERE     xibi.jobno = o1       -- JOBNO is pk1
                                     AND xibi.org_id = o2    -- ORG_ID  is pk2
                                     AND xiih.invnosupl = xibi.invnosupl
                                     AND rt.shipment_header_id =
                                            xiih.shipment_header_id
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
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     -- to check for p_collection_time greater than xla posted date


                                     AND xal.last_update_date <=
                                            NVL (
                                               TO_DATE (
                                                  p_collection_time,
                                                  'YYYY-MM-DD HH24:MI:SS'),
                                               xal.last_update_date)));
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            ELSIF p_table_name = 'XXC10679_IMP_BOE_INV'
            THEN                                                        --Giea
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE (   EXISTS
                             (SELECT 1
                                FROM xxc10679_imp_boe_hdr xibh,
                                     xxc10584_imp_inv_hdr xiih,
                                     rcv_transactions rt,
                                     rcv_receiving_sub_ledger rrsl,
                                     xla_distribution_links xdl,
                                     xla_events xe,
                                     xla_ae_headers xah,
                                     xla_ae_lines xal
                               WHERE     xibh.jobno = o1       -- JOBNO is pk1
                                     AND xibh.org_id = o2    -- ORG_ID  is pk2
                                     AND xiih.invnosupl = o3 -- INVNOSUPL is pk3
                                     AND rt.shipment_header_id =
                                            xiih.shipment_header_id
                                     AND rt.transaction_id =
                                            rrsl.rcv_transaction_id
                                     AND rrsl.rcv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'RCV_RECEIVING_SUB_LEDGER'
                                     AND xdl.ae_header_id = xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     -- to check for p_collection_time greater than xla posted date


                                     AND xal.last_update_date <=
                                            NVL (
                                               TO_DATE (
                                                  p_collection_time,
                                                  'YYYY-MM-DD HH24:MI:SS'),
                                               xal.last_update_date))
                       OR EXISTS
                             (SELECT 1
                                FROM xxc10679_imp_boe_hdr xibh,
                                     xxc10584_imp_inv_hdr xiih,
                                     rcv_transactions rt,
                                     mtl_material_transactions mmt,
                                     mtl_transaction_accounts mta,
                                     xla_transaction_entities xte,
                                     xla_events xe,
                                     xla_distribution_links xdl,
                                     xla_ae_headers xah,
                                     xla_ae_lines xal
                               WHERE     xibh.jobno = o1       -- JOBNO is pk1
                                     AND xibh.org_id = o2    -- ORG_ID  is pk2
                                     AND xiih.invnosupl = o3 -- INVNOSUPL is pk3
                                     AND rt.shipment_header_id =
                                            xiih.shipment_header_id
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
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     -- to check for p_collection_time greater than xla posted date


                                     AND xal.last_update_date <=
                                            NVL (
                                               TO_DATE (
                                                  p_collection_time,
                                                  'YYYY-MM-DD HH24:MI:SS'),
                                               xal.last_update_date)));
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            ELSIF p_table_name = 'XXC10679_IMP_BOE_PARTS'
            THEN                                                   --Giea XIBP
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE (   EXISTS
                             (SELECT 1
                                FROM xxc10679_imp_boe_parts xibp,
                                     xxc10679_imp_boe_hdr xibh,
                                     xxc10679_imp_boe_inv xibi,
                                     xxc10584_imp_inv_hdr xiih,
                                     rcv_transactions rt,
                                     rcv_receiving_sub_ledger rrsl,
                                     xla_distribution_links xdl,
                                     xla_events xe,
                                     xla_ae_headers xah,
                                     xla_ae_lines xal
                               WHERE     xibp.jobno = o1       -- jobno is pk1
                                     AND xibp.org_id = o2      --org_id is pk2
                                     AND xibp.invnosupl = o3 -- INVNOSUPL is pk3
                                     AND xibp.bpsrno = o4      --BPSRNO is pk4
                                     AND xibp.jobno = xibh.jobno
                                     AND xibp.org_id = xibh.org_id
                                     AND xibp.invnosupl = xiih.invnosupl
                                     AND xibp.invnosupl = xibi.invnosupl
                                     AND xibi.jobno = xibh.jobno
                                     AND xibi.org_id = xibh.org_id
                                     AND xiih.invnosupl = xibi.invnosupl
                                     AND rt.shipment_header_id =
                                            xiih.shipment_header_id
                                     AND rt.transaction_id =
                                            rrsl.rcv_transaction_id
                                     AND rrsl.rcv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'RCV_RECEIVING_SUB_LEDGER'
                                     AND xdl.ae_header_id = xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     -- to check for p_collection_time greater than xla posted date


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
                                               'YYYY-MM-DD HH24:MI:SS'))
                       OR EXISTS
                             (SELECT 1
                                FROM xxc10679_imp_boe_parts xibp,
                                     xxc10679_imp_boe_hdr xibh,
                                     xxc10584_imp_inv_hdr xiih,
                                     xxc10679_imp_boe_inv xibi,
                                     rcv_transactions rt,
                                     mtl_material_transactions mmt,
                                     mtl_transaction_accounts mta,
                                     xla_transaction_entities xte,
                                     xla_events xe,
                                     xla_distribution_links xdl,
                                     xla_ae_headers xah,
                                     xla_ae_lines xal
                               WHERE     xibp.jobno = o1       -- jobno is pk1
                                     AND xibp.org_id = o2      --org_id is pk2
                                     AND xibp.invnosupl = o3 -- INVNOSUPL is pk3
                                     AND xibp.bpsrno = o4      --BPSRNO is pk4
                                     AND xibp.jobno = xibh.jobno
                                     AND xibp.org_id = xibh.org_id
                                     AND xibp.invnosupl = xiih.invnosupl
                                     AND xibp.invnosupl = xibi.invnosupl
                                     AND xibi.jobno = xibh.jobno
                                     AND xibi.org_id = xibh.org_id
                                     AND xiih.invnosupl = xibi.invnosupl
                                     AND rt.shipment_header_id =
                                            xiih.shipment_header_id
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
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     -- to check for p_collection_time greater than xla posted date


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
                                               'YYYY-MM-DD HH24:MI:SS')));*/
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            --      END IF;            ELSE
            --                l_status_mess := ( '1 New value and Old value is same' );
            --            END IF;

            ELSE
               l_count := 1;                  --Capturing record for new table
               L_STATUS_MESS := P_TABLE_NAME || ' TABLE NOT FOUND IN THE PACKAGE.';
            END IF;
         END IF;
      ELSE
         l_status_mess :=
            (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
             || p_prog_val);
      END IF;

      IF (l_count = 0 AND l_status_mess IS NULL)
      THEN
         l_status_mess := 'UNPOSTED TRANSACTION,HENCE IGNORING RECORD';
      ELSIF l_count = 1 AND l_status_mess IS NULL
      THEN
         l_status_mess := 'RECORD IS ELIGIBLE WILL GET CAPTURED IN GG';
      END IF;

      COMMIT;
      xxccil_insert_debug_log (p_table_name,
                               l_key_value,
                               l_count,
                               -- l_old_val,             --Commented by Aditya R on 17-Jun-2025 CRQ CHG0230785
                               -- l_new_val,             --Commented by Aditya R on 17-Jun-2025 CRQ CHG0230785
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
            || ' AND p_key_value1,p_key_value2,p_key_value3 are  '
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
         --
         xxccil_insert_debug_log (p_table_name,
                                  l_key_value,
                                  l_count,
                                  --    l_old_val,       --Commented by Aditya R on 17-Jun-2025 CRQ CHG0230785
                                  --    l_new_val,       --Commented by Aditya R on 17-Jun-2025 CRQ CHG0230785
                                  l_status_mess);
   END xxccil_gg_filter_condition_prc;


   -- Function is to check whether the client is having super user access or not

   FUNCTION xxccil_client_superuser_access (p_client_id    VARCHAR2,
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
   END xxccil_client_superuser_access;

   ---- Function is to check the p_prog_val is excluded CP or not            --1.1 changes start

   FUNCTION xxccil_cp_check (p_prog_val VARCHAR2, p_qry_cnt NUMBER,p_client_id   IN VARCHAR2)   -- Changed by Aditya R for CHG0250599
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
                            fnd_concurrent_queues fcq,
                            (SELECT SUBSTR (p_prog_val,
                                            1,
                                            (INSTR (p_prog_val, '@') - 1))
                                       AS program
                               FROM DUAL) cp_check
                      WHERE    program = fcp.concurrent_program_name
                            OR program = fcq.concurrent_queue_name)
                            AND p_prog_val not like 'rwrun%'                                          -- Added by Aditya R on 20-Aug-2025 for CHG0250599
                            AND (p_client_id is null OR p_client_id != 'INTERFACE' OR p_prog_val not like 'sqlplus%');                  -- Added by Aditya R on 22-Aug-2025 for CHG0250599

      RETURN l_count;
   END xxccil_cp_check;                                      --1.1 changes end
END xxccil_gg_filter_condition_pkg;
/
CREATE OR REPLACE PACKAGE BODY APPS.xxccil_gg_filter_condition_pkg
/******************************************************************************
   NAME:       xxccil_gg_filter_condition_pkg.pkb
   PURPOSE:   Validate india specific and posted transactions and return the count back to Golden Gate

   REVISIONS:
    Ver        Date        Author            Description                            Reviewed By           Reviewed Date
    ----      --------      -----------       ----------------------------------     ----------------      -------------
    1.0        02-05-2025  WJ454(BSL)        Created this package.                                    DD-MM-RRRR
    1.1        24-02-2025  AL02R            created the xxccil_CP_CHECK function
                                            to check is p_prog_val is excluded
                                        CP or not and added the logic to
                                        compare onld value and new value
    1.2        24-02-2025  WJ454            created the xxccil_CP_CHECK function
                                        to check whether the client is having
                                        super user access or not
    1.3       17-06-2025  XW294             Changed the flow as per new requirement,
                                            Removed unused tables.Commented old/new values.
                                            (CHG0230785)
   1.4        22-Aug-2025  XW294           Changed the CP_check function and client_id Null
                                           conditions.(CHG0250599)
   ASSUMPTIONS:
   LIMITATIONS:
   ALGORITHM:
   NOTES:
******************************************************************************/
AS
   l_count            NUMBER := 0;
   l_key_value        VARCHAR2 (4000);
   -- l_old_val          VARCHAR2 (4000);
   -- l_new_val          VARCHAR2 (4000);
   --l_erro_mess        VARCHAR2 (4000);
   l_status_mess      VARCHAR2 (1000) DEFAULT NULL;
   l_prog_val         VARCHAR2 (1000);
   l_start_time       DATE;
   l_parameter_mess   VARCHAR2 (1000);

   /******************************************************************************
      NAME:        xxccil_gg_filter_condition_prc
      PURPOSE:    Validate india specific and posted transactions and return the count back to Golden Gate

      REVISIONS:
      Ver        Date        Author               Description
      ---------  ----------  ---------------      ----------------------------------
      1.0        02-05-2025  WJ454(BSL)          Created this procedure  xxccil_gg_filter_condition_prc
      1.1       17-06-2025   XW294               Removed old-new values and added new l_key_value message(CHG0230785)

      INPUT PARAMETERS:  P_TABLE_NAME,P_KEY_VALUE1,P_KEY_VALUE2,P_KEY_VALUE3

      OUTPUT PARAMETERS:   p_vc_err_buff
                           p_vc_ret_code
      INOUT PARAMETERS:

      ASSUMPTIONS:
      LIMITATIONS:
      NOTES:
   ******************************************************************************/
   PROCEDURE xxccil_gg_filter_condition_prc (
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
      --    P_TRANS_DATE IN DATE     DEFAULT NULL ,

      --      o1                   IN     VARCHAR2 DEFAULT NULL,
      --      o2                   IN     VARCHAR2 DEFAULT NULL,
      --      o3                   IN     VARCHAR2 DEFAULT NULL,
      --      o4                   IN     VARCHAR2 DEFAULT NULL,
      --      o5                   IN     VARCHAR2 DEFAULT NULL,
      --      o6                   IN     VARCHAR2 DEFAULT NULL,
      --      o7                   IN     VARCHAR2 DEFAULT NULL,
      --      o8                   IN     VARCHAR2 DEFAULT NULL,
      --      o9                   IN     VARCHAR2 DEFAULT NULL,
      --      o10                  IN     VARCHAR2 DEFAULT NULL,
      --      o11                  IN     VARCHAR2 DEFAULT NULL,
      --      o12                  IN     VARCHAR2 DEFAULT NULL,
      --      o13                  IN     VARCHAR2 DEFAULT NULL,
      --      o14                  IN     VARCHAR2 DEFAULT NULL,
      --      o15                  IN     VARCHAR2 DEFAULT NULL,
      --      o16                  IN     VARCHAR2 DEFAULT NULL,
      --      o17                  IN     VARCHAR2 DEFAULT NULL,
      --      o18                  IN     VARCHAR2 DEFAULT NULL,
      --      o19                  IN     VARCHAR2 DEFAULT NULL,
      --      o20                  IN     VARCHAR2 DEFAULT NULL,
      --      o21                  IN     VARCHAR2 DEFAULT NULL,
      --      o22                  IN     VARCHAR2 DEFAULT NULL,
      --      o23                  IN     VARCHAR2 DEFAULT NULL,
      --      o24                  IN     VARCHAR2 DEFAULT NULL,
      --      o25                  IN     VARCHAR2 DEFAULT NULL,
      --      o26                  IN     VARCHAR2 DEFAULT NULL,
      --      o27                  IN     VARCHAR2 DEFAULT NULL,
      --      o28                  IN     VARCHAR2 DEFAULT NULL,
      --      o29                  IN     VARCHAR2 DEFAULT NULL,
      --      o30                  IN     VARCHAR2 DEFAULT NULL,
      --      n1                   IN     VARCHAR2 DEFAULT NULL,
      --      n2                   IN     VARCHAR2 DEFAULT NULL,
      --      n3                   IN     VARCHAR2 DEFAULT NULL,
      --      n4                   IN     VARCHAR2 DEFAULT NULL,
      --      n5                   IN     VARCHAR2 DEFAULT NULL,
      --      n6                   IN     VARCHAR2 DEFAULT NULL,
      --      n7                   IN     VARCHAR2 DEFAULT NULL,
      --      n8                   IN     VARCHAR2 DEFAULT NULL,
      --      n9                   IN     VARCHAR2 DEFAULT NULL,
      --      n10                  IN     VARCHAR2 DEFAULT NULL,
      --      n11                  IN     VARCHAR2 DEFAULT NULL,
      --      n12                  IN     VARCHAR2 DEFAULT NULL,
      --      n13                  IN     VARCHAR2 DEFAULT NULL,
      --      n14                  IN     VARCHAR2 DEFAULT NULL,
      --      n15                  IN     VARCHAR2 DEFAULT NULL,
      --      n16                  IN     VARCHAR2 DEFAULT NULL,
      --      n17                  IN     VARCHAR2 DEFAULT NULL,
      --      n18                  IN     VARCHAR2 DEFAULT NULL,
      --      n19                  IN     VARCHAR2 DEFAULT NULL,
      --      n20                  IN     VARCHAR2 DEFAULT NULL,
      --      n21                  IN     VARCHAR2 DEFAULT NULL,
      --      n22                  IN     VARCHAR2 DEFAULT NULL,
      --      n23                  IN     VARCHAR2 DEFAULT NULL,
      --      n24                  IN     VARCHAR2 DEFAULT NULL,
      --      n25                  IN     VARCHAR2 DEFAULT NULL,
      --      n26                  IN     VARCHAR2 DEFAULT NULL,
      --      n27                  IN     VARCHAR2 DEFAULT NULL,
      --      n28                  IN     VARCHAR2 DEFAULT NULL,
      --      n29                  IN     VARCHAR2 DEFAULT NULL,
      --      n30                  IN     VARCHAR2 DEFAULT NULL,
      p_record_timestamp   IN     VARCHAR2 DEFAULT NULL,
      p_commit_timestamp   IN     VARCHAR2 DEFAULT NULL,
      p_count_val             OUT VARCHAR2,
      p_err_msg               OUT VARCHAR2)
   AS
      -- ln_count number;
      -- ln_log_seq number;
      -- lc_key_value varchar2(100);

      PROCEDURE xxccil_insert_debug_log (p_log_object       VARCHAR2,
                                         p_log_key_value    VARCHAR2,
                                         p_qry_cnt          NUMBER,
                                         -- p_old_val          VARCHAR2,       --Commented by Aditya R on 17-Jun-2025 CRQ CHG0230785
                                         -- p_new_val          VARCHAR2,       --Commented by Aditya R on 17-Jun-2025 CRQ CHG0230785
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
            SELECT xxc.xxc_goldengate_seq.NEXTVAL,
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
                   -- l_old_val,                                              --Commented by Aditya R on 17-Jun-2025 CRQ CHG0230785
                   -- l_new_val,                                              --Commented by Aditya R on 17-Jun-2025 CRQ CHG0230785
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
                  'Error while inserting into debug table XXC_GOLDENGATE_LOG'
               || SQLERRM;
      END;
   BEGIN
      l_start_time := SYSDATE;

      --  1. If you able pass table name from GG as Hard coded i will use 1 singel proce all 42
      -- 2. Creatpage AND all 42 procedure get seperate
      -- 3. 43 sepererate proceduer

      BEGIN
         SELECT                                                        --   n1
                   --                || NVL2 (o1, '|' || o1, '')                    --Commented by Aditya R on 17-Jun-2025 CRQ CHG0230785
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

      --Commented by Aditya R on 17-Jun-2025 CRQ CHG0230785
      -- Concatenating all the new values in to a single string.

      --        BEGIN
      --             l_new_val := n1 || ','|| n2 || ',' || n3 || ',' || n4 || ',' || n5 || ',' || n6 || ',' || n7 || ','|| n8 || ',' || n9 || ',' || n10 || ',' || n11 || ',' || n12 || ','  || n13 || ','  || n14 || ','  || n15 || ','  || n16 || ','  || n17  || ',' || n18 || ','  || n19 || ','  || n20 || ','  || n21 || ','  || n22 || ','  || n23 || ','  || n24 || ','  || n25 || ','  || n26 || ','  || n27 || ','  || n28 || ','  || n29 || ','  || n30;
      --        EXCEPTION
      --            WHEN others THEN
      --             l_new_val := SUBSTR(n1 || n2 || n3 || n4 || n5 || n6 || n7 || n8 || n9 || n10 || n11 || n12 || n13 || n14 || n15 || n16 || n17 || n18 || n19 || n20 || n21 || n22 || n23 || n24 || n25 || n26 || n27 || n28 || n29 || n30, 1, 4000);
      --        END;
      --
      --
      --  -- Concatenating all the old values in to a single string.
      --        BEGIN
      --             l_old_val := o1 || ','|| o2 || ',' || o3 || ',' || o4 || ',' || o5 || ',' || o6 || ',' || o7 || ','|| o8 || ',' || o9 || ',' || o10 || ',' || o11 || ',' || o12 || ','  || o13 || ','  || o14 || ','  || o15 || ','  || o16 || ','  || o17  || ',' || o18 || ','  || o19 || ','  || o20 || ','  || o21 || ','  || o22 || ','  || o23 || ','  || o24 || ','  || o25 || ','  || o26 || ','  || o27 || ','  || o28 || ','  || o29 || ','  || o30;
      --        EXCEPTION
      --            WHEN others THEN
      --             l_old_val := SUBSTR(o1 || o2 || o3 || o4 || o5 || o6 || o7 || o8 || o9 || o10 || o11 || o12 || o13 || o14 || o15 || o16 || o17 || o18 || o19 || o20 || o21 || o22 || o23 || o24 || o25 || o26 || o27 || o28 || o29 || o30, 1, 4000);
      --        END;

      l_count := 0;
      l_status_mess := NULL;

      --- Concurrent Program Check
      l_count := xxccil_cp_check (p_prog_val, l_count,p_client_id); --Added by Aditya R on 17-Jun-2025 for CRQ CHG0230785


      IF l_count = 1
      THEN
         IF p_event IN ('DELETE', 'INSERT')
         THEN
            IF p_client_id IS NULL --AND (p_prog_val NOT LIKE 'frmweb%' OR p_prog_val != 'JDBC Thin Client')
            THEN
               l_count := 1;
               l_status_mess := 'Record is ' || P_EVENT || 'ed from backend';
            ELSE
               l_count := 0;
               l_status_mess :=
                     'Record is '
                  || P_EVENT
                  || 'ed from frontend.';
            END IF;
         --        ELSIF length(l_new_val) > 29 THEN
         --            IF ( l_old_val != l_new_val ) THEN                                                --1.1 changes start
         --                l_count := 1;
         --            END IF;

         --1.1 changes end

         --                       IF l_count = 1 THEN
         ELSE
            IF p_table_name IN ('PO_HEADERS_ALL',
                                'PO_LINES_ALL',
                                'PO_LINE_LOCATIONS_ALL',
                                'PO_DISTRIBUTIONS_ALL',
                                'PO_RELEASES_ALL',
                                --'GL_BALANCES',
                                'OE_ORDER_HEADERS_ALL',
                                'OE_ORDER_LINES_ALL',
                                'WSH_DELIVERY_DETAILS')
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --         IF l_count = 1
               --         THEN

--               IF p_client_id IS NULL AND (p_prog_val LIKE 'frmweb%' OR p_prog_val = 'JDBC Thin Client')
--               THEN
               l_count := xxccil_client_superuser_access (p_client_id, l_count);

               IF l_count = 1
               THEN
                  l_status_mess :=
                     'Record is updated by backend or by superuser';
               ELSE
                  --l_count := 0;
                  l_status_mess := 'Record is updated by frontend';
               END IF;
               --END IF;
            --         ELSE
            --            l_status_mess :=
            --               (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            -- Added remaining tables
            ELSIF P_TABLE_NAME IN ('RCV_PARAMETERS',
                                   'RA_CUST_TRX_TYPES_ALL',
                                   'RA_ACCOUNT_DEFAULT_SEGMENTS',
                                   'QP_LIST_LINES',
                                   'QP_LIST_HEADERS_B',
                                   'PO_SYSTEM_PARAMETERS_ALL',
                                   'ORG_ACCT_PERIODS',
                                   'OE_TRANSACTION_TYPES_ALL',
                                   'MTL_SYSTEM_ITEMS_B',
                                   'MTL_SECONDARY_INVENTORIES',
                                   'MTL_PARAMETERS',
                                   'MTL_INTERORG_PARAMETERS',
                                   'IBY_EXTERNAL_PAYEES_ALL',
                                   'HZ_CUST_SITE_USES_ALL',
                                   'HZ_CUST_PROFILE_AMTS',
                                   'HZ_CUST_ACCT_SITES_ALL',
                                   'HZ_CUST_ACCOUNTS',
                                   'GL_PERIODS',
                                   'GL_PERIOD_TYPES',
                                   'GL_PERIOD_STATUSES',
                                   'GL_LEDGERS',
                                   'FND_FLEX_VALUES_TL',
                                   'FND_FLEX_VALUES',
                                   'BOM_STRUCTURES_B',
                                   'BOM_COMPONENTS_B',
                                   'AR_SYSTEM_PARAMETERS_ALL',
                                   'AR_RECEIVABLES_TRX_ALL',
                                   'AP_SYSTEM_PARAMETERS_ALL',
                                   'AP_SUPPLIERS',
                                   'AP_BANK_BRANCHES')
            THEN
               l_status_mess := NULL;
            ELSIF p_table_name = 'GL_DAILY_RATES'
            THEN
               IF p_key_value1 = 'INR' AND p_key_value2 = 'Corporate'
               THEN
                  l_count := 1;
               ELSE
                  l_count := 0;
                  l_status_mess :=
                     (' GL_DAILY RATE IS NOT UPDATED FOR INR CURRENCY ');
               END IF;
            /*
            ELSIF p_table_name = 'GL_JE_HEADERS'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               IF                                            --l_count != 1 OR
                 p_key_value1 != 'P'
               THEN                                          -- o22 --> status
                  l_count := 0;
--                  l_status_mess :=
--                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
--                      || p_prog_val);
               END IF;
            ELSIF p_table_name = 'GL_JE_LINES'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

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
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               IF                                            --l_count != 1 OR
                 p_key_value1 != 'P'
               THEN                                           -- o3 --> status
                  l_count := 0;
--                  l_status_mess :=
--                     (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
--                      || p_prog_val);
               END IF; */
            -- Commented GL_JE tables as per requiremnt by Aditya R on 17-Jun-2025 CRQ CHG0230785
            ELSIF (p_table_name = 'XLA_AE_HEADERS')
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               -- o1 = AE_HEADER_ID

               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM apps.xla_ae_headers XAH, apps.gl_ledgers gl
                           WHERE     xah.ae_header_id =
                                        TO_NUMBER (p_key_value1)
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND gl.ledger_id = xah.ledger_id);
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            ELSIF (p_table_name = 'XLA_AE_LINES')
            THEN
               -- l_count := xxccil_cp_check (p_prog_val, l_count);

               -- 01 = AE_HEADER_ID
               -- o2 = AE_LINE_NUM

               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM apps.xla_ae_headers xah,
                                 apps.xla_ae_lines xal,
                                 apps.gl_ledgers gl
                           WHERE     xal.ae_header_id =
                                        TO_NUMBER (p_key_value1)
                                 AND xal.ae_line_num =
                                        TO_NUMBER (p_key_value2)
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND gl.ledger_id = xah.ledger_id
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F');
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            ELSIF p_table_name = 'RCV_TRANSACTIONS'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE (   EXISTS
                             (SELECT 1
                                FROM rcv_receiving_sub_ledger rrsl,
                                     xla_distribution_links xdl,
                                     xla_events xe,
                                     xla_ae_headers xah,
                                     xla_ae_lines xal
                               WHERE     rrsl.rcv_transaction_id =
                                            p_key_value1 --o1 -- TRANSACTION_ID is PK1
                                     AND rrsl.rcv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'RCV_RECEIVING_SUB_LEDGER'
                                     AND xdl.ae_header_id = xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     -- to check for p_collection_time greater than xla posted date


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
                                               'YYYY-MM-DD HH24:MI:SS'))
                       OR EXISTS
                             (SELECT 1
                                FROM mtl_material_transactions mmt,
                                     mtl_transaction_accounts mta,
                                     xla_events xe,
                                     xla_distribution_links xdl,
                                     xla_ae_headers xah,
                                     xla_ae_lines xal
                               WHERE     mmt.rcv_transaction_id =
                                            p_key_value1 --o1 -- TRANSACTION_ID is PK1
                                     AND mmt.transaction_id =
                                            mta.transaction_id
                                     AND mta.inv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'MTL_TRANSACTION_ACCOUNTS'
                                     AND xdl.ae_header_id = xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     -- to check for p_collection_time greater than xla posted date


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
                                               'YYYY-MM-DD HH24:MI:SS')));
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            --Condition on DS_AVAL_UAL
            ELSIF p_table_name = 'RCV_SHIPMENT_HEADERS'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE (   EXISTS
                             (SELECT 1
                                FROM rcv_transactions rt,
                                     rcv_receiving_sub_ledger rrsl,
                                     xla_distribution_links xdl,
                                     xla_events xe,
                                     xla_ae_headers xah,
                                     xla_ae_lines xal
                               WHERE     rt.shipment_header_id = p_key_value1 --o1 --SHIPMENT_HEADER_ID is PK1
                                     AND rt.transaction_id =
                                            rrsl.rcv_transaction_id
                                     AND rrsl.rcv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'RCV_RECEIVING_SUB_LEDGER'
                                     AND xdl.ae_header_id = xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     -- to check for p_collection_time greater than xla posted date


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
                                               'YYYY-MM-DD HH24:MI:SS'))
                       OR EXISTS
                             (SELECT 1
                                FROM rcv_transactions rt,
                                     mtl_material_transactions mmt,
                                     mtl_transaction_accounts mta,
                                     xla_events xe,
                                     xla_distribution_links xdl,
                                     xla_ae_headers xah,
                                     xla_ae_lines xal
                               WHERE     rt.shipment_header_id = p_key_value1 --o1 --SHIPMENT_HEADER_ID is PK1
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
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     -- to check for p_collection_time greater than xla posted date


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
                                               'YYYY-MM-DD HH24:MI:SS')));
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            ELSIF p_table_name = 'RCV_SHIPMENT_LINES'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE (   EXISTS
                             (SELECT 1
                                FROM rcv_transactions rt,
                                     rcv_receiving_sub_ledger rrsl,
                                     xla_distribution_links xdl,
                                     xla_events xe,
                                     xla_ae_headers xah,
                                     xla_ae_lines xal
                               WHERE     rt.shipment_line_id = p_key_value1 --o1 --SHIPMENT_LINE_ID is PK1
                                     AND rt.transaction_id =
                                            rrsl.rcv_transaction_id
                                     AND rrsl.rcv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'RCV_RECEIVING_SUB_LEDGER'
                                     AND xdl.ae_header_id = xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     -- to check for p_collection_time greater than xla posted date


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
                                               'YYYY-MM-DD HH24:MI:SS'))
                       OR EXISTS
                             (SELECT 1
                                FROM rcv_transactions rt,
                                     mtl_material_transactions mmt,
                                     mtl_transaction_accounts mta,
                                     xla_events xe,
                                     xla_distribution_links xdl,
                                     xla_ae_headers xah,
                                     xla_ae_lines xal
                               WHERE     rt.shipment_line_id = p_key_value1 --o1 -- --SHIPMENT_LINE_ID is PK1
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
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     -- to check for p_collection_time greater than xla posted date


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
                                               'YYYY-MM-DD HH24:MI:SS')));
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            ELSIF p_table_name = 'MTL_MATERIAL_TRANSACTIONS'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM mtl_material_transactions mmt,
                                 mtl_transaction_accounts mta,
                                 xla_events xe,
                                 xla_distribution_links xdl,
                                 xla_ae_headers xah,
                                 xla_ae_lines xal
                           WHERE     mmt.transaction_id = p_key_value1 --o1 --transaction_id is PK1
                                 AND mmt.transaction_id = mta.transaction_id
                                 AND mta.inv_sub_ledger_id =
                                        xdl.source_distribution_id_num_1
                                 AND xdl.source_distribution_type =
                                        'MTL_TRANSACTION_ACCOUNTS'
                                 AND xdl.ae_header_id = xah.ae_header_id
                                 AND xdl.application_id = xah.application_id
                                 AND xdl.ae_line_num = xal.ae_line_num
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xe.entity_id = xah.entity_id
                                 AND xah.ae_header_id = xal.ae_header_id
                                 -- to check for p_collection_time greater than xla posted date


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
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            ELSIF p_table_name = 'RA_CUSTOMER_TRX_ALL'
            THEN
               --                l_count := xxccil_cp_check(p_prog_val, l_count);
               --                --l_count := xxccil_client_superuser_access(p_client_id, l_count);



               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM ra_cust_trx_line_gl_dist_all rctl,
                                 xla_distribution_links xdl,
                                 xla_events xe,
                                 xla_ae_headers xah,
                                 xla_ae_lines xal
                           WHERE     rctl.customer_trx_id = p_key_value1 -- o1 --CUSTOMER_TRX_ID is PK1
                                 AND rctl.event_id = xe.event_id
                                 AND xe.entity_id = xah.entity_id
                                 AND xdl.source_distribution_id_num_1 =
                                        rctl.cust_trx_line_gl_dist_id
                                 AND xdl.event_id = xe.event_id
                                 AND xdl.ae_header_id = xah.ae_header_id
                                 AND xdl.event_id = xah.event_id
                                 AND xdl.ae_header_id = xal.ae_header_id
                                 AND xdl.ae_line_num = xal.ae_line_num
                                 AND source_distribution_type =
                                        'RA_CUST_TRX_LINE_GL_DIST_ALL'
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xah.ae_header_id = xal.ae_header_id
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
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            ELSIF p_table_name = 'RA_CUSTOMER_TRX_LINES_ALL'
            THEN
               -- l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM ra_cust_trx_line_gl_dist_all rctl,
                                 xla_distribution_links xdl,
                                 xla_events xe,
                                 xla_ae_headers xah,
                                 xla_ae_lines xal
                           WHERE     rctl.customer_trx_line_id = p_key_value1 --o1
                                 AND rctl.event_id = xe.event_id
                                 AND xe.entity_id = xah.entity_id
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xah.ae_header_id = xdl.ae_header_id
                                 AND xdl.ae_line_num = xdl.ae_line_num
                                 AND xdl.source_distribution_type =
                                        'RA_CUST_TRX_LINE_GL_DIST_ALL'
                                 AND xdl.source_distribution_id_num_1 =
                                        rctl.cust_trx_line_gl_dist_id
                                 -- to check for p_collection_time greater than xla posted date

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
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            ELSIF p_table_name = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM xla_distribution_links xdl,
                                 xla_events xe,
                                 xla_ae_headers xah,
                                 xla_ae_lines xal
                           WHERE     xdl.source_distribution_id_num_1 =
                                        p_key_value1 -- o1 --CUST_TRX_LINE_GL_DIST_ID is pk1
                                 AND xe.event_id = p_key_value2 --o2       -- event_id is pk2
                                 AND xe.entity_id = xah.entity_id
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xah.ae_header_id = xdl.ae_header_id
                                 AND xdl.ae_line_num = xdl.ae_line_num
                                 AND xdl.source_distribution_type =
                                        'RA_CUST_TRX_LINE_GL_DIST_ALL'
                                 -- to check for p_collection_time greater than xla posted date
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
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            /*
            ELSIF p_table_name = 'WSH_DELIVERY_ASSIGNMENTS'
            THEN                                                    -- khaleel
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
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
                           WHERE     wdd.delivery_detail_id = p_key_value1 --o1 -- DELIVERY_DETAIL_ID is PK
                                 AND oola.header_id = oha.header_id
                                 AND oha.header_id = wdd.source_header_id
                                 AND oola.line_id = wdd.source_line_id
                                 --   AND wda.DELIVERY_DETAIL_ID                 = wdd.DELIVERY_DETAIL_ID
                                 AND wdd.delivery_detail_id =
                                        mmt.picking_line_id
                                 AND wdd.source_line_id =
                                        mmt.trx_source_line_id
                                 AND mtt.transaction_type_id =
                                        mmt.transaction_type_id
                                 AND mtt.transaction_action_id =
                                        mmt.transaction_action_id
                                 AND mmt.transaction_id = mta.transaction_id
                                 AND mta.inv_sub_ledger_id =
                                        xdl.source_distribution_id_num_1
                                 AND xdl.source_distribution_type =
                                        'MTL_TRANSACTION_ACCOUNTS'
                                 AND xdl.ae_header_id = xah.ae_header_id
                                 AND xdl.application_id = xah.application_id
                                 AND xdl.ae_line_num = xal.ae_line_num
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xe.entity_id = xah.entity_id
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
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
                                           'YYYY-MM-DD HH24:MI:SS')
                                 AND gir.je_header_id = gjh.je_header_id
                                 AND gjh.status = 'P');
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF; */
            /*   ELSIF p_table_name = 'WSH_DELIVERY_DETAILS' THEN
                   l_count := xxccil_cp_check(p_prog_val, l_count);
           --l_count := xxccil_client_superuser_access(p_client_id, l_count);
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
                                   AND mmt.trx_source_line_id = o2    -- source_line_id     is pk2
       --    AND wdd.DELIVERY_DETAIL_ID            = MMT.PICKING_LINE_ID
       --    AND wdd.source_line_id                = mmt.TRX_SOURCE_LINE_ID
                                   AND mtt.transaction_type_id = mmt.transaction_type_id
                                   AND mtt.transaction_action_id = mmt.transaction_action_id
                                   AND mmt.transaction_id = mta.transaction_id
                                   AND mta.inv_sub_ledger_id = xdl.source_distribution_id_num_1
                                   AND xdl.source_distribution_type = 'MTL_TRANSACTION_ACCOUNTS'
                                   AND xdl.ae_header_id = xah.ae_header_id
                                   AND xdl.application_id = xah.application_id

                                   AND xdl.ae_line_num = xal.ae_line_num
                                   AND xe.event_status_code = 'P'
                                   AND xe.process_status_code = 'P'
                                   AND xah.gl_transfer_status_code = 'Y'
                                   AND xah.accounting_entry_status_code = 'F'
                                   AND xe.entity_id = xah.entity_id
                                   AND xah.ae_header_id = xal.ae_header_id
                                   AND xal.gl_sl_link_id = gir.gl_sl_link_id


                                   AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                   ),
                                                                                'YYYY-MM-DD HH24:MI:SS'),
                                                                        to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
       'YYYY-MM-DD HH24:MI:SS')
                                   AND gir.je_header_id = gjh.je_header_id
                                   AND gjh.status = 'P'
                           );

                   ELSE
                       l_status_mess := ( '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
                                          || p_prog_val );
                   END IF; */
            /*
            ELSIF p_table_name = 'WSH_NEW_DELIVERIES'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
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
                           WHERE     wda.delivery_id = p_key_value1 --o1
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
                                 AND mmt.transaction_id = mta.transaction_id
                                 AND mta.inv_sub_ledger_id =
                                        xdl.source_distribution_id_num_1
                                 AND xdl.source_distribution_type =
                                        'MTL_TRANSACTION_ACCOUNTS'
                                 AND xdl.ae_header_id = xah.ae_header_id
                                 AND xdl.application_id = xah.application_id
                                 AND xdl.ae_line_num = xal.ae_line_num
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xe.entity_id = xah.entity_id
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
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
                                           'YYYY-MM-DD HH24:MI:SS')
                                 AND gir.je_header_id = gjh.je_header_id
                                 AND gjh.status = 'P');
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            */
            ELSIF p_table_name = 'AR_PAYMENT_SCHEDULES_ALL'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM ar_receivable_applications_all ara,
                                 ra_cust_trx_line_gl_dist_all rctl,
                                 xla_distribution_links xdl,
                                 xla_events xe,
                                 xla_ae_headers xah,
                                 xla_ae_lines xal
                           WHERE     ara.payment_schedule_id = p_key_value1 -- o1
                                 AND ara.event_id = xe.event_id
                                 AND xe.entity_id = xah.entity_id
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND rctl.customer_trx_id =
                                        ara.customer_trx_id
                                 AND xah.ae_header_id = xdl.ae_header_id
                                 AND xdl.ae_line_num = xdl.ae_line_num
                                 AND xdl.source_distribution_type =
                                        'RA_CUST_TRX_LINE_GL_DIST_ALL'
                                 AND xdl.source_distribution_id_num_1 =
                                        rctl.cust_trx_line_gl_dist_id
                                 --  AND APSA.PAYMENT_SCHEDULE_ID = ARA.PAYMENT_SCHEDULE_ID
                                 -- to check for p_collection_time greater than xla posted date
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
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            /*
            ELSIF p_table_name = 'AR_CASH_RECEIPTS_ALL'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
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
                           WHERE     arch.cash_receipt_id = p_key_value1 --o1
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
                                 AND xdl.ae_line_num = xdl.ae_line_num
                                 AND xdl.source_distribution_type =
                                        'AR_DISTRIBUTIONS_ALL'
                                 AND xdl.source_distribution_id_num_1 =
                                        ada.line_id
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
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
                                           'YYYY-MM-DD HH24:MI:SS')
                                 AND gir.je_header_id = gjh.je_header_id);
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            */
            /*
            ELSIF p_table_name = 'AR_RECEIVABLE_APPLICATIONS_ALL'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE (   EXISTS
                             (SELECT 1
                                FROM ra_cust_trx_line_gl_dist_all rctl,
                                     xla_distribution_links xdl,
                                     xla_events xe,
                                     xla_ae_headers xah,
                                     xla_ae_lines xal
                               WHERE     xe.event_id = p_key_value2
                                     AND rctl.customer_trx_id = p_key_value3
                                     --  AND ARA.EVENT_ID                   = XE.EVENT_ID
                                     --  AND ARA.CUSTOMER_TRX_ID            = RCTL.CUSTOMER_TRX_ID
                                     AND xe.entity_id = xah.entity_id
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xah.ae_header_id = xal.ae_header_id
                                     AND xah.ae_header_id = xdl.ae_header_id
                                     AND xdl.ae_line_num = xdl.ae_line_num
                                     AND xdl.source_distribution_type =
                                            'RA_CUST_TRX_LINE_GL_DIST_ALL'
                                     AND xdl.source_distribution_id_num_1 =
                                            rctl.cust_trx_line_gl_dist_id
                                     -- to check for p_collection_time greater than xla posted date

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
                                               'YYYY-MM-DD HH24:MI:SS'))
                       OR EXISTS
                             (SELECT 1
                                FROM ar_distributions_all ada,
                                     xla_distribution_links xdl,
                                     xla_events xe,
                                     xla_ae_headers xah,
                                     xla_ae_lines xal
                               WHERE     xe.event_id = p_key_value2
                                     AND ada.source_id =  p_key_value1 --o1-- RECEIVABLE_APPLICATION_ID is PK1
                                     --      AND ARA.EVENT_ID                    = XE.EVENT_ID
                                     --    and ADA.SOURCE_ID                   = ARA.RECEIVABLE_APPLICATION_ID
                                     AND ada.source_table = 'RA'
                                     AND xe.entity_id = xah.entity_id
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code =
                                            'F'
                                     AND xah.ae_header_id = xal.ae_header_id
                                     AND xah.ae_header_id = xdl.ae_header_id
                                     AND xdl.ae_line_num = xdl.ae_line_num
                                     AND xdl.source_distribution_type =
                                            'AR_DISTRIBUTIONS_ALL'
                                     AND xdl.source_distribution_id_num_1 =
                                            ada.line_id
                                     -- to check for p_collection_time greater than xla posted date

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
                                               'YYYY-MM-DD HH24:MI:SS')));
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            */
            /*
            ELSIF p_table_name = 'AR_CASH_RECEIPT_HISTORY_ALL'
            THEN
               -- l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
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
                           WHERE     ard.source_id = p_key_value1 --o1 -- CASH_RECEIPT_HISTORY_ID is pk1
                                 --      AND acra.EVENT_ID                   = XE.EVENT_ID
                                 --    AND ACRA.CASH_RECEIPT_HISTORY_ID    = ARD.SOURCE_ID
                                 AND ard.source_table = 'CRH'
                                 AND xe.entity_id = xah.entity_id
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND gjh.status = 'P'
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xah.ae_header_id = xdl.ae_header_id
                                 AND xdl.ae_line_num = xdl.ae_line_num
                                 AND xdl.source_distribution_type =
                                        'AR_DISTRIBUTIONS_ALL'
                                 AND xdl.source_distribution_id_num_1 =
                                        ard.line_id
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
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
                                           'YYYY-MM-DD HH24:MI:SS')
                                 AND gir.je_header_id = gjh.je_header_id);
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            */
            ELSIF p_table_name = 'AR_REVENUE_ADJUSTMENTS_ALL'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM xla_events xe,
                                 xla_distribution_links xdl,
                                 xla_ae_headers xah,
                                 xla_ae_lines xal,
                                 ra_customer_trx_lines_all rctl,
                                 ra_cust_trx_line_gl_dist_all ragl
                           WHERE     ragl.customer_trx_id = p_key_value1 --o1 -- CUSTOMER_TRX_ID is PK1
                                 AND rctl.customer_trx_line_id = p_key_value2 --o2 -- FROM_CUST_TRX_LINE_ID is PK2
                                 AND ragl.event_id = xe.event_id
                                 --   AND ARAA.CUSTOMER_TRX_ID                            = RAGL.CUSTOMER_TRX_ID
                                 AND xe.entity_id = xah.entity_id
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xah.ae_header_id = xdl.ae_header_id
                                 AND xdl.ae_line_num = xdl.ae_line_num
                                 AND xdl.source_distribution_type =
                                        'RA_CUST_TRX_LINE_GL_DIST_ALL'
                                 AND xdl.source_distribution_id_num_1 =
                                        ragl.cust_trx_line_gl_dist_id
                                 --     AND ARAA.FROM_CUST_TRX_LINE_ID                      = RCTL.CUSTOMER_TRX_LINE_ID
                                 AND rctl.customer_trx_line_id =
                                        ragl.customer_trx_line_id
                                 -- to check for p_collection_time greater than xla posted date
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
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            ELSIF p_table_name = 'AR_DEFERRED_LINES_ALL'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM xla_events xe,
                                 xla_distribution_links xdl,
                                 xla_ae_headers xah,
                                 xla_ae_lines xal,
                                 ra_customer_trx_lines_all rctl,
                                 ra_cust_trx_line_gl_dist_all ragl
                           WHERE     rctl.customer_trx_line_id = p_key_value1 --o1 --CUSTOMER_TRX_LINE_ID is PK1
                                 AND ragl.event_id = xe.event_id
                                 AND xe.entity_id = xah.entity_id
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xah.ae_header_id = xdl.ae_header_id
                                 AND xdl.ae_line_num = xdl.ae_line_num
                                 AND xdl.source_distribution_type =
                                        'RA_CUST_TRX_LINE_GL_DIST_ALL'
                                 AND xdl.source_distribution_id_num_1 =
                                        ragl.cust_trx_line_gl_dist_id
                                 --  AND ADLA.CUSTOMER_TRX_LINE_ID            = RCTL.CUSTOMER_TRX_LINE_ID

                                 AND rctl.customer_trx_line_id =
                                        ragl.customer_trx_line_id
                                 -- to check for p_collection_time greater than xla posted date
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
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            /*
            ELSIF p_table_name = 'AR_ADJUSTMENTS_ALL'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
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
                           WHERE     xe.event_id = p_key_value1 --o1
                                 --          AND ADA.EVENT_ID                  = XE.EVENT_ID
                                 AND xe.entity_id = xah.entity_id
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND gjh.status = 'P'
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xah.ae_header_id = xdl.ae_header_id
                                 AND xdl.ae_line_num = xdl.ae_line_num
                                 AND xdl.source_distribution_type =
                                        'AR_DISTRIBUTIONS_ALL'
                                 AND xdl.source_distribution_id_num_1 =
                                        adda.line_id
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
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
                                           'YYYY-MM-DD HH24:MI:SS')
                                 AND gir.je_header_id = gjh.je_header_id);
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            */
            ELSIF p_table_name = 'AP_SUPPLIER_SITES_ALL'
            THEN                                              --NEED TO UPDATE
               l_count := 1;
            /*
            ELSIF p_table_name = 'AP_INVOICES_ALL'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
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
                           WHERE     aila.invoice_id = p_key_value1 --o1       --p_key_value1
                                 --        and AIA.INVOICE_ID                 = AILA.INVOICE_ID
                                 AND aila.invoice_id = aida.invoice_id
                                 AND aila.line_number =
                                        aida.invoice_line_number
                                 AND aida.invoice_distribution_id =
                                        xdl.source_distribution_id_num_1
                                 AND xdl.source_distribution_type =
                                        'AP_INV_DIST'
                                 AND xdl.ae_header_id = xah.ae_header_id
                                 AND xdl.application_id = xah.application_id
                                 AND xdl.ae_line_num = xal.ae_line_num
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xe.entity_id = xah.entity_id
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                 --AND xal.creation_date <= nvl(TO_DATE(p_collection_time, 'YYYY-MM-DD HH24:MI:SS'),
                                 --                                     xal.creation_date)



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
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            ELSIF p_table_name = 'AP_INVOICE_LINES_ALL'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
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
                           WHERE     aida.invoice_id = p_key_value1 --o1
                                 AND aida.invoice_line_number = p_key_value2 --o2
                                 --            and AILA.INVOICE_ID                   = AIDA.INVOICE_ID
                                 --          and AILA.LINE_NUMBER                  = AIDA.INVOICE_LINE_NUMBER
                                 AND aida.invoice_distribution_id =
                                        xdl.source_distribution_id_num_1
                                 AND xdl.source_distribution_type =
                                        'AP_INV_DIST'
                                 AND xdl.ae_header_id = xah.ae_header_id
                                 AND xdl.application_id = xah.application_id
                                 AND xdl.ae_line_num = xal.ae_line_num
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xe.entity_id = xah.entity_id
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
                                 --                                AND xal.creation_date <= nvl(TO_DATE(p_collection_time, 'YYYY-MM-DD HH24:MI:SS'),
                                 --                                                                xal.creation_date)

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
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            ELSIF p_table_name = 'AP_INVOICE_DISTRIBUTIONS_ALL'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
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
                           WHERE     xdl.source_distribution_id_num_1 = p_key_value1 --o1 -- INVOICE_DISTRIBUTION_ID is pk1
                                 --        AND AIDA.INVOICE_DISTRIBUTION_ID        = XDL.SOURCE_DISTRIBUTION_ID_NUM_1

                                 AND xdl.source_distribution_type =
                                        'AP_INV_DIST'
                                 AND xdl.ae_header_id = xah.ae_header_id
                                 AND xdl.application_id = xah.application_id
                                 AND xdl.ae_line_num = xal.ae_line_num
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xe.entity_id = xah.entity_id
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id
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
                                           'YYYY-MM-DD HH24:MI:SS')
                                 AND gir.je_header_id = gjh.je_header_id
                                 AND gjh.status = 'P');
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;

            ELSIF p_table_name = 'AP_PAYMENT_SCHEDULES_ALL'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM ap_invoice_payments_all aipa,
                                 xla_events xe,
                                 xla_ae_headers xah,
                                 xla_ae_lines xal
                           WHERE     aipa.invoice_id = p_key_value1 --o1
                                 AND aipa.payment_num = p_key_value2 --o2
                                 AND aipa.accounting_event_id = xe.event_id
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xe.entity_id = xah.entity_id
                                 AND xah.ae_header_id = xal.ae_header_id
                                 -- to check for p_collection_time greater than xla posted date


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
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            ELSIF p_table_name = 'AP_INVOICE_PAYMENTS_ALL'
            THEN
               -- l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM xla_events xe,
                                 xla_ae_headers xah,
                                 xla_ae_lines xal
                           WHERE     xe.event_id = p_key_value1 --o1 -- ACCOUNTING_EVENT_ID is pk1
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xe.entity_id = xah.entity_id
                                 AND xah.ae_header_id = xal.ae_header_id
                                 -- to check for p_collection_time greater than xla posted date


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
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
                        ELSIF p_table_name = 'AP_CHECKS_ALL'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM ap_invoice_payments_all aipa,
                                 xla_events xe,
                                 xla_ae_headers xah,
                                 xla_ae_lines xal
                           WHERE     aipa.check_id = p_key_value1 --o1
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xe.entity_id = xah.entity_id
                                 AND xah.ae_header_id = xal.ae_header_id
                                 -- to check for p_collection_time greater than xla posted date


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
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            ELSIF p_table_name = 'AP_PAYMENT_HISTORY_ALL'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM xla_events xe,
                                 xla_ae_headers xah,
                                 xla_ae_lines xal
                           WHERE     xe.event_id = p_key_value1 --o1 -- ACCOUNTING_EVENT_ID is pk1
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xe.entity_id = xah.entity_id
                                 AND xah.ae_header_id = xal.ae_header_id
                                 -- to check for p_collection_time greater than xla posted date


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
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;

            ELSIF p_table_name = 'OE_PRICE_ADJUSTMENTS'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
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
                               WHERE     oha.header_id = p_key_value1--- o1
                                     AND oola.line_id = p_key_value2 --o2
                                     AND oha.header_id = oola.header_id
                                     --        AND OPA.HEADER_ID                   = OHA.HEADER_ID
                                     --        AND OPA.LINE_ID                     = OOLA.LINE_ID
                                     AND oha.header_id = wdd.source_header_id
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
                                               'YYYY-MM-DD HH24:MI:SS')
                                     AND gir.je_header_id = gjh.je_header_id
                                     AND gjh.status = 'P')
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
                               WHERE     oha.header_id = p_key_value1 --o1
                                     AND oola.line_id = p_key_value2 --o2
                                     AND oha.header_id = oola.header_id
                                     --        AND OPA.HEADER_ID                   = OHA.HEADER_ID
                                     --        AND OPA.LINE_ID                     = OOLA.LINE_ID
                                     AND oha.header_id =
                                            rsl.oe_order_header_id
                                     AND oola.line_id = rsl.oe_order_line_id
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
                                     AND xdl.ae_header_id = xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
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
                                               'YYYY-MM-DD HH24:MI:SS')
                                     AND gir.je_header_id = gjh.je_header_id
                                     AND gjh.status = 'P')
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
                               WHERE     oha.header_id = p_key_value1 --o1
                                     AND oola.line_id = p_key_value2 --o2
                                     AND oha.header_id = oola.header_id
                                     --    AND OPA.HEADER_ID                          = OHA.HEADER_ID
                                     --    AND OPA.LINE_ID                            = OOLA.LINE_ID
                                     AND oha.header_id = odss.header_id
                                     AND odss.line_id = oola.line_id
                                     AND odss.po_header_id = rsl.po_header_id
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
                                     AND xdl.ae_header_id = xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
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
                                               'YYYY-MM-DD HH24:MI:SS')
                                     AND gir.je_header_id = gjh.je_header_id
                                     AND gjh.status = 'P'));
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            */
            /*     ELSIF p_table_name = 'OE_ORDER_HEADERS_ALL' THEN
                     l_count := xxccil_cp_check(p_prog_val, l_count);
             --l_count := xxccil_client_superuser_access(p_client_id, l_count);
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
                                         wdd.source_header_id = o1
                                     AND wdd.delivery_detail_id = mmt.picking_line_id
                                     AND wdd.source_line_id = mmt.trx_source_line_id
                                     AND mtt.transaction_type_id = mmt.transaction_type_id
                                     AND mtt.transaction_action_id = mmt.transaction_action_id
                                     AND mmt.transaction_id = mta.transaction_id
                                     AND mta.inv_sub_ledger_id = xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type = 'MTL_TRANSACTION_ACCOUNTS'
                                     AND xdl.ae_header_id = xah.ae_header_id
                                     AND xdl.application_id = xah.application_id

                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code = 'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     AND xal.gl_sl_link_id = gir.gl_sl_link_id


                                     AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                     ),
                                                                                  'YYYY-MM-DD HH24:MI:SS'),
                                                                          to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
         'YYYY-MM-DD HH24:MI:SS')
                                     AND gir.je_header_id = gjh.je_header_id
                                     AND gjh.status = 'P'
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
                                         rsl.oe_order_header_id = o1
                                     AND rsl.shipment_line_id = rt.shipment_line_id
                                     AND rt.transaction_type = 'DELIVER'
                                     AND rt.transaction_id = mmt.rcv_transaction_id
                                     AND mmt.transaction_id = mta.transaction_id
                                     AND mta.inv_sub_ledger_id = xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type = 'MTL_TRANSACTION_ACCOUNTS'
                                     AND xdl.ae_header_id = xah.ae_header_id
                                     AND xdl.application_id = xah.application_id

                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code = 'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     AND xal.gl_sl_link_id = gir.gl_sl_link_id


                                     AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                     ),
                                                                                  'YYYY-MM-DD HH24:MI:SS'),
                                                                          to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
         'YYYY-MM-DD HH24:MI:SS')
                                     AND gir.je_header_id = gjh.je_header_id
                                     AND gjh.status = 'P'
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
                                         odss.header_id = o1
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

                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code = 'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     AND xal.gl_sl_link_id = gir.gl_sl_link_id


                                     AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                     ),
                                                                                  'YYYY-MM-DD HH24:MI:SS'),
                                                                          to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
         'YYYY-MM-DD HH24:MI:SS')
                                     AND gir.je_header_id = gjh.je_header_id
                                     AND gjh.status = 'P'
                             ) );

                     ELSE
                         l_status_mess := ( '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
                                            || p_prog_val );
                     END IF;
 /*
                 ELSIF p_table_name = 'OE_ORDER_LINES_ALL' THEN
                     l_count := xxccil_cp_check(p_prog_val, l_count);
             --l_count := xxccil_client_superuser_access(p_client_id, l_count);
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
                                         wdd.source_line_id = o1
                               --      AND OOLA.HEADER_ID                 = OHA.HEADER_ID
                                     AND oha.header_id = wdd.source_header_id
                             --        AND OOLA.LINE_ID                   = WDD.SOURCE_LINE_ID
                                     AND wdd.delivery_detail_id = mmt.picking_line_id
                                     AND wdd.source_line_id = mmt.trx_source_line_id
                                     AND mtt.transaction_type_id = mmt.transaction_type_id
                                     AND mtt.transaction_action_id = mmt.transaction_action_id
                                     AND mmt.transaction_id = mta.transaction_id
                                     AND mta.inv_sub_ledger_id = xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type = 'MTL_TRANSACTION_ACCOUNTS'
                                     AND xdl.ae_header_id = xah.ae_header_id
                                     AND xdl.application_id = xah.application_id

                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code = 'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     AND xal.gl_sl_link_id = gir.gl_sl_link_id


                                     AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                     ),
                                                                                  'YYYY-MM-DD HH24:MI:SS'),
                                                                          to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
         'YYYY-MM-DD HH24:MI:SS')
                                     AND gir.je_header_id = gjh.je_header_id
                                     AND gjh.status = 'P'
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
                                         rsl.oe_order_line_id = o1
                                 --    AND OOLA.HEADER_ID                  = OHA.HEADER_ID
                                     AND oha.header_id = rsl.oe_order_header_id
                                 --    AND OOLA.LINE_ID                    = RSL.OE_ORDER_LINE_ID
                                     AND rsl.shipment_line_id = rt.shipment_line_id
                                     AND rt.transaction_type = 'DELIVER'
                                     AND rt.transaction_id = mmt.rcv_transaction_id
                                     AND mmt.transaction_id = mta.transaction_id
                                     AND mta.inv_sub_ledger_id = xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type = 'MTL_TRANSACTION_ACCOUNTS'
                                     AND xdl.ae_header_id = xah.ae_header_id
                                     AND xdl.application_id = xah.application_id

                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code = 'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     AND xal.gl_sl_link_id = gir.gl_sl_link_id


                                     AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                     ),
                                                                                  'YYYY-MM-DD HH24:MI:SS'),
                                                                          to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
         'YYYY-MM-DD HH24:MI:SS')
                                     AND gir.je_header_id = gjh.je_header_id
                                     AND gjh.status = 'P'
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
                               --      AND OOLA.HEADER_ID                  = OHA.HEADER_ID
                                     AND oha.header_id = odss.header_id
                                 --    AND ODSS.LINE_ID                    = OOLA.LINE_ID
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

                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xah.gl_transfer_status_code = 'Y'
                                     AND xah.accounting_entry_status_code = 'F'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     AND xal.gl_sl_link_id = gir.gl_sl_link_id


                                     AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                     ),
                                                                                  'YYYY-MM-DD HH24:MI:SS'),
                                                                          to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
         'YYYY-MM-DD HH24:MI:SS')
                                     AND gir.je_header_id = gjh.je_header_id
                                     AND gjh.status = 'P'
                             ) );

                     ELSE
                         l_status_mess := ( '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
                                            || p_prog_val );
                     END IF;
 */
            /*
                       ELSIF p_table_name = 'FA_ADJUSTMENTS'
                       THEN
                          --l_count := xxccil_cp_check (p_prog_val, l_count);

                          --l_count := xxccil_client_superuser_access(p_client_id, l_count);

                          --         IF l_count = 1
                          --         THEN
                          SELECT COUNT (1)
                            INTO l_count
                            FROM DUAL
                           WHERE EXISTS
                                    (SELECT 1
                                       FROM apps.fa_transaction_headers fth,
                                            apps.xla_events xev,
                                            apps.xla_ae_headers xah,
                                            apps.xla_distribution_links xdl,
                                            apps.xla_ae_lines xal,
                                            apps.gl_je_headers gjh,
                                            apps.gl_import_references gir,
                                            apps.xla_transaction_entities xte
                                      WHERE     fth.transaction_header_id = p_key_value1 --o1
                                            AND fth.event_id = xah.event_id
                                            AND xah.event_id = xev.event_id
                                            AND xev.entity_id = xte.entity_id
                                            AND xte.source_id_int_1 =
                                                   fth.transaction_header_id
                                            AND xah.ae_header_id = xal.ae_header_id
                                            AND xah.ae_header_id = xdl.ae_header_id
                                            AND xdl.ae_line_num = xal.ae_line_num
                                            AND xdl.event_id = xah.event_id
                                            AND xdl.source_distribution_id_num_1 =
                                                   fth.transaction_header_id
                                            AND xah.gl_transfer_status_code = 'Y'
                                            AND xal.gl_sl_link_id = gir.gl_sl_link_id
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
                                                      'YYYY-MM-DD HH24:MI:SS')
                                            AND gjh.je_header_id = gir.je_header_id
                                            AND gjh.status = 'P');
                       --         ELSE
                       --            l_status_mess :=
                       --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
                       --                || p_prog_val);
                       --         END IF;
                       ELSIF p_table_name = 'FA_ASSET_HISTORY'
                       THEN
                          --l_count := xxccil_cp_check (p_prog_val, l_count);

                          --l_count := xxccil_client_superuser_access(p_client_id, l_count);

                          --         IF l_count = 1
                          --         THEN
                          SELECT COUNT (1)
                            INTO l_count
                            FROM DUAL
                           WHERE EXISTS
                                    (SELECT 1
                                       FROM apps.fa_transaction_headers fth,
                                            apps.fa_adjustments fa,
                                            apps.xla_events xev,
                                            apps.xla_ae_headers xah,
                                            apps.xla_distribution_links xdl,
                                            apps.xla_ae_lines xal,
                                            apps.gl_je_headers gjh,
                                            apps.gl_import_references gir,
                                            apps.xla_transaction_entities xte
                                      WHERE     fth.asset_id = p_key_value1 --o1
                                            AND fth.transaction_header_id = p_key_value2 --o2 -- TRANSACTION_HEADER_ID_IN is pk2
                                            AND fth.transaction_header_id =
                                                   fa.transaction_header_id
                                            --        AND FTH.TRANSACTION_HEADER_ID        = FAH.TRANSACTION_HEADER_ID_IN
                                            --        AND FAH.ASSET_ID                     = FTH.ASSET_ID
                                            AND fth.event_id = xah.event_id
                                            AND xah.event_id = xev.event_id
                                            AND xev.entity_id = xte.entity_id
                                            AND xah.ae_header_id = xal.ae_header_id
                                            AND xah.ae_header_id = xdl.ae_header_id
                                            AND xdl.ae_line_num = xal.ae_line_num
                                            AND xdl.event_id = xah.event_id
                                            AND xdl.source_distribution_id_num_1 =
                                                   fth.transaction_header_id
                                            AND xah.gl_transfer_status_code = 'Y'
                                            AND xal.gl_sl_link_id = gir.gl_sl_link_id
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
                                                      'YYYY-MM-DD HH24:MI:SS')
                                            AND gjh.je_header_id = gir.je_header_id
                                            AND gjh.status = 'P');
                       --         ELSE
                       --            l_status_mess :=
                       --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
                       --                || p_prog_val);
                       --         END IF;
                       ELSIF p_table_name = 'FA_BOOKS'
                       THEN
                          --l_count := xxccil_cp_check (p_prog_val, l_count);

                          --l_count := xxccil_client_superuser_access(p_client_id, l_count);
                          --         IF l_count = 1
                          --         THEN
                          SELECT COUNT (1)
                            INTO l_count
                            FROM DUAL
                           WHERE EXISTS
                                    (SELECT 1
                                       FROM apps.fa_transaction_headers fth,
                                            apps.fa_adjustments fa,
                                            apps.xla_events xev,
                                            apps.xla_ae_headers xah,
                                            apps.xla_distribution_links xdl,
                                            apps.xla_ae_lines xal,
                                            apps.gl_je_headers gjh,
                                            apps.gl_import_references gir,
                                            apps.xla_transaction_entities xte
                                      WHERE     fth.transaction_header_id = p_key_value1 --o1
                                            AND fth.transaction_header_id =
                                                   fa.transaction_header_id
                                            AND fth.event_id = xah.event_id
                                            AND xah.event_id = xev.event_id
                                            AND xev.entity_id = xte.entity_id
                                            AND xah.ae_header_id = xal.ae_header_id
                                            AND xah.ae_header_id = xdl.ae_header_id
                                            AND xdl.ae_line_num = xal.ae_line_num
                                            AND xdl.event_id = xah.event_id
                                            AND xdl.source_distribution_id_num_1 =
                                                   fth.transaction_header_id
                                            AND xah.gl_transfer_status_code = 'Y'
                                            AND xal.gl_sl_link_id = gir.gl_sl_link_id
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
                                                      'YYYY-MM-DD HH24:MI:SS')
                                            AND gjh.je_header_id = gir.je_header_id
                                            AND gjh.status = 'P');
                       --         ELSE
                       --            l_status_mess :=
                       --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
                       --                || p_prog_val);
                       --         END IF;
                       ELSIF p_table_name = 'FA_DEPRN_DETAIL'
                       THEN
                          --l_count := xxccil_cp_check (p_prog_val, l_count);

                          --l_count := xxccil_client_superuser_access(p_client_id, l_count);
                          --         IF l_count = 1
                          --         THEN
                          SELECT COUNT (1)
                            INTO l_count
                            FROM DUAL
                           WHERE EXISTS
                                    (SELECT 1
                                       FROM apps.fa_deprn_detail fds,
                                            apps.xla_events xev,
                                            apps.xla_ae_headers xah,
                                            apps.xla_distribution_links xdl,
                                            apps.xla_ae_lines xal,
                                            apps.gl_je_headers gjh,
                                            apps.gl_import_references gir,
                                            apps.xla_transaction_entities xte
                                      WHERE     xdl.source_distribution_id_char_4 = p_key_value1 --o1 --BOOK_TYPE_CODE  as pk1
                                            AND xdl.source_distribution_id_num_1 = p_key_value2 --o2 --ASSET_ID   as pk2
                                            AND xdl.source_distribution_id_num_2 = p_key_value3 --o3 -- PERIOD_COUNTER as pk3
                                            --     AND FDS.EVENT_ID                     = XAH.EVENT_ID



                                            AND xah.event_id = xev.event_id
                                            AND xev.entity_id = xte.entity_id
                                            AND xte.entity_code = 'DEPRECIATION'
                                            AND xah.ae_header_id = xal.ae_header_id
                                            AND xah.ae_header_id = xdl.ae_header_id
                                            AND xdl.ae_line_num = xal.ae_line_num
                                            AND xdl.event_id = xah.event_id
                                            --    AND XDL.SOURCE_DISTRIBUTION_ID_NUM_1 = FDS.ASSET_ID
                                            --    AND XDL.SOURCE_DISTRIBUTION_ID_CHAR_4 = FDS.BOOK_TYPE_CODE
                                            --    AND XDL.SOURCE_DISTRIBUTION_ID_NUM_2 = FDS.PERIOD_COUNTER
                                            --    AND XDL.SOURCE_DISTRIBUTION_ID_NUM_3 = FDS.DEPRN_RUN_ID
                                            AND xah.gl_transfer_status_code = 'Y'
                                            AND xal.gl_sl_link_id = gir.gl_sl_link_id
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
                                                      'YYYY-MM-DD HH24:MI:SS')
                                            AND gjh.je_header_id = gir.je_header_id
                                            AND gjh.status = 'P');
                       --         ELSE
                       --            l_status_mess :=
                       --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
                       --                || p_prog_val);
                       --         END IF;
                       ELSIF p_table_name = 'FA_DISTRIBUTION_HISTORY'
                       THEN
                          --l_count := xxccil_cp_check (p_prog_val, l_count);

                          --l_count := xxccil_client_superuser_access(p_client_id, l_count);
                          --         IF l_count = 1
                          --         THEN
                          SELECT COUNT (1)
                            INTO l_count
                            FROM DUAL
                           WHERE (   EXISTS
                                        (SELECT 1
                                           FROM apps.fa_transaction_headers fth,
                                                apps.fa_adjustments fa,
                                                apps.xla_events xev,
                                                apps.xla_ae_headers xah,
                                                apps.xla_distribution_links xdl,
                                                apps.xla_ae_lines xal,
                                                apps.gl_je_headers gjh,
                                                apps.gl_import_references gir,
                                                apps.xla_transaction_entities xte
                                          WHERE     fth.transaction_header_id = p_key_value1 --o1 --  TRANSACTION_HEADER_ID_IN as pk1
                                                --      AND FDH.TRANSACTION_HEADER_ID_IN     = FTH.TRANSACTION_HEADER_ID
                                                AND fth.transaction_header_id =
                                                       fa.transaction_header_id
                                                AND fth.event_id = xah.event_id
                                                AND xah.event_id = xev.event_id
                                                AND xev.entity_id = xte.entity_id
                                                AND xte.source_id_int_1 =
                                                       fth.transaction_header_id
                                                AND xah.ae_header_id = xal.ae_header_id
                                                AND xah.ae_header_id = xdl.ae_header_id
                                                AND xdl.ae_line_num = xal.ae_line_num
                                                AND xdl.event_id = xah.event_id
                                                AND xdl.source_distribution_id_num_1 =
                                                       fth.transaction_header_id
                                                AND xah.gl_transfer_status_code = 'Y'
                                                AND xal.gl_sl_link_id =
                                                       gir.gl_sl_link_id
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
                                                          'YYYY-MM-DD HH24:MI:SS')
                                                AND gjh.je_header_id = gir.je_header_id
                                                AND gjh.status = 'P')
                                  OR EXISTS
                                        (SELECT 1
                                           FROM apps.fa_transaction_headers fth,
                                                apps.fa_adjustments fa,
                                                apps.xla_events xev,
                                                apps.xla_ae_headers xah,
                                                apps.xla_distribution_links xdl,
                                                apps.xla_ae_lines xal,
                                                apps.gl_je_headers gjh,
                                                apps.gl_import_references gir,
                                                apps.xla_transaction_entities xte
                                          WHERE     fth.transaction_header_id = p_key_value2 --o2 --  TRANSACTION_HEADER_ID_OUT as pk2
                                                --        AND FDH.TRANSACTION_HEADER_ID_OUT        = FTH.TRANSACTION_HEADER_ID
                                                AND fth.transaction_header_id =
                                                       fa.transaction_header_id
                                                AND fth.event_id = xah.event_id
                                                AND xah.event_id = xev.event_id
                                                AND xev.entity_id = xte.entity_id
                                                AND xte.source_id_int_1 =
                                                       fth.transaction_header_id
                                                AND xah.ae_header_id = xal.ae_header_id
                                                AND xah.ae_header_id = xdl.ae_header_id
                                                AND xdl.ae_line_num = xal.ae_line_num
                                                AND xdl.event_id = xah.event_id
                                                AND xdl.source_distribution_id_num_1 =
                                                       fth.transaction_header_id
                                                AND xah.gl_transfer_status_code = 'Y'
                                                AND xal.gl_sl_link_id =
                                                       gir.gl_sl_link_id
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
                                                          'YYYY-MM-DD HH24:MI:SS')
                                                AND gjh.je_header_id = gir.je_header_id
                                                AND gjh.status = 'P'));
                       --         ELSE
                       --            l_status_mess :=
                       --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
                       --                || p_prog_val);
                       --         END IF;
                       ELSIF p_table_name = 'FA_RETIREMENTS'
                       THEN
                          --l_count := xxccil_cp_check (p_prog_val, l_count);

                          --l_count := xxccil_client_superuser_access(p_client_id, l_count);
                          --         IF l_count = 1
                          --         THEN
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
                                                     --    AND FR.TRANSACTION_HEADER_ID_IN     = FTH.TRANSACTION_HEADER_ID
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


                                                         AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                                         ),
                                                                                                      'YYYY-MM-DD HH24:MI:SS'),
                                                                                              to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
                             'YYYY-MM-DD HH24:MI:SS')
                                                         AND gjh.je_header_id = gir.je_header_id
                                                         AND gjh.status = 'P'
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
                                                             fth.transaction_header_id = o2        -- TRANSACTION_HEADER_ID_OUT as pk2
                                                   --      AND FR.TRANSACTION_HEADER_ID_OUT    = FTH.TRANSACTION_HEADER_ID
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


                                                         AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                                         ),
                                                                                                      'YYYY-MM-DD HH24:MI:SS'),
                                                                                              to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
                             'YYYY-MM-DD HH24:MI:SS')
                                                         AND gjh.je_header_id = gir.je_header_id
                                                         AND gjh.status = 'P'
                                                 ) );*/

            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            /*
            ELSIF p_table_name = 'FA_TRANSACTION_HEADERS'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
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
                                              AND xah.event_id = o2
                              --    AND FTH.TRANSACTION_HEADER_ID       = FA.TRANSACTION_HEADER_ID
                              --    AND FTH.EVENT_ID                    = XAH.EVENT_ID
                                              AND xah.event_id = xev.event_id
                                              AND xev.entity_id = xte.entity_id
                                              AND xah.ae_header_id = xal.ae_header_id
                                              AND xah.ae_header_id = xdl.ae_header_id
                                              AND xdl.ae_line_num = xal.ae_line_num
                                              AND xdl.event_id = xah.event_id
                              --    AND XDL.SOURCE_DISTRIBUTION_ID_NUM_1 = FTH.TRANSACTION_HEADER_ID
                                              AND xah.gl_transfer_status_code = 'Y'
                                              AND xal.gl_sl_link_id = gir.gl_sl_link_id


                                              AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                              ),
                                                                                           'YYYY-MM-DD HH24:MI:SS'),
                                                                                   to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
                  'YYYY-MM-DD HH24:MI:SS')
                                              AND gjh.je_header_id = gir.je_header_id
                                              AND gjh.status = 'P'
                                      ); */

            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            /*
            ELSIF p_table_name = 'FA_DEPRN_SUMMARY'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
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
                                                 apps.xla_events               xev,
                                                 apps.xla_ae_headers           xah,
                                                 apps.xla_distribution_links   xdl,
                                                 apps.xla_ae_lines             xal,
                                                 apps.gl_je_headers            gjh,
                                                 apps.gl_import_references     gir,
                                                 apps.xla_transaction_entities xte
                                             WHERE
                                                     xdl.source_distribution_id_char_4 = o1
                                                 AND xdl.source_distribution_id_num_1 = o2
                                                 AND xdl.source_distribution_id_num_2 = o3
                                 --    AND FDS.EVENT_ID                        = XAH.EVENT_ID
                                                 AND xah.event_id = xev.event_id
                                                 AND xev.entity_id = xte.entity_id
                                                 AND xte.entity_code = 'DEPRECIATION'
                                                 AND xah.ae_header_id = xal.ae_header_id
                                                 AND xah.ae_header_id = xdl.ae_header_id
                                                 AND xdl.ae_line_num = xal.ae_line_num
                                                 AND xdl.event_id = xah.event_id
                                 --    AND XDL.SOURCE_DISTRIBUTION_ID_NUM_1    = FDS.ASSET_ID
                                 --    AND XDL.SOURCE_DISTRIBUTION_ID_CHAR_4   = FDS.BOOK_TYPE_CODE
                                 --    AND XDL.SOURCE_DISTRIBUTION_ID_NUM_2    = FDS.PERIOD_COUNTER
                                 --    AND XDL.SOURCE_DISTRIBUTION_ID_NUM_3    = FDS.DEPRN_RUN_ID
                                                 AND xah.gl_transfer_status_code = 'Y'
                                                 AND xal.gl_sl_link_id = gir.gl_sl_link_id


                                                 AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'
                                                 ),
                                                                                              'YYYY-MM-DD HH24:MI:SS'),
                                                                                      to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
                     'YYYY-MM-DD HH24:MI:SS')
                                                 AND gjh.je_header_id = gir.je_header_id
                                                 AND gjh.status = 'P'
                                         ); */

            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            ELSIF p_table_name = 'AR_DISTRIBUTIONS_ALL'
            THEN
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM xla_events xe,
                                 xla_ae_headers xah,
                                 xla_distribution_links xdl,
                                 xla_ae_lines xal
                           WHERE     xdl.source_distribution_id_num_1 =
                                        p_key_value1    -- o1 --LINE_ID is PK1
                                 AND xdl.source_distribution_type =
                                        'AR_DISTRIBUTIONS_ALL'
                                 AND xah.ae_header_id = xdl.ae_header_id
                                 AND xdl.ae_line_num = xdl.ae_line_num
                                 AND xe.entity_id = xah.entity_id
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xah.ae_header_id = xal.ae_header_id
                                 -- to check for p_collection_time greater than xla posted date


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
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            ELSIF p_table_name = 'XLA_DISTRIBUTION_LINKS'
            THEN
               -- l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM xla_ae_headers xah, xla_ae_lines xal
                           WHERE     xah.ae_header_id = xal.ae_header_id
                                 AND xah.ae_header_id = p_key_value1 --o1 -- AE_HEADER_ID is pk1
                                 AND xal.ae_line_num = p_key_value2 --o2 --AE_LINE_NUM is pk2
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 -- to check for p_collection_time greater than xla posted date



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
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            -----changes start for gia spacific table
            /*
            ELSIF p_table_name = 'XLA_EVENTS'
            THEN                                                        --Giea
               --  l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM xla_events xe,
                                 xla_ae_headers xah,
                                 xla_ae_lines xal,
                                 xla_distribution_links xdl
                           WHERE     xe.event_id = p_key_value1--o1       -- EVENT_ID is pk1
                                 AND xe.entity_id = xah.entity_id
                                 AND xe.event_id = xah.event_id
                                 AND xah.ae_header_id = xal.ae_header_id
                                 AND xdl.ae_header_id = xah.ae_header_id
                                 AND xdl.ae_line_num = xal.ae_line_num
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 AND xe.event_status_code = 'P'
                                 AND xe.process_status_code = 'P'
                                 -- to check for p_collection_time greater than xla posted date
                                 AND xal.last_update_date <=
                                        NVL (
                                           TO_DATE (p_collection_time,
                                                    'YYYY-MM-DD HH24:MI:SS'),
                                           xal.last_update_date));
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            */
            ELSIF p_table_name = 'XLA_AE_LINES'
            THEN                                                        --Giea
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM xla_ae_lines xal, xla_ae_headers xah
                           WHERE     xal.ae_header_id = p_key_value1 --o1 -- AE_HEADER_ID is pk1
                                 AND xal.ae_line_num = p_key_value2 --o2 --AE_LINE_NUM    is pk2
                                 AND xal.ae_header_id = xah.ae_header_id
                                 AND xah.gl_transfer_status_code = 'Y'
                                 AND xah.accounting_entry_status_code = 'F'
                                 -- to check for p_collection_time greater than xla posted date



                                 AND xal.last_update_date <=
                                        NVL (
                                           TO_DATE (p_collection_time,
                                                    'YYYY-MM-DD HH24:MI:SS'),
                                           xal.last_update_date));
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            -- Commented Below tables as per requirement by Aditya R on 17-Jun-2025 CRQ  CHG0230785
            /*ELSIF p_table_name = 'XXC10679_IMP_BOE_HDR'
            THEN                                                        --Giea
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE (   EXISTS
                             (SELECT 1
                                FROM xxc10679_imp_boe_inv xibi,
                                     xxc10584_imp_inv_hdr xiih,
                                     rcv_transactions rt,
                                     rcv_receiving_sub_ledger rrsl,
                                     xla_distribution_links xdl,
                                     xla_events xe,
                                     xla_ae_headers xah,
                                     xla_ae_lines xal
                               WHERE     xibi.jobno = o1       -- JOBNO is pk1
                                     AND xibi.org_id = o2    -- ORG_ID  is pk2
                                     AND xiih.invnosupl = xibi.invnosupl
                                     AND rt.shipment_header_id =
                                            xiih.shipment_header_id
                                     AND rt.transaction_id =
                                            rrsl.rcv_transaction_id
                                     AND rrsl.rcv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'RCV_RECEIVING_SUB_LEDGER'
                                     AND xdl.ae_header_id = xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     -- to check for p_collection_time greater than xla posted date


                                     AND xal.last_update_date <=
                                            NVL (
                                               TO_DATE (
                                                  p_collection_time,
                                                  'YYYY-MM-DD HH24:MI:SS'),
                                               xal.last_update_date))
                       OR EXISTS
                             (SELECT 1
                                FROM xxc10679_imp_boe_inv xibi,
                                     xxc10584_imp_inv_hdr xiih,
                                     rcv_transactions rt,
                                     mtl_material_transactions mmt,
                                     mtl_transaction_accounts mta,
                                     xla_transaction_entities xte,
                                     xla_events xe,
                                     xla_distribution_links xdl,
                                     xla_ae_headers xah,
                                     xla_ae_lines xal
                               WHERE     xibi.jobno = o1       -- JOBNO is pk1
                                     AND xibi.org_id = o2    -- ORG_ID  is pk2
                                     AND xiih.invnosupl = xibi.invnosupl
                                     AND rt.shipment_header_id =
                                            xiih.shipment_header_id
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
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     -- to check for p_collection_time greater than xla posted date


                                     AND xal.last_update_date <=
                                            NVL (
                                               TO_DATE (
                                                  p_collection_time,
                                                  'YYYY-MM-DD HH24:MI:SS'),
                                               xal.last_update_date)));
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            ELSIF p_table_name = 'XXC10679_IMP_BOE_INV'
            THEN                                                        --Giea
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE (   EXISTS
                             (SELECT 1
                                FROM xxc10679_imp_boe_hdr xibh,
                                     xxc10584_imp_inv_hdr xiih,
                                     rcv_transactions rt,
                                     rcv_receiving_sub_ledger rrsl,
                                     xla_distribution_links xdl,
                                     xla_events xe,
                                     xla_ae_headers xah,
                                     xla_ae_lines xal
                               WHERE     xibh.jobno = o1       -- JOBNO is pk1
                                     AND xibh.org_id = o2    -- ORG_ID  is pk2
                                     AND xiih.invnosupl = o3 -- INVNOSUPL is pk3
                                     AND rt.shipment_header_id =
                                            xiih.shipment_header_id
                                     AND rt.transaction_id =
                                            rrsl.rcv_transaction_id
                                     AND rrsl.rcv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'RCV_RECEIVING_SUB_LEDGER'
                                     AND xdl.ae_header_id = xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     -- to check for p_collection_time greater than xla posted date


                                     AND xal.last_update_date <=
                                            NVL (
                                               TO_DATE (
                                                  p_collection_time,
                                                  'YYYY-MM-DD HH24:MI:SS'),
                                               xal.last_update_date))
                       OR EXISTS
                             (SELECT 1
                                FROM xxc10679_imp_boe_hdr xibh,
                                     xxc10584_imp_inv_hdr xiih,
                                     rcv_transactions rt,
                                     mtl_material_transactions mmt,
                                     mtl_transaction_accounts mta,
                                     xla_transaction_entities xte,
                                     xla_events xe,
                                     xla_distribution_links xdl,
                                     xla_ae_headers xah,
                                     xla_ae_lines xal
                               WHERE     xibh.jobno = o1       -- JOBNO is pk1
                                     AND xibh.org_id = o2    -- ORG_ID  is pk2
                                     AND xiih.invnosupl = o3 -- INVNOSUPL is pk3
                                     AND rt.shipment_header_id =
                                            xiih.shipment_header_id
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
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     -- to check for p_collection_time greater than xla posted date


                                     AND xal.last_update_date <=
                                            NVL (
                                               TO_DATE (
                                                  p_collection_time,
                                                  'YYYY-MM-DD HH24:MI:SS'),
                                               xal.last_update_date)));
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            ELSIF p_table_name = 'XXC10679_IMP_BOE_PARTS'
            THEN                                                   --Giea XIBP
               --l_count := xxccil_cp_check (p_prog_val, l_count);

               --l_count := xxccil_client_superuser_access(p_client_id, l_count);
               --         IF l_count = 1
               --         THEN
               SELECT COUNT (1)
                 INTO l_count
                 FROM DUAL
                WHERE (   EXISTS
                             (SELECT 1
                                FROM xxc10679_imp_boe_parts xibp,
                                     xxc10679_imp_boe_hdr xibh,
                                     xxc10679_imp_boe_inv xibi,
                                     xxc10584_imp_inv_hdr xiih,
                                     rcv_transactions rt,
                                     rcv_receiving_sub_ledger rrsl,
                                     xla_distribution_links xdl,
                                     xla_events xe,
                                     xla_ae_headers xah,
                                     xla_ae_lines xal
                               WHERE     xibp.jobno = o1       -- jobno is pk1
                                     AND xibp.org_id = o2      --org_id is pk2
                                     AND xibp.invnosupl = o3 -- INVNOSUPL is pk3
                                     AND xibp.bpsrno = o4      --BPSRNO is pk4
                                     AND xibp.jobno = xibh.jobno
                                     AND xibp.org_id = xibh.org_id
                                     AND xibp.invnosupl = xiih.invnosupl
                                     AND xibp.invnosupl = xibi.invnosupl
                                     AND xibi.jobno = xibh.jobno
                                     AND xibi.org_id = xibh.org_id
                                     AND xiih.invnosupl = xibi.invnosupl
                                     AND rt.shipment_header_id =
                                            xiih.shipment_header_id
                                     AND rt.transaction_id =
                                            rrsl.rcv_transaction_id
                                     AND rrsl.rcv_sub_ledger_id =
                                            xdl.source_distribution_id_num_1
                                     AND xdl.source_distribution_type =
                                            'RCV_RECEIVING_SUB_LEDGER'
                                     AND xdl.ae_header_id = xah.ae_header_id
                                     AND xdl.application_id =
                                            xah.application_id
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     -- to check for p_collection_time greater than xla posted date


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
                                               'YYYY-MM-DD HH24:MI:SS'))
                       OR EXISTS
                             (SELECT 1
                                FROM xxc10679_imp_boe_parts xibp,
                                     xxc10679_imp_boe_hdr xibh,
                                     xxc10584_imp_inv_hdr xiih,
                                     xxc10679_imp_boe_inv xibi,
                                     rcv_transactions rt,
                                     mtl_material_transactions mmt,
                                     mtl_transaction_accounts mta,
                                     xla_transaction_entities xte,
                                     xla_events xe,
                                     xla_distribution_links xdl,
                                     xla_ae_headers xah,
                                     xla_ae_lines xal
                               WHERE     xibp.jobno = o1       -- jobno is pk1
                                     AND xibp.org_id = o2      --org_id is pk2
                                     AND xibp.invnosupl = o3 -- INVNOSUPL is pk3
                                     AND xibp.bpsrno = o4      --BPSRNO is pk4
                                     AND xibp.jobno = xibh.jobno
                                     AND xibp.org_id = xibh.org_id
                                     AND xibp.invnosupl = xiih.invnosupl
                                     AND xibp.invnosupl = xibi.invnosupl
                                     AND xibi.jobno = xibh.jobno
                                     AND xibi.org_id = xibh.org_id
                                     AND xiih.invnosupl = xibi.invnosupl
                                     AND rt.shipment_header_id =
                                            xiih.shipment_header_id
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
                                     AND xdl.ae_line_num = xal.ae_line_num
                                     AND xe.event_status_code = 'P'
                                     AND xe.process_status_code = 'P'
                                     AND xe.entity_id = xah.entity_id
                                     AND xah.ae_header_id = xal.ae_header_id
                                     -- to check for p_collection_time greater than xla posted date


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
                                               'YYYY-MM-DD HH24:MI:SS')));*/
            --         ELSE
            --            l_status_mess :=
            --               (   '2 Program is either a concurrent program or run by the Concurrent Manager Program is := '
            --                || p_prog_val);
            --         END IF;
            --      END IF;            ELSE
            --                l_status_mess := ( '1 New value and Old value is same' );
            --            END IF;

            ELSE
               l_count := 1;                  --Capturing record for new table
               L_STATUS_MESS := P_TABLE_NAME || ' TABLE NOT FOUND IN THE PACKAGE.';
            END IF;
         END IF;
      ELSE
         l_status_mess :=
            (   'Program is either a concurrent program or run by the Concurrent Manager Program is := '
             || p_prog_val);
      END IF;

      IF (l_count = 0 AND l_status_mess IS NULL)
      THEN
         l_status_mess := 'UNPOSTED TRANSACTION,HENCE IGNORING RECORD';
      ELSIF l_count = 1 AND l_status_mess IS NULL
      THEN
         l_status_mess := 'RECORD IS ELIGIBLE WILL GET CAPTURED IN GG';
      END IF;

      COMMIT;
      xxccil_insert_debug_log (p_table_name,
                               l_key_value,
                               l_count,
                               -- l_old_val,             --Commented by Aditya R on 17-Jun-2025 CRQ CHG0230785
                               -- l_new_val,             --Commented by Aditya R on 17-Jun-2025 CRQ CHG0230785
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
            || ' AND p_key_value1,p_key_value2,p_key_value3 are  '
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
         --
         xxccil_insert_debug_log (p_table_name,
                                  l_key_value,
                                  l_count,
                                  --    l_old_val,       --Commented by Aditya R on 17-Jun-2025 CRQ CHG0230785
                                  --    l_new_val,       --Commented by Aditya R on 17-Jun-2025 CRQ CHG0230785
                                  l_status_mess);
   END xxccil_gg_filter_condition_prc;


   -- Function is to check whether the client is having super user access or not

   FUNCTION xxccil_client_superuser_access (p_client_id    VARCHAR2,
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
   END xxccil_client_superuser_access;

   ---- Function is to check the p_prog_val is excluded CP or not            --1.1 changes start

   FUNCTION xxccil_cp_check (p_prog_val VARCHAR2, p_qry_cnt NUMBER,p_client_id   IN VARCHAR2)   -- Changed by Aditya R for CHG0250599
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
                            fnd_concurrent_queues fcq,
                            (SELECT SUBSTR (p_prog_val,
                                            1,
                                            (INSTR (p_prog_val, '@') - 1))
                                       AS program
                               FROM DUAL) cp_check
                      WHERE    program = fcp.concurrent_program_name
                            OR program = fcq.concurrent_queue_name)
                            AND p_prog_val not like 'rwrun%'                                          -- Added by Aditya R on 20-Aug-2025 for CHG0250599
                            AND (p_client_id is null OR p_client_id != 'INTERFACE' OR p_prog_val not like 'sqlplus%');                  -- Added by Aditya R on 22-Aug-2025 for CHG0250599

      RETURN l_count;
   END xxccil_cp_check;                                      --1.1 changes end
END xxccil_gg_filter_condition_pkg;
/
