/* Formatted on 3/24/2025 11:51:13 AM (QP5 v5.336) */
CREATE OR REPLACE PROCEDURE APPS.ADOR_AR_INV_MIG (errbuf     VARCHAR2,
                                                  retcode    NUMBER,
                                                  p_org_id   NUMBER-- p_INTERFACE_LINE_CONTEXT   VARCHAR2
                                                                   )
AS
    -- Purpose : Create Invoice using .csv file

    CURSOR c1 IS SELECT * FROM CUS.ADOR_CM_DM_MAP;

    --WHERE created_by = fnd_global.user_id;

    CURSOR c2 IS
        SELECT *
          FROM CUS.ADOR_CM_DM_MAP
         WHERE 1 = 1                         --created_by = fnd_global.user_id
                     AND ERR_MSG IS NULL AND ERR_FLAG = 'Y';

    v_sales_rep_id          NUMBER;
    v_bill_to_customer      NUMBER;
    v_bill_to_address_id    NUMBER;
    v_bill_to_site_use_id   NUMBER;
    v_ship_to_customer      NUMBER;
    v_ship_to_address_id    NUMBER;
    v_ship_to_site_use_id   NUMBER;
    v_sp_rec_segment1       VARCHAR2 (15);
    v_sp_rec_segment2       VARCHAR2 (15);
    v_sp_rec_segment3       VARCHAR2 (15);
    v_sp_rec_segment4       VARCHAR2 (15);
    v_type_rec_segment5     VARCHAR2 (15); -- segment5 from Transaction type rest all from Sales person
    v_sp_rec_segment6       VARCHAR2 (15);
    v_sp_rec_segment7       VARCHAR2 (15);
    v_sp_rec_segment8       VARCHAR2 (15);
    v_sp_rev_segment1       VARCHAR2 (15);
    v_sp_rev_segment2       VARCHAR2 (15);
    v_sp_rev_segment3       VARCHAR2 (15);
    v_sp_rev_segment4       VARCHAR2 (15);
    v_type_rev_segment5     VARCHAR2 (15); -- segment5 from Transaction type rest all from Sales person
    v_sp_rev_segment6       VARCHAR2 (15);
    v_sp_rev_segment7       VARCHAR2 (15);
    v_sp_rev_segment8       VARCHAR2 (15);
    v_cust_trx_type_id      NUMBER;
    v_rec_ccid              NUMBER;
    v_rev_ccid              NUMBER;
    v_amount                NUMBER;
    v_batch_source_name     VARCHAR2 (100);
    v_PAYMENT_TERM          VARCHAR2 (20) := NULL;
    v_type                  VARCHAR2 (10) := NULL;
    v_valid                 CHAR (1) := 'Y';
    v_TAX_CATEGORY_ID       NUMBER;
    v_third_party_cnt       NUMBER;
    v_date_cnt              NUMBER := 0;
    v_exiting_inv           VARCHAR2 (50) := NULL;
    v_existing_date         DATE;
    v_exiting_inv_cnt       NUMBER := 0;
    v_duplicate_QT_No       NUMBER := 0;
    V_LINE_NUMBER           NUMBER := 1;
    V_SET_OF_BOOKS_ID       NUMBER;
    V_ERR_MSG               VARCHAR2 (2000);
    v_sales_rep_number      VARCHAR2 (30 BYTE);
    V_ORG_ID                NUMBER;
    v_process_flag          VARCHAR2 (1);
    V_PROCESS_MSG           VARCHAR2 (2000);
BEGIN
    -- Checking if organization exists in org_organization definition

    BEGIN
        SELECT 1
          INTO V_ORG_ID
          FROM HR_OPERATING_UNITS
         WHERE ORGANIZATION_ID = P_ORG_ID;
    EXCEPTION
        WHEN OTHERS
        THEN
            DBMS_OUTPUT.PUT_LINE ('Operating unit not found  ' || p_org_id);
            fnd_file.put_line (fnd_file.output,
                               'Operating unit not found  ' || p_org_id);
    END;


    IF (V_ORG_ID IS NOT NULL)
    THEN
        UPDATE CUS.ADOR_CM_DM_MAP
           SET ORG_ID = P_ORG_ID;

        COMMIT;

        fnd_file.put_line (
            fnd_file.output,
            'Operating unit updated in staging table as: ' || p_org_id);

        v_valid := 'Y';

        fnd_file.put_line (fnd_file.output, 'Validating data..');

        FOR inv_data IN c1
        LOOP
            BEGIN
                SELECT name
                  INTO v_batch_source_name
                  FROM ra_batch_sources_all
                 WHERE name = inv_data.BATCH_SOUR     -- From the custom table
                                                  AND org_id = p_org_id;
            EXCEPTION
                WHEN OTHERS
                THEN
                    DBMS_OUTPUT.PUT_LINE (
                        'Batch Source not found ->  ' || inv_data.BATCH_SOUR);
                    fnd_file.put_line (
                        fnd_file.output,
                        'Batch Source not found ->  ' || inv_data.BATCH_SOUR);
                    v_valid := 'N';
                    V_ERR_MSG := 'Invalid Batch Name';
            END;


            BEGIN
                SELECT SALESREP_ID, SALESREP_NUMBER
                  INTO v_sales_rep_id, v_sales_rep_number
                  FROM apps.JTF_RS_DEFRESOURCES_V jtrd, JTF_RS_SALESREPS jtrs
                 WHERE     jtrd.resource_id = jtrs.resource_Id
                       AND UPPER (RESOURCE_NAME) =
                           UPPER (inv_data.SALES_PERSON) --inv_trx_data.SALES_PERSON
                       AND jtrs.org_id = p_org_id
                       AND STATUS = 'A';
            EXCEPTION
                WHEN OTHERS
                THEN
                    DBMS_OUTPUT.PUT_LINE (
                           'Sale Person not found. Check Sales Person -> '
                        || inv_data.SALES_PERSON);
                    fnd_file.put_line (
                        fnd_file.output,
                           'Sale Person not found. Check Sales Person -> '
                        || inv_data.SALES_PERSON);
                    v_valid := 'N';
                    V_ERR_MSG := V_ERR_MSG || ' Invalid Sales Person';
            END;


            BEGIN
                SELECT cust_trx_type_id
                  INTO v_cust_trx_type_id
                  FROM ra_cust_trx_types_all rtype
                 WHERE     rtype.name = inv_data.TRANSACTION_TYPE
                       AND org_id = p_org_id;
            EXCEPTION
                WHEN OTHERS
                THEN
                    DBMS_OUTPUT.PUT_LINE (
                           'Transaction Type not found. Check Transaction Type -> '
                        || inv_data.TRANSACTION_TYPE);
                    fnd_file.put_line (
                        fnd_file.output,
                           'Transaction Type not found. Check Transaction Type -> '
                        || inv_data.TRANSACTION_TYPE);
                    v_valid := 'N';
                    V_ERR_MSG := V_ERR_MSG || ' Invalid Transaction type';
            END;


            BEGIN
                SELECT hca.CUST_ACCOUNT_ID,
                       hcasa.cust_acct_site_id,
                       hcus.site_use_id,
                       'IMMEDIATE'
                  INTO v_bill_to_customer,
                       v_bill_to_address_id,
                       v_bill_to_site_use_id,
                       v_payMENT_TERM
                  FROM hz_cust_accounts        hca,
                       hz_cust_site_uses_all   hcus,
                       hz_cust_acct_sites_all  hcasa
                 WHERE     1 = 1
                       AND hcasa.cust_acct_site_id = hcus.cust_acct_site_id
                       AND hcasa.status = 'A'
                       AND hcus.status = 'A'
                       AND hcus.location = inv_data.BILL_TO_SITE_NAME
                       AND hcus.site_use_code = 'BILL_TO'
                       AND hcasa.org_id = hcus.org_id
                       AND hcasa.cust_account_id = hca.cust_account_id
                       AND hcasa.org_id = p_org_id
                       AND hca.account_number =
                           inv_data.BILL_TO_CUSTOMER_NUMBER;
            --fnd_file.put_line (fnd_file.output, 'Payment Term is  ->  '||v_payMENT_TERM);

            EXCEPTION
                WHEN OTHERS
                THEN
                    DBMS_OUTPUT.PUT_LINE (
                           'Customer not found or Bill to site is not Found. Customer Number -> '
                        || inv_data.BILL_TO_CUSTOMER_NUMBER
                        || '-'
                        || inv_data.BILL_TO_SITE_NAME);
                    fnd_file.put_line (
                        fnd_file.output,
                           'Customer not found or Bill to site is not Found. Customer Number -> '
                        || inv_data.BILL_TO_CUSTOMER_NUMBER
                        || '-'
                        || inv_data.BILL_TO_SITE_NAME);
                    v_valid := 'N';
                    V_ERR_MSG :=
                           V_ERR_MSG
                        || ' Invalid Bill to site or Customer Number.';
            END;


            BEGIN
                SELECT hca.CUST_ACCOUNT_ID,
                       hcasa.cust_acct_site_id,
                       hcus.site_use_id,
                       'IMMEDIATE'
                  INTO v_ship_to_customer,
                       v_ship_to_address_id,
                       v_ship_to_site_use_id,
                       v_payMENT_TERM
                  FROM hz_cust_accounts        hca,
                       hz_cust_site_uses_all   hcus,
                       hz_cust_acct_sites_all  hcasa
                 WHERE     1 = 1
                       AND hcasa.cust_acct_site_id = hcus.cust_acct_site_id
                       --and     hcus.primary_flag = 'Y'
                       AND hcasa.status = 'A'
                       AND hcus.status = 'A'
                       AND hcus.location = inv_data.SHIP_TO_SITE_NAME
                       AND hcus.site_use_code = 'SHIP_TO'
                       AND hcasa.org_id = hcus.org_id
                       AND hcasa.cust_account_id = hca.cust_account_id
                       AND hcasa.org_id = p_org_id
                       AND hca.account_number =
                           inv_data.SHIP_TO_CUSTOMER_NUMBER;
            EXCEPTION
                WHEN OTHERS
                THEN
                    DBMS_OUTPUT.PUT_LINE (
                           'Customer not found or Ship to site is not found. Customer Number -> '
                        || inv_data.SHIP_TO_CUSTOMER_NUMBER
                        || '-'
                        || inv_data.SHIP_TO_SITE_NAME);
                    fnd_file.put_line (
                        fnd_file.output,
                           'Customer not found or Ship to site is not found. Customer Number -> '
                        || inv_data.SHIP_TO_CUSTOMER_NUMBER
                        || '-'
                        || inv_data.SHIP_TO_SITE_NAME);
                    v_valid := 'N';
                    V_ERR_MSG :=
                           V_ERR_MSG
                        || ' Invalid Ship to site or Customer Number.';
            END;

            BEGIN
                SELECT                                        --glcc.segment5,
                       rtype.TYPE
                  --INTO v_type_rec_segment5,
                  INTO v_type
                  FROM ra_cust_trx_types_all rtype --, gl_code_combinations glcc
                 WHERE     1 = 1
                       --   AND rtype.gl_id_rec = glcc.code_combination_id
                       AND rtype.name = inv_data.TRANSACTION_TYPE
                       AND org_id = p_org_id;
            EXCEPTION
                WHEN OTHERS
                THEN
                    DBMS_OUTPUT.PUT_LINE (
                           'Receivable gl_code from Transaction Type not found. Transaction Type is ->  '
                        || inv_data.TRANSACTION_TYPE);
                    fnd_file.put_line (
                        fnd_file.output,
                           'Receivable gl_code from Transaction Type not found. Transaction Type is ->  '
                        || inv_data.TRANSACTION_TYPE);
                    v_valid := 'N';
            END;

            IF v_type = 'CM'
            THEN
                v_payMENT_TERM := NULL;
            ELSE
                v_payMENT_TERM := inv_data.PAYMENT_TERM;
            END IF;

            --v_payMENT_TERM := inv_data.PAYMENT_TERM;

            IF (v_payMENT_TERM = 'XXX' AND v_type <> 'CM')
            THEN
                DBMS_OUTPUT.PUT_LINE (
                       'Payment Term is not valid for Customer Number  ->  '
                    || inv_data.BILL_TO_CUSTOMER_NUMBER
                    || '-'
                    || inv_data.PAYMENT_TERM);
                fnd_file.put_line (
                    fnd_file.output,
                       'Payment Term is not valid for Customer Number  ->  '
                    || inv_data.BILL_TO_CUSTOMER_NUMBER
                    || '-'
                    || inv_data.PAYMENT_TERM);
                v_valid := 'N';
            END IF;


            BEGIN
                -- for duplicate inv number checking
                SELECT COUNT (1)
                  INTO v_duplicate_QT_No
                  FROM CUS.ADOR_CM_DM_MAP a
                 WHERE     1 = 1        --   a.created_by = fnd_global.user_id
                       AND a.Transaction_Number = inv_data.Transaction_Number;

                IF v_duplicate_QT_No > 1
                THEN
                    DBMS_OUTPUT.PUT_LINE (
                           'File has duplicate Quotation Numbers ->  '
                        || 'Quotation Number  ->'
                        || inv_data.Transaction_Number);
                    v_valid := 'N';
                    fnd_file.put_line (
                        fnd_file.output,
                           'File has duplicate Quotation Numbers ->  '
                        || 'Quotation Number  ->'
                        || inv_data.Transaction_Number);
                    V_ERR_MSG :=
                        V_ERR_MSG || ' Duplicate Inv number in file.';
                END IF;


                --------------------------  check 21mar25 ---------------
                SELECT COUNT (1)
                  INTO v_exiting_inv_cnt
                  FROM ra_customer_Trx_all rhead
                 WHERE     1 = 1
                       AND rhead.TRX_NUMBER = inv_data.Transaction_Number
                       AND rhead.org_id = p_org_id;

                IF v_exiting_inv_cnt > 0
                THEN
                    SELECT trx_number, trx_date
                      INTO v_exiting_inv, v_existing_date
                      FROM ra_customer_Trx_all rhead
                     WHERE     1 = 1
                           AND rhead.TRX_NUMBER = inv_data.Transaction_Number
                           AND rhead.org_id = p_org_id;

                    IF v_exiting_inv IS NOT NULL
                    THEN
                        DBMS_OUTPUT.PUT_LINE (
                               'Number given in grouping field Already Exists For ->  '
                            || 'Grouping Field ->'
                            || inv_data.Transaction_Number
                            || ' Used For Transaction Number ->'
                            || v_exiting_inv
                            || ' Transaction Date  -->'
                            || v_existing_date);

                        v_valid := 'N';

                        fnd_file.put_line (
                            fnd_file.output,
                               'Number given in grouping field Already Exists For ->  '
                            || 'Grouping Field ->'
                            || inv_data.Transaction_Number
                            || ' Used For Transaction Number ->'
                            || v_exiting_inv
                            || ' Transaction Date  -->'
                            || v_existing_date);
                        V_ERR_MSG :=
                            V_ERR_MSG || ' Invocie number already exists.';
                    END IF;
                END IF;
            END;

            DBMS_OUTPUT.put_line (
                'Err_msg : ' || v_err_msg || '  err_flag : ' || v_valid);

            UPDATE CUS.ADOR_CM_DM_MAP
               SET ERR_MSG = V_ERR_MSG, ERR_FLAG = v_valid
             WHERE     Transaction_Number = inv_data.Transaction_Number
                   AND org_ID = p_org_id;

            COMMIT;
        END LOOP;

        COMMIT;
        --- end loop for validation

        fnd_file.put_line (fnd_file.output, 'Data validation done ..');


        V_VALID := 'Y';
        ----------------------------------------------------------------------

        fnd_file.put_line (
            fnd_file.output,
            'Inserting data into interface from stagin table...');

        IF v_valid = 'Y'
        THEN
            FOR inv_trx_data IN C2
            LOOP
                V_PROCESS_FLAG := NULL;
                V_PROCESS_MSG := NULL;

                BEGIN
                    -- CALCULATING SET OF BOOKS ID
                    SELECT SET_OF_BOOKS_ID
                      INTO V_SET_OF_BOOKS_ID
                      FROM GL_SETS_OF_BOOKS
                     WHERE NAME = inv_trx_data.SET_OF_BOOKS_NAME;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        DBMS_OUTPUT.PUT_LINE (
                            'SET OF BOOKS ERROR!' || V_SET_OF_BOOKS_ID);
                        fnd_file.put_line (
                            fnd_file.output,
                            'SET OF BOOKS ERROR!' || V_SET_OF_BOOKS_ID);
                END;

                BEGIN
                    SELECT name
                      INTO v_batch_source_name
                      FROM ra_batch_sources_all
                     WHERE     name = inv_trx_data.BATCH_SOUR
                           AND org_id = p_org_id;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        DBMS_OUTPUT.PUT_LINE (
                               'Batch Source not found ->  '
                            || inv_trx_data.BATCH_SOUR);
                        fnd_file.put_line (
                            fnd_file.output,
                               'Batch Source not found ->  '
                            || inv_trx_data.BATCH_SOUR);
                        v_valid := 'N';
                END;



                BEGIN
                    SELECT SALESREP_ID, SALESREP_NUMBER
                      INTO v_sales_rep_id, v_sales_rep_number
                      FROM apps.JTF_RS_DEFRESOURCES_V  jtrd,
                           JTF_RS_SALESREPS            jtrs
                     WHERE     jtrd.resource_id = jtrs.resource_Id
                           AND UPPER (RESOURCE_NAME) =
                               UPPER (inv_trx_data.SALES_PERSON) --inv_trx_data.SALES_PERSON
                           AND jtrs.org_id = p_org_id
                           AND STATUS = 'A';
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        DBMS_OUTPUT.PUT_LINE (
                               'Sale Person not found. Check Sales Person -> '
                            || inv_trx_data.SALES_PERSON);
                        fnd_file.put_line (
                            fnd_file.output,
                               'Sale Person not found. Check Sales Person -> '
                            || inv_trx_data.SALES_PERSON);
                        v_valid := 'N';
                END;


                BEGIN
                    SELECT cust_trx_type_id
                      INTO v_cust_trx_type_id
                      FROM ra_cust_trx_types_all rtype
                     WHERE     rtype.name = inv_trx_data.TRANSACTION_TYPE
                           AND org_id = p_org_id;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        DBMS_OUTPUT.PUT_LINE (
                               'Transaction Type not found. Check Transaction Type -> '
                            || inv_trx_data.TRANSACTION_TYPE);
                        fnd_file.put_line (
                            fnd_file.output,
                               'Transaction Type not found. Check Transaction Type -> '
                            || inv_trx_data.TRANSACTION_TYPE);
                        v_valid := 'N';
                END;

                DBMS_OUTPUT.PUT_LINE (
                    'Transaction Type id ---> ' || v_cust_trx_type_id);


                BEGIN
                    SELECT hca.CUST_ACCOUNT_ID,
                           hcasa.cust_acct_site_id,
                           hcus.site_use_id,
                           'IMMEDIATE'
                      INTO v_bill_to_customer,
                           v_bill_to_address_id,
                           v_bill_to_site_use_id,
                           v_payMENT_TERM
                      FROM hz_cust_accounts        hca,
                           hz_cust_site_uses_all   hcus,
                           hz_cust_acct_sites_all  hcasa
                     WHERE     1 = 1
                           AND hcasa.cust_acct_site_id =
                               hcus.cust_acct_site_id
                           --and     hcus.primary_flag = 'Y'
                           AND hcasa.status = 'A'
                           AND hcus.status = 'A'
                           AND hcus.location = inv_trx_data.BILL_TO_SITE_NAME
                           AND hcus.site_use_code = 'BILL_TO'
                           AND hcasa.org_id = hcus.org_id
                           AND hcasa.cust_account_id = hca.cust_account_id
                           AND hcasa.org_id = p_org_id
                           AND hca.account_number =
                               inv_trx_data.BILL_TO_CUSTOMER_NUMBER;
                --fnd_file.put_line (fnd_file.output, 'Payment Term is  ->  '||v_payMENT_TERM);

                EXCEPTION
                    WHEN OTHERS
                    THEN
                        DBMS_OUTPUT.PUT_LINE (
                               'Customer not found or Bill to site is not Found. Customer Number -> '
                            || inv_trx_data.BILL_TO_CUSTOMER_NUMBER
                            || '-'
                            || inv_trx_data.BILL_TO_SITE_NAME);
                        fnd_file.put_line (
                            fnd_file.output,
                               'Customer not found or Bill to site is not Found. Customer Number -> '
                            || inv_trx_data.BILL_TO_CUSTOMER_NUMBER
                            || '-'
                            || inv_trx_data.BILL_TO_SITE_NAME);
                        v_valid := 'N';
                END;

                DBMS_OUTPUT.PUT_LINE (
                    'v_bill_to_customer: ' || v_bill_to_customer);
                DBMS_OUTPUT.PUT_LINE (
                    'v_bill_to_address_id: ' || v_bill_to_address_id);
                DBMS_OUTPUT.PUT_LINE (
                    'v_bill_to_site_use_id: ' || v_bill_to_site_use_id);



                BEGIN
                    SELECT hca.CUST_ACCOUNT_ID,
                           hcasa.cust_acct_site_id,
                           hcus.site_use_id,
                           'IMMEDIATE'
                      INTO v_ship_to_customer,
                           v_ship_to_address_id,
                           v_ship_to_site_use_id,
                           v_payMENT_TERM
                      FROM hz_cust_accounts        hca,
                           hz_cust_site_uses_all   hcus,
                           hz_cust_acct_sites_all  hcasa
                     WHERE     1 = 1
                           AND hcasa.cust_acct_site_id =
                               hcus.cust_acct_site_id
                           --and     hcus.primary_flag = 'Y'
                           AND hcasa.status = 'A'
                           AND hcus.status = 'A'
                           AND hcus.location = inv_trx_data.SHIP_TO_SITE_NAME
                           AND hcus.site_use_code = 'SHIP_TO'
                           AND hcasa.org_id = hcus.org_id
                           AND hcasa.cust_account_id = hca.cust_account_id
                           AND hcasa.org_id = p_org_id
                           AND hca.account_number =
                               inv_trx_data.SHIP_TO_CUSTOMER_NUMBER;
                --fnd_file.put_line (fnd_file.output, 'Payment Term is  ->  '||v_payMENT_TERM);
                -- SR18061329 ship to and bill to site name added in exception messages

                EXCEPTION
                    WHEN OTHERS
                    THEN
                        DBMS_OUTPUT.PUT_LINE (
                               'Customer not found or Ship to site is not found. Customer Number -> '
                            || inv_trx_data.SHIP_TO_CUSTOMER_NUMBER
                            || '-'
                            || inv_trx_data.SHIP_TO_SITE_NAME);
                        fnd_file.put_line (
                            fnd_file.output,
                               'Customer not found or Ship to site is not found. Customer Number -> '
                            || inv_trx_data.SHIP_TO_CUSTOMER_NUMBER
                            || '-'
                            || inv_trx_data.SHIP_TO_SITE_NAME);
                        v_valid := 'N';
                END;

                DBMS_OUTPUT.PUT_LINE (
                    'v_ship_to_customer: ' || v_ship_to_customer);
                DBMS_OUTPUT.PUT_LINE (
                    'v_ship_to_address_id: ' || v_ship_to_address_id);
                DBMS_OUTPUT.PUT_LINE (
                    'v_ship_to_site_use_id: ' || v_ship_to_site_use_id);


                -- Receivable gl_code from Transaction Type

                BEGIN
                    SELECT                                    --glcc.segment5,
                           rtype.TYPE
                      --INTO v_type_rec_segment5,
                      INTO v_type
                      FROM ra_cust_trx_types_all rtype --, gl_code_combinations glcc
                     WHERE     1 = 1
                           --   AND rtype.gl_id_rec = glcc.code_combination_id
                           AND rtype.name = inv_trx_data.TRANSACTION_TYPE
                           AND org_id = p_org_id;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        DBMS_OUTPUT.PUT_LINE (
                               'Receivable gl_code from Transaction Type not found. Transaction Type is ->  '
                            || inv_trx_data.TRANSACTION_TYPE);
                        fnd_file.put_line (
                            fnd_file.output,
                               'Receivable gl_code from Transaction Type not found. Transaction Type is ->  '
                            || inv_trx_data.TRANSACTION_TYPE);
                        v_valid := 'N';
                END;

                DBMS_OUTPUT.put_line ('V_type: ' || v_type);


                IF v_type = 'CM'
                THEN
                    v_payMENT_TERM := NULL;
                ELSE
                    v_payMENT_TERM := inv_trx_data.PAYMENT_TERM;
                END IF;

                --v_payMENT_TERM := inv_trx_data.PAYMENT_TERM;

                IF (v_payMENT_TERM = 'XXX' AND v_type <> 'CM')
                THEN
                    DBMS_OUTPUT.PUT_LINE (
                           'Payment Term is not valid for Customer Number  ->  '
                        || inv_trx_data.BILL_TO_CUSTOMER_NUMBER
                        || '-'
                        || inv_trx_data.PAYMENT_TERM);
                    fnd_file.put_line (
                        fnd_file.output,
                           'Payment Term is not valid for Customer Number  ->  '
                        || inv_trx_data.BILL_TO_CUSTOMER_NUMBER
                        || '-'
                        || inv_trx_data.PAYMENT_TERM);
                    v_valid := 'N';
                END IF;


                DBMS_OUTPUT.PUT_LINE ('PAYMENT TERM : ' || V_PAYMENT_TERM);
                DBMS_OUTPUT.PUT_LINE ('Inserting in interfaces ');

                --            fnd_file.put_line (
                --                    fnd_file.output,'PAYMENT TERM : ' || V_PAYMENT_TERM);

                BEGIN
                    BEGIN
                        INSERT INTO ra_interface_lines_all (
                                        Inventory_item_id,              --null
                                        LINE_NUMBER,                      -- 1
                                        set_of_books_id,  -- v_set_of_books_id
                                        trx_number,                    -- null
                                        PRIMARY_SALESREP_ID,  --v_sales_rep_id
                                        PRIMARY_SALESREP_NUMBER, -- v_sales_rep_number
                                        BATCH_SOURCE_NAME, -- inv_trx_data.BATCH_SOUR
                                        LINE_TYPE,                   -- 'LINE'
                                        cust_trx_type_name, -- inv_trx_data.TRANSACTION_TYPE
                                        cust_trx_type_id, -- v_cust_trx_type_id
                                        TRX_DATE, --inv_trx_data.TRANSACTION_DATE
                                        GL_DATE, --TO_DATE (inv_trx_data.gl_date, 'YYYY/MM/DD HH24:MI:SS')
                                        CURRENCY_CODE, --inv_trx_data.currency_code
                                        orig_system_bill_customer_id, --v_bill_to_customer
                                        orig_system_bill_address_id, --v_bill_to_address_id
                                        orig_system_ship_customer_id, --v_ship_to_customer
                                        orig_system_ship_address_id, --v_ship_to_address_id
                                        orig_system_sold_customer_id, --v_bill_to_customer
                                        amount, --inv_trx_data.Transaction_Amount
                                        QUANTITY,                          --1
                                        unit_selling_price, --inv_trx_data.Transaction_Amount,
                                        DESCRIPTION, --'ador test'      --attribute1 from csv file
                                        conversion_type,             -- 'User'
                                        conversion_rate,                -- '1'
                                        INTERFACE_LINE_CONTEXT, -- 'Migration'
                                        INTERFACE_LINE_ATTRIBUTE1, --  inv_trx_data.Transaction_Number
                                        org_id,                     --p_org_Id
                                        INTERNAL_NOTES, --inv_trx_data.SPECIAL_INSTRUCTION
                                        -- term_id,
                                        term_name,            --v_payMENT_TERM
                                        LINE_GDF_ATTR_CATEGORY,          -- ''
                                        LINE_GDF_ATTRIBUTE19, --inv_trx_data.Transaction_Number
                                        LINE_GDF_ATTRIBUTE20,  --v_line_number
                                        comments, --inv_trx_data.SPECIAL_INSTRUCTION
                                        INVOICING_RULE_ID,               -- -2
                                        ACCOUNTING_RULE_ID,            -- 1000
                                        last_updated_by, --inv_trx_data.created_by
                                        created_by,  --inv_trx_data.created_by
                                        creation_Date)              -- sysdate
                                 VALUES (
                                     NULL,
                                     V_LINE_NUMBER,
                                     V_SET_OF_BOOKS_ID, -- newly passed from excel file
                                     inv_trx_data.Transaction_Number, -- Invoice number
                                     v_sales_rep_id,
                                     v_sales_rep_number,
                                     inv_trx_data.BATCH_SOUR,
                                     'LINE',                       --LINE_TYPE
                                     inv_trx_data.TRANSACTION_TYPE,
                                     v_cust_trx_type_id,
                                     inv_trx_data.TRANSACTION_DATE,
                                     inv_trx_data.gl_date, -- newly passed from excel file
                                     inv_trx_data.currency_code, -- newly passed from excel file
                                     v_bill_to_customer,
                                     v_bill_to_address_id,
                                     v_ship_to_customer,
                                     v_ship_to_address_id,
                                     v_bill_to_customer,
                                     inv_trx_data.Transaction_Amount, --v_amount,
                                     1, --inv_trx_data.QTY,                    --QUANTITY
                                     inv_trx_data.Transaction_Amount, --unit_selling_price
                                     inv_trx_data.TRASACTION_LINE_DESCRIPTION, --'Legacy AR Migration',                --DESCRIPTION      --Need to discuss
                                     'User', -- inv_trx_data.conversion_type,                                      ---- newly passed from excel file
                                     '1', -- inv_trx_data.conversion_rate ,                                     ----- newly passed from excel file
                                     'MIGRATION', --p_INTERFACE_LINE_CONTEXT,               --
                                     inv_trx_data.Transaction_Number,
                                     p_org_id,
                                     inv_trx_data.SPECIAL_INSTRUCTION, --INTERNAL_NOTES
                                     v_payMENT_TERM,               --term_name
                                     '',              --LINE_GDF_ATTR_CATEGORY
                                     inv_trx_data.Transaction_Number, ---LINE_GDF_ATTRIBUTE19
                                     V_LINE_NUMBER,     --LINE_GDF_ATTRIBUTE20
                                     inv_trx_data.SPECIAL_INSTRUCTION,      --
                                     '', ---2,                                 -- INVOICING_RULE_ID
                                     '', ---1000,                                --ACCOUNTING_RULE_ID
                                     inv_trx_data.created_by,
                                     inv_trx_data.created_by,
                                     SYSDATE);
                    EXCEPTION
                        WHEN OTHERS
                        THEN
                            DBMS_OUTPUT.PUT_LINE (
                                'In inserting ra_interface_lines_all exception!!');
                            fnd_file.put_line (
                                fnd_file.output,
                                'In inserting ra_interface_lines_all exception!!');
                            v_process_flag := 'E';
                            v_process_msg :=
                                'Error in ra_interface_lines_all';
                    END;

                    --            fnd_file.put_line (
                    --                    fnd_file.output,'Inserted data in ra_interface_lines_all');

                    BEGIN
                        INSERT INTO ra_interface_distributions_all (
                                        account_class,
                                        amount,
                                        segment1, -- inv_trx_data.REV_SEGMENT1
                                        segment2,  --inv_trx_data.REV_SEGMENT2
                                        segment3,  --inv_trx_data.REV_SEGMENT3
                                        segment4,  --inv_trx_data.REV_SEGMENT4
                                        segment5,  --inv_trx_data.REV_SEGMENT5
                                        segment6,  --inv_trx_data.REV_SEGMENT6
                                        percent,
                                        interface_line_context,  --'MIGRATION'
                                        interface_line_attribute1, --inv_trx_data.Transaction_Number
                                        -- interface_line_attribute2,
                                        org_id,
                                        last_updated_by,
                                        created_by,
                                        creation_Date)
                             VALUES ('REV',
                                     inv_trx_data.Transaction_Amount,
                                     inv_trx_data.REV_SEGMENT1,
                                     inv_trx_data.REV_SEGMENT2,
                                     inv_trx_data.REV_SEGMENT3,
                                     inv_trx_data.REV_SEGMENT4,
                                     inv_trx_data.REV_SEGMENT5,
                                     inv_trx_data.REV_SEGMENT6,
                                     100,
                                     'MIGRATION',  --p_INTERFACE_LINE_CONTEXT,
                                     '',    --inv_trx_data.Transaction_Number,
                                     -- V_LINE_NUMBER,
                                     p_org_id,
                                     inv_trx_data.created_by,
                                     inv_trx_data.created_by,
                                     SYSDATE);
                    EXCEPTION
                        WHEN OTHERS
                        THEN
                            DBMS_OUTPUT.PUT_LINE (
                                'In inserting ra_interface_distributions_all for REV exception!!');
                            fnd_file.put_line (
                                fnd_file.output,
                                'In inserting ra_interface_distributions_all for REV exception!!');
                            v_process_flag := 'E';
                            v_process_msg :=
                                   V_PROCESS_MSG
                                || 'Error in ra_interface_distributions_all REV';
                    END;

                    --            fnd_file.put_line (
                    --                    fnd_file.output,'Inserted data in ra_interface_distributions_all for REV');

                    BEGIN
                        INSERT INTO ra_interface_distributions_all (
                                        account_class,
                                        amount,
                                        segment1,  --inv_trx_data.REC_SEGMENT1
                                        segment2,  --inv_trx_data.REC_SEGMENT2
                                        segment3,  --inv_trx_data.REC_SEGMENT3
                                        segment4,  --inv_trx_data.REC_SEGMENT4
                                        segment5,  --inv_trx_data.REC_SEGMENT5
                                        segment6,  --inv_trx_data.REC_SEGMENT6
                                        percent,
                                        interface_line_context,
                                        interface_line_attribute1,
                                        -- interface_line_attribute2,
                                        org_id,
                                        last_updated_by,
                                        created_by,
                                        creation_Date)
                             VALUES ('REC',
                                     inv_trx_data.Transaction_Amount,
                                     inv_trx_data.REC_SEGMENT1,
                                     inv_trx_data.REC_SEGMENT2,
                                     inv_trx_data.REC_SEGMENT3,
                                     inv_trx_data.REC_SEGMENT4,
                                     inv_trx_data.REC_SEGMENT5,
                                     inv_trx_data.REC_SEGMENT6,
                                     100,
                                     'MIGRATION',  --p_INTERFACE_LINE_CONTEXT,
                                     '',    --inv_trx_data.Transaction_Number,
                                     --V_LINE_NUMBER,
                                     p_org_id,
                                     inv_trx_data.created_by,
                                     inv_trx_data.created_by,
                                     SYSDATE);
                    EXCEPTION
                        WHEN OTHERS
                        THEN
                            DBMS_OUTPUT.PUT_LINE (
                                'In inserting ra_interface_distributions_all for RCV exception!!');
                            fnd_file.put_line (
                                fnd_file.output,
                                'In inserting ra_interface_distributions_all for RCV exception!!');
                            v_process_flag := 'E';
                            v_process_msg :=
                                   V_PROCESS_MSG
                                || 'Error in ra_interface_distributions_all REC';
                    END;

                    --             fnd_file.put_line (
                    --                    fnd_file.output,'Inserted data in ra_interface_distributions_all for REC');


                    BEGIN
                        INSERT INTO RA_INTERFACE_SALESCREDITS_ALL (
                                        org_id,
                                        INTERFACE_LINE_CONTEXT,
                                        INTERFACE_LINE_ATTRIBUTE1,
                                        --INTERFACE_LINE_ATTRIBUTE2,
                                        --interface_line_attribute8,
                                        SALESREP_ID,
                                        SALES_CREDIT_TYPE_ID,
                                        SALES_CREDIT_PERCENT_SPLIT,
                                        last_updated_by,
                                        created_by,
                                        creation_Date)
                             VALUES (p_org_id,
                                     'MIGRATION',  --p_INTERFACE_LINE_CONTEXT,
                                     inv_trx_data.Transaction_Number,
                                     -- V_LINE_NUMBER,
                                     --inv_trx_data.attribute5,
                                     v_sales_rep_id,
                                     1,                 --SALES_CREDIT_TYPE_ID
                                     100,         --SALES_CREDIT_PERCENT_SPLIT
                                     inv_trx_data.created_by,
                                     inv_trx_data.created_by,
                                     SYSDATE);
                    EXCEPTION
                        WHEN OTHERS
                        THEN
                            DBMS_OUTPUT.PUT_LINE (
                                'In inserting RA_INTERFACE_SALESCREDITS_ALL for exception!!');
                            fnd_file.put_line (
                                fnd_file.output,
                                'In inserting RA_INTERFACE_SALESCREDITS_ALL for exception!!');
                            v_process_flag := 'E';
                            v_process_msg :=
                                   V_PROCESS_MSG
                                || 'Error in RA_INTERFACE_SALESCREDITS_ALL REC';
                    END;

                    --             fnd_file.put_line (
                    --                    fnd_file.output,'Inserted data in RA_INTERFACE_SALESCREDITS_ALL ');

                    UPDATE CUS.ADOR_CM_DM_MAP
                       SET PROCESS_FLAG = V_PROCESS_FLAG,
                           PROCESS_MSG = V_PROCESS_MSG
                     WHERE     TRANSACTION_NUMBER =
                               inv_trx_data.TRANSACTION_NUMBER
                           AND ORG_ID = P_ORG_ID;
                END;
            END LOOP;
        END IF;
        
        
    END IF;                                                   -- insert end if

    COMMIT;
END;
/