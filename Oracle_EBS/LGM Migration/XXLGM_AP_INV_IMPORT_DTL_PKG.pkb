CREATE OR REPLACE PACKAGE BODY APPS.XXLGM_AP_INV_IMPORT_DTL_PKG
IS
   /*************************************************************************/
   -- PROCEDURE TO PRINT LINE
   /*************************************************************************/
   PROCEDURE print_line (X_TEXT    IN VARCHAR2,
                         X_WHERE   IN VARCHAR2 DEFAULT 'LOG')
   IS
      X_TEXT1   VARCHAR2 (4000);
   BEGIN
      IF X_WHERE = 'LOG'
      THEN
         APPS.FND_FILE.PUT_LINE (APPS.FND_FILE.LOG, X_TEXT);
      ELSE
         APPS.FND_FILE.PUT_LINE (APPS.FND_FILE.OUTPUT, X_TEXT);
      END IF;

      DBMS_OUTPUT.PUT_LINE (X_TEXT);
   EXCEPTION
      WHEN OTHERS
      THEN
         X_TEXT1 := 'ERROR IN PRINT LINE :' || SQLERRM;
         APPS.FND_FILE.PUT_LINE (APPS.FND_FILE.LOG, X_TEXT1);
   END print_line;

   /*************************************************************************/
   -- PROCEDURE TO VERIFY THE  OPen AP Invoice
   /*************************************************************************/
   PROCEDURE XXLGM_INV_VERIFY_P (RETCODE OUT VARCHAR2, ERRBUF OUT VARCHAR2)
   IS
      CURSOR CUR_APINV_MAIN
      IS
         SELECT INVOICE_NUM,
                INVOICE_TYPE_LOOKUP_CODE,
                INVOICE_DATE,
                VENDOR_SITE_CODE,
                INVOICE_AMOUNT,
                INVOICE_CURRENCY_CODE,
                PAYMENT_CURRENCY_CODE,
                EXCHANGE_RATE_TYPE,
                EXCHANGE_RATE,
                EXCHANGE_DATE,
                TERMS_NAME,
                TERMS_DATE,
                DESCRIPTION,
                SOURCE,
                PAYMENT_METHOD_LOOKUP_CODE,
                DOC_CATEGORY_CODE,
                INVOICE_RECEIVED_DATE,
                GOODS_RECEIVED_DATE,
                GL_DATE,
                VENDOR_ID,
                VENDOR_CODE,
                VENDOR_NAME,
                IMP_REFER_NUM,
                LIABILITY_ACCOUNT,
                ORGANIZATION_CODE
           FROM ITC.XXLGM_AP_INV_HDR_STG_T
          WHERE REC_STATUS IS NULL;

      CURSOR CUR_APINVLINE_MAIN
      IS
         SELECT INVOICE_NUM,
                LINE_NUMBER,
                LINE_TYPE_LOOKUP_CODE,
                AMOUNT,
                ACCOUNTING_DATE,
                DESCRIPTION,
                P_ACC_CODE,
                ORGANIZATION,
                LOCATION,
                TAX_CATEGORY,
                INTENDED_USE,
                SAC_CODE,
                HSN_CODE
           FROM ITC.XXLGM_AP_INV_LINE_STG_T
          WHERE REC_STATUS IS NULL;

      CURSOR CUR_RECUPDATE
      IS
         SELECT DISTINCT INVOICE_NUM
           FROM ITC.XXLGM_AP_INV_LINE_STG_T
          WHERE REC_STATUS = 'V';

      TYPE CUR_APINV_REC IS TABLE OF CUR_APINV_MAIN%ROWTYPE
         INDEX BY PLS_INTEGER;

      TYPE CUR_APINVLINE_REC IS TABLE OF CUR_APINVLINE_MAIN%ROWTYPE
         INDEX BY PLS_INTEGER;

      TYPE CUR_RECUPDATE_REC IS TABLE OF CUR_RECUPDATE%ROWTYPE
         INDEX BY PLS_INTEGER;

      T_CUR_APINV_MAIN_REC           CUR_APINV_REC;
      T_CUR_APINV_MAIN_LINE_REC      CUR_APINVLINE_REC;
      T_CUR_RECUPDATE_REC            CUR_RECUPDATE_REC;
      L_TOT_CNT                      NUMBER;
      L_ERR_MSG                      VARCHAR2 (4000);
      l_cnt_exp                      NUMBER;
      L_INVOICE_NUM                  VARCHAR2 (250);
      L_INVOICE_TYPE_LOOKUP_CODE     VARCHAR2 (100);
      L_INVOICE_DATE                 DATE;
      L_VENDOR_NAME                  VARCHAR2 (100);
      L_VENDOR_SITE_CODE             VARCHAR2 (100);
      L_INVOICE_AMOUNT               NUMBER;
      L_INVOICE_CURRENCY_CODE        VARCHAR2 (100);
      L_TERMS_NAME                   VARCHAR2 (100);
      L_DESCRIPTION                  VARCHAR2 (500);
      L_SOURCE                       VARCHAR2 (200);
      L_PAYMENT_METHOD_LOOKUP_CODE   VARCHAR2 (100);
      L_GL_DATE                      DATE;
      L_VENDOR_ID                    NUMBER;
      L_VENDOR_SITE_ID               NUMBER;
      L_TERMS                        NUMBER;
      L_CCID                         NUMBER;
      L_LINE_NUM                     NUMBER;
      L_VENDOR_ID_1                  NUMBER;
      L_VENDOR_ID_2                  NUMBER;
      L_REC_STATUS                   NUMBER;
      L_CODE                         VARCHAR2 (100);
      L_LIABILITY                    NUMBER;
      L_ORG_ID                       NUMBER;
      L_VENDOR_CODE                  VARCHAR2 (15);
      L_PERIOD_NAME                  VARCHAR2 (15);
      L_IMP_REFER_NUM                VARCHAR2 (150);
      L_HDR_AMOUNT                   NUMBER;
      L_LINE_AMOUNT                  NUMBER;
      L_INVOICE_TYPE                 VARCHAR2 (100);
      L_AMOUNT                       NUMBER;
      L_LINE_TYPE                    VARCHAR2 (50);
      L_PERIOD_YEAR                  VARCHAR2 (15);
      --    L_VALID_SUP VARCHAR2(50);
      L_ORG_CNT                      NUMBER;
      L_LOC_CNT                      NUMBER;
      L_TAX_CNT                      NUMBER;
      L_SAC_CNT                      NUMBER;
      L_HSN_CNT                      NUMBER;
      L_INTENDED_USE                 NUMBER;
      L_CNT                          NUMBER := 0;
      TX_CNT                         NUMBER;
      v_temp2                        BOOLEAN;
      T_INVOICE_NUM                  NUMBER;
      L_START_DATE                   DATE;
      L_YEAR_END                     DATE;
      T_TX_CNT                       NUMBER;
      L_TAX_CATEGORY_CNT             NUMBER;
      L_VENDOR_REGISTER_STATUS       VARCHAR2 (100);
   BEGIN
      BEGIN
         OPEN CUR_APINV_MAIN;

         FETCH CUR_APINV_MAIN
         BULK COLLECT INTO T_CUR_APINV_MAIN_REC;

         CLOSE CUR_APINV_MAIN;

         IF T_CUR_APINV_MAIN_REC.COUNT <> 0
         THEN
            L_TOT_CNT := T_CUR_APINV_MAIN_REC.COUNT;

            FOR I IN T_CUR_APINV_MAIN_REC.FIRST .. T_CUR_APINV_MAIN_REC.LAST
            LOOP
               RETCODE := '0';
               L_ERR_MSG :=
                     'Message from XXLGM_AP_INVOICE_PKG.XXLGM_INVOICE_VERIFY:'
                  || T_CUR_APINV_MAIN_REC (I).INVOICE_NUM;
               L_ORG_ID := NULL;
               L_ERR_MSG := NULL;
               L_INVOICE_NUM := NULL;
               L_INVOICE_TYPE_LOOKUP_CODE := NULL;
               L_VENDOR_NAME := NULL;
               L_VENDOR_SITE_CODE := NULL;
               L_INVOICE_AMOUNT := 0;
               L_INVOICE_CURRENCY_CODE := NULL;
               L_TERMS_NAME := NULL;
               L_DESCRIPTION := NULL;
               L_SOURCE := NULL;
               L_PAYMENT_METHOD_LOOKUP_CODE := NULL;
               L_INVOICE_CURRENCY_CODE := NULL;
               L_LIABILITY := NULL;
               L_VENDOR_CODE := NULL;
               L_VENDOR_NAME := NULL;
               L_PERIOD_NAME := NULL;
               L_IMP_REFER_NUM := NULL;
               L_HDR_AMOUNT := NULL;
               L_LINE_AMOUNT := NULL;
               L_INVOICE_TYPE := NULL;
               L_AMOUNT := NULL;
               L_LINE_TYPE := NULL;
               L_PERIOD_YEAR := NULL;
               TX_CNT := NULL;
               L_START_DATE := NULL;
               L_YEAR_END := NULL;

               T_INVOICE_NUM := NULL;
               T_TX_CNT := NULL;
               --    L_VALID_SUP  := NULL;


               l_cnt_exp := 0;
               L_TAX_CATEGORY_CNT := 0;
               L_VENDOR_REGISTER_STATUS := NULL;

               BEGIN
                  /*********V01 Verification of Organization Code**************/
                  /*
                     SELECT V.ORGANIZATION_ID
                       INTO L_ORG_ID
                       FROM APPS.MTL_PARAMETERS_VIEW M,
                            APPS.HR_ORGANIZATION_UNITS_V V
                      WHERE     M.COST_ORGANIZATION_ID = V.ORGANIZATION_ID
                            AND (   UPPER (V.NAME) =
                                       UPPER (
                                          T_CUR_APINV_MAIN_REC (I).ORGANIZATION_CODE)
                                 OR ORGANIZATION_CODE =
                                       UPPER (
                                          T_CUR_APINV_MAIN_REC (I).ORGANIZATION_CODE));*/
                  SELECT ORGANIZATION_ID
                    INTO L_ORG_ID
                    FROM APPS.HR_OPERATING_UNITS V
                   WHERE     1 = 1
                         AND (UPPER (V.NAME) =
                                 UPPER (
                                    T_CUR_APINV_MAIN_REC (I).ORGANIZATION_CODE));

                  IF L_ORG_ID IS NULL
                  THEN
                     L_ERR_MSG :=
                           RTRIM (L_ERR_MSG)
                        || ' ,I01- INVALID OPERATING UNIT NAME ';
                     RETCODE := '2';
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     L_ERR_MSG :=
                           RTRIM (L_ERR_MSG)
                        || ' ,I01- INVALID OPERATING UNIT NAME ';
                     RETCODE := '2';
               END;

               /*********V01 Verification of Organization Code**************/

               BEGIN
                  /*---------Validation for Vendor Code-----------*/

                  BEGIN
                     SELECT SEGMENT1, VENDOR_NAME
                       INTO L_VENDOR_CODE, L_VENDOR_NAME
                       FROM APPS.PO_VENDORS
                      WHERE     LTRIM (RTRIM (SEGMENT1)) =
                                   T_CUR_APINV_MAIN_REC (I).VENDOR_CODE
                            AND LTRIM (RTRIM (VENDOR_NAME)) =
                                   T_CUR_APINV_MAIN_REC (I).VENDOR_NAME;

                     print_line (
                        'Inside vendor validation ' || L_VENDOR_CODE);

                     IF (L_VENDOR_CODE IS NULL OR L_VENDOR_NAME IS NULL)
                     THEN
                        L_ERR_MSG :=
                           RTRIM (L_ERR_MSG) || ' ,I01- INVALID VENDOR';
                        RETCODE := '2';
                     --                  L_VALID_SUP := 'N';
                     END IF;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        L_ERR_MSG :=
                           RTRIM (L_ERR_MSG) || ' ,I01- INVALID VENDOR ';
                        RETCODE := '2';
                  --                   L_VALID_SUP := 'N';
                  END;


                  /*---------------------------Validation of invoice number -------------------------------------*/
                  BEGIN
                     SELECT INVOICE_NUM
                       INTO L_INVOICE_NUM       --L_VENDOR_CODE, L_VENDOR_NAME
                       FROM APPS.ap_invoices_all
                      WHERE     1 = 1
                            AND INVOICE_NUM =
                                   T_CUR_APINV_MAIN_REC (I).INVOICE_NUM
                            AND ORG_ID = L_ORG_ID;

                     print_line ('Inside Invoice number validation ');

                     IF (L_INVOICE_NUM IS NOT NULL)
                     THEN
                        L_ERR_MSG :=
                              RTRIM (L_ERR_MSG)
                           || ' ,I01- INVOICE ALREADY EXISTS';
                        RETCODE := '2';
                     END IF;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        NULL;
                  END;

                  /*---------------------------Validation of invoice number -------------------------------------*/
                  L_INVOICE_NUM := NULL; --Set back to null for other validation



                  IF L_VENDOR_CODE IS NOT NULL
                  THEN
                     /*------------------------   validation of vendor SITE ------------------------*/
                     print_line (
                        'Inside vendor site validation ' || L_VENDOR_CODE);

                     BEGIN
                        SELECT VENDOR_SITE_ID
                          INTO L_VENDOR_SITE_ID
                          FROM APPS.PO_VENDOR_SITES_ALL PS,
                               APPS.PO_VENDORS PV
                         WHERE     VENDOR_SITE_CODE =
                                      T_CUR_APINV_MAIN_REC (I).VENDOR_SITE_CODE
                               AND PS.VENDOR_ID = PV.VENDOR_ID
                               AND PAY_SITE_FLAG = 'Y'
                               AND PV.SEGMENT1 =
                                      T_CUR_APINV_MAIN_REC (I).VENDOR_CODE
                               AND ORG_ID = L_ORG_ID;

                        IF L_VENDOR_SITE_ID IS NULL
                        THEN
                           print_line (
                              'Inside vendor validation Null vendor site');
                           L_ERR_MSG :=
                                 RTRIM (L_ERR_MSG)
                              || ' ,I02- INVALID VENDOR SITE NAME ';
                           RETCODE := '2';
                        END IF;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           print_line (
                                 'Inside vendor validation other error'
                              || SQLERRM);
                           L_ERR_MSG :=
                                 RTRIM (L_ERR_MSG)
                              || ' ,I02- INVALID VENDOR SITE NAME ';
                           RETCODE := '2';
                     END;
                  END IF;
               END;

               /*------------------------   validation of vendor SITE ------------------------*/

               /*----------------------   Validation of INVOICE_CURRENCY_CODE AND EXCHANGE_DATE --------------------*/
               BEGIN
                  IF (T_CUR_APINV_MAIN_REC (I).INVOICE_CURRENCY_CODE <> 'INR')
                  THEN
                     IF (T_CUR_APINV_MAIN_REC (I).EXCHANGE_RATE IS NULL)
                     THEN
                        L_ERR_MSG :=
                              RTRIM (L_ERR_MSG)
                           || ' ,I03- INVALID EXCHANGE RATE FOR '
                           || T_CUR_APINV_MAIN_REC (I).VENDOR_NAME;
                        RETCODE := '2';
                     END IF;

                     IF (T_CUR_APINV_MAIN_REC (I).EXCHANGE_DATE IS NULL)
                     THEN
                        L_ERR_MSG :=
                              RTRIM (L_ERR_MSG)
                           || ' ,I03- INVALID EXCHANGE DATE FOR '
                           || T_CUR_APINV_MAIN_REC (I).VENDOR_NAME;
                        RETCODE := '2';
                     END IF;

                     IF (T_CUR_APINV_MAIN_REC (I).EXCHANGE_RATE_TYPE IS NULL)
                     THEN
                        L_ERR_MSG :=
                              RTRIM (L_ERR_MSG)
                           || ' ,I03- INVALID EXCHANGE RATE TYPE FOR '
                           || T_CUR_APINV_MAIN_REC (I).VENDOR_NAME;
                        RETCODE := '2';
                     END IF;
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     L_ERR_MSG :=
                           RTRIM (L_ERR_MSG)
                        || ' ,I03-INVALID EXCHANGE DATE FOR '
                        || T_CUR_APINV_MAIN_REC (I).VENDOR_NAME;
                     RETCODE := '2';
               END;

               /*----------------------   Validation of INVOICE_CURRENCY_CODE AND EXCHANGE_DATE --------------------*/
               /*------------------------   validation of INVOICE_NUM with LINE ------------------------*/
               BEGIN
                  SELECT DISTINCT INVOICE_NUM
                    INTO L_INVOICE_NUM
                    FROM ITC.XXLGM_AP_INV_LINE_STG_T
                   WHERE INVOICE_NUM = T_CUR_APINV_MAIN_REC (I).INVOICE_NUM;

                  IF L_INVOICE_NUM IS NULL
                  THEN
                     L_ERR_MSG :=
                           RTRIM (L_ERR_MSG)
                        || ' ,I01- INVOICE DOES NOT EXIST IN LINE ';
                     RETCODE := '2';
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     L_ERR_MSG :=
                           RTRIM (L_ERR_MSG)
                        || ' ,I01- INVOICE DOES NOT EXIST IN LINE ';
                     RETCODE := '2';
               END;

               /*------------------------   validation of INVOICE_NUM with LINE ------------------------*/
               /*------------------------   validation of Document category code ------------------------*/
               BEGIN
                  SELECT CODE
                    INTO L_CODE
                    FROM apps.FND_DOC_SEQUENCE_CATEGORIES
                   WHERE     CODE =
                                T_CUR_APINV_MAIN_REC (I).DOC_CATEGORY_CODE
                         AND APPLICATION_ID = 200;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     L_ERR_MSG :=
                           RTRIM (L_ERR_MSG)
                        || ' ,I01- INVALID DOC_CATEGORY_CODE ';
                     RETCODE := '2';
               END;

               IF L_CODE IS NULL
               THEN
                  L_ERR_MSG :=
                     RTRIM (L_ERR_MSG) || ' ,I01- INVALID DOC_CATEGORY_CODE ';
                  RETCODE := '2';
               END IF;

               /*------------------------   validation of Document category code ------------------------*/


               /*------------------------   validation of INVOICE SOURCE ------------------------*/
               BEGIN
                  SELECT SOURCE
                    INTO L_SOURCE
                    FROM ITC.XXLGM_AP_INV_HDR_STG_T
                   WHERE     INVOICE_NUM =
                                T_CUR_APINV_MAIN_REC (I).INVOICE_NUM
                         AND SOURCE IN ('LGM_MIGRATION'); --Need to change at the time of running the request on PROD

                  IF L_SOURCE IS NULL
                  THEN
                     L_ERR_MSG :=
                        RTRIM (L_ERR_MSG) || ' ,I01- INVALID INVOICE SOURCE ';
                     RETCODE := '2';
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     L_ERR_MSG :=
                        RTRIM (L_ERR_MSG) || ' ,I01- INVALID INVOICE SOURCE ';
                     RETCODE := '2';
               END;

               /*------------------------   validation of INVOICE SOURCE------------------------*/
               /*------------------------   validation of INVOICE TYPE LOOKUP CODE ------------------------*/
               BEGIN
                  SELECT INVOICE_TYPE_LOOKUP_CODE
                    INTO L_INVOICE_TYPE_LOOKUP_CODE
                    FROM ITC.XXLGM_AP_INV_HDR_STG_T
                   WHERE     INVOICE_NUM =
                                T_CUR_APINV_MAIN_REC (I).INVOICE_NUM
                         AND INVOICE_TYPE_LOOKUP_CODE IN
                                (SELECT DISTINCT LOOKUP_CODE
                                   FROM FND_LOOKUP_VALUES
                                  WHERE     LOOKUP_TYPE = 'INVOICE TYPE'
                                        AND ENABLED_FLAG = 'Y');

                  IF L_INVOICE_TYPE_LOOKUP_CODE IS NULL
                  THEN
                     L_ERR_MSG :=
                           RTRIM (L_ERR_MSG)
                        || ' ,I01- INVALID INVOICE INVOICE TYPE LOOKUP CODE ';
                     RETCODE := '2';
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     L_ERR_MSG :=
                           RTRIM (L_ERR_MSG)
                        || ' ,I01- INVALID INVOICE INVOICE TYPE LOOKUP CODE ';
                     RETCODE := '2';
               END;

               /*------------------------   validation of INVOICE TYPE LOOKUP CODE------------------------*/

               /*------------------------   validation of INVOICE AMOUNT with INVOICE_TYPE_LOOKUP_CODE ------------------------*/
               BEGIN
                  SELECT INVOICE_TYPE_LOOKUP_CODE, INVOICE_AMOUNT
                    INTO L_INVOICE_TYPE, L_AMOUNT
                    FROM ITC.XXLGM_AP_INV_HDR_STG_T
                   WHERE INVOICE_NUM = T_CUR_APINV_MAIN_REC (I).INVOICE_NUM;

                  IF L_INVOICE_TYPE = 'STANDARD' AND L_AMOUNT <= 0
                  THEN
                     L_ERR_MSG :=
                           RTRIM (L_ERR_MSG)
                        || ' , I01- INVALID INVOICE AMOUNT ';
                     RETCODE := '2';
                  END IF;


                  IF     (   L_INVOICE_TYPE = 'CREDIT'
                          OR L_INVOICE_TYPE = 'DEBIT')
                     AND L_AMOUNT > 0
                  THEN
                     L_ERR_MSG :=
                           RTRIM (L_ERR_MSG)
                        || ' , I01- INVALID INVOICE AMOUNT ';
                     RETCODE := '2';
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     L_ERR_MSG :=
                           RTRIM (L_ERR_MSG)
                        || ' , I01- INVALID INVOICE AMOUNT ';
                     RETCODE := '2';
               END;



               /*------------------------   validation of INVOICE AMOUNT ------------------------*/


               BEGIN
                  SELECT COUNT (TAX_CATEGORY)
                    INTO TX_CNT
                    FROM ITC.XXLGM_AP_INV_LINE_STG_T T
                   WHERE     1 = 1
                         AND T.INVOICE_NUM =
                                T_CUR_APINV_MAIN_REC (I).INVOICE_NUM;

                  IF TX_CNT = 0
                  THEN
                     SELECT INVOICE_AMOUNT,
                            (SELECT SUM (AMOUNT)
                               FROM ITC.XXLGM_AP_INV_LINE_STG_T
                              WHERE INVOICE_NUM =
                                       T_CUR_APINV_MAIN_REC (I).INVOICE_NUM)
                       INTO L_HDR_AMOUNT, L_LINE_AMOUNT
                       FROM ITC.XXLGM_AP_INV_HDR_STG_T
                      WHERE INVOICE_NUM =
                               T_CUR_APINV_MAIN_REC (I).INVOICE_NUM;

                     IF L_HDR_AMOUNT <> L_LINE_AMOUNT
                     THEN
                        L_ERR_MSG :=
                              RTRIM (L_ERR_MSG)
                           || ' ,I01-INVOICE AMOUNT DOES NOT MATCH WITH LINE AMOUNT ';
                        RETCODE := '2';
                     END IF;
                  END IF;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     L_HDR_AMOUNT := 0;
                     L_LINE_AMOUNT := 0;
                  WHEN OTHERS
                  THEN
                     L_ERR_MSG :=
                           RTRIM (L_ERR_MSG)
                        || ' ,I01-INVOICE AMOUNT DOES NOT MATCH WITH LINE AMOUNT ';
                     RETCODE := '2';
               END;

               /*------------------------   validation of INVOICE AMOUNT------------------------*/
               /*--------------------   Validation of LIABILITY ACCOUNT -----------------*/
               IF T_CUR_APINV_MAIN_REC (I).LIABILITY_ACCOUNT IS NOT NULL
               THEN
                  BEGIN
                     SELECT CODE_COMBINATION_ID
                       INTO L_LIABILITY
                       FROM GL_CODE_COMBINATIONS_KFV
                      WHERE CONCATENATED_SEGMENTS =
                               LTRIM (
                                  RTRIM (
                                     T_CUR_APINV_MAIN_REC (I).LIABILITY_ACCOUNT));

                     IF L_LIABILITY IS NULL
                     THEN
                        L_ERR_MSG :=
                              RTRIM (L_ERR_MSG)
                           || ' ,I04- INVALID LIABILITY ACCOUNT ';
                        RETCODE := '2';
                     END IF;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        L_ERR_MSG :=
                              RTRIM (L_ERR_MSG)
                           || ' ,I04-INVALID LIABILITY ACCOUNT ';
                        RETCODE := '2';
                  END;
               END IF;

               /*----------------------   Validation of LIABILITY ACCOUNT --------------------*/
               /************Update Records for Status************/
               --    apps.fnd_file.put_line(apps.fnd_file.output,'I am before updation in table');
               --   print_line('Total'||L_TOT_CNT);
               IF RETCODE <> '0'
               THEN
                  --   apps.fnd_file.put_line(apps.fnd_file.output,'I am inside updation in table');
                  --   print_line('ERROR - INVOICE NUMBER: ' || T_CUR_APINV_MAIN_REC(I).INVOICE_NUM ||L_ERR_MSG);
                  ERRBUF := L_ERR_MSG;

                  --  print_line(ERRBUF);
                  --    apps.fnd_file.put_line(apps.fnd_file.output,ERRBUF ||'and'||L_ERR_MSG);
                  UPDATE ITC.XXLGM_AP_INV_HDR_STG_T T
                     SET T.REC_STATUS = 'E', T.ERR_MESSAGE = L_ERR_MSG
                   WHERE t.INVOICE_NUM = T_CUR_APINV_MAIN_REC (I).INVOICE_NUM;

                  COMMIT;
               ELSE
                  UPDATE ITC.XXLGM_AP_INV_HDR_STG_T T
                     SET T.REC_STATUS = 'V'
                   WHERE t.INVOICE_NUM = T_CUR_APINV_MAIN_REC (I).INVOICE_NUM;

                  --   print_line(T_CUR_APINV_MAIN_REC(I).INVOICE_NUM || 'SUCESSES');
                  COMMIT;
               END IF;
            /************Update Records for Status************/

            /**************************bOTTOM LINE**************************/
            END LOOP;

            COMMIT;
         --  apps.fnd_file.put_line(apps.fnd_file.output,'Total No of Invoices hEADERS got updated-'||L_TOT_CNT);

         ELSE
            --  L_ERR_MSG :='No Data To Process';
            RETCODE := '2';
            PRINT_LINE ('No Rows in Invoice Headers To Process');
         END IF;
      END;

      BEGIN
         L_TOT_CNT := NULL;

         OPEN CUR_APINVLINE_MAIN;

         FETCH CUR_APINVLINE_MAIN
         BULK COLLECT INTO T_CUR_APINV_MAIN_LINE_REC;

         CLOSE CUR_APINVLINE_MAIN;

         IF T_CUR_APINV_MAIN_LINE_REC.COUNT <> 0
         THEN
            L_TOT_CNT := T_CUR_APINV_MAIN_LINE_REC.COUNT;

            FOR I IN T_CUR_APINV_MAIN_LINE_REC.FIRST ..
                     T_CUR_APINV_MAIN_LINE_REC.LAST
            LOOP
               RETCODE := '0';
               L_ERR_MSG :=
                     'Message from XXLGM_AP_INVOICE_DTL_PKG.XXLGM_INVOICE_VERIFY:'
                  || T_CUR_APINV_MAIN_LINE_REC (I).INVOICE_NUM;
               L_ERR_MSG := NULL;
               L_INVOICE_NUM := NULL;
               L_LINE_NUM := NULL;
               L_VENDOR_ID_1 := NULL;
               L_VENDOR_ID_2 := NULL;
               L_CCID := NULL;
               l_cnt_exp := 0;
               L_ORG_CNT := NULL;
               L_LOC_CNT := NULL;
               L_TAX_CNT := NULL;
               L_SAC_CNT := NULL;
               L_HSN_CNT := NULL;
               L_INTENDED_USE := NULL;
               T_INVOICE_NUM := NULL;


               /*------------------------   validation of INVOICE_NUM with Header ------------------------*/
               BEGIN
                  SELECT COUNT (INVOICE_NUM)
                    INTO L_INVOICE_NUM
                    FROM ITC.XXLGM_AP_INV_HDR_STG_T
                   WHERE INVOICE_NUM =
                            T_CUR_APINV_MAIN_LINE_REC (I).INVOICE_NUM;
               /*  IF L_INVOICE_NUM IS NULL THEN
                    L_ERR_MSG := RTRIM(L_ERR_MSG) ||' ,I01- INVOICE DOES NOT EXIST IN HEADER ';
                    RETCODE   := '2';
                 END IF;*/
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     L_ERR_MSG :=
                           RTRIM (L_ERR_MSG)
                        || ' ,I01- INVOICE DOES NOT EXIST IN HEADER ';
                     RETCODE := '2';
               END;

               /*------------------------   validation of INVOICE_NUM with Header ------------------------*/
               /*------------------------   validation of INVOICE LINE_TYPE_LOOKUP_CODE ------------------------*/
               BEGIN
                  SELECT LINE_TYPE_LOOKUP_CODE
                    INTO L_LINE_TYPE
                    FROM ITC.XXLGM_AP_INV_LINE_STG_T
                   WHERE     INVOICE_NUM =
                                T_CUR_APINV_MAIN_LINE_REC (I).INVOICE_NUM
                         AND LINE_NUMBER =
                                T_CUR_APINV_MAIN_LINE_REC (I).LINE_NUMBER
                         AND LINE_TYPE_LOOKUP_CODE IN
                                (SELECT LOOKUP_CODE
                                   FROM FND_LOOKUP_VALUES
                                  WHERE     LOOKUP_TYPE = 'INVOICE LINE TYPE'
                                        AND ENABLED_FLAG = 'Y');

                  IF L_LINE_TYPE IS NULL
                  THEN
                     L_ERR_MSG :=
                           RTRIM (L_ERR_MSG)
                        || ' , I01- INVALID  LINE_TYPE_LOOKUP_CODE ';
                     RETCODE := '2';
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     L_ERR_MSG :=
                           RTRIM (L_ERR_MSG)
                        || ' , I01- INVALID  LINE_TYPE_LOOKUP_CODE ';
                     RETCODE := '2';
               END;

               /*------------------------   validation of INVOICE LINE_TYPE_LOOKUP_CODE ------------------------*/
               /*--------------------   Validation of CODE COMBINATION ID -----------------*/
               BEGIN
                  SELECT CODE_COMBINATION_ID
                    INTO L_CCID
                    FROM APPS.GL_CODE_COMBINATIONS_KFV C
                   WHERE        CONCATENATED_SEGMENTS =
                                LTRIM (
                                   RTRIM (
                                      T_CUR_APINV_MAIN_LINE_REC (I).P_ACC_CODE))
                         AND END_DATE_ACTIVE IS NULL;

                  IF L_CCID IS NULL
                  THEN
                     L_ERR_MSG :=
                           RTRIM (L_ERR_MSG)
                        || ' ,I04- INVALID CODE COMBINATION ID ';
                     RETCODE := '2';
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     L_ERR_MSG :=
                           RTRIM (L_ERR_MSG)
                        || ' ,I04-INVALID CODE COMBINATION ID ';
                     RETCODE := '2';
               END;


               /************Update Records for Status************/
               print_line ('Total' || L_TOT_CNT);

               IF RETCODE <> '0'
               THEN
                  print_line ('inside if debug for code combination ');
                  print_line (
                        'ERROR - INVOICE NUMBER: '
                     || T_CUR_APINV_MAIN_LINE_REC (I).INVOICE_NUM
                     || L_ERR_MSG);
                  ERRBUF := L_ERR_MSG;
                  print_line (ERRBUF);

                  --    apps.fnd_file.put_line(apps.fnd_file.output,ERRBUF ||'and'||L_ERR_MSG);
                  UPDATE ITC.XXLGM_AP_INV_LINE_STG_T T
                     SET T.REC_STATUS = 'E', T.ERR_MESSAGE = L_ERR_MSG
                   WHERE     t.INVOICE_NUM =
                                T_CUR_APINV_MAIN_LINE_REC (I).INVOICE_NUM
                         AND t.LINE_NUMBER =
                                T_CUR_APINV_MAIN_LINE_REC (I).LINE_NUMBER;

                  COMMIT;
                  v_temp2 :=
                     fnd_concurrent.set_completion_status ('WARNING', ERRBUF);
                  COMMIT;
               ELSE
                  UPDATE ITC.XXLGM_AP_INV_LINE_STG_T T
                     SET T.REC_STATUS = 'V'
                   WHERE     t.INVOICE_NUM =
                                T_CUR_APINV_MAIN_LINE_REC (I).INVOICE_NUM
                         AND t.LINE_NUMBER =
                                T_CUR_APINV_MAIN_LINE_REC (I).LINE_NUMBER;

                  print_line (
                     T_CUR_APINV_MAIN_LINE_REC (I).INVOICE_NUM || 'SUCESSES');

                  COMMIT;
               END IF;
            /************Update Records for Status************/
            END LOOP;

            COMMIT;
         --  apps.fnd_file.put_line(apps.fnd_file.output,'Total No of Invoices LINES got updated-'||L_TOT_CNT);

         ELSE
            --  L_ERR_MSG :='No Data To Process';
            RETCODE := '2';
            PRINT_LINE ('No Rows in Invoice Lines To Process');
         END IF;
      END;

      BEGIN
         print_line ('UPDATING LINES STATUS FOR DUPLICATE INVOICE IN FILE'); ---ADDED MAR19

         UPDATE ITC.XXLGM_AP_INV_HDR_STG_T T
            SET T.REC_STATUS = 'E',
                T.ERR_MESSAGE =
                   T.ERR_MESSAGE || ', I03-DUPLICATE INVOICE NUMBER IN FILE '
          WHERE t.INVOICE_NUM IN (  SELECT DISTINCT INVOICE_NUM
                                      FROM ITC.XXLGM_AP_INV_HDR_STG_T
                                     WHERE 1 = 1
                                  GROUP BY invoice_num
                                    HAVING COUNT (VENDOR_CODE) > 1);

         COMMIT;


         --


         print_line ('UPDATING LINES STATUS FOR INVALID LINE');

         UPDATE ITC.XXLGM_AP_INV_LINE_STG_T T
            SET T.REC_STATUS = 'E'
          WHERE T.INVOICE_NUM IN (SELECT DISTINCT invoice_num
                                    FROM ITC.XXLGM_AP_INV_LINE_STG_T
                                   WHERE REC_STATUS = 'E');

         COMMIT;

         print_line ('UPDATING LINES FOR INVALID HEADER ');

         UPDATE ITC.XXLGM_AP_INV_LINE_STG_T T
            SET T.REC_STATUS = 'E',
                T.ERR_MESSAGE =
                   T.ERR_MESSAGE || ',I03- INVALID INVOICE HEADER '
          WHERE (   T.INVOICE_NUM IN (SELECT DISTINCT invoice_num
                                        FROM ITC.XXLGM_AP_INV_HDR_STG_T
                                       WHERE REC_STATUS = 'E')
                 OR T.INVOICE_NUM NOT IN
                       (SELECT DISTINCT INVOICE_NUM
                          FROM ITC.XXLGM_AP_INV_HDR_STG_T));

         COMMIT;

         print_line ('UPDATING HEADER FOR INVALID LINES ');

         UPDATE ITC.XXLGM_AP_INV_HDR_STG_T T
            SET T.REC_STATUS = 'E',
                T.ERR_MESSAGE =
                      T.ERR_MESSAGE
                   || ', I03-NOT ALL THE INVOICES LINES ARE VALID FOR INVOICE '
          WHERE t.INVOICE_NUM IN (SELECT DISTINCT invoice_num
                                    FROM ITC.XXLGM_AP_INV_LINE_STG_T
                                   WHERE REC_STATUS = 'E');

         COMMIT;
      END;
   /************Update Records for Status FOR HEADER************/

   END XXLGM_INV_VERIFY_P;


   PROCEDURE XXLGM_INV_MAIN_INSERT_P (RETCODE   OUT VARCHAR2,
                                      ERRBUF    OUT VARCHAR2)
   IS
      CURSOR CUR_APINV_MAIN
      IS
         SELECT INVOICE_NUM,
                INVOICE_TYPE_LOOKUP_CODE,
                INVOICE_DATE,
                VENDOR_CODE,
                VENDOR_NAME,
                VENDOR_SITE_CODE,
                INVOICE_AMOUNT,
                INVOICE_CURRENCY_CODE,
                PAYMENT_CURRENCY_CODE,
                DESCRIPTION,
                SOURCE,
                DOC_CATEGORY_CODE,
                INVOICE_RECEIVED_DATE,
                GOODS_RECEIVED_DATE,
                GL_DATE,
                ORGANIZATION_CODE,
                IMP_REFER_NUM,
                VENDOR_ID,
                DUMMY_INVOICE_ID,
                EXCHANGE_RATE_TYPE,
                EXCHANGE_RATE,
                EXCHANGE_DATE,
                ATTRIBUTE_CATEGORY,
                ATTRIBUTE1,
                ATTRIBUTE2,
                ATTRIBUTE3,
                ATTRIBUTE4,
                ATTRIBUTE5,
                ATTRIBUTE6,
                ATTRIBUTE7,
                ATTRIBUTE8,
                ATTRIBUTE9,
                ATTRIBUTE10,
                ATTRIBUTE11,
                ATTRIBUTE12,
                ATTRIBUTE13,
                ATTRIBUTE14,
                ATTRIBUTE15,
                LIABILITY_ACCOUNT
           FROM ITC.XXLGM_AP_INV_HDR_STG_T
          WHERE REC_STATUS = 'V';

      CURSOR CUR_APINVLINE_MAIN (inv_num VARCHAR2)
      IS
         SELECT INVOICE_NUM,
                LINE_NUMBER,
                LINE_TYPE_LOOKUP_CODE,
                AMOUNT,
                ACCOUNTING_DATE,
                DESCRIPTION,
                P_ACC_CODE,
                DUMMY_INVOICE_ID
           FROM ITC.XXLGM_AP_INV_LINE_STG_T
          WHERE REC_STATUS = 'V' AND INVOICE_NUM = inv_num;

      TYPE CUR_APINV_REC IS TABLE OF CUR_APINV_MAIN%ROWTYPE
         INDEX BY PLS_INTEGER;

      TYPE CUR_APINVLINE_REC IS TABLE OF CUR_APINVLINE_MAIN%ROWTYPE
         INDEX BY PLS_INTEGER;

      T_CUR_APINV_MAIN_REC         CUR_APINV_REC;
      T_CUR_APINV_MAIN_LINE_REC    CUR_APINVLINE_REC;
      L_ERR_MSG                    VARCHAR2 (5000);
      L_TOT_CNT                    NUMBER;
      l_cnt_exp                    NUMBER;
      L_INVOICE_NUM                VARCHAR2 (150);
      L_INVOICE_TYPE_LOOKUP_CODE   VARCHAR2 (100);
      L_INVOICE_DATE               DATE;
      L_VENDOR_CODE                VARCHAR2 (100);
      L_VENDOR_NAME                VARCHAR2 (100);
      L_VENDOR_SITE_CODE           VARCHAR2 (100);
      L_INVOICE_AMOUNT             NUMBER;
      L_INVOICE_CURRENCY_CODE      VARCHAR2 (100);
      L_SOURCE                     VARCHAR2 (200);
      L_GL_DATE                    DATE;
      L_VENDOR_ID                  NUMBER;
      L_VENDOR_SITE_ID             NUMBER;
      L_INVOICE_ID                 NUMBER;
      L_LINE_NUM                   NUMBER;
      L_VENDOR_ID_1                NUMBER;
      L_VENDOR_ID_2                NUMBER;
      L_REC_STATUS                 NUMBER;
      L_LIABILITY                  NUMBER;
      L_ORG_ID                     NUMBER;
      L_LIABILITY_COMBINATION_ID   NUMBER;
   BEGIN
      BEGIN
         OPEN CUR_APINV_MAIN;

         FETCH CUR_APINV_MAIN
         BULK COLLECT INTO T_CUR_APINV_MAIN_REC;

         CLOSE CUR_APINV_MAIN;

         IF T_CUR_APINV_MAIN_REC.COUNT <> 0
         THEN
            L_TOT_CNT := T_CUR_APINV_MAIN_REC.COUNT;

            FOR I IN T_CUR_APINV_MAIN_REC.FIRST .. T_CUR_APINV_MAIN_REC.LAST
            LOOP
               L_VENDOR_ID := NULL;
               L_VENDOR_SITE_ID := NULL;

               /*-----------------------  Insertion of Liability Account -----------------*/

               BEGIN
                  SELECT CODE_COMBINATION_ID
                    INTO L_LIABILITY_COMBINATION_ID
                    FROM GL_CODE_COMBINATIONS_KFV
                   WHERE CONCATENATED_SEGMENTS =
                            LTRIM (
                               RTRIM (
                                 T_CUR_APINV_MAIN_REC(I).LIABILITY_ACCOUNT));
                DBMS_OUTPUT.PUT_LINE('VALUE of liability account after calculation: '||L_LIABILITY_COMBINATION_ID);

                  IF L_LIABILITY_COMBINATION_ID IS NULL
                  THEN
                     L_ERR_MSG :=
                           RTRIM (L_ERR_MSG)
                        || ' ,I01- INVALID LIABILITY ACCOUNT ';
                     RETCODE := '2';
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                DBMS_OUTPUT.PUT_LINE('Inside exception : '||L_LIABILITY_COMBINATION_ID);
                     L_ERR_MSG :=
                           RTRIM (L_ERR_MSG)
                        || ' ,I01- INVALID LIABILITY ACCOUNT ';
                     RETCODE := '2';
               END;


               /*------------------------   Insertion of vendor ------------------------*/
               BEGIN
                  SELECT VENDOR_ID
                    INTO L_VENDOR_ID
                    FROM apps.PO_VENDORS
                   WHERE LTRIM (RTRIM (VENDOR_ID)) =
                            T_CUR_APINV_MAIN_REC (I).VENDOR_ID;

                  IF L_VENDOR_ID IS NULL
                  THEN
                     L_ERR_MSG :=
                        RTRIM (L_ERR_MSG) || ' ,I01- INVALID VENDOR ID ';
                     RETCODE := '2';
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     L_ERR_MSG :=
                        RTRIM (L_ERR_MSG) || ' ,I01- INVALID VENDOR ID ';
                     RETCODE := '2';
               END;

               /*------------------------   Insertion of vendor SITE ------------------------*/
               BEGIN
                  SELECT VENDOR_SITE_ID
                    INTO L_VENDOR_SITE_ID
                    FROM apps.PO_VENDOR_SITES_ALL
                   WHERE     VENDOR_SITE_CODE =
                                T_CUR_APINV_MAIN_REC (I).VENDOR_SITE_CODE
                         AND VENDOR_ID = L_VENDOR_ID
                         AND PAY_SITE_FLAG = 'Y';

                  IF L_VENDOR_SITE_ID IS NULL
                  THEN
                     L_ERR_MSG :=
                           RTRIM (L_ERR_MSG)
                        || ' ,I02- INVALID SITE ,CHECK IF PAY SITE';
                     RETCODE := '2';
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     L_ERR_MSG :=
                           RTRIM (L_ERR_MSG)
                        || ' ,I02- INVALID SITE ,CHECK IF PAY SITE';
                     RETCODE := '2';
               END;

               /*------------------------  Insertion of vendor SITE ------------------------*/
               SELECT AP.AP_INVOICES_INTERFACE_S.NEXTVAL
                 INTO L_INVOICE_ID
                 FROM DUAL;

               /*-----------------------  Get the ORG_ID using the oraganziation code ---------------------------    */

               SELECT ORGANIZATION_ID
                 INTO L_ORG_ID
                 FROM APPS.HR_OPERATING_UNITS V
                WHERE     1 = 1
                      AND (UPPER (V.NAME) =
                              UPPER (
                                 T_CUR_APINV_MAIN_REC (I).ORGANIZATION_CODE));

               /*-----------------------  Get the ORG_ID using the oraganziation code ---------------------------    */
                DBMS_OUTPUT.PUT_LINE('Value of liability account before insertion: '||L_LIABILITY_COMBINATION_ID);
               INSERT
                 INTO apps.AP_INVOICES_INTERFACE (
                         INVOICE_ID,
                         INVOICE_NUM,
                         INVOICE_TYPE_LOOKUP_CODE,
                         INVOICE_DATE                             --,VENDOR_ID
                                     ,
                         VENDOR_NUM,
                         VENDOR_NAME                         --,VENDOR_SITE_ID
                                    ,
                         VENDOR_SITE_CODE,
                         INVOICE_AMOUNT,
                         INVOICE_CURRENCY_CODE,
                         PAYMENT_CURRENCY_CODE,
                         DESCRIPTION,
                         SOURCE,
                         GL_DATE,                                    --,ORG_ID
                         ORG_ID,
                         OPERATING_UNIT,
                         DOC_CATEGORY_CODE,
                         LAST_UPDATED_BY,
                         LAST_UPDATE_DATE,
                         CREATED_BY,
                         CREATION_DATE,
                         INVOICE_RECEIVED_DATE,
                         GOODS_RECEIVED_DATE,
                         CALC_TAX_DURING_IMPORT_FLAG,
                         TAX_INVOICE_INTERNAL_SEQ,
                         EXCHANGE_RATE_TYPE,
                         EXCHANGE_RATE,
                         EXCHANGE_DATE,
                         ATTRIBUTE_CATEGORY,
                         ATTRIBUTE1,
                         ATTRIBUTE2,
                         ATTRIBUTE3,
                         ATTRIBUTE4,
                         ATTRIBUTE5,
                         ATTRIBUTE6,
                         ATTRIBUTE7,
                         ATTRIBUTE8,
                         ATTRIBUTE9,
                         ATTRIBUTE10,
                         ATTRIBUTE11,
                         ATTRIBUTE12,
                         ATTRIBUTE13,
                         ATTRIBUTE14,
                         ATTRIBUTE15,
                         ACCTS_PAY_CODE_COMBINATION_ID)
               VALUES (
                         L_INVOICE_ID,
                         T_CUR_APINV_MAIN_REC (I).INVOICE_NUM,
                         UPPER (
                            T_CUR_APINV_MAIN_REC (I).INVOICE_TYPE_LOOKUP_CODE),
                         T_CUR_APINV_MAIN_REC (I).INVOICE_DATE  --,L_VENDOR_ID
                                                              ,
                         T_CUR_APINV_MAIN_REC (I).VENDOR_CODE,
                         T_CUR_APINV_MAIN_REC (I).VENDOR_NAME --,L_VENDOR_SITE_ID
                                                             ,
                         T_CUR_APINV_MAIN_REC (I).VENDOR_SITE_CODE,
                         T_CUR_APINV_MAIN_REC (I).INVOICE_AMOUNT,
                         T_CUR_APINV_MAIN_REC (I).INVOICE_CURRENCY_CODE,
                         T_CUR_APINV_MAIN_REC (I).PAYMENT_CURRENCY_CODE,
                         SUBSTR (T_CUR_APINV_MAIN_REC (I).DESCRIPTION,
                                 1,
                                 239),
                         T_CUR_APINV_MAIN_REC (I).SOURCE,
                         T_CUR_APINV_MAIN_REC (I).GL_DATE,         --,L_ORG_ID
                         L_ORG_ID,
                         T_CUR_APINV_MAIN_REC (I).ORGANIZATION_CODE,
                         T_CUR_APINV_MAIN_REC (I).DOC_CATEGORY_CODE,
                         FND_GLOBAL.USER_ID,
                         SYSDATE,
                         FND_GLOBAL.USER_ID,
                         SYSDATE,
                         T_CUR_APINV_MAIN_REC (I).INVOICE_RECEIVED_DATE,
                         T_CUR_APINV_MAIN_REC (I).GOODS_RECEIVED_DATE,
                         'Y',
                         T_CUR_APINV_MAIN_REC (I).IMP_REFER_NUM,
                         T_CUR_APINV_MAIN_REC (I).EXCHANGE_RATE_TYPE,
                         T_CUR_APINV_MAIN_REC (I).EXCHANGE_RATE,
                         T_CUR_APINV_MAIN_REC (I).EXCHANGE_DATE,
                         T_CUR_APINV_MAIN_REC (I).ATTRIBUTE_CATEGORY,
                         T_CUR_APINV_MAIN_REC (I).ATTRIBUTE1,
                         T_CUR_APINV_MAIN_REC (I).ATTRIBUTE2,
                         T_CUR_APINV_MAIN_REC (I).ATTRIBUTE3,
                         T_CUR_APINV_MAIN_REC (I).ATTRIBUTE4,
                         T_CUR_APINV_MAIN_REC (I).ATTRIBUTE5,
                         T_CUR_APINV_MAIN_REC (I).ATTRIBUTE6,
                         T_CUR_APINV_MAIN_REC (I).ATTRIBUTE7,
                         T_CUR_APINV_MAIN_REC (I).ATTRIBUTE8,
                         T_CUR_APINV_MAIN_REC (I).ATTRIBUTE9,
                         T_CUR_APINV_MAIN_REC (I).ATTRIBUTE10,
                         T_CUR_APINV_MAIN_REC (I).ATTRIBUTE11,
                         T_CUR_APINV_MAIN_REC (I).ATTRIBUTE12,
                         T_CUR_APINV_MAIN_REC (I).ATTRIBUTE13,
                         T_CUR_APINV_MAIN_REC (I).ATTRIBUTE14,
                         T_CUR_APINV_MAIN_REC (I).ATTRIBUTE15,
                         L_LIABILITY_COMBINATION_ID);

               BEGIN
                  L_TOT_CNT := NULL;

                  OPEN CUR_APINVLINE_MAIN (T_CUR_APINV_MAIN_REC (I).INVOICE_NUM);

                  FETCH CUR_APINVLINE_MAIN
                  BULK COLLECT INTO T_CUR_APINV_MAIN_LINE_REC;

                  CLOSE CUR_APINVLINE_MAIN;

                  IF T_CUR_APINV_MAIN_LINE_REC.COUNT <> 0
                  THEN
                     L_TOT_CNT := T_CUR_APINV_MAIN_LINE_REC.COUNT;

                     FOR J IN T_CUR_APINV_MAIN_LINE_REC.FIRST ..
                              T_CUR_APINV_MAIN_LINE_REC.LAST
                     LOOP
                        RETCODE := '0';
                        L_ERR_MSG := NULL;
                        L_INVOICE_NUM := NULL;
                        L_LINE_NUM := NULL;
                        L_VENDOR_ID_1 := NULL;
                        L_VENDOR_ID_2 := NULL;
                        --L_CCID          :=NULL;
                        l_cnt_exp := 0;

                        INSERT
                          INTO apps.AP_INVOICE_LINES_INTERFACE (
                                  INVOICE_ID,
                                  INVOICE_LINE_ID,
                                  LINE_NUMBER,
                                  LINE_TYPE_LOOKUP_CODE,
                                  AMOUNT,
                                  ACCOUNTING_DATE,
                                  DESCRIPTION,
                                  DIST_CODE_CONCATENATED,
                                  ORG_ID,
                                  LAST_UPDATED_BY,
                                  LAST_UPDATE_DATE,
                                  CREATED_BY,
                                  CREATION_DATE)
                        VALUES (
                                  L_INVOICE_ID,
                                  ap.AP_INVOICE_LINES_INTERFACE_S.NEXTVAL,
                                  T_CUR_APINV_MAIN_LINE_REC (J).LINE_NUMBER,
                                  T_CUR_APINV_MAIN_LINE_REC (J).LINE_TYPE_LOOKUP_CODE,
                                  T_CUR_APINV_MAIN_LINE_REC (J).AMOUNT,
                                  T_CUR_APINV_MAIN_LINE_REC (J).ACCOUNTING_DATE,
                                  SUBSTR (
                                     T_CUR_APINV_MAIN_LINE_REC (J).DESCRIPTION,
                                     1,
                                     239),
                                  T_CUR_APINV_MAIN_LINE_REC (J).P_ACC_CODE,
                                  L_ORG_ID,
                                  FND_GLOBAL.USER_ID,
                                  SYSDATE,
                                  FND_GLOBAL.USER_ID,
                                  SYSDATE);
                     END LOOP;

                     COMMIT;
                  -- apps.fnd_file.put_line(apps.fnd_file.output,'Total No of Invoices LINES got updated-'||L_TOT_CNT);
                  END IF;
               END;
            END LOOP;

            COMMIT;
         --  apps.fnd_file.put_line(apps.fnd_file.output,'Total No of Invoices got selected in cursor-'||L_TOT_CNT);
         END IF;
      END;

      UPDATE ITC.XXLGM_AP_INV_HDR_STG_T T
         SET REC_STATUS = 'P'
       WHERE T.INVOICE_NUM IN
                (SELECT A.INVOICE_NUM
                   FROM APPS.AP_INVOICES_INTERFACE a,
                        apps.AP_INVOICE_LINES_INTERFACE b
                  WHERE a.invoice_id = b.invoice_id);

      UPDATE ITC.XXLGM_AP_INV_LINE_STG_T T
         SET REC_STATUS = 'P'
       WHERE T.INVOICE_NUM IN
                (SELECT DISTINCT a.INVOICE_NUM
                   FROM APPS.AP_INVOICES_INTERFACE a,
                        apps.AP_INVOICE_LINES_INTERFACE b
                  WHERE a.invoice_id = b.invoice_id);

      COMMIT;
   END XXLGM_INV_MAIN_INSERT_P;
END XXLGM_AP_INV_IMPORT_DTL_PKG;
/
