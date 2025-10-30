CREATE OR REPLACE PACKAGE BODY APPS.XXCCTT_GG_FILTER_CONDITION_PKG
/******************************************************************************
   NAME:       xxcctt_gg_filter_condition_pkg.pkb
   PURPOSE:    Validate india specific and posted transactions and return the count back to Golden Gate


   REVISIONS:
   Ver        Date        Author               Description                        Reviewed By       Reviewed Date
   ---------  ----------  ---------------      ---------------------------------- ----------------  -------------
   1.0        02-05-2025  WJ454(BSL)           Created this package.                                DD-MM-RRRR
   1.1        14-04-2025  AL02R                Added the tabel in validation
   1.2        11-06-2025  XW294               Removed old new values and restructured
                                               code(CHG0243331)
   1.3        22-08-2025  XW294               Changed get_cp_count function and
                                              Client_id Null condition is changed.(CHG0251511)
   ASSUMPTIONS:
   LIMITATIONS:
   ALGORITHM:
   NOTES:
******************************************************************************/
AS
   --  g_program_list   xxc.xxc011975_table_of_varchar2_256 := xxc.xxc011975_table_of_varchar2_256();
   -- g_queue_list     xxc.xxc011975_table_of_varchar2_256 := xxc.xxc011975_table_of_varchar2_256();
   -- g_ou_list        xxc.xxc011975_table_of_number := xxc.xxc011975_table_of_number();



   -- Function is to check whether the client/updated user is having super user access or not
   /*
   FUNCTION get_su_update_count (p_client_id IN VARCHAR2)
   RETURN NUMBER
   IS
       l_su_count NUMBER;
   BEGIN
           SELECT COUNT(1) INTO l_su_count
             FROM dual
            WHERE EXISTS
            (
               SELECT 1
                 FROM fnd_profile_options fpo
                     ,fnd_profile_option_values fpov
                     ,fnd_user fu
                WHERE fpo.profile_option_name = 'FND_DIAGNOSTICS'
                  AND fpo.profile_option_id = fpov.profile_option_id
                  AND fu.user_id = fpov.level_value
                  AND fpov.profile_option_value = 'Y'
                  AND fu.user_name = nvl(p_client_id, fu.user_name)
           );

       RETURN l_su_count;
   END get_su_update_count;

   */
   --Function to check the is deleted or inserted records are INDIA related or not

   FUNCTION is_backend_change_for_ind_org (p_table_name    IN VARCHAR2,
                                           p_key_value7    IN VARCHAR2,
                                           p_key_value8    IN VARCHAR2,
                                           p_key_value9    IN VARCHAR2,
                                           p_key_value10   IN VARCHAR2,
                                           p_key_value11   IN VARCHAR2,
                                           p_key_value12   IN VARCHAR2)
      RETURN NUMBER
   IS
      l_eligible_count   NUMBER;
   BEGIN
      IF p_table_name = 'PO_RELEASES_ALL'
      THEN
         -- p_key_value7 = ORG_ID
         l_eligible_count := is_ind_org (p_key_value7, NULL);
      ELSIF (p_table_name = 'PO_HEADERS_ALL')
      THEN
         -- p_key_value7 = ORG_ID
         l_eligible_count := is_ind_org (p_key_value7, NULL);
      ELSIF (p_table_name = 'PO_LINES_ALL')
      THEN
         -- p_key_value7 = ORG_ID
         l_eligible_count := is_ind_org (p_key_value7, NULL);
      ELSIF (p_table_name = 'PO_LINE_LOCATIONS_ALL')
      THEN
         -- p_key_value7 = ORG_ID
         l_eligible_count := is_ind_org (p_key_value7, NULL);
      ELSIF (p_table_name = 'PO_DISTRIBUTIONS_ALL')
      THEN
         -- p_key_value7 = ORG_ID
         l_eligible_count := is_ind_org (p_key_value7, NULL);
      ELSIF (p_table_name = 'WSH_DELIVERY_DETAILS')
      THEN
         -- p_key_value7 = ORGANIZATION_ID
         l_eligible_count := is_ind_org (NULL, p_key_value7);
      ELSIF (p_table_name = 'OE_ORDER_LINES_ALL')
      THEN
         -- p_key_value7 = ORG_ID
         l_eligible_count := is_ind_org (p_key_value7, NULL);
      ELSIF (p_table_name = 'OE_ORDER_HEADERS_ALL')
      THEN
         -- p_key_value7 = ORG_ID
         l_eligible_count := is_ind_org (p_key_value7, NULL);
      ELSIF p_table_name = 'ORG_ACCT_PERIODS'
      THEN
         -- p_key_value7 = ORGANIZATION_ID

         l_eligible_count := is_ind_org (NULL, p_key_value7);
      ELSIF p_table_name = 'MTL_SECONDARY_INVENTORIES'
      THEN
         -- p_key_value7 = ORGANIZATION_ID
         l_eligible_count := is_ind_org (NULL, p_key_value7);
      ELSIF p_table_name = 'AR_SYSTEM_PARAMETERS_ALL'
      THEN
         -- p_key_value7 = SET_OF_BOOKS_ID
         IF p_key_value7 IN ('3001')
         THEN
            l_eligible_count := 1;
         END IF;
      ELSIF p_table_name = 'AR_RECEIVABLES_TRX_ALL'
      THEN
         -- p_key_value7 = org_id
         l_eligible_count := is_ind_org (p_key_value7, NULL);
      ELSIF p_table_name = 'AP_SYSTEM_PARAMETERS_ALL'
      THEN
         -- p_key_value7 = org_id
         l_eligible_count := is_ind_org (p_key_value7, NULL);
      ELSIF p_table_name = 'MTL_PARAMETERS'
      THEN
         -- p_key_value7 = ORGANIZATION_ID
         l_eligible_count := is_ind_org (NULL, p_key_value7);
      ELSIF p_table_name = 'GL_PERIOD_STATUSES
'
      THEN
         -- p_key_value7 = SET_OF_BOOKS_ID

         IF p_key_value7 IN ('3001')
         THEN
            l_eligible_count := 1;
         END IF;
      ELSIF p_table_name = 'GL_LEDGERS
'
      THEN
         -- p_key_value7 = LEDGER_ID

         IF p_key_value7 IN ('3001')
         THEN
            l_eligible_count := 1;
         END IF;
      ELSIF p_table_name = 'GL_DAILY_RATES'
      THEN
         -- p_key_value7 = TO_CURRENCY
         -- p_key_value8 = CONVERSION_TYPE
         IF p_key_value7 = 'INR' AND p_key_value8 = 'Corporate'
         THEN
            l_eligible_count := 1;
         ELSE
            l_eligible_count := 0;
         -- l_status_message := ( ' GL_DAILY RATE IS NOT Deleted or inserted FOR INR CURRENCY ' );
         END IF;
      ELSIF p_table_name = 'MTL_INTERORG_PARAMETERS'
      THEN
         l_eligible_count := 1;
      ELSIF (p_table_name = 'IBY_EXTERNAL_PAYEES_ALL')
      THEN
         -- p_key_value7 = EXT_PAYEE_ID
         -- p_key_value8 = PAYEE_PARTY_ID

         -- Check whether the payments are related to India Operating Units in apps.iby_payments_alltable.
         -- Changed the is_ind_org function as per requirment.by Aditya R on 12-Jun-2025 CRQ CHG0243331

         /*SELECT COUNT (1)
           INTO l_eligible_count
           FROM DUAL
          WHERE EXISTS
                   (SELECT 1
                      FROM APPS.iby_payments_all
                     WHERE     payee_party_id = TO_NUMBER (p_key_value8)
                           AND 1 = (is_ind_org (org_id, NULL)));*/
         SELECT COUNT (1)
           INTO l_eligible_count
           FROM DUAL
          WHERE EXISTS
                   (SELECT 1
                      FROM APPS.iby_payments_all IBA,
                           ORG_ORGANIZATION_DEFINITIONS OOD
                     WHERE     OOD.OPERATING_UNIT = IBA.ORG_ID
                           AND SET_OF_BOOKS_ID IN (3001)
                           AND payee_party_id = TO_NUMBER (p_key_value8));
      ELSIF (p_table_name = 'OE_TRANSACTION_TYPES_ALL')
      THEN
         --p_key_value7= ORG_ID

         l_eligible_count := is_ind_org (p_key_value7, NULL);
      --1.1 END

      ELSIF (p_table_name = 'RA_CUSTOMER_TRX_ALL')
      THEN
         -- p_key_value7 = CUSTOMER_TRX_ID
         -- p_key_value8 = SET_OF_BOOKS_ID

         IF p_key_value8 IN ('3001')
         THEN
            l_eligible_count := 1;
         END IF;
      ELSIF (p_table_name = 'QP_LIST_HEADERS_B')
      THEN
           --p_key_value7=list_header_id

           --l_eligible_count := 1;
           --Added by Aditya R to check wherther grant_type,grant_Id is india specific on 13-Jun-2025 for CRQ CHG0243331

           SELECT CASE MAX (B.GRANTEE_TYPE)
                     WHEN 'OU'
                     THEN
                        NVL (
                           (SELECT 1
                              FROM DUAL
                             WHERE (SELECT C.GRANTEE_ID
                                      FROM QP_GRANTS C
                                     WHERE     C.INSTANCE_ID = B.INSTANCE_ID
                                           AND C.GRANTEE_TYPE = 'OU') IN (SELECT HOU.ORGANIZATION_ID
                                                                            FROM HR_OPERATING_UNITS HOU
                                                                           WHERE HOU.SET_OF_BOOKS_ID =
                                                                                    3001)),
                           0)
                     WHEN 'GLOBAL'
                     THEN
                        1
                  END
                     AS RESULT
             INTO l_eligible_count
             FROM APPS.QP_LIST_HEADERS_B A, APPS.QP_GRANTS B
            WHERE     A.LIST_HEADER_ID = B.INSTANCE_ID
                  AND A.LIST_HEADER_ID = P_KEY_VALUE7
         GROUP BY B.INSTANCE_ID;
      ELSIF (p_table_name = 'QP_LIST_LINES')
      THEN
           --p_key_value7=list_header_id

           --ln_count := 1;

           --Added by Aditya R to check wherther grant_type,grant_Id is india specific on 13-Jun-2025 for CRQ CHG0243331

           SELECT CASE MAX (B.GRANTEE_TYPE)
                     WHEN 'OU'
                     THEN
                        NVL (
                           (SELECT 1
                              FROM DUAL
                             WHERE (SELECT C.GRANTEE_ID
                                      FROM QP_GRANTS C
                                     WHERE     C.INSTANCE_ID = B.INSTANCE_ID
                                           AND C.GRANTEE_TYPE = 'OU') IN (SELECT HOU.ORGANIZATION_ID
                                                                            FROM HR_OPERATING_UNITS HOU
                                                                           WHERE HOU.SET_OF_BOOKS_ID =
                                                                                    3001)),
                           0)
                     WHEN 'GLOBAL'
                     THEN
                        1
                  END
                     AS RESULT
             INTO l_eligible_count
             FROM APPS.QP_LIST_HEADERS_B A, APPS.QP_GRANTS B
            WHERE     A.LIST_HEADER_ID = B.INSTANCE_ID
                  AND A.LIST_HEADER_ID = P_KEY_VALUE7
         GROUP BY B.INSTANCE_ID;
      --l_eligible_count := 1;
      ELSIF (p_table_name = 'RA_CUST_TRX_TYPES_ALL')
      THEN
         -- p_key_value7 = SET_OF_BOOKS_ID
         IF p_key_value8 IN ('3001')
         THEN
            l_eligible_count := 1;
         END IF;
      ELSIF (p_table_name = 'RCV_PARAMETERS')
      THEN
         -- p_key_value7 = ORGANIZATION_ID

         l_eligible_count := is_ind_org (NULL, p_key_value7);
      --1.1 changes end
      ELSIF (p_table_name = 'RA_CUSTOMER_TRX_LINES_ALL')
      THEN
         -- p_key_value7 = CUSTOMER_TRX_LINE_ID
         -- p_key_value8 = SET_OF_BOOKS_ID

         IF p_key_value8 IN ('3001')
         THEN
            l_eligible_count := 1;
         END IF;
      ELSIF (p_table_name = 'RA_CUST_TRX_LINE_GL_DIST_ALL')
      THEN
         -- p_key_value7 = CUST_TRX_LINE_GL_DIST_ID
         -- p_key_value8 = SET_OF_BOOKS_ID

         IF p_key_value8 IN ('3001')
         THEN
            l_eligible_count := 1;
         END IF;
      ELSIF (P_TABLE_NAME = 'AR_PAYMENT_SCHEDULES_ALL')
      THEN
         -- p_key_value7 = PAYMENT_SCHEDULE_ID
         -- p_key_value8 = CUSTOMER_TRX_ID
         -- p_key_value9 = ORG_ID

         l_eligible_count := is_ind_org (p_key_value9, NULL);
      ELSIF P_TABLE_NAME = 'MTL_SYSTEM_ITEMS_B'
      THEN
         -- p_key_value7 = INVENTORY_ITEM_ID
         -- p_key_value8 = ORGANIZATION_ID

         l_eligible_count := is_ind_org (NULL, p_key_value8);
      ELSIF P_TABLE_NAME = 'AR_DISTRIBUTIONS_ALL'
      THEN
         -- p_key_value7 = LINE_ID
         -- p_key_value8 = ORG_ID
         l_eligible_count := is_ind_org (p_key_value8, NULL);
      ELSIF P_TABLE_NAME = 'XLA_DISTRIBUTION_LINKS'
      THEN
         -- p_key_value7 = AE_HEADER_ID
         -- p_key_value8 = AE_LINE_NUM
         SELECT COUNT (1)
           INTO l_eligible_count
           FROM DUAL
          WHERE EXISTS
                   (SELECT 1
                      FROM APPS.XLA_AE_HEADERS XAH
                     WHERE     1 = 1
                           AND XAH.AE_HEADER_ID = p_key_value7  --AE_HEADER_ID
                           AND XAH.LEDGER_ID = 3001);
      ELSIF P_TABLE_NAME = 'AR_REVENUE_ADJUSTMENTS_ALL'
      THEN
         -- p_key_value7 = REVENUE_ADJUSTMENT_ID
         -- p_key_value8 = ORG_ID

         l_eligible_count := is_ind_org (p_key_value8, NULL);
      ELSIF P_TABLE_NAME = 'AR_DEFERRED_LINES_ALL'
      THEN
         -- p_key_value7 = CUSTOMER_TRX_LINE_ID
         -- p_key_value8 = ORG_ID

         l_eligible_count := is_ind_org (p_key_value8, NULL);
      /* ELSIF P_TABLE_NAME = 'HZ_PARTIES'
       THEN
            -- p_key_value7 = PARTY_ID
               SELECT COUNT(1)
               INTO l_eligible_count
               FROM DUAL
               WHERE  (EXISTS (select 1 from  HZ_CUST_ACCOUNTS HCA,
                                             HZ_PARTY_SITES HZP,
                                             HZ_CUST_ACCT_SITES_ALL HCAS
                            -- APPS.HR_OPERATING_UNITS HOU

                            WHERE    HCA.PARTY_ID               = TO_NUMBER(p_key_value7)    -- PARTY_ID
                         and HZP.PARTY_ID           = TO_NUMBER(p_key_value7)
                         and HCA.CUST_ACCOUNT_ID    = HCAS.CUST_ACCOUNT_ID
                         and HZP.PARTY_SITE_ID      = HCAS.PARTY_SITE_ID
                         and 1 = is_ind_org(HCAS.ORG_ID,null  )
                     --    and HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                            )
                   or exists
                           (select 1 from   HZ_PARTIES HP,
                                    HZ_CUST_ACCOUNTS HCA,
                            HZ_RELATIONSHIPS HRP,
                            HZ_PARTY_SITES HZP,
                            HZ_CUST_ACCT_SITES_ALL HCAS,
                                            APPS.HR_OPERATING_UNITS HOU

                   where
                   (HP.PARTY_TYPE='PERSON' and HRP.RELATIONSHIP_CODE = 'CONTACT' and HRP.OBJECT_ID = p_key_value7 and HRP.SUBJECT_ID = HCA.PARTY_ID)
                   or (HP.PARTY_TYPE='PARTY_RELATIONSHIP' and HRP.RELATIONSHIP_CODE = 'CONTACT_OF' and HRP.PARTY_ID = p_key_value7 and HRP.OBJECT_ID = HCA.PARTY_ID)
                   and HCA.CUST_ACCOUNT_ID = HCAS.CUST_ACCOUNT_ID
                   and HZP.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
                   and HCAS.ORG_ID = HOU.ORGANIZATION_ID
    and hou.set_of_books_id = 3001
                 --  and HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                     )); */
      -- commented by Aditya R on 10-Jun-25 for CRQ CHG0243331

      ELSIF P_TABLE_NAME = 'HZ_CUST_ACCOUNTS'
      THEN
         -- p_key_value7 = CUST_ACCOUNT_ID
         SELECT COUNT (1)
           INTO l_eligible_count
           FROM DUAL
          WHERE EXISTS
                   (SELECT 1
                      FROM HZ_PARTIES HP,
                           HZ_PARTY_SITES HZP,
                           HZ_CUST_ACCT_SITES_ALL HCAS,
                           APPS.HR_OPERATING_UNITS HOU
                     WHERE     HCAS.CUST_ACCOUNT_ID =
                                  TO_NUMBER (p_key_value7)   --CUST_ACCOUNT_ID
                           AND HP.PARTY_ID = HZP.PARTY_ID
                           AND HZP.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
                           AND HCAS.ORG_ID = HOU.ORGANIZATION_ID
                           AND hou.set_of_books_id = 3001);
      /*
      ELSIF P_TABLE_NAME = 'HZ_LOCATIONS'
      THEN
          -- p_key_value7 = LOCATION_ID
            SELECT COUNT(1)
            INTO l_eligible_count
            FROM DUAL
            WHERE  EXISTS
                        (SELECT 1 FROM
                          HZ_PARTY_SITES HZP,
                          HZ_CUST_ACCT_SITES_ALL HCAS,
                          APPS.HR_OPERATING_UNITS HOU

                         WHERE   HZP.LOCATION_ID = TO_NUMBER(p_key_value7)   -- location_id
                                    and HZP.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
                                    and HCAS.org_id            = HOU.ORGANIZATION_ID
      and hou.set_of_books_id = 3001
                         ); */
      -- Commented By Aditya R on 10-Jun-25 CRQ CHG0243331

      ELSIF P_TABLE_NAME = 'HZ_CUST_SITE_USES_ALL'
      THEN
         -- p_key_value7 = SITE_USE_ID
         -- p_key_value8 = ORG_ID
         l_eligible_count := is_ind_org (p_key_value8, NULL);
      ELSIF P_TABLE_NAME = 'HZ_CUST_ACCT_SITES_ALL'
      THEN
         -- p_key_value7 = CUST_ACCT_SITE_ID
         -- p_key_value8 = ORG_ID
         l_eligible_count := is_ind_org (p_key_value8, NULL);
      /*ELSIF P_TABLE_NAME = 'PO_LOCATION_ASSOCIATIONS_ALL'
      THEN
            -- p_key_value7 = LOCATION_ID
            -- p_key_value8 = ORG_ID
          l_eligible_count := is_ind_org(p_key_value8,null);*/
      ---- Commented By Aditya R on 10-Jun-25 CRQ CHG0243331

      ELSIF P_TABLE_NAME = 'AP_SUPPLIERS'
      THEN
         -- p_key_value7 = VENDOR_ID
         SELECT COUNT (1)
           INTO l_eligible_count
           FROM DUAL
          WHERE EXISTS
                   (SELECT 1
                      FROM APPS.AP_SUPPLIER_SITES_ALL APS,
                           HR_OPERATING_UNITS HOU
                     WHERE     APS.VENDOR_ID = TO_NUMBER (p_key_value7) -- VENDOR_ID
                           AND APS.ORG_ID = HOU.ORGANIZATION_ID
                           AND hou.set_of_books_id = 3001 --AND  HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                                                         );
      ELSIF P_TABLE_NAME = 'AP_SUPPLIER_SITES_ALL'
      THEN
         -- p_key_value7 = VENDOR_SITE_ID
         -- p_key_value8 = ORG_ID
         l_eligible_count := is_ind_org (p_key_value8, NULL);
      /*
      ELSIF P_TABLE_NAME = 'AP_SUPPLIER_CONTACTS'
      THEN
          -- p_key_value7 = VENDOR_CONTACT_ID
          SELECT COUNT(1)
          INTO l_eligible_count
          FROM DUAL
          WHERE  EXISTS (select 1 from   APPS.AP_SUPPLIER_CONTACTS ASCC,
                                         APPS.AP_SUPPLIER_SITES_ALL APS,
                                         APPS.HR_OPERATING_UNITS HOU
                                  WHERE  ASCC.VENDOR_CONTACT_ID   =  TO_NUMBER(p_key_value7)   -- VENDOR_CONTACT_ID is pk1
                                  AND APS.VENDOR_SITE_ID   = nvl(ASCC.VENDOR_SITE_ID,APS.VENDOR_SITE_ID)
                                  AND APS.ORG_ID           = HOU.ORGANIZATION_ID
       and hou.set_of_books_id = 3001
                                 -- AND HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                       );*/
      -- Commented by Aditya R on 11-Jun-25 for CRQ CHG0243331
      /*
      ELSIF P_TABLE_NAME = 'MTL_ITEM_CATEGORIES'
      THEN
          -- p_key_value7 = INVENTORY_ITEM_ID
          -- p_key_value8 = ORGANIZATION_ID
          -- p_key_value9 = CATEGORY_SET_ID
              l_eligible_count := is_ind_org(null,p_key_value8); */
      ---- Commented by Aditya R on 11-Jun-25 for CRQ CHG0243331

      /*
      ELSIF P_TABLE_NAME = 'MTL_ITEM_REVISIONS_B'
      THEN
           -- p_key_value7 = REVISION_ID
  -- p_key_value8 = ORGANIZATION_ID
   l_eligible_count := is_ind_org(null,p_key_value8);*/
      ---- Commented by Aditya R on 11-Jun-25 for CRQ CHG0243331

      ELSIF P_TABLE_NAME = 'BOM_STRUCTURES_B'
      THEN
         -- p_key_value7 = BILL_SEQUENCE_ID
         -- p_key_value8 = ORGANIZATION_ID

         l_eligible_count := is_ind_org (NULL, p_key_value8);
      ELSIF P_TABLE_NAME = 'BOM_COMPONENTS_B'
      THEN
         -- p_key_value7 = COMPONENT_SEQUENCE_ID
         SELECT COUNT (1)
           INTO l_eligible_count
           FROM DUAL
          WHERE EXISTS
                   (SELECT 1
                      FROM APPS.BOM_COMPONENTS_B MCB,
                           APPS.BOM_STRUCTURES_B msb,
                           APPS.ORG_ORGANIZATION_DEFINITIONS ORG,
                           APPS.HR_OPERATING_UNITS HOU
                     WHERE     MCB.COMPONENT_SEQUENCE_ID = p_key_value7 -- COMPONENT_SEQUENCE_ID is pk1
                           AND mcb.BILL_SEQUENCE_ID = msb.BILL_SEQUENCE_ID
                           AND ORG.ORGANIZATION_ID = MSB.ORGANIZATION_ID
                           AND ORG.OPERATING_UNIT = HOU.ORGANIZATION_ID
                           AND hou.set_of_books_id = 3001 -- and HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                                                         );
      ELSIF P_TABLE_NAME = 'XLA_AE_HEADERS'
      THEN
         -- p_key_value7 = AE_HEADER_ID
         -- p_key_value8 = LEDGER_ID
         IF p_key_value8 IN ('3001')
         THEN
            l_eligible_count := 1;
         END IF;
      ELSIF P_TABLE_NAME = 'XLA_AE_LINES'
      THEN
         -- p_key_value7 = AE_HEADER_ID
         -- p_key_value8 = AE_LINE_NUM
         -- p_key_value9 = LEDGER_ID
         IF p_key_value9 IN ('3001')
         THEN
            l_eligible_count := 1;
         END IF;
      /*
        ELSIF P_TABLE_NAME = 'XLA_EVENTS'
        THEN
             -- p_key_value7 = EVENT_ID

                SELECT COUNT(1)
                INTO l_eligible_count
                FROM DUAL
                WHERE  EXISTS (select 1 from  APPS.XLA_EVENTS XE,
                                              APPS.XLA_AE_HEADERS XAH,
                                              APPS.HR_OPERATING_UNITS HOU
                                        where XE.EVENT_ID    = TO_NUMBER(p_key_value7)   -- EVENT_ID is pk1
                                        AND XE.ENTITY_ID = XAH.ENTITY_ID
                                        AND XE.EVENT_ID = XAH.EVENT_ID
                                        AND XAH.LEDGER_ID = HOU.SET_OF_BOOKS_ID
          and hou.set_of_books_id = 3001
                              ); */
      -- Commented by Aditya R on 11-Jun-25 for CRQ CHG0243331
      /*
       ELSIF P_TABLE_NAME = 'HZ_ORG_CONTACTS'
       THEN
             -- p_key_value7 = ORG_CONTACT_ID

       SELECT COUNT(1)
       INTO l_eligible_count
       FROM DUAL
       WHERE  EXISTS (select 1 from HZ_ORG_CONTACTS HOC,
                                    HZ_PARTIES HP,
                                    HZ_CUST_ACCOUNTS HCA,
                                    HZ_RELATIONSHIPS HRP,
                                    HZ_PARTY_SITES HZP,
                                    HZ_CUST_ACCT_SITES_ALL HCAS,
                                    APPS.HR_OPERATING_UNITS HOU
                                WHERE HOC.ORG_CONTACT_ID = TO_NUMBER(p_key_value7)  -- ORG_CONTACT_ID pk1
                                and (HP.PARTY_TYPE='PERSON' and HRP.RELATIONSHIP_CODE = 'CONTACT' and HRP.OBJECT_ID = HP.PARTY_ID and HRP.SUBJECT_ID = HCA.PARTY_ID)
                                    or (HP.PARTY_TYPE='PARTY_RELATIONSHIP' and HRP.RELATIONSHIP_CODE = 'CONTACT_OF' and HRP.PARTY_ID = HP.PARTY_ID and HRP.OBJECT_ID = HCA.PARTY_ID)
                                 AND HRP.RELATIONSHIP_ID = HOC.PARTY_RELATIONSHIP_ID
                                 and HCA.CUST_ACCOUNT_ID = HCAS.CUST_ACCOUNT_ID
                                 and HZP.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
                                 and HCAS.ORG_ID = HOU.ORGANIZATION_ID
      and hou.set_of_books_id = 3001
                               --  and HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                     ); */
      -- Commented by Aditya R on 11-Jun-25 for CRQ CHG0243331

      /*
      ELSIF P_TABLE_NAME = 'HZ_CUST_ACCOUNT_ROLES'
      THEN
           -- p_key_value7 = CUST_ACCOUNT_ROLE_ID

              SELECT COUNT(1)
              INTO l_eligible_count
              FROM DUAL
              WHERE  EXISTS (select 1 from HZ_CUST_ACCOUNT_ROLES HCAR,
                                           HZ_PARTIES HP,
                                           HZ_CUST_ACCOUNTS HCA,
                                           HZ_RELATIONSHIPS HRP,
                                           HZ_PARTY_SITES HZP,
                                           HZ_CUST_ACCT_SITES_ALL HCAS,
                                           APPS.HR_OPERATING_UNITS HOU
                                      WHERE HCAR.CUST_ACCOUNT_ROLE_ID = p_key_value7  -- CUST_ACCOUNT_ROLE_ID pk1
                                      and (HP.PARTY_TYPE='PERSON' and HRP.RELATIONSHIP_CODE = 'CONTACT' and HRP.OBJECT_ID = HP.PARTY_ID and HRP.SUBJECT_ID = HCA.PARTY_ID)
                                      or (HP.PARTY_TYPE='PARTY_RELATIONSHIP' and HRP.RELATIONSHIP_CODE = 'CONTACT_OF' and HRP.PARTY_ID = HP.PARTY_ID and HRP.OBJECT_ID = HCA.PARTY_ID)
                                      and HCA.CUST_ACCOUNT_ID = HCAS.CUST_ACCOUNT_ID
                                      and HCAR.CUST_ACCOUNT_ID = HCA.CUST_ACCOUNT_ID
                                      and HZP.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
                                      and HCAS.ORG_ID = HOU.ORGANIZATION_ID
        and hou.set_of_books_id = 3001
                                     -- and HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                            );  */
      -- Commented by Aditya R on 11-Jun-25 for CRQ CHG0243331

      /*
      ELSIF P_TABLE_NAME = 'HZ_PARTY_SITE_USES'
      THEN
         -- p_key_value7 = PARTY_SITE_ID
      SELECT COUNT(1)
      INTO l_eligible_count
      FROM DUAL
      WHERE  EXISTS (select 1 from
                                   HZ_PARTY_SITES HZP,
                                   HZ_CUST_ACCT_SITES_ALL HCAS,
                                   APPS.HR_OPERATING_UNITS HOU
                               WHERE HZP.PARTY_SITE_ID = TO_NUMBER(p_key_value7)  -- PARTY_SITE_ID pk1
                              and HZP.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
                          -- AND HPSU.PARTY_SITE_ID = HZP.PARTY_SITE_ID
                              and HCAS.ORG_ID = HOU.ORGANIZATION_ID
      and hou.set_of_books_id = 3001
                          --    and HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                   );

      ELSIF P_TABLE_NAME = 'HZ_PARTY_SITES'
      THEN
           -- p_key_value7 = PARTY_ID
           -- p_key_value8 = PARTY_SITE_ID
      SELECT COUNT(1)
      INTO l_eligible_count
      FROM DUAL
      WHERE  (EXISTS (select 1 from  HZ_PARTIES HP,
                                     HZ_CUST_ACCOUNTS HCA,
                                     HZ_CUST_ACCT_SITES_ALL HCAS,
                                     APPS.HR_OPERATING_UNITS HOU
                       WHERE HP.PARTY_ID = TO_NUMBER(p_key_value7)  -- PARTY_ID is pk1
                       and HCAS.PARTY_SITE_ID   = TO_NUMBER(p_key_value8)   -- PARTY_SITE_ID is pk2
                    --and HP.PARTY_ID = HZP.PARTY_ID
                     and HP.PARTY_ID = HCA.PARTY_ID
                     and HCA.CUST_ACCOUNT_ID = HCAS.CUST_ACCOUNT_ID
                -- and HZP.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
                  and HCAS.ORG_ID = HOU.ORGANIZATION_ID
   and hou.set_of_books_id = 3001
                  --and HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                           )
                    or exists
                     (select 1
                    from
                       HZ_CUST_ACCT_SITES_ALL HCAS,
                       APPS.HR_OPERATING_UNITS HOU
                    where HCAS.PARTY_SITE_ID   = TO_NUMBER(p_key_value8)    -- PARTY_SITE_ID is pk2
                  -- and HZP.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
                    and HCAS.ORG_ID = HOU.ORGANIZATION_ID
  and hou.set_of_books_id = 3001
                   -- and HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                       )
                 );

    ELSIF P_TABLE_NAME = 'HZ_ROLE_RESPONSIBILITY'
    THEN
         -- p_key_value7 = RESPONSIBILITY_ID
      SELECT COUNT(1)
      INTO l_eligible_count
      FROM DUAL
      WHERE  EXISTS (select 1 from HZ_ROLE_RESPONSIBILITY HRR,

                                   HZ_CUST_ACCT_SITES_ALL HCAS,
                                   HZ_CUST_ACCOUNT_ROLES HCAR,
                                   APPS.HR_OPERATING_UNITS HOU
                             WHERE HRR.RESPONSIBILITY_ID = TO_NUMBER(p_key_value7)  -- RESPONSIBILITY_ID pk1
                              and HCAR.CUST_ACCT_SITE_ID = HCAS.CUST_ACCT_SITE_ID
                              AND HRR.CUST_ACCOUNT_ROLE_ID = HCAR.CUST_ACCOUNT_ROLE_ID
                              and HCAS.ORG_ID = HOU.ORGANIZATION_ID
      and hou.set_of_books_id = 3001
                            --  and HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                   );

      ELSIF P_TABLE_NAME = 'HZ_CONTACT_POINTS'
      THEN
            -- p_key_value7 = contact_point_id
                  SELECT COUNT(1)
                  INTO l_eligible_count
                  FROM DUAL
                  WHERE  EXISTS (select 1 from HZ_CONTACT_POINTS HCP,
                                           HZ_PARTIES HP,
                             HZ_CUST_ACCOUNTS HCA,
                             HZ_RELATIONSHIPS HRP,
                             HZ_CUST_ACCT_SITES_ALL HCAS,
                             HZ_PARTY_SITES HZP,
                             APPS.HR_OPERATING_UNITS HOU
                           WHERE HCP.CONTACT_POINT_ID = p_key_value7  -- CONTACT_POINT_ID pk1
                           and (HP.PARTY_TYPE='PERSON' and HRP.RELATIONSHIP_CODE = 'CONTACT' and HRP.OBJECT_ID = HP.PARTY_ID and HRP.SUBJECT_ID = HCA.PARTY_ID)
                      or (HP.PARTY_TYPE='PARTY_RELATIONSHIP' and HRP.RELATIONSHIP_CODE = 'CONTACT_OF' and HRP.PARTY_ID = HP.PARTY_ID and HRP.OBJECT_ID = HCA.PARTY_ID)
                      and HCA.CUST_ACCOUNT_ID = HCAS.CUST_ACCOUNT_ID
                      AND HCP.OWNER_TABLE_ID = HP.PARTY_ID
                      and HZP.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
                      and HCAS.ORG_ID = HOU.ORGANIZATION_ID
    and hou.set_of_books_id = 3001
                     -- and HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                              );

      ELSIF P_TABLE_NAME = 'HZ_CUSTOMER_PROFILES'
      THEN
          -- p_key_value7 = CUST_ACCOUNT_PROFILE_ID
              SELECT COUNT(1)
              INTO l_eligible_count
              FROM DUAL
              WHERE  EXISTS (select 1 from HZ_CUSTOMER_PROFILES HCPR,
                                       HZ_PARTIES HP,
                         HZ_CUST_ACCOUNTS HCA,
                         HZ_CUST_ACCT_SITES_ALL HCAS,
                         HZ_PARTY_SITES HZP,
                         HZ_CUST_SITE_USES_ALL HCSU,
                         APPS.HR_OPERATING_UNITS HOU
                       WHERE HCPR.CUST_ACCOUNT_PROFILE_ID = TO_NUMBER(p_key_value7)  -- CUST_ACCOUNT_PROFILE_ID pk1
                       and HP.PARTY_ID = HCA.PARTY_ID
                  and HP.PARTY_ID = HZP.PARTY_ID
                  and HCA.CUST_ACCOUNT_ID = HCAS.CUST_ACCOUNT_ID
                  and HCA.CUST_ACCOUNT_ID = HCPR.CUST_ACCOUNT_ID
                  and HZP.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
                  and HCSU.CUST_ACCT_SITE_ID = HCAS.CUST_ACCT_SITE_ID
                  and HCAS.ORG_ID = HOU.ORGANIZATION_ID
   and hou.set_of_books_id = 3001
                   -- and HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                         );  */
      -- -- Commented by Aditya R on 11-Jun-25 for CRQ CHG0243331

      ELSIF P_TABLE_NAME = 'HZ_CUST_PROFILE_AMTS'
      THEN
         -- p_key_value7 = CUST_ACCOUNT_PROFILE_ID
         SELECT COUNT (1)
           INTO l_eligible_count
           FROM DUAL
          WHERE EXISTS
                   (SELECT 1
                      FROM HZ_CUSTOMER_PROFILES HCPR,
                           HZ_PARTIES HP,
                           HZ_CUST_ACCOUNTS HCA,
                           HZ_CUST_ACCT_SITES_ALL HCAS,
                           HZ_PARTY_SITES HZP,
                           HZ_CUST_SITE_USES_ALL HCSU,
                           APPS.HR_OPERATING_UNITS HOU
                     WHERE     HCPR.CUST_ACCOUNT_PROFILE_ID =
                                  TO_NUMBER (p_key_value7) -- CUST_ACCOUNT_PROFILE_ID pk1
                           --  and HCPA.CUST_ACCOUNT_PROFILE_ID = HCPR.CUST_ACCOUNT_PROFILE_ID
                           AND HP.PARTY_ID = HCA.PARTY_ID
                           AND HP.PARTY_ID = HZP.PARTY_ID
                           AND HCA.CUST_ACCOUNT_ID = HCAS.CUST_ACCOUNT_ID
                           AND HCA.CUST_ACCOUNT_ID = HCPR.CUST_ACCOUNT_ID
                           AND HZP.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
                           AND HCSU.CUST_ACCT_SITE_ID =
                                  HCAS.CUST_ACCT_SITE_ID
                           AND HCAS.ORG_ID = HOU.ORGANIZATION_ID
                           AND hou.set_of_books_id = 3001 --  and HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                                                         );
      /*
      ELSIF P_TABLE_NAME = 'HZ_RELATIONSHIPS'
      THEN
           -- p_key_value7 = RELATIONSHIP_ID

              SELECT COUNT(1)
              INTO l_eligible_count
              FROM DUAL
              WHERE  EXISTS (select 1 from HZ_RELATIONSHIPS HRP,
                         HZ_PARTIES HP,
                         HZ_CUST_ACCOUNTS HCA,
                         HZ_PARTY_SITES HZP,
                         HZ_CUST_ACCT_SITES_ALL HCAS,
                         APPS.HR_OPERATING_UNITS HOU
                       WHERE HRP.RELATIONSHIP_ID = p_key_value7  -- RELATIONSHIP_ID pk1
                  and (HP.PARTY_TYPE='PERSON' and HRP.RELATIONSHIP_CODE = 'CONTACT' and HRP.OBJECT_ID = HP.PARTY_ID and HRP.SUBJECT_ID = HCA.PARTY_ID)
                  or (HP.PARTY_TYPE='PARTY_RELATIONSHIP' and HRP.RELATIONSHIP_CODE = 'CONTACT_OF' and HRP.PARTY_ID = HP.PARTY_ID and HRP.OBJECT_ID = HCA.PARTY_ID)
                  and HCA.CUST_ACCOUNT_ID = HCAS.CUST_ACCOUNT_ID
                  and HZP.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
                  and HCAS.ORG_ID = HOU.ORGANIZATION_ID
   and hou.set_of_books_id = 3001
                  --  and HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                           ); */
      ---- Commented by Aditya R on 11-Jun-25 for CRQ CHG0243331

      ELSIF P_TABLE_NAME = 'RCV_TRANSACTIONS'
      THEN
         -- p_key_value7 = TRANSACTION_ID
         -- p_key_value8 = ORGANIZATION_ID

         l_eligible_count := is_ind_org (NULL, p_key_value8);
      ELSIF P_TABLE_NAME = 'RCV_SHIPMENT_HEADERS'
      THEN
         -- p_key_value7 = SHIPMENT_HEADER_ID
         -- p_key_value8 = SHIP_TO_ORG_ID

         l_eligible_count := is_ind_org (p_key_value8, NULL);
      ELSIF P_TABLE_NAME = 'RCV_SHIPMENT_LINES'
      THEN
         -- p_key_value7 = SHIPMENT_LINE_ID
         -- p_key_value8 = SHIPMENT_HEADER_ID
         SELECT COUNT (1)
           INTO l_eligible_count
           FROM DUAL
          WHERE EXISTS
                   (SELECT 1
                      FROM RCV_SHIPMENT_HEADERS
                     WHERE     SHIPMENT_HEADER_ID = p_key_value8
                           AND 1 = is_ind_org (SHIP_TO_ORG_ID, NULL));
      ELSIF P_TABLE_NAME = 'MTL_MATERIAL_TRANSACTIONS'
      THEN
         -- p_key_value7 = TRANSACTION_ID
         -- p_key_value8 = ORGANIZATION_ID
         l_eligible_count := is_ind_org (NULL, p_key_value8);
      ELSIF p_table_name = 'PO_SYSTEM_PARAMETERS_ALL' --Added by Aditya R on 12-Jun-25 CRQ CHG0243331
      THEN
         -- p_key_value7 = org_id
         l_eligible_count := is_ind_org (p_key_value7, NULL);
      ELSIF (p_table_name = 'GL_PERIOD_TYPES') --Added by Aditya R on 12-Jun-25 CRQ CHG0243331
      THEN
         -- p_key_value7 = PERIOD_TYPE_ID
         -- p_key_value8 = DESCRIPTION
         -- p_key_value9 = PERIOD_TYPE

         SELECT COUNT (1)
           INTO l_eligible_count
           FROM gl_periods
          WHERE     PERIOD_SET_NAME = 'Std Accounting'
                AND period_type = p_key_value9;
      ELSIF (p_table_name = 'GL_PERIODS') --Added by Aditya R on 12-Jun-25 CRQ CHG0243331
      THEN
         -- p_key_value7 = PERIOD_NAME
         -- p_key_value8 = PERIOD_SET_NAME
         IF p_key_value8 = 'Std Accounting'
         THEN
            l_eligible_count := 1;
         END IF;
      ELSIF P_TABLE_NAME IN ('RA_ACCOUNT_DEFAULT_SEGMENTS', --Added by Aditya R on 12-Jun-25 CRQ CHG0243331
                             'FND_FLEX_VALUES_TL',
                             'FND_FLEX_VALUES',
                             'AP_BANK_BRANCHES')
      THEN
         l_eligible_count := 1;
      ELSE
         l_eligible_count := 1;
      END IF;



      RETURN l_eligible_count;
   END is_backend_change_for_ind_org;



   -- Function is to check the p_prog_val is excluded CP or not
   FUNCTION get_cp_count (p_prog_val IN VARCHAR2, p_client_id IN VARCHAR2)    -- Changed by Aditya R for CHG0251511
      RETURN NUMBER
   IS
      ln_cp_count   NUMBER;
   BEGIN
      SELECT COUNT (1)
        INTO ln_cp_count
        FROM DUAL
       WHERE (p_client_id = 'INTERFACE' and p_prog_val like 'sqlplus%')         --- Added by Aditya R on 21-Aug-2025 (CHG0251511) for not capturing Interface Records
       OR    EXISTS
                (SELECT 1
                   FROM fnd_concurrent_programs fcp,
                        fnd_concurrent_queues fcq,
                        (SELECT SUBSTR (p_prog_val,
                                        1,
                                        (INSTR (p_prog_val, '@') - 1))
                                   AS program
                           FROM DUAL) cp_check
                  WHERE (   program = fcp.concurrent_program_name
                         OR program = fcq.CONCURRENT_QUEUE_NAME))
                         OR p_prog_val LIKE 'rwrun%';                           --- Added by Aditya R 20-Aug-2025 (CHG0251511)

      RETURN ln_cp_count;
   END get_cp_count;

   -- Function is to check whether its india org or not
   FUNCTION is_ind_org (p_operating_unit    IN NUMBER,
                        p_organization_id   IN NUMBER)
      RETURN NUMBER
   IS
      l_org_count   NUMBER;
   BEGIN
      ----Pass the ORG_id in p_operating_unit and Oraganization_id in p_organization_id
      SELECT COUNT (1)
        INTO l_org_count
        FROM DUAL
       WHERE (EXISTS
                 (SELECT 1
                    FROM apps.org_organization_definitions
                   WHERE     SET_OF_BOOKS_ID = 3001
                         AND (   OPERATING_UNIT = p_operating_unit
                              OR ORGANIZATION_ID = p_organization_id)));

      RETURN l_org_count;
   END is_ind_org;



   /******************************************************************************
      NAME:        xxcctt_gg_filter_condition_prc
      PURPOSE:

      REVISIONS:
      Ver        Date        Author               Description
      ---------  ----------  ---------------      ----------------------------------
      1.0        02-05-2025  WJ454(BSL)           Created this procedure
   1.1  17-04-2025  AL02R     Added the table and make india vaidation on SET_OF_BOOKS_ID
      1.2       11-06-2025  XW294                 Removed old new values and unused paramters.

      INPUT PARAMETERS:P_TABLE_NAME,P_KEY_VALUE1,P_KEY_VALUE2,P_KEY_VALUE3

      OUTPUT PARAMETERS:   p_count_val
                           p_err_msg
      INOUT PARAMETERS:

      ASSUMPTIONS:
      LIMITATIONS:
      NOTES:
   ******************************************************************************/
   PROCEDURE xxcctt_gg_filter_condition_prc (
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
      p_record_timestamp   IN     VARCHAR2 DEFAULT NULL,
      p_commit_timestamp   IN     VARCHAR2 DEFAULT NULL,
      p_count_val             OUT VARCHAR2,
      p_err_msg               OUT VARCHAR2)
   AS
      ln_cp_upd_ind             NUMBER := 0;
      ln_superuser_access_ind   NUMBER := 0;
      ln_count                  NUMBER := 0;
      -- ln_compare_old_new_values   NUMBER := 0;
      lc_key_value              XXC.xxc_goldengate_log.log_key_value%TYPE;
      --ln_ind_asset_ind                NUMBER := 0;
      -- lc_old_val                  VARCHAR2 (4000);
      -- lc_new_val                  VARCHAR2 (4000);
      l_status_message          VARCHAR2 (4000);
      l_parameter_mess          VARCHAR2 (1000);
      l_start_time              DATE;

      -- Procedure for logging data for debugging

      PROCEDURE xxcctt_insert_debug_log (p_log_object       VARCHAR2,
                                         p_log_key_value    VARCHAR2,
                                         p_qry_cnt          NUMBER --,p_old_val          VARCHAR2
                                                                  --,p_new_val          VARCHAR2
                                         ,
                                         p_status           VARCHAR2)
      AS
         PRAGMA AUTONOMOUS_TRANSACTION;
      BEGIN
         l_parameter_mess :=            -- Added by Aditya R on 9-Jun-2025 CRQ CHG0243331
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
            SELECT xxc.XXC_GG_LOG_SEQ.NEXTVAL,
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
                   --   lc_old_val,
                   --   lc_new_val,
                   p_status
              FROM DUAL
             WHERE     1 = 1
--                   AND NVL (apps.fnd_profile.VALUE ('XXC_INDIA_AUDIT_LOG'),
--                            'No') = 'Yes' /*Profile option based Debug Logging to be made available by adding and condition here*/
                                         ;

         COMMIT;
      EXCEPTION
         WHEN OTHERS
         THEN
            P_ERR_MSG :=
                  'Error while inserting into debug table XXC_GOLDENGATE_LOG'
               || SQLERRM;
      END;
   BEGIN
      -- Initialize variables.
      ln_count := 0;
      --ln_compare_old_new_values := 0;
      lc_key_value := NULL;
      --lc_new_val := NULL;
      -- lc_old_val := NULL;
      ln_cp_upd_ind := 0;
      ln_superuser_access_ind := 0;
      p_count_val := 0;
      l_start_time := SYSDATE;


      -- Concatenate the Parameters for logging.
      BEGIN
         SELECT    p_prog_val
                || NVL2 (p_client_id, '|' || p_client_id, '')
                || NVL2 (p_event_time, '|' || p_event_time, '')
                || NVL2 (p_collection_time, '|' || p_collection_time, '')
                || NVL2 (p_event, '|' || p_event, '')
                || NVL2 (p_key_value1, '|' || p_key_value1, '')
                || NVL2 (p_key_value2, '|' || p_key_value2, '')
                || NVL2 (p_key_value3, '|' || p_key_value3, '')
                || NVL2 (p_key_value4, '|' || p_key_value4, '')
                || NVL2 (p_key_value5, '|' || p_key_value5, '')
                || NVL2 (p_key_value6, '|' || p_key_value6, '')
                || NVL2 (p_key_value7, '|' || p_key_value7, '')
                || NVL2 (p_key_value8, '|' || p_key_value8, '')
                || NVL2 (p_key_value9, '|' || p_key_value9, '')
                || NVL2 (p_key_value10, '|' || p_key_value10, '')
                || NVL2 (p_key_value11, '|' || p_key_value11, '')
                || NVL2 (p_key_value12, '|' || p_key_value12, '')
                || NVL2 (p_record_timestamp, '|' || p_record_timestamp, '')
                || NVL2 (p_commit_timestamp, '|' || p_commit_timestamp, '')
           INTO lc_key_value
           FROM DUAL;
      EXCEPTION
         WHEN OTHERS
         THEN
            lc_key_value := NULL;
      END;

      -- Concatenating all the new values in to a single string.

      --        BEGIN
      --             lc_new_val := n1 || ','|| n2 || ',' || n3 || ',' || n4 || ',' || n5 || ',' || n6 || ',' || n7 || ','|| n8 || ',' || n9 || ',' || n10 || ',' || n11 || ',' || n12 || ','  || n13 || ','  || n14 || ','  || n15 || ','  || n16 || ','  || n17  || ',' || n18 || ','  || n19 || ','  || n20 || ','  || n21 || ','  || n22 || ','  || n23 || ','  || n24 || ','  || n25 || ','  || n26 || ','  || n27 || ','  || n28 || ','  || n29 || ','  || n30;
      --        EXCEPTION
      --            WHEN others THEN
      --             lc_new_val := SUBSTR(n1 || n2 || n3 || n4 || n5 || n6 || n7 || n8 || n9 || n10 || n11 || n12 || n13 || n14 || n15 || n16 || n17 || n18 || n19 || n20 || n21 || n22 || n23 || n24 || n25 || n26 || n27 || n28 || n29 || n30, 1, 4000);
      --        END;

      -- Concatenating all the old values in to a single string.
      --        BEGIN
      --             lc_old_val := o1 || ','|| o2 || ',' || o3 || ',' || o4 || ',' || o5 || ',' || o6 || ',' || o7 || ','|| o8 || ',' || o9 || ',' || o10 || ',' || o11 || ',' || o12 || ','  || o13 || ','  || o14 || ','  || o15 || ','  || o16 || ','  || o17  || ',' || o18 || ','  || o19 || ','  || o20 || ','  || o21 || ','  || o22 || ','  || o23 || ','  || o24 || ','  || o25 || ','  || o26 || ','  || o27 || ','  || o28 || ','  || o29 || ','  || o30;
      --        EXCEPTION
      --            WHEN others THEN
      --             lc_old_val := SUBSTR(o1 || o2 || o3 || o4 || o5 || o6 || o7 || o8 || o9 || o10 || o11 || o12 || o13 || o14 || o15 || o16 || o17 || o18 || o19 || o20 || o21 || o22 || o23 || o24 || o25 || o26 || o27 || o28 || o29 || o30, 1, 4000);
      --        END;

      -- Comparing all the old values with all the new values
      -- to check change is occured for inscope column or not

      ---Check if program is concurrent or not
      -- Changed by Aditya R on 20-Aug-2025
      ln_count := get_cp_count (p_prog_val,p_client_id); -- Added by Aditya R on 11-Jun-2025 for CRQ CHG0243331

      IF ln_count = 0
      THEN
         IF p_event IN ('DELETE', 'INSERT')
         THEN             -- If the record is deleted or inserted from backend
            -- Added by Aditya R on 22-Aug-2025 for CHG0251511
            IF p_client_id IS NULL AND (p_prog_val NOT LIKE 'frmweb%' AND p_prog_val != 'JDBC Thin Client')
            THEN
               ln_count :=
                  is_backend_change_for_ind_org (p_table_name,
                                                 p_key_value7,
                                                 p_key_value8,
                                                 p_key_value9,
                                                 p_key_value10,
                                                 p_key_value11,
                                                 p_key_value12);

               IF ln_count > 0
               THEN
                  l_status_message :=
                     'Record is deleted/inserted from backend , so capturing it in AVDF';
               ELSE
                  l_status_message :=
                     'Record is deleted/inserted from backend but dat is not related to India , so not capturing it in AVDF';
               END IF;
            ELSE
               l_status_message :=
                  'Record is deleted/inserted from fronend and its a draft';
            END IF;
         --         ELSIF LENGTH (lc_new_val) > 29
         --         THEN
         --            IF (lc_old_val != lc_new_val)
         --            THEN
         --               --ln_count := 1;
         --               ln_compare_old_new_values := 1;
         --            END IF;
         --
         --            IF ln_compare_old_new_values = 1 -- If old and new values are not matched then process the below tables
         --            THEN
         ELSE
            -- Process Individual tables
            --            IF     p_table_name IN ('PO_HEADERS_ALL',
            --                                    'PO_LINES_ALL',
            --                                    'PO_LINE_LOCATIONS_ALL',
            --                                    'PO_DISTRIBUTIONS_ALL',
            --                                    'PO_RELEASES_ALL',
            --                                    'OE_ORDER_HEADERS_ALL',
            --                                    'OE_ORDER_LINES_ALL')
            --               AND p_client_id IS NULL
            --            THEN
            --               --p_key_value1 = ORGANIZATION_ID OR ORG_ID
            --               ln_count := is_ind_org (p_key_value1, NULL);
            IF p_table_name IN ('PO_HEADERS_ALL',
                                'PO_LINES_ALL',
                                'PO_LINE_LOCATIONS_ALL',
                                'PO_DISTRIBUTIONS_ALL',
                                'PO_RELEASES_ALL',
                                'OE_ORDER_HEADERS_ALL',
                                'OE_ORDER_LINES_ALL')
            THEN
               --Added by Aditya R on 22-Aug-2025 for CHG0251511
               IF p_client_id IS NULL AND (p_prog_val NOT LIKE 'frmweb%' AND p_prog_val != 'JDBC Thin Client')
               THEN
                  -- Backend update: calling function to check Indian org
                  ln_count := is_ind_org (p_key_value1, NULL);

                  IF ln_count = 1
                  THEN
                     l_status_message :=
                        'Record is updated from backend and is India specific';
                  ELSE
                     l_status_message :=
                        'Record is updated from backend but not India specific';
                  END IF;
               ELSE
                  -- Frontend or concurrent program
                  --ln_count := 0;                  --         No change                -- changed by Aditya R on 20-Aug-2025 for CHG0251511
                  l_status_message := 'Record is updated from frontend.';
               END IF;
            --            ELSIF (    p_table_name = 'WSH_DELIVERY_DETAILS'
            --                   AND p_client_id IS NULL)
            --            THEN
            --               -- p_key_value7 = ORGANIZATION_ID
            --               ln_count := is_ind_org (NULL, p_key_value7);
            --            --  ELSIF  p_table_name = 'GL_BALANCES' AND p_client_id IS NULL     -- Commented by Aditya R 10-Jun-25 for CRQ CHG0243331
            --            --  THEN
            --            --    ln_count :=1;
            -- Changed by Aditya R on 22-Aug-2025 added table in above condition
            ELSIF p_table_name = 'WSH_DELIVERY_DETAILS'
            THEN
               IF p_client_id IS NULL AND (p_prog_val NOT LIKE 'frmweb%' AND p_prog_val != 'JDBC Thin Client')  -- Changed by Aditya R for CHG0251511
               THEN
                  -- Backend update: check if it's India-specific
                  ln_count := is_ind_org (NULL, p_key_value7);

                  IF ln_count = 1
                  THEN
                     l_status_message := 'Record is updated from backend and is india specific';
                  ELSE
                     l_status_message :=
                        'Record is updated from backend but not India specific';
                  END IF;
               ELSE
                  -- Frontend Update

                  l_status_message := 'Record is updated from frontend';
               END IF;
            ELSIF p_table_name = 'MTL_SECONDARY_INVENTORIES'
            THEN
               -- p_key_value1 = ORGANIZATION_ID
               ln_count := is_ind_org (NULL, p_key_value1);
            ELSIF p_table_name = 'AR_SYSTEM_PARAMETERS_ALL'
            THEN
               -- p_key_value1 = SET_OF_BOOKS_ID
               IF p_key_value1 IN ('3001')
               THEN
                  ln_count := 1;
               END IF;
            ELSIF p_table_name = 'AR_RECEIVABLES_TRX_ALL'
            THEN
               -- p_key_value1 = org_id
               ln_count := is_ind_org (p_key_value1, NULL);
            ELSIF p_table_name = 'AP_SYSTEM_PARAMETERS_ALL'
            THEN
               -- p_key_value1 = org_id
               ln_count := is_ind_org (p_key_value1, NULL);
            ELSIF p_table_name = 'ORG_ACCT_PERIODS'
            THEN
               -- p_key_value1 = ORGANIZATION_ID

               ln_count := is_ind_org (NULL, p_key_value1);
            ELSIF p_table_name = 'MTL_PARAMETERS'
            THEN
               -- p_key_value1 = ORGANIZATION_ID

               ln_count := is_ind_org (NULL, p_key_value1);
            ELSIF p_table_name = 'GL_PERIOD_STATUSES
'
            THEN
               -- p_key_value1 = SET_OF_BOOKS_ID

               IF p_key_value1 IN ('3001')
               THEN
                  ln_count := 1;
               END IF;
            ELSIF p_table_name = 'GL_LEDGERS
'
            THEN
               -- p_key_value1 = LEDGER_ID

               IF p_key_value1 IN ('3001')
               THEN
                  ln_count := 1;
               END IF;
            ELSIF p_table_name = 'GL_DAILY_RATES'
            THEN
               -- P_KEY_VALUE1 = TO_CURRENCY
               -- P_KEY_VALUE2 = CONVERSION_TYPE
               IF P_KEY_VALUE1 = 'INR' AND P_KEY_VALUE2 = 'Corporate'
               THEN
                  ln_count := 1;
               ELSE
                  ln_count := 0;
                  l_status_message :=
                     (' GL_DAILY RATE IS NOT UPDATED FOR INR CURRENCY ');
               END IF;
            ---1.1 START
            ELSIF p_table_name = 'MTL_INTERORG_PARAMETERS'
            THEN
               ln_count := 1;
            ELSIF (p_table_name = 'IBY_EXTERNAL_PAYEES_ALL')
            THEN
               -- p_key_value1 = EXT_PAYEE_ID
               -- p_key_value2 = PAYEE_PARTY_ID

               -- Check whether the payments are related to India Operating Units in apps.iby_payments_alltable.

               -- Changed the is_ind_org function as per requirment.by Aditya R on 12-Jun-2025 CRQ CHG0243331

               /*SELECT COUNT (1)
                 INTO l_eligible_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM APPS.iby_payments_all
                           WHERE     payee_party_id = TO_NUMBER (p_key_value8)
                                 AND 1 = (is_ind_org (org_id, NULL)));*/
               SELECT COUNT (1)
                 INTO ln_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM APPS.iby_payments_all IBA,
                                 ORG_ORGANIZATION_DEFINITIONS OOD
                           WHERE     OOD.OPERATING_UNIT = IBA.ORG_ID
                                 AND SET_OF_BOOKS_ID IN (3001)
                                 AND payee_party_id =
                                        TO_NUMBER (p_key_value2));
            ELSIF (p_table_name = 'OE_TRANSACTION_TYPES_ALL')
            THEN
               --p_key_value1= ORG_ID

               ln_count := is_ind_org (p_key_value1, NULL);
            --1.1 END

            ELSIF (p_table_name = 'RA_CUSTOMER_TRX_ALL')
            THEN
               -- p_key_value1 = CUSTOMER_TRX_ID
               -- p_key_value2 = SET_OF_BOOKS_ID

               IF p_key_value2 IN ('3001')
               THEN
                  SELECT COUNT (1)
                    INTO ln_count
                    FROM DUAL
                   WHERE EXISTS
                            (SELECT 1
                               FROM APPS.RA_CUST_TRX_LINE_GL_DIST_ALL RCTL,
                                    APPS.XLA_EVENTS XE,
                                    APPS.XLA_AE_HEADERS XAH,
                                    APPS.XLA_AE_LINES XAL,
                                    apps.xla_Distribution_links xdl
                              WHERE     RCTL.CUSTOMER_TRX_ID =
                                           TO_NUMBER (P_KEY_VALUE1)
                                    AND RCTL.EVENT_ID = XE.EVENT_ID
                                    AND XE.ENTITY_ID = XAH.ENTITY_ID
                                    AND XE.EVENT_STATUS_CODE = 'P'
                                    AND XE.PROCESS_STATUS_CODE = 'P'
                                    AND XDL.SOURCE_DISTRIBUTION_ID_NUM_1 =
                                           RCTL.CUST_TRX_LINE_GL_DIST_ID
                                    AND XDL.EVENT_ID = XE.EVENT_ID
                                    AND XDL.AE_HEADER_ID = XAH.AE_HEADER_ID
                                    AND XDL.EVENT_ID = XAH.EVENT_ID
                                    AND XDL.AE_HEADER_ID = XAL.AE_HEADER_ID
                                    AND XDL.AE_LINE_NUM = XAL.AE_LINE_NUM
                                    AND SOURCE_DISTRIBUTION_TYPE =
                                           'RA_CUST_TRX_LINE_GL_DIST_ALL'
                                    AND XAH.AE_HEADER_ID = XAL.AE_HEADER_ID
                                    AND 1 = is_ind_org (RCTL.ORG_ID, NULL)
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
               END IF;
            -- 1.1 changes start

            ELSIF (p_table_name = 'QP_LIST_HEADERS_B')
            THEN
                 --p_key_value1=list_header_id

                 --ln_count := 1;

                 --Added by Aditya R to check wherther grant_type,grant_Id is india specific on 13-Jun-2025 for CRQ CHG0243331

                 SELECT CASE MAX (B.GRANTEE_TYPE)
                           WHEN 'OU'
                           THEN
                              NVL (
                                 (SELECT 1
                                    FROM DUAL
                                   WHERE (SELECT C.GRANTEE_ID
                                            FROM QP_GRANTS C
                                           WHERE     C.INSTANCE_ID =
                                                        B.INSTANCE_ID
                                                 AND C.GRANTEE_TYPE = 'OU') IN (SELECT HOU.ORGANIZATION_ID
                                                                                  FROM HR_OPERATING_UNITS HOU
                                                                                 WHERE HOU.SET_OF_BOOKS_ID =
                                                                                          3001)),
                                 0)
                           WHEN 'GLOBAL'
                           THEN
                              1
                        END
                           AS RESULT
                   INTO ln_count
                   FROM APPS.QP_LIST_HEADERS_B A, APPS.QP_GRANTS B
                  WHERE     A.LIST_HEADER_ID = B.INSTANCE_ID
                        AND A.LIST_HEADER_ID = P_KEY_VALUE1
               GROUP BY B.INSTANCE_ID;
            ELSIF (p_table_name = 'QP_LIST_LINES')
            THEN
                 --p_key_value1=list_header_id

                 --ln_count := 1;

                 --Added by Aditya R to check wherther grant_type,grant_Id is india specific on 13-Jun-2025 for CRQ CHG0243331

                 SELECT CASE MAX (B.GRANTEE_TYPE)
                           WHEN 'OU'
                           THEN
                              NVL (
                                 (SELECT 1
                                    FROM DUAL
                                   WHERE (SELECT C.GRANTEE_ID
                                            FROM QP_GRANTS C
                                           WHERE     C.INSTANCE_ID =
                                                        B.INSTANCE_ID
                                                 AND C.GRANTEE_TYPE = 'OU') IN (SELECT HOU.ORGANIZATION_ID
                                                                                  FROM HR_OPERATING_UNITS HOU
                                                                                 WHERE HOU.SET_OF_BOOKS_ID =
                                                                                          3001)),
                                 0)
                           WHEN 'GLOBAL'
                           THEN
                              1
                        END
                           AS RESULT
                   INTO ln_count
                   FROM APPS.QP_LIST_HEADERS_B A, APPS.QP_GRANTS B
                  WHERE     A.LIST_HEADER_ID = B.INSTANCE_ID
                        AND A.LIST_HEADER_ID = P_KEY_VALUE1
               GROUP BY B.INSTANCE_ID;
            ELSIF (p_table_name = 'RA_CUST_TRX_TYPES_ALL')
            THEN
               -- p_key_value1 = SET_OF_BOOKS_ID
               IF p_key_value2 IN ('3001')
               THEN
                  ln_count := 1;
               END IF;
            ELSIF (p_table_name = 'RCV_PARAMETERS')
            THEN
               -- p_key_value1 = ORGANIZATION_ID

               ln_count := is_ind_org (NULL, p_key_value1);
            --1.1 changes end
            ELSIF (p_table_name = 'RA_CUSTOMER_TRX_LINES_ALL')
            THEN
               -- p_key_value1 = CUSTOMER_TRX_LINE_ID
               -- p_key_value2 = SET_OF_BOOKS_ID

               IF p_key_value2 IN ('3001')
               THEN
                  SELECT COUNT (1)
                    INTO ln_count
                    FROM DUAL
                   WHERE EXISTS
                            (SELECT 1
                               FROM APPS.RA_CUST_TRX_LINE_GL_DIST_ALL RCTL,
                                    RA_CUSTOMER_TRX_ALL RCT,
                                    APPS.XLA_DISTRIBUTION_LINKS XDL,
                                    APPS.XLA_EVENTS XE,
                                    APPS.XLA_AE_HEADERS XAH,
                                    APPS.XLA_AE_LINES XAL
                              -- APPS.HR_OPERATING_UNITS HOU
                              WHERE     RCTL.CUSTOMER_TRX_LINE_ID =
                                           TO_NUMBER (p_key_value1)
                                    AND RCTL.EVENT_ID = XE.EVENT_ID
                                    AND XE.ENTITY_ID = XAH.ENTITY_ID
                                    AND XE.EVENT_STATUS_CODE = 'P'
                                    AND XE.PROCESS_STATUS_CODE = 'P'
                                    AND XAH.AE_HEADER_ID = XAL.AE_HEADER_ID
                                    AND XAH.AE_HEADER_ID = XDL.AE_HEADER_ID
                                    AND XDL.AE_LINE_NUM = XDL.AE_LINE_NUM
                                    AND XDL.SOURCE_DISTRIBUTION_TYPE =
                                           'RA_CUST_TRX_LINE_GL_DIST_ALL'
                                    AND XDL.SOURCE_DISTRIBUTION_ID_NUM_1 =
                                           RCTL.CUST_TRX_LINE_GL_DIST_ID
                                    AND 1 = is_ind_org (RCT.ORG_ID, NULL)
                                    -- AND HOU.NAME IN ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                                    AND RCTL.CUSTOMER_TRX_ID =
                                           RCT.CUSTOMER_TRX_ID
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
                                              'YYYY-MM-DD HH24:MI:SS') --      and rctla.customer_trx_id = RCT.CUSTOMER_TRX_ID
                                                                      --      AND RCTL.CUSTOMER_TRX_LINE_ID = RCTLA.CUSTOMER_TRX_LINE_ID
                         );
               END IF;
            ELSIF (p_table_name = 'RA_CUST_TRX_LINE_GL_DIST_ALL')
            THEN
               -- p_key_value1 = CUST_TRX_LINE_GL_DIST_ID
               -- p_key_value2 = SET_OF_BOOKS_ID

               IF p_key_value2 IN ('3001')
               THEN
                  SELECT COUNT (1)
                    INTO ln_count
                    FROM DUAL
                   WHERE EXISTS
                            (SELECT 1
                               FROM APPS.RA_CUST_TRX_LINE_GL_DIST_ALL RCTL,
                                    APPS.XLA_EVENTS XE,
                                    APPS.XLA_AE_HEADERS XAH,
                                    APPS.XLA_DISTRIBUTION_LINKS XDL,
                                    APPS.XLA_AE_LINES XAL
                              -- APPS.HR_OPERATING_UNITS HOU
                              WHERE     XDL.SOURCE_DISTRIBUTION_ID_NUM_1 =
                                           TO_NUMBER (p_key_value1)
                                    AND XE.EVENT_ID = RCTL.EVENT_ID
                                    -- AND RCTL.EVENT_ID = XE.EVENT_ID
                                    AND XE.ENTITY_ID = XAH.ENTITY_ID
                                    AND XE.EVENT_STATUS_CODE = 'P'
                                    AND XE.PROCESS_STATUS_CODE = 'P'
                                    AND XAH.AE_HEADER_ID = XAL.AE_HEADER_ID
                                    AND XAH.AE_HEADER_ID = XDL.AE_HEADER_ID
                                    AND XDL.AE_LINE_NUM = XDL.AE_LINE_NUM
                                    AND XDL.SOURCE_DISTRIBUTION_TYPE =
                                           'RA_CUST_TRX_LINE_GL_DIST_ALL'
                                    --       AND XDL.SOURCE_DISTRIBUTION_ID_NUM_1 = RCTL.CUST_TRX_LINE_GL_DIST_ID
                                    AND 1 = is_ind_org (RCTL.ORG_ID, NULL)
                                    -- AND HOU.NAME IN ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
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
               END IF;
            ELSIF (P_TABLE_NAME = 'AR_PAYMENT_SCHEDULES_ALL')
            THEN
               -- p_key_value1 = PAYMENT_SCHEDULE_ID
               -- p_key_value2 = CUSTOMER_TRX_ID
               -- p_key_value3 = ORG_ID

               IF 1 = is_ind_org (p_key_value3, NULL)
               THEN
                  SELECT COUNT (1)
                    INTO ln_count
                    FROM DUAL
                   WHERE (   EXISTS
                                (SELECT 1
                                   FROM APPS.AR_RECEIVABLE_APPLICATIONS_ALL ARA,
                                        APPS.AR_DISTRIBUTIONS_ALL ADA,
                                        apps.XLA_EVENTS XE,
                                        APPS.XLA_AE_HEADERS XAH,
                                        APPS.XLA_AE_LINES XAL,
                                        APPS.XLA_DISTRIBUTION_LINKS XDL
                                  --HR_OPERATING_UNITS HOU
                                  WHERE     ARA.PAYMENT_SCHEDULE_ID =
                                               TO_NUMBER (p_key_value1) --PAYMENT_SCHEDULE_ID is pk1
                                        AND ARA.RECEIVABLE_APPLICATION_ID =
                                               ADA.SOURCE_ID
                                        AND ADA.SOURCE_TABLE = 'RA'
                                        AND ARA.EVENT_ID = XE.EVENT_ID
                                        AND XE.ENTITY_ID = XAH.ENTITY_ID
                                        AND XE.EVENT_STATUS_CODE = 'P'
                                        AND XE.PROCESS_STATUS_CODE = 'P'
                                        AND xdl.SOURCE_DISTRIBUTION_ID_NUM_1 =
                                               ada.line_id
                                        AND xdl.event_id = xe.event_id
                                        AND xdl.ae_header_id =
                                               xah.ae_header_id
                                        AND xdl.event_id = xah.event_id
                                        AND xdl.ae_header_id =
                                               xal.ae_header_id
                                        AND XDL.AE_LINE_NUM = XAL.AE_LINE_NUM
                                        AND 1 = is_ind_org (ARA.ORG_ID, NULL)
                                        --  AND HOU.NAME IN ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                                        AND SOURCE_DISTRIBUTION_TYPE =
                                               'AR_DISTRIBUTIONS_ALL'
                                        AND XAH.AE_HEADER_ID =
                                               XAL.AE_HEADER_ID
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
                                                  'YYYY-MM-DD HH24:MI:SS') --  AND APSA.PAYMENT_SCHEDULE_ID = ARA.PAYMENT_SCHEDULE_ID
                                                                          )
                          OR EXISTS
                                (SELECT 1
                                   FROM APPS.RA_CUST_TRX_LINE_GL_DIST_ALL RCTL,
                                        apps.XLA_EVENTS XE,
                                        APPS.XLA_AE_HEADERS XAH,
                                        APPS.XLA_AE_LINES XAL,
                                        APPS.XLA_DISTRIBUTION_LINKS XDL
                                  --  APPS.HR_OPERATING_UNITS HOU
                                  WHERE     RCTL.CUSTOMER_TRX_ID =
                                               TO_NUMBER (p_key_value2) -- CUSTOMER_TRX_ID is pk2
                                        AND RCTL.EVENT_ID = XE.EVENT_ID
                                        --    AND RCTL.CUSTOMER_TRX_ID = APSA.CUSTOMER_TRX_ID
                                        AND XE.ENTITY_ID = XAH.ENTITY_ID
                                        AND XE.EVENT_STATUS_CODE = 'P'
                                        AND XE.PROCESS_STATUS_CODE = 'P'
                                        AND xdl.SOURCE_DISTRIBUTION_ID_NUM_1 =
                                               RCTL.CUST_TRX_LINE_GL_DIST_ID
                                        AND xdl.event_id = xe.event_id
                                        AND xdl.ae_header_id =
                                               xah.ae_header_id
                                        AND xdl.event_id = xah.event_id
                                        AND xdl.ae_header_id =
                                               xal.ae_header_id
                                        AND XDL.AE_LINE_NUM = XAL.AE_LINE_NUM
                                        AND 1 =
                                               is_ind_org (RCTL.ORG_ID, NULL)
                                        --    AND HOU.NAME IN ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                                        AND SOURCE_DISTRIBUTION_TYPE =
                                               'RA_CUST_TRX_LINE_GL_DIST_ALL'
                                        AND XAH.AE_HEADER_ID =
                                               XAL.AE_HEADER_ID
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
               END IF;
            ELSIF P_TABLE_NAME = 'MTL_SYSTEM_ITEMS_B'
            THEN
               -- p_key_value1 = INVENTORY_ITEM_ID
               -- p_key_value2 = ORGANIZATION_ID

               SELECT COUNT (1)
                 INTO ln_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM MTL_SYSTEM_ITEMS_B MSIB
                           WHERE     MSIB.INVENTORY_ITEM_ID = P_KEY_VALUE1 -- INVENTORY_ITEM_ID is pk1
                                 AND MSIB.ORGANIZATION_ID = P_KEY_VALUE2 -- ORGANIZATION_ID is pk2
                                 AND 1 = is_ind_org (NULL, P_KEY_VALUE2));
            ELSIF P_TABLE_NAME = 'AR_DISTRIBUTIONS_ALL'
            THEN
               -- p_key_value1 = LINE_ID
               -- p_key_value2 = ORG_ID
               IF 1 = is_ind_org (p_key_value2, NULL)
               THEN
                  SELECT COUNT (1)
                    INTO ln_count
                    FROM DUAL
                   WHERE EXISTS
                            (SELECT 1
                               FROM APPS.AR_DISTRIBUTIONS_ALL ADDA,
                                    APPS.XLA_EVENTS XE,
                                    APPS.XLA_AE_HEADERS XAH,
                                    APPS.XLA_DISTRIBUTION_LINKS XDL,
                                    APPS.XLA_AE_LINES XAL
                              WHERE     ADDA.LINE_ID =
                                           TO_NUMBER (p_key_value1) --LINE_ID is PK1
                                    AND XDL.SOURCE_DISTRIBUTION_ID_NUM_1 =
                                           ADDA.LINE_ID
                                    AND XDL.SOURCE_DISTRIBUTION_TYPE =
                                           'AR_DISTRIBUTIONS_ALL'
                                    AND XAH.AE_HEADER_ID = XDL.AE_HEADER_ID
                                    AND XDL.AE_LINE_NUM = XDL.AE_LINE_NUM
                                    AND XE.ENTITY_ID = XAH.ENTITY_ID
                                    AND 1 = is_ind_org (ADDA.ORG_ID, NULL)
                                    AND XE.EVENT_STATUS_CODE = 'P'
                                    AND XE.PROCESS_STATUS_CODE = 'P'
                                    AND XAH.AE_HEADER_ID = XAL.AE_HEADER_ID
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
               END IF;
            ELSIF P_TABLE_NAME = 'XLA_DISTRIBUTION_LINKS'
            THEN
               -- p_key_value1 = AE_HEADER_ID
               -- p_key_value2 = AE_LINE_NUM
               SELECT COUNT (1)
                 INTO ln_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM APPS.XLA_AE_HEADERS XAH,
                                 APPS.XLA_AE_LINES XAL
                           WHERE     XAH.AE_HEADER_ID = XAL.AE_HEADER_ID
                                 AND XAH.AE_HEADER_ID = P_KEY_VALUE1 --AE_HEADER_ID
                                 AND XAL.AE_LINE_NUM = P_KEY_VALUE2 --AE_LINE_NUM
                                 AND XAH.GL_TRANSFER_STATUS_CODE = 'Y'
                                 AND XAH.ACCOUNTING_ENTRY_STATUS_CODE = 'F'
                                 AND XAH.LEDGER_ID = 3001
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
            ELSIF P_TABLE_NAME = 'AR_REVENUE_ADJUSTMENTS_ALL'
            THEN
               -- p_key_value1 = REVENUE_ADJUSTMENT_ID
               -- p_key_value2 = ORG_ID

               IF 1 = is_ind_org (p_key_value2, NULL)
               THEN
                  SELECT COUNT (1)
                    INTO ln_count
                    FROM DUAL
                   WHERE EXISTS
                            (SELECT 1
                               FROM AR_REVENUE_ADJUSTMENTS_ALL ARAA,
                                    apps.XLA_EVENTS XE,
                                    APPS.XLA_AE_HEADERS XAH,
                                    APPS.XLA_AE_LINES XAL,
                                    APPS.XLA_DISTRIBUTION_LINKS XDL,
                                    RA_CUSTOMER_TRX_LINES_ALL RCTL,
                                    APPS.RA_CUST_TRX_LINE_GL_DIST_ALL RAGL
                              WHERE     ARAA.REVENUE_ADJUSTMENT_ID =
                                           TO_NUMBER (p_key_value1) -- REVENUE_ADJUSTMENT_ID is pk1
                                    AND RAGL.EVENT_ID = XE.EVENT_ID
                                    AND XE.ENTITY_ID = XAH.ENTITY_ID
                                    AND XE.EVENT_STATUS_CODE = 'P'
                                    AND XE.PROCESS_STATUS_CODE = 'P'
                                    AND XAH.GL_TRANSFER_STATUS_CODE = 'Y'
                                    AND XAH.ACCOUNTING_ENTRY_STATUS_CODE =
                                           'F'
                                    AND XAH.AE_HEADER_ID = XAL.AE_HEADER_ID
                                    AND xdl.SOURCE_DISTRIBUTION_ID_NUM_1 =
                                           RAGL.CUST_TRX_LINE_GL_DIST_ID
                                    AND xdl.event_id = xe.event_id
                                    AND xdl.ae_header_id = xah.ae_header_id
                                    AND xdl.event_id = xah.event_id
                                    AND XDL.AE_HEADER_ID = XAL.AE_HEADER_ID
                                    AND XDL.AE_LINE_NUM = XAL.AE_LINE_NUM
                                    AND XDL.SOURCE_DISTRIBUTION_TYPE =
                                           'RA_CUST_TRX_LINE_GL_DIST_ALL'
                                    AND 1 = is_ind_org (ARAA.ORG_ID, NULL)
                                    AND ARAA.CUSTOMER_TRX_ID =
                                           RCTL.CUSTOMER_TRX_ID
                                    AND RCTL.CUSTOMER_TRX_LINE_ID =
                                           RAGL.CUSTOMER_TRX_LINE_ID
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
               END IF;
            ELSIF P_TABLE_NAME = 'AR_DEFERRED_LINES_ALL'
            THEN
               -- p_key_value1 = CUSTOMER_TRX_LINE_ID
               -- p_key_value2 = ORG_ID

               IF 1 = is_ind_org (p_key_value2, NULL)
               THEN
                  SELECT COUNT (1)
                    INTO ln_count
                    FROM DUAL
                   WHERE EXISTS
                            (SELECT 1
                               FROM APPS.XLA_EVENTS XE,
                                    APPS.XLA_AE_HEADERS XAH,
                                    APPS.XLA_AE_LINES XAL,
                                    APPS.XLA_DISTRIBUTION_LINKS XDL,
                                    RA_CUSTOMER_TRX_LINES_ALL RCTL,
                                    APPS.RA_CUST_TRX_LINE_GL_DIST_ALL RAGL
                              --HR_OPERATING_UNITS HOU

                              WHERE     RCTL.CUSTOMER_TRX_LINE_ID =
                                           P_KEY_VALUE1 -- CUSTOMER_TRX_LINE_ID is pk1
                                    AND RAGL.EVENT_ID = XE.EVENT_ID
                                    AND XE.ENTITY_ID = XAH.ENTITY_ID
                                    AND XE.EVENT_STATUS_CODE = 'P'
                                    AND XE.PROCESS_STATUS_CODE = 'P'
                                    AND XAH.GL_TRANSFER_STATUS_CODE = 'Y'
                                    AND XAH.ACCOUNTING_ENTRY_STATUS_CODE =
                                           'F'
                                    AND XAH.AE_HEADER_ID = XAL.AE_HEADER_ID
                                    AND xdl.SOURCE_DISTRIBUTION_ID_NUM_1 =
                                           RAGL.CUST_TRX_LINE_GL_DIST_ID
                                    AND xdl.event_id = xe.event_id
                                    AND xdl.ae_header_id = xah.ae_header_id
                                    AND xdl.event_id = xah.event_id
                                    AND XDL.AE_HEADER_ID = XAL.AE_HEADER_ID
                                    AND XDL.AE_LINE_NUM = XAL.AE_LINE_NUM
                                    AND XDL.SOURCE_DISTRIBUTION_TYPE =
                                           'RA_CUST_TRX_LINE_GL_DIST_ALL'
                                    --      AND HOU.NAME IN ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                                    AND 1 = is_ind_org (RCTL.ORG_ID, NULL)
                                    --    AND ADLA.ORG_ID = HOU.ORGANIZATION_ID
                                    --    AND ADLA.CUSTOMER_TRX_LINE_ID = RCTL.CUSTOMER_TRX_LINE_ID
                                    AND RCTL.CUSTOMER_TRX_LINE_ID =
                                           RAGL.CUSTOMER_TRX_LINE_ID
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
               END IF;
            /*
            ELSIF P_TABLE_NAME = 'HZ_PARTIES'
            THEN
                 -- p_key_value1 = PARTY_ID
                    SELECT COUNT(1)
                    INTO ln_count
                    FROM DUAL
                    WHERE  (EXISTS (select 1 from  HZ_CUST_ACCOUNTS HCA,
                                                  HZ_PARTY_SITES HZP,
                                                  HZ_CUST_ACCT_SITES_ALL HCAS
                                 -- APPS.HR_OPERATING_UNITS HOU

                                 WHERE    HCA.PARTY_ID               = TO_NUMBER(p_key_value1)    -- PARTY_ID
                              and HZP.PARTY_ID           = TO_NUMBER(p_key_value1)
                              and HCA.CUST_ACCOUNT_ID    = HCAS.CUST_ACCOUNT_ID
                              and HZP.PARTY_SITE_ID      = HCAS.PARTY_SITE_ID
                              and 1 = is_ind_org(HCAS.ORG_ID ,null )
                          --    and HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                                 )
                        or exists
                                (select 1 from   HZ_PARTIES HP,
                                         HZ_CUST_ACCOUNTS HCA,
                                 HZ_RELATIONSHIPS HRP,
                                 HZ_PARTY_SITES HZP,
                                 HZ_CUST_ACCT_SITES_ALL HCAS,
                                                 APPS.HR_OPERATING_UNITS HOU

                        where
                        (HP.PARTY_TYPE='PERSON' and HRP.RELATIONSHIP_CODE = 'CONTACT' and HRP.OBJECT_ID = P_KEY_VALUE1 and HRP.SUBJECT_ID = HCA.PARTY_ID)
                        or (HP.PARTY_TYPE='PARTY_RELATIONSHIP' and HRP.RELATIONSHIP_CODE = 'CONTACT_OF' and HRP.PARTY_ID = P_KEY_VALUE1 and HRP.OBJECT_ID = HCA.PARTY_ID)
                        and HCA.CUST_ACCOUNT_ID = HCAS.CUST_ACCOUNT_ID
                        and HZP.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
                        and HCAS.ORG_ID = HOU.ORGANIZATION_ID
         and hou.set_of_books_id = 3001
                      --  and HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                          )); */
            -- Commented by Aditya R 10-Jun-25 for CRQ CHG0243331

            ELSIF P_TABLE_NAME = 'HZ_CUST_ACCOUNTS'
            THEN
               -- p_key_value1 = CUST_ACCOUNT_ID
               SELECT COUNT (1)
                 INTO ln_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM HZ_PARTIES HP,
                                 HZ_PARTY_SITES HZP,
                                 HZ_CUST_ACCT_SITES_ALL HCAS,
                                 APPS.HR_OPERATING_UNITS HOU
                           WHERE     HCAS.CUST_ACCOUNT_ID =
                                        TO_NUMBER (p_key_value1) --CUST_ACCOUNT_ID
                                 AND HP.PARTY_ID = HZP.PARTY_ID
                                 AND HZP.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
                                 AND HCAS.ORG_ID = HOU.ORGANIZATION_ID
                                 AND hou.set_of_books_id = 3001);
            /*
            ELSIF P_TABLE_NAME = 'HZ_LOCATIONS'
            THEN
                -- p_key_value1 = LOCATION_ID
                  SELECT COUNT(1)
                  INTO ln_count
                  FROM DUAL
                  WHERE  EXISTS
                              (SELECT 1 FROM  HZ_PARTIES HP,
                                HZ_CUST_ACCOUNTS HCA,
                                HZ_PARTY_SITES HZP,
                                HZ_CUST_ACCT_SITES_ALL HCAS,
                                APPS.HR_OPERATING_UNITS HOU

                               WHERE   HZP.LOCATION_ID = TO_NUMBER(p_key_value1)   -- location_id
                                          and HP.PARTY_ID = HCA.PARTY_ID
                                          and HP.PARTY_ID = HZP.PARTY_ID
                                          and HCA.CUST_ACCOUNT_ID = HCAS.CUST_ACCOUNT_ID
                                          and HZP.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
                                          and HCAS.org_id            = HOU.ORGANIZATION_ID
            and hou.set_of_books_id = 3001
                                        --  and HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                               ); */
            -- commented By Aditya R on 10-Jun-25 for CRQ CHG0243331

            ELSIF P_TABLE_NAME = 'HZ_CUST_SITE_USES_ALL'
            THEN
               -- p_key_value1 = SITE_USE_ID
               -- p_key_value2 = ORG_ID
               IF 1 = is_ind_org (p_key_value2, NULL)
               THEN
                  SELECT COUNT (1)
                    INTO ln_count
                    FROM DUAL
                   WHERE EXISTS
                            (SELECT 1
                               FROM HZ_CUST_SITE_USES_ALL HCSU,
                                    HZ_PARTIES HP,
                                    HZ_CUST_ACCOUNTS HCA,
                                    HZ_PARTY_SITES HZP,
                                    HZ_CUST_ACCT_SITES_ALL HCAS,
                                    APPS.HR_OPERATING_UNITS HOU
                              WHERE     HCSU.SITE_USE_ID =
                                           TO_NUMBER (p_key_value1) -- SITE_USE_ID
                                    AND HP.PARTY_ID = HCA.PARTY_ID
                                    AND HP.PARTY_ID = HZP.PARTY_ID
                                    AND HCA.CUST_ACCOUNT_ID =
                                           HCAS.CUST_ACCOUNT_ID
                                    AND HZP.PARTY_SITE_ID =
                                           HCAS.PARTY_SITE_ID
                                    AND HCAS.CUST_ACCT_SITE_ID =
                                           HCSU.CUST_ACCT_SITE_ID
                                    AND HCAS.org_id = HOU.ORGANIZATION_ID
                                    AND hou.set_of_books_id = 3001 -- and HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                                                                  );
               END IF;
            ELSIF P_TABLE_NAME = 'HZ_CUST_ACCT_SITES_ALL'
            THEN
               -- p_key_value1 = CUST_ACCT_SITE_ID
               -- p_key_value2 = ORG_ID
               IF 1 = is_ind_org (p_key_value2, NULL)
               THEN
                  SELECT COUNT (1)
                    INTO ln_count
                    FROM DUAL
                   WHERE EXISTS
                            (SELECT 1
                               FROM HZ_CUST_ACCT_SITES_ALL HCAS,
                                    HZ_PARTIES HP,
                                    HZ_CUST_ACCOUNTS HCA,
                                    HZ_PARTY_SITES HZP,
                                    APPS.HR_OPERATING_UNITS HOU
                              WHERE     HCAS.CUST_ACCT_SITE_ID =
                                           TO_NUMBER (p_key_value1) -- CUST_ACCT_SITE_ID
                                    AND HP.PARTY_ID = HCA.PARTY_ID
                                    AND HP.PARTY_ID = HZP.PARTY_ID
                                    AND HCA.CUST_ACCOUNT_ID =
                                           HCAS.CUST_ACCOUNT_ID
                                    AND HZP.PARTY_SITE_ID =
                                           HCAS.PARTY_SITE_ID
                                    AND hou.set_of_books_id = 3001
                                    -- and HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                                    AND HCAS.org_id = HOU.ORGANIZATION_ID);
               END IF;
            /*
            ELSIF P_TABLE_NAME = 'PO_LOCATION_ASSOCIATIONS_ALL'
            THEN
                  -- p_key_value1 = LOCATION_ID
                  -- p_key_value2 = ORG_ID
                 IF 1=is_ind_org(p_key_value2,null )
                 THEN
                    SELECT COUNT(1)
                    INTO ln_count
                    FROM DUAL
                    WHERE  EXISTS (select 1 from  PO_LOCATION_ASSOCIATIONS_ALL PLAA,
                                                  HZ_PARTIES HP,
                                                  HZ_CUST_ACCOUNTS HCA,
                                                  HZ_CUST_ACCT_SITES_ALL HCAS,
                                                  HZ_CUST_SITE_USES_ALL HCSU,
                                                  HZ_PARTY_SITES HZP,
                                                  APPS.HR_OPERATING_UNITS HOU

                                    WHERE    PLAA.LOCATION_ID  = P_KEY_VALUE1   -- LOCATION_ID is pk1
                                    and HP.PARTY_ID = HCA.PARTY_ID
                                    and HP.PARTY_ID = HZP.PARTY_ID
                                    and HCA.CUST_ACCOUNT_ID = HCAS.CUST_ACCOUNT_ID
                                    and HZP.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
                                    and HCSU.CUST_ACCT_SITE_ID = HCAS.CUST_ACCT_SITE_ID
                                    and HCSU.SITE_USE_ID = PLAA.SITE_USE_ID
                                    AND PLAA.CUSTOMER_ID = HCA.CUST_ACCOUNT_ID
                                    and HCAS.ORG_ID = HOU.ORGANIZATION_ID
            and hou.set_of_books_id = 3001
                                  --  and HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                                    and HCAS.org_id   = HOU.ORGANIZATION_ID
                                 );
                 END IF; */
            -- -- Commented By Aditya R on 10-Jun-25 CRQ CHG0243331

            ELSIF P_TABLE_NAME = 'AP_SUPPLIERS'
            THEN
               -- p_key_value1 = VENDOR_ID
               SELECT COUNT (1)
                 INTO ln_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM APPS.AP_SUPPLIER_SITES_ALL APS,
                                 HR_OPERATING_UNITS HOU
                           WHERE     APS.VENDOR_ID = TO_NUMBER (p_key_value1) -- VENDOR_ID
                                 AND APS.ORG_ID = HOU.ORGANIZATION_ID
                                 AND hou.set_of_books_id = 3001 --AND  HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                                                               );
            ELSIF P_TABLE_NAME = 'AP_SUPPLIER_SITES_ALL'
            THEN
               -- p_key_value1 = VENDOR_SITE_ID
               -- p_key_value2 = ORG_ID
               IF 1 = is_ind_org (p_key_value2, NULL)
               THEN
                  SELECT COUNT (1)
                    INTO ln_count
                    FROM DUAL
                   WHERE EXISTS
                            (SELECT 1
                               FROM APPS.AP_SUPPLIER_SITES_ALL APS,
                                    HR_OPERATING_UNITS HOU
                              WHERE     APS.VENDOR_SITE_ID =
                                           TO_NUMBER (p_key_value1) -- VENDOR_SITE_ID
                                    AND APS.ORG_ID = HOU.ORGANIZATION_ID
                                    AND hou.set_of_books_id = 3001 --AND HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                                                                  );
               END IF;
            /*
            ELSIF P_TABLE_NAME = 'AP_SUPPLIER_CONTACTS'
            THEN
                -- p_key_value1 = VENDOR_CONTACT_ID
                SELECT COUNT(1)
                INTO ln_count
                FROM DUAL
                WHERE  EXISTS (select 1 from   APPS.AP_SUPPLIER_CONTACTS ASCC,
                                               APPS.AP_SUPPLIER_SITES_ALL APS,
                                               APPS.HR_OPERATING_UNITS HOU
                                        WHERE  ASCC.VENDOR_CONTACT_ID   =  TO_NUMBER(p_key_value1)   -- VENDOR_CONTACT_ID is pk1
                                        AND APS.VENDOR_SITE_ID   = nvl(ASCC.VENDOR_SITE_ID,APS.VENDOR_SITE_ID)
                                        AND APS.ORG_ID           = HOU.ORGANIZATION_ID
             and hou.set_of_books_id = 3001
                                       -- AND HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                             );*/
            -- -- Commented by Aditya R on 11-Jun-25 for CRQ CHG0243331

            /*
            ELSIF P_TABLE_NAME = 'MTL_ITEM_CATEGORIES'
            THEN
                -- p_key_value1 = INVENTORY_ITEM_ID
                -- p_key_value2 = ORGANIZATION_ID
                -- p_key_value3 = CATEGORY_SET_ID
                    SELECT COUNT(1)
                    INTO ln_count
                    FROM DUAL
                    WHERE  EXISTS (select 1 from MTL_ITEM_CATEGORIES MIC,
                                                 APPS.ORG_ORGANIZATION_DEFINITIONS ORG,
                                                 APPS.HR_OPERATING_UNITS HOU
                                          WHERE MIC.INVENTORY_ITEM_ID = P_KEY_VALUE1  -- INVENTORY_ITEM_ID is pk1
                                            and MIC.ORGANIZATION_ID = P_KEY_VALUE2    --ORGANIZATION_ID  is pk2
                                            and MIC.CATEGORY_SET_ID = P_KEY_VALUE3      -- CATEGORY_SET_ID is pk3
                                            and ORG.ORGANIZATION_ID = MIC.ORGANIZATION_ID
                                            and ORG.OPERATING_UNIT = HOU.ORGANIZATION_ID
              and hou.set_of_books_id = 3001
                                          --  and HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                                 );*/
            -- Commented by Aditya R on 11-Jun-25 for CRQ CHG0243331

            /*
            ELSIF P_TABLE_NAME = 'MTL_ITEM_REVISIONS_B'
            THEN
                 -- p_key_value1 = REVISION_ID
                  SELECT COUNT(1)
                  INTO ln_count
                  FROM DUAL
                  WHERE  EXISTS (select 1 from MTL_ITEM_REVISIONS_B MIRB,
                                               APPS.ORG_ORGANIZATION_DEFINITIONS ORG,
                                               APPS.HR_OPERATING_UNITS HOU
                                          WHERE MIRB.REVISION_ID = P_KEY_VALUE1  -- REVISION_ID is pk1
                                          and ORG.ORGANIZATION_ID = MIRB.ORGANIZATION_ID
                                          and ORG.OPERATING_UNIT = HOU.ORGANIZATION_ID
            and hou.set_of_books_id = 3001
                                       --   and HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                               );*/
            -- Commented by Aditya R on 11-Jun-25 for CRQ CHG0243331

            ELSIF P_TABLE_NAME = 'BOM_STRUCTURES_B'
            THEN
               -- p_key_value1 = BILL_SEQUENCE_ID
               SELECT COUNT (1)
                 INTO ln_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM APPS.BOM_STRUCTURES_B MSB,
                                 APPS.ORG_ORGANIZATION_DEFINITIONS ORG,
                                 APPS.HR_OPERATING_UNITS HOU
                           WHERE     MSB.BILL_SEQUENCE_ID = P_KEY_VALUE1 -- BILL_SEQUENCE_ID is pk1
                                 AND ORG.ORGANIZATION_ID =
                                        MSB.ORGANIZATION_ID
                                 AND ORG.OPERATING_UNIT = HOU.ORGANIZATION_ID
                                 AND hou.set_of_books_id = 3001 --  and HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                                                               );
            ELSIF P_TABLE_NAME = 'BOM_COMPONENTS_B'
            THEN
               -- p_key_value1 = COMPONENT_SEQUENCE_ID
               SELECT COUNT (1)
                 INTO ln_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM APPS.BOM_COMPONENTS_B MCB,
                                 APPS.BOM_STRUCTURES_B msb,
                                 APPS.ORG_ORGANIZATION_DEFINITIONS ORG,
                                 APPS.HR_OPERATING_UNITS HOU
                           WHERE     MCB.COMPONENT_SEQUENCE_ID = P_KEY_VALUE1 -- COMPONENT_SEQUENCE_ID is pk1
                                 AND mcb.BILL_SEQUENCE_ID =
                                        msb.BILL_SEQUENCE_ID
                                 AND ORG.ORGANIZATION_ID =
                                        MSB.ORGANIZATION_ID
                                 AND ORG.OPERATING_UNIT = HOU.ORGANIZATION_ID
                                 AND hou.set_of_books_id = 3001 -- and HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                                                               );
            ELSIF P_TABLE_NAME = 'XLA_AE_HEADERS'
            THEN
               -- p_key_value1 = AE_HEADER_ID
               -- p_key_value2 = LEDGER_ID
               IF p_key_value2 IN ('3001')
               THEN
                  SELECT COUNT (1)
                    INTO ln_count
                    FROM DUAL
                   WHERE EXISTS
                            (SELECT 1
                               FROM APPS.XLA_AE_HEADERS XAH,
                                    HR_OPERATING_UNITS HOU
                              WHERE     XAH.AE_HEADER_ID =
                                           TO_NUMBER (p_key_value1) -- AE_HEADER_ID
                                    AND XAH.GL_TRANSFER_STATUS_CODE = 'Y'
                                    AND XAH.ACCOUNTING_ENTRY_STATUS_CODE =
                                           'F'
                                    AND hou.set_of_books_id = 3001
                                    -- and hou.NAME IN ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                                    AND XAH.LEDGER_ID = HOU.SET_OF_BOOKS_ID);
               END IF;
            ELSIF P_TABLE_NAME = 'XLA_AE_LINES'
            THEN
               -- p_key_value1 = AE_HEADER_ID
               -- p_key_value2 = AE_LINE_NUM
               -- p_key_value3 = LEDGER_ID
               IF p_key_value3 IN ('3001')
               THEN
                  SELECT COUNT (1)
                    INTO ln_count
                    FROM DUAL
                   WHERE EXISTS
                            (SELECT 1
                               FROM APPS.XLA_AE_LINES XAL,
                                    APPS.XLA_AE_HEADERS XAH,
                                    APPS.HR_OPERATING_UNITS HOU
                              WHERE     XAL.AE_HEADER_ID =
                                           TO_NUMBER (p_key_value1) -- AE_HEADER_ID
                                    AND XAL.AE_LINE_NUM =
                                           TO_NUMBER (p_key_value2) --AE_LINE_NUM
                                    AND XAL.AE_HEADER_ID = XAH.AE_HEADER_ID
                                    AND XAH.GL_TRANSFER_STATUS_CODE = 'Y'
                                    AND XAH.ACCOUNTING_ENTRY_STATUS_CODE =
                                           'F'
                                    AND XAH.LEDGER_ID = HOU.SET_OF_BOOKS_ID
                                    AND hou.set_of_books_id = 3001
                                    --  and hou.NAME IN ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
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
               END IF;
            /*
              ELSIF P_TABLE_NAME = 'XLA_EVENTS'
              THEN
                   -- p_key_value1 = EVENT_ID

                      SELECT COUNT(1)
                      INTO ln_count
                      FROM DUAL
                      WHERE  EXISTS (select 1 from  APPS.XLA_EVENTS XE,
                                                    APPS.XLA_AE_HEADERS XAH,
                                                    APPS.XLA_AE_LINES XAL,
                                                    APPS.XLA_DISTRIBUTION_LINKS XDL,
                                                    APPS.HR_OPERATING_UNITS HOU
                                              where XE.EVENT_ID    = TO_NUMBER(p_key_value1)   -- EVENT_ID is pk1
                                              AND XE.ENTITY_ID = XAH.ENTITY_ID
                                              AND XE.EVENT_ID = XAH.EVENT_ID
                                              AND XAH.AE_HEADER_ID = XAL.AE_HEADER_ID
                                              AND XDL.AE_HEADER_ID = XAH.AE_HEADER_ID
                                              AND XDL.AE_LINE_NUM = XAL.AE_LINE_NUM
                                              AND XAH.LEDGER_ID = HOU.SET_OF_BOOKS_ID
                                              AND XAH.GL_TRANSFER_STATUS_CODE='Y'
                                              AND XAH.ACCOUNTING_ENTRY_STATUS_CODE='F'
                                              AND XE.EVENT_STATUS_CODE='P'
                                              AND XE.PROCESS_STATUS_CODE='P'
                and hou.set_of_books_id = 3001
                                             -- and hou.NAME IN ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                                              AND xal.creation_date <= TO_DATE(nvl(to_char(TO_TIMESTAMP(p_collection_time, 'YYYY-MM-DD HH24:MI:SS.FF6'),
                                                                        'YYYY-MM-DD HH24:MI:SS'), to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')),
                                                                       'YYYY-MM-DD HH24:MI:SS')
                                    ); */
            -- Commented by Aditya R on 11-Jun-25 for CRQ CHG0243331

            /*
            ELSIF P_TABLE_NAME = 'HZ_ORG_CONTACTS'
            THEN
                  -- p_key_value1 = ORG_CONTACT_ID

            SELECT COUNT(1)
            INTO ln_count
            FROM DUAL
            WHERE  EXISTS (select 1 from HZ_ORG_CONTACTS HOC,
                                         HZ_PARTIES HP,
                                         HZ_CUST_ACCOUNTS HCA,
                                         HZ_RELATIONSHIPS HRP,
                                         HZ_PARTY_SITES HZP,
                                         HZ_CUST_ACCT_SITES_ALL HCAS,
                                         APPS.HR_OPERATING_UNITS HOU
                                     WHERE HOC.ORG_CONTACT_ID = TO_NUMBER(p_key_value1)  -- ORG_CONTACT_ID pk1
                                     and (HP.PARTY_TYPE='PERSON' and HRP.RELATIONSHIP_CODE = 'CONTACT' and HRP.OBJECT_ID = HP.PARTY_ID and HRP.SUBJECT_ID = HCA.PARTY_ID)
                                         or (HP.PARTY_TYPE='PARTY_RELATIONSHIP' and HRP.RELATIONSHIP_CODE = 'CONTACT_OF' and HRP.PARTY_ID = HP.PARTY_ID and HRP.OBJECT_ID = HCA.PARTY_ID)
                                      AND HRP.RELATIONSHIP_ID = HOC.PARTY_RELATIONSHIP_ID
                                      and HCA.CUST_ACCOUNT_ID = HCAS.CUST_ACCOUNT_ID
                                      and HZP.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
                                      and HCAS.ORG_ID = HOU.ORGANIZATION_ID
           and hou.set_of_books_id = 3001
                                    --  and HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                          ); */
            -- Commented by Aditya R on 11-Jun-25 for CRQ CHG0243331

            /*
            ELSIF P_TABLE_NAME = 'HZ_CUST_ACCOUNT_ROLES'
            THEN
                 -- p_key_value1 = CUST_ACCOUNT_ROLE_ID

                    SELECT COUNT(1)
                    INTO ln_count
                    FROM DUAL
                    WHERE  EXISTS (select 1 from HZ_CUST_ACCOUNT_ROLES HCAR,
                                                 HZ_PARTIES HP,
                                                 HZ_CUST_ACCOUNTS HCA,
                                                 HZ_RELATIONSHIPS HRP,
                                                 HZ_PARTY_SITES HZP,
                                                 HZ_CUST_ACCT_SITES_ALL HCAS,
                                                 APPS.HR_OPERATING_UNITS HOU
                                            WHERE HCAR.CUST_ACCOUNT_ROLE_ID = P_KEY_VALUE1  -- CUST_ACCOUNT_ROLE_ID pk1
                                            and (HP.PARTY_TYPE='PERSON' and HRP.RELATIONSHIP_CODE = 'CONTACT' and HRP.OBJECT_ID = HP.PARTY_ID and HRP.SUBJECT_ID = HCA.PARTY_ID)
                                            or (HP.PARTY_TYPE='PARTY_RELATIONSHIP' and HRP.RELATIONSHIP_CODE = 'CONTACT_OF' and HRP.PARTY_ID = HP.PARTY_ID and HRP.OBJECT_ID = HCA.PARTY_ID)
                                            and HCA.CUST_ACCOUNT_ID = HCAS.CUST_ACCOUNT_ID
                                            and HCAR.CUST_ACCOUNT_ID = HCA.CUST_ACCOUNT_ID
                                            and HZP.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
                                            and HCAS.ORG_ID = HOU.ORGANIZATION_ID
              and hou.set_of_books_id = 3001
                                           -- and HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                                  ); */
            -- Commented by Aditya R on 11-Jun-25 for CRQ CHG0243331
            /*
            ELSIF P_TABLE_NAME = 'HZ_PARTY_SITE_USES'
            THEN
               -- p_key_value1 = PARTY_SITE_ID
            SELECT COUNT(1)
            INTO ln_count
            FROM DUAL
            WHERE  EXISTS (select 1 from HZ_CUST_ACCOUNT_ROLES HCAR,
                                         HZ_PARTIES HP,
                                         HZ_CUST_ACCOUNTS HCA,
                                         HZ_RELATIONSHIPS HRP,
                                         HZ_PARTY_SITES HZP,
                                         HZ_CUST_ACCT_SITES_ALL HCAS,
                                         APPS.HR_OPERATING_UNITS HOU
                                     WHERE HZP.PARTY_SITE_ID = TO_NUMBER(p_key_value1)  -- PARTY_SITE_ID pk1
                                     and (HP.PARTY_TYPE='PERSON' and HRP.RELATIONSHIP_CODE = 'CONTACT' and HRP.OBJECT_ID = HP.PARTY_ID and HRP.SUBJECT_ID = HCA.PARTY_ID)
                                      or (HP.PARTY_TYPE='PARTY_RELATIONSHIP' and HRP.RELATIONSHIP_CODE = 'CONTACT_OF' and HRP.PARTY_ID = HP.PARTY_ID and HRP.OBJECT_ID = HCA.PARTY_ID)
                                    and HCA.CUST_ACCOUNT_ID = HCAS.CUST_ACCOUNT_ID
                                    and HZP.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
                                -- AND HPSU.PARTY_SITE_ID = HZP.PARTY_SITE_ID
                                    and HCAS.ORG_ID = HOU.ORGANIZATION_ID
            and hou.set_of_books_id = 3001
                                --    and HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                         );

            ELSIF P_TABLE_NAME = 'HZ_PARTY_SITES'
            THEN
                 -- p_key_value1 = PARTY_ID
                 -- p_key_value2 = PARTY_SITE_ID
            SELECT COUNT(1)
            INTO ln_count
            FROM DUAL
            WHERE  (EXISTS (select 1 from  HZ_CUST_ACCOUNT_ROLES HCAR,
                                           HZ_PARTIES HP,
                                           HZ_CUST_ACCOUNTS HCA,
                                           HZ_CUST_ACCT_SITES_ALL HCAS,
                                           APPS.HR_OPERATING_UNITS HOU
                             WHERE HP.PARTY_ID = TO_NUMBER(p_key_value1)  -- PARTY_ID is pk1
                             and HCAS.PARTY_SITE_ID   = TO_NUMBER(p_key_value2)   -- PARTY_SITE_ID is pk2
                          --and HP.PARTY_ID = HZP.PARTY_ID
                           and HP.PARTY_ID = HCA.PARTY_ID
                           and HCA.CUST_ACCOUNT_ID = HCAS.CUST_ACCOUNT_ID
                      -- and HZP.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
                        and HCAS.ORG_ID = HOU.ORGANIZATION_ID
         and hou.set_of_books_id = 3001
                        --and HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                                 )
                          or exists
                           (select 1
                          from HZ_PARTIES HP,
                             HZ_CUST_ACCOUNTS HCA,
                             HZ_RELATIONSHIPS HRP,
                             HZ_CUST_ACCT_SITES_ALL HCAS,
                             APPS.HR_OPERATING_UNITS HOU
                          where HCAS.PARTY_SITE_ID   = TO_NUMBER(p_key_value2)    -- PARTY_SITE_ID is pk2
                          and (HP.PARTY_TYPE='PERSON' and HRP.RELATIONSHIP_CODE = 'CONTACT' and HRP.OBJECT_ID = HP.PARTY_ID and HRP.SUBJECT_ID = HCA.PARTY_ID)
                          or (HP.PARTY_TYPE='PARTY_RELATIONSHIP' and HRP.RELATIONSHIP_CODE = 'CONTACT_OF' and HRP.PARTY_ID = HP.PARTY_ID and HRP.OBJECT_ID = HCA.PARTY_ID)
                          and HCA.CUST_ACCOUNT_ID = HCAS.CUST_ACCOUNT_ID
                        -- and HZP.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
                          and HCAS.ORG_ID = HOU.ORGANIZATION_ID
        and hou.set_of_books_id = 3001
                         -- and HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                             )
                       );

          ELSIF P_TABLE_NAME = 'HZ_ROLE_RESPONSIBILITY'
          THEN
               -- p_key_value1 = RESPONSIBILITY_ID
            SELECT COUNT(1)
            INTO ln_count
            FROM DUAL
            WHERE  EXISTS (select 1 from HZ_ROLE_RESPONSIBILITY HRR,
                                         HZ_PARTIES HP,
                                         HZ_CUST_ACCOUNTS HCA,
                                         HZ_RELATIONSHIPS HRP,
                                         HZ_CUST_ACCT_SITES_ALL HCAS,
                                         HZ_CUST_ACCOUNT_ROLES HCAR,
                                         HZ_PARTY_SITES HZP,
                                         APPS.HR_OPERATING_UNITS HOU
                                   WHERE HRR.RESPONSIBILITY_ID = TO_NUMBER(p_key_value1)  -- RESPONSIBILITY_ID pk1
                                   and (HP.PARTY_TYPE='PERSON' and HRP.RELATIONSHIP_CODE = 'CONTACT' and HRP.OBJECT_ID = HP.PARTY_ID and HRP.SUBJECT_ID = HCA.PARTY_ID)
                                    or (HP.PARTY_TYPE='PARTY_RELATIONSHIP' and HRP.RELATIONSHIP_CODE = 'CONTACT_OF' and HRP.PARTY_ID = HP.PARTY_ID and HRP.OBJECT_ID = HCA.PARTY_ID)
                                    and HCA.CUST_ACCOUNT_ID = HCAS.CUST_ACCOUNT_ID
                                    and HZP.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
                                    and HCAR.CUST_ACCOUNT_ID = HCA.CUST_ACCOUNT_ID
                                    and HCAR.CUST_ACCT_SITE_ID = HCAS.CUST_ACCT_SITE_ID
                                    AND HRR.CUST_ACCOUNT_ROLE_ID = HCAR.CUST_ACCOUNT_ROLE_ID
                                    and HCAS.ORG_ID = HOU.ORGANIZATION_ID
            and hou.set_of_books_id = 3001
                                  --  and HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                         );

            ELSIF P_TABLE_NAME = 'HZ_CONTACT_POINTS'
            THEN
                  -- p_key_value1 = contact_point_id
                        SELECT COUNT(1)
                        INTO ln_count
                        FROM DUAL
                        WHERE  EXISTS (select 1 from HZ_CONTACT_POINTS HCP,
                                                 HZ_PARTIES HP,
                                   HZ_CUST_ACCOUNTS HCA,
                                   HZ_RELATIONSHIPS HRP,
                                   HZ_CUST_ACCT_SITES_ALL HCAS,
                                   HZ_PARTY_SITES HZP,
                                   APPS.HR_OPERATING_UNITS HOU
                                 WHERE HCP.CONTACT_POINT_ID = P_KEY_VALUE1  -- CONTACT_POINT_ID pk1
                                 and (HP.PARTY_TYPE='PERSON' and HRP.RELATIONSHIP_CODE = 'CONTACT' and HRP.OBJECT_ID = HP.PARTY_ID and HRP.SUBJECT_ID = HCA.PARTY_ID)
                            or (HP.PARTY_TYPE='PARTY_RELATIONSHIP' and HRP.RELATIONSHIP_CODE = 'CONTACT_OF' and HRP.PARTY_ID = HP.PARTY_ID and HRP.OBJECT_ID = HCA.PARTY_ID)
                            and HCA.CUST_ACCOUNT_ID = HCAS.CUST_ACCOUNT_ID
                            AND HCP.OWNER_TABLE_ID = HP.PARTY_ID
                            and HZP.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
                            and HCAS.ORG_ID = HOU.ORGANIZATION_ID
          and hou.set_of_books_id = 3001
                           -- and HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                                    );

            ELSIF P_TABLE_NAME = 'HZ_CUSTOMER_PROFILES'
            THEN
                -- p_key_value1 = CUST_ACCOUNT_PROFILE_ID
                    SELECT COUNT(1)
                    INTO ln_count
                    FROM DUAL
                    WHERE  EXISTS (select 1 from HZ_CUSTOMER_PROFILES HCPR,
                                             HZ_PARTIES HP,
                               HZ_CUST_ACCOUNTS HCA,
                               HZ_CUST_ACCT_SITES_ALL HCAS,
                               HZ_PARTY_SITES HZP,
                               HZ_CUST_SITE_USES_ALL HCSU,
                               APPS.HR_OPERATING_UNITS HOU
                             WHERE HCPR.CUST_ACCOUNT_PROFILE_ID = TO_NUMBER(p_key_value1)  -- CUST_ACCOUNT_PROFILE_ID pk1
                             and HP.PARTY_ID = HCA.PARTY_ID
                        and HP.PARTY_ID = HZP.PARTY_ID
                        and HCA.CUST_ACCOUNT_ID = HCAS.CUST_ACCOUNT_ID
                        and HCA.CUST_ACCOUNT_ID = HCPR.CUST_ACCOUNT_ID
                        and HZP.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
                        and HCSU.CUST_ACCT_SITE_ID = HCAS.CUST_ACCT_SITE_ID
                        and HCAS.ORG_ID = HOU.ORGANIZATION_ID
         and hou.set_of_books_id = 3001
                         -- and HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                               ); */
            -- -- Commented by Aditya R on 11-Jun-25 for CRQ CHG0243331

            ELSIF P_TABLE_NAME = 'HZ_CUST_PROFILE_AMTS'
            THEN
               -- p_key_value1 = CUST_ACCOUNT_PROFILE_ID
               SELECT COUNT (1)
                 INTO ln_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM HZ_CUSTOMER_PROFILES HCPR,
                                 HZ_PARTIES HP,
                                 HZ_CUST_ACCOUNTS HCA,
                                 HZ_CUST_ACCT_SITES_ALL HCAS,
                                 HZ_PARTY_SITES HZP,
                                 HZ_CUST_SITE_USES_ALL HCSU,
                                 APPS.HR_OPERATING_UNITS HOU
                           WHERE     HCPR.CUST_ACCOUNT_PROFILE_ID =
                                        TO_NUMBER (p_key_value1) -- CUST_ACCOUNT_PROFILE_ID pk1
                                 --  and HCPA.CUST_ACCOUNT_PROFILE_ID = HCPR.CUST_ACCOUNT_PROFILE_ID
                                 AND HP.PARTY_ID = HCA.PARTY_ID
                                 AND HP.PARTY_ID = HZP.PARTY_ID
                                 AND HCA.CUST_ACCOUNT_ID =
                                        HCAS.CUST_ACCOUNT_ID
                                 AND HCA.CUST_ACCOUNT_ID =
                                        HCPR.CUST_ACCOUNT_ID
                                 AND HZP.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
                                 AND HCSU.CUST_ACCT_SITE_ID =
                                        HCAS.CUST_ACCT_SITE_ID
                                 AND HCAS.ORG_ID = HOU.ORGANIZATION_ID
                                 AND hou.set_of_books_id = 3001 --  and HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                                                               );
            /*
            ELSIF P_TABLE_NAME = 'HZ_RELATIONSHIPS'
            THEN
                 -- p_key_value1 = RELATIONSHIP_ID

                    SELECT COUNT(1)
                    INTO ln_count
                    FROM DUAL
                    WHERE  EXISTS (select 1 from HZ_RELATIONSHIPS HRP,
                               HZ_PARTIES HP,
                               HZ_CUST_ACCOUNTS HCA,
                               HZ_PARTY_SITES HZP,
                               HZ_CUST_ACCT_SITES_ALL HCAS,
                               APPS.HR_OPERATING_UNITS HOU
                             WHERE HRP.RELATIONSHIP_ID = P_KEY_VALUE1  -- RELATIONSHIP_ID pk1
                        and (HP.PARTY_TYPE='PERSON' and HRP.RELATIONSHIP_CODE = 'CONTACT' and HRP.OBJECT_ID = HP.PARTY_ID and HRP.SUBJECT_ID = HCA.PARTY_ID)
                        or (HP.PARTY_TYPE='PARTY_RELATIONSHIP' and HRP.RELATIONSHIP_CODE = 'CONTACT_OF' and HRP.PARTY_ID = HP.PARTY_ID and HRP.OBJECT_ID = HCA.PARTY_ID)
                        and HCA.CUST_ACCOUNT_ID = HCAS.CUST_ACCOUNT_ID
                        and HZP.PARTY_SITE_ID = HCAS.PARTY_SITE_ID
                        and HCAS.ORG_ID = HOU.ORGANIZATION_ID
         and hou.set_of_books_id = 3001
                        --  and HOU.name in ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                                 );  */
            ---- Commented by Aditya R on 11-Jun-25 for CRQ CHG0243331

            ELSIF P_TABLE_NAME = 'RCV_TRANSACTIONS'
            THEN
               -- p_key_value1 = TRANSACTION_ID
               SELECT COUNT (1)
                 INTO ln_count
                 FROM DUAL
                WHERE (   EXISTS
                             (SELECT 1
                                FROM RCV_TRANSACTIONS RT,
                                     APPS.ORG_ORGANIZATION_DEFINITIONS ORG,
                                     APPS.HR_OPERATING_UNITS HOU,
                                     APPS.RCV_RECEIVING_SUB_LEDGER RRSL,
                                     APPS.XLA_DISTRIBUTION_LINKS XDL,
                                     APPS.XLA_EVENTS XE,
                                     APPS.XLA_AE_HEADERS XAH,
                                     APPS.XLA_AE_LINES XAL
                               WHERE     RT.TRANSACTION_ID = P_KEY_VALUE1 --  pk1 is TRANSACTION_ID
                                     AND RT.TRANSACTION_ID =
                                            RRSL.RCV_TRANSACTION_ID
                                     AND RRSL.RCV_SUB_LEDGER_ID =
                                            XDL.SOURCE_DISTRIBUTION_ID_NUM_1
                                     AND XDL.SOURCE_DISTRIBUTION_TYPE =
                                            'RCV_RECEIVING_SUB_LEDGER'
                                     AND XDL.AE_HEADER_ID = XAH.AE_HEADER_ID
                                     AND XDL.APPLICATION_ID =
                                            XAH.APPLICATION_ID
                                     AND XDL.AE_LINE_NUM = XAL.AE_LINE_NUM
                                     AND XE.EVENT_STATUS_CODE = 'P'
                                     AND XE.PROCESS_STATUS_CODE = 'P'
                                     AND XAH.GL_TRANSFER_STATUS_CODE = 'Y'
                                     AND XAH.ACCOUNTING_ENTRY_STATUS_CODE =
                                            'F'
                                     AND XE.ENTITY_ID = XAH.ENTITY_ID
                                     AND RT.ORGANIZATION_ID =
                                            ORG.ORGANIZATION_ID
                                     AND HOU.ORGANIZATION_ID =
                                            ORG.OPERATING_UNIT
                                     AND hou.set_of_books_id = 3001
                                     --  AND HOU.NAME           IN ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                                     AND XAH.AE_HEADER_ID = XAL.AE_HEADER_ID
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
                                FROM RCV_TRANSACTIONS RT,
                                     APPS.ORG_ORGANIZATION_DEFINITIONS ORG,
                                     APPS.HR_OPERATING_UNITS HOU,
                                     MTL_MATERIAL_TRANSACTIONS MMT,
                                     MTL_TRANSACTION_ACCOUNTS MTA,
                                     APPS.XLA_EVENTS XE,
                                     APPS.XLA_DISTRIBUTION_LINKS XDL,
                                     APPS.XLA_AE_HEADERS XAH,
                                     APPS.XLA_AE_LINES XAL
                               WHERE     RT.TRANSACTION_ID = P_KEY_VALUE1 --  pk1 is TRANSACTION_ID
                                     AND RT.TRANSACTION_ID =
                                            MMT.RCV_TRANSACTION_ID
                                     AND MMT.TRANSACTION_ID =
                                            MTA.TRANSACTION_ID
                                     AND MTA.INV_SUB_LEDGER_ID =
                                            XDL.SOURCE_DISTRIBUTION_ID_NUM_1
                                     AND XDL.SOURCE_DISTRIBUTION_TYPE =
                                            'MTL_TRANSACTION_ACCOUNTS'
                                     AND XDL.AE_HEADER_ID = XAH.AE_HEADER_ID
                                     AND XDL.APPLICATION_ID =
                                            XAH.APPLICATION_ID
                                     AND XDL.AE_LINE_NUM = XAL.AE_LINE_NUM
                                     AND XE.EVENT_STATUS_CODE = 'P'
                                     AND XE.PROCESS_STATUS_CODE = 'P'
                                     AND XAH.GL_TRANSFER_STATUS_CODE = 'Y'
                                     AND XAH.ACCOUNTING_ENTRY_STATUS_CODE =
                                            'F'
                                     AND XE.ENTITY_ID = XAH.ENTITY_ID
                                     AND RT.ORGANIZATION_ID =
                                            ORG.ORGANIZATION_ID
                                     AND HOU.ORGANIZATION_ID =
                                            ORG.OPERATING_UNIT
                                     AND hou.set_of_books_id = 3001
                                     -- AND HOU.NAME           IN ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                                     AND XAH.AE_HEADER_ID = XAL.AE_HEADER_ID
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
            ELSIF P_TABLE_NAME = 'RCV_SHIPMENT_HEADERS'
            THEN
               -- p_key_value1 = SHIPMENT_HEADER_ID
               SELECT COUNT (1)
                 INTO ln_count
                 FROM DUAL
                WHERE (   EXISTS
                             (SELECT 1
                                FROM RCV_SHIPMENT_HEADERS RSH,
                                     APPS.ORG_ORGANIZATION_DEFINITIONS ORG,
                                     APPS.HR_OPERATING_UNITS HOU,
                                     RCV_TRANSACTIONS RT,
                                     APPS.RCV_RECEIVING_SUB_LEDGER RRSL,
                                     APPS.XLA_DISTRIBUTION_LINKS XDL,
                                     APPS.XLA_EVENTS XE,
                                     APPS.XLA_AE_HEADERS XAH,
                                     APPS.XLA_AE_LINES XAL
                               WHERE     RSH.SHIPMENT_HEADER_ID =
                                            P_KEY_VALUE1 --  pk1 is SHIPMENT_HEADER_ID
                                     AND RT.SHIPMENT_HEADER_ID =
                                            RSH.SHIPMENT_HEADER_ID
                                     AND RT.TRANSACTION_ID =
                                            RRSL.RCV_TRANSACTION_ID
                                     AND RRSL.RCV_SUB_LEDGER_ID =
                                            XDL.SOURCE_DISTRIBUTION_ID_NUM_1
                                     AND XDL.SOURCE_DISTRIBUTION_TYPE =
                                            'RCV_RECEIVING_SUB_LEDGER'
                                     AND XDL.AE_HEADER_ID = XAH.AE_HEADER_ID
                                     AND XDL.APPLICATION_ID =
                                            XAH.APPLICATION_ID
                                     AND XDL.AE_LINE_NUM = XAL.AE_LINE_NUM
                                     AND XE.EVENT_STATUS_CODE = 'P'
                                     AND XE.PROCESS_STATUS_CODE = 'P'
                                     AND XAH.GL_TRANSFER_STATUS_CODE = 'Y'
                                     AND XAH.ACCOUNTING_ENTRY_STATUS_CODE =
                                            'F'
                                     AND XE.ENTITY_ID = XAH.ENTITY_ID
                                     AND RSH.SHIP_TO_ORG_ID =
                                            ORG.ORGANIZATION_ID
                                     AND HOU.ORGANIZATION_ID =
                                            ORG.OPERATING_UNIT
                                     AND hou.set_of_books_id = 3001
                                     -- AND HOU.NAME           IN ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                                     AND XAH.AE_HEADER_ID = XAL.AE_HEADER_ID
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
                                FROM RCV_SHIPMENT_HEADERS RSH,
                                     APPS.ORG_ORGANIZATION_DEFINITIONS ORG,
                                     APPS.HR_OPERATING_UNITS HOU,
                                     RCV_TRANSACTIONS RT,
                                     MTL_MATERIAL_TRANSACTIONS MMT,
                                     MTL_TRANSACTION_ACCOUNTS MTA,
                                     APPS.XLA_EVENTS XE,
                                     APPS.XLA_DISTRIBUTION_LINKS XDL,
                                     APPS.XLA_AE_HEADERS XAH,
                                     APPS.XLA_AE_LINES XAL
                               WHERE     RSH.SHIPMENT_HEADER_ID =
                                            P_KEY_VALUE1 --  pk1 is SHIPMENT_HEADER_ID
                                     AND RT.TRANSACTION_ID =
                                            MMT.RCV_TRANSACTION_ID
                                     AND MMT.TRANSACTION_ID =
                                            MTA.TRANSACTION_ID
                                     AND MTA.INV_SUB_LEDGER_ID =
                                            XDL.SOURCE_DISTRIBUTION_ID_NUM_1
                                     AND XDL.SOURCE_DISTRIBUTION_TYPE =
                                            'MTL_TRANSACTION_ACCOUNTS'
                                     AND XDL.AE_HEADER_ID = XAH.AE_HEADER_ID
                                     AND XDL.APPLICATION_ID =
                                            XAH.APPLICATION_ID
                                     AND XDL.AE_LINE_NUM = XAL.AE_LINE_NUM
                                     AND XE.EVENT_STATUS_CODE = 'P'
                                     AND XE.PROCESS_STATUS_CODE = 'P'
                                     AND XAH.GL_TRANSFER_STATUS_CODE = 'Y'
                                     AND XAH.ACCOUNTING_ENTRY_STATUS_CODE =
                                            'F'
                                     AND XE.ENTITY_ID = XAH.ENTITY_ID
                                     AND RSH.SHIP_TO_ORG_ID =
                                            ORG.ORGANIZATION_ID
                                     AND HOU.ORGANIZATION_ID =
                                            ORG.OPERATING_UNIT
                                     AND hou.set_of_books_id = 3001
                                     --AND HOU.NAME           IN ('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                                     AND XAH.AE_HEADER_ID = XAL.AE_HEADER_ID
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
            ELSIF P_TABLE_NAME = 'RCV_SHIPMENT_LINES'
            THEN
               -- p_key_value1 = SHIPMENT_LINE_ID
               -- p_key_value2 = SHIPMENT_HEADER_ID
               SELECT COUNT (1)
                 INTO ln_count
                 FROM DUAL
                WHERE (   EXISTS
                             (SELECT 1
                                FROM RCV_TRANSACTIONS RT,
                                     APPS.RCV_RECEIVING_SUB_LEDGER RRSL,
                                     APPS.XLA_DISTRIBUTION_LINKS XDL,
                                     APPS.XLA_EVENTS XE,
                                     APPS.XLA_AE_HEADERS XAH,
                                     APPS.XLA_AE_LINES XAL,
                                     APPS.ORG_ORGANIZATION_DEFINITIONS ORG,
                                     APPS.HR_OPERATING_UNITS HOU
                               WHERE     RT.SHIPMENT_LINE_ID = P_KEY_VALUE1 -- SHIPMENT_LINE_ID is pk1
                                     AND RT.TRANSACTION_ID =
                                            RRSL.RCV_TRANSACTION_ID
                                     AND RT.ORGANIZATION_ID =
                                            ORG.ORGANIZATION_ID
                                     AND ORG.OPERATING_UNIT =
                                            HOU.ORGANIZATION_ID
                                     AND hou.set_of_books_id = 3001
                                     --   AND HOU.NAME IN('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                                     AND RRSL.RCV_SUB_LEDGER_ID =
                                            XDL.SOURCE_DISTRIBUTION_ID_NUM_1
                                     AND XDL.SOURCE_DISTRIBUTION_TYPE =
                                            'RCV_RECEIVING_SUB_LEDGER'
                                     AND XDL.AE_HEADER_ID = XAH.AE_HEADER_ID
                                     AND XDL.APPLICATION_ID =
                                            XAH.APPLICATION_ID
                                     AND XDL.AE_LINE_NUM = XAL.AE_LINE_NUM
                                     AND XE.EVENT_STATUS_CODE = 'P'
                                     AND XE.PROCESS_STATUS_CODE = 'P'
                                     AND XAH.GL_TRANSFER_STATUS_CODE = 'Y'
                                     AND XAH.ACCOUNTING_ENTRY_STATUS_CODE =
                                            'F'
                                     AND XE.ENTITY_ID = XAH.ENTITY_ID
                                     AND XAH.AE_HEADER_ID = XAL.AE_HEADER_ID
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
                                FROM RCV_TRANSACTIONS RT,
                                     MTL_MATERIAL_TRANSACTIONS MMT,
                                     MTL_TRANSACTION_ACCOUNTS MTA,
                                     APPS.XLA_EVENTS XE,
                                     APPS.XLA_DISTRIBUTION_LINKS XDL,
                                     APPS.XLA_AE_HEADERS XAH,
                                     APPS.XLA_AE_LINES XAL,
                                     APPS.ORG_ORGANIZATION_DEFINITIONS ORG,
                                     APPS.HR_OPERATING_UNITS HOU
                               WHERE     RT.SHIPMENT_HEADER_ID = P_KEY_VALUE2 -- SHIPMENT_HEADER_ID is pk2
                                     AND RT.TRANSACTION_ID =
                                            MMT.RCV_TRANSACTION_ID
                                     AND RT.ORGANIZATION_ID =
                                            ORG.ORGANIZATION_ID
                                     AND ORG.OPERATING_UNIT =
                                            HOU.ORGANIZATION_ID
                                     AND hou.set_of_books_id = 3001
                                     --   AND HOU.NAME IN('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                                     AND MMT.TRANSACTION_ID =
                                            MTA.TRANSACTION_ID
                                     AND MTA.INV_SUB_LEDGER_ID =
                                            XDL.SOURCE_DISTRIBUTION_ID_NUM_1
                                     AND XDL.SOURCE_DISTRIBUTION_TYPE =
                                            'MTL_TRANSACTION_ACCOUNTS'
                                     AND XDL.AE_HEADER_ID = XAH.AE_HEADER_ID
                                     AND XDL.APPLICATION_ID =
                                            XAH.APPLICATION_ID
                                     AND XDL.AE_LINE_NUM = XAL.AE_LINE_NUM
                                     AND XE.EVENT_STATUS_CODE = 'P'
                                     AND XE.PROCESS_STATUS_CODE = 'P'
                                     AND XAH.GL_TRANSFER_STATUS_CODE = 'Y'
                                     AND XAH.ACCOUNTING_ENTRY_STATUS_CODE =
                                            'F'
                                     AND XE.ENTITY_ID = XAH.ENTITY_ID
                                     AND XAH.AE_HEADER_ID = XAL.AE_HEADER_ID
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
            ELSIF P_TABLE_NAME = 'MTL_MATERIAL_TRANSACTIONS'
            THEN
               -- p_key_value1 = TRANSACTION_ID
               SELECT COUNT (1)
                 INTO ln_count
                 FROM DUAL
                WHERE EXISTS
                         (SELECT 1
                            FROM APPS.ORG_ORGANIZATION_DEFINITIONS ORG,
                                 APPS.HR_OPERATING_UNITS HOU,
                                 MTL_TRANSACTION_ACCOUNTS MTA,
                                 APPS.XLA_EVENTS XE,
                                 APPS.XLA_DISTRIBUTION_LINKS XDL,
                                 APPS.XLA_AE_HEADERS XAH,
                                 APPS.XLA_AE_LINES XAL
                           WHERE     MTA.TRANSACTION_ID = P_KEY_VALUE1 -- TRANSACTION_ID is pk1
                                 --  and MMT.TRANSACTION_ID             = MTA.TRANSACTION_ID
                                 AND MTA.INV_SUB_LEDGER_ID =
                                        XDL.SOURCE_DISTRIBUTION_ID_NUM_1
                                 AND XDL.SOURCE_DISTRIBUTION_TYPE =
                                        'MTL_TRANSACTION_ACCOUNTS'
                                 AND XDL.AE_HEADER_ID = XAH.AE_HEADER_ID
                                 AND XDL.APPLICATION_ID = XAH.APPLICATION_ID
                                 AND XDL.AE_LINE_NUM = XAL.AE_LINE_NUM
                                 AND XE.EVENT_STATUS_CODE = 'P'
                                 AND XE.PROCESS_STATUS_CODE = 'P'
                                 AND XAH.GL_TRANSFER_STATUS_CODE = 'Y'
                                 AND XAH.ACCOUNTING_ENTRY_STATUS_CODE = 'F'
                                 AND XE.ENTITY_ID = XAH.ENTITY_ID
                                 AND MTA.ORGANIZATION_ID =
                                        ORG.ORGANIZATION_ID
                                 AND ORG.OPERATING_UNIT = HOU.ORGANIZATION_ID
                                 AND hou.set_of_books_id = 3001
                                 --  AND HOU.name           IN('CTT India Dewas Operating Unit','CTT India Pithampur Operating Unit')
                                 AND XAH.AE_HEADER_ID = XAL.AE_HEADER_ID
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
            ELSIF p_table_name = 'PO_SYSTEM_PARAMETERS_ALL' --Added by Aditya R on 12-Jun-25 CRQ CHG0243331
            THEN
               -- p_key_value1 = org_id
               ln_count := is_ind_org (p_key_value1, NULL);
            ELSIF (p_table_name = 'GL_PERIOD_TYPES') --Added by Aditya R on 12-Jun-25 CRQ CHG0243331
            THEN
               -- p_key_value1 = PERIOD_TYPE_ID
               -- p_key_value2 = DESCRIPTION
               -- p_key_value3 = PERIOD_TYPE

               SELECT COUNT (1)
                 INTO ln_count
                 FROM gl_periods
                WHERE     PERIOD_SET_NAME = 'Std Accounting'
                      AND period_type = p_key_value3;
            ELSIF (p_table_name = 'GL_PERIODS') --Added by Aditya R on 12-Jun-25 CRQ CHG0243331
            THEN
               -- p_key_value1 = PERIOD_NAME
               -- p_key_value2 = PERIOD_SET_NAME
               IF p_key_value2 = 'Std Accounting'
               THEN
                  ln_count := 1;
               END IF;
            ELSIF P_TABLE_NAME IN ('RA_ACCOUNT_DEFAULT_SEGMENTS', --Added by Aditya R on 12-Jun-25 CRQ CHG0243331
                                   'FND_FLEX_VALUES_TL',
                                   'FND_FLEX_VALUES',
                                   'AP_BANK_BRANCHES')
            THEN
               ln_count := 1;
            ELSE
               ln_count := 1;
               l_status_message :=
                  P_TABLE_NAME || ' TABLE NOT FOUND IN PACKAGE CODE.';
            END IF;
         --            ELSE
         --               l_status_message :=
         --                     l_status_message
         --                  || (   'new values and old values are same'
         --                      || ' l count is '
         --                      || ln_count);
         --            END IF;
         --         ELSE
         --            l_status_message :=
         --               ('no change in In-scope column values hence ignoring the record');
         END IF;
      ELSE
         LN_COUNT := 0;
         l_status_message :=
            (   'Record is updated by Concurrent program or interface p_prog_val = '
             || p_prog_val);
      END IF;

      --P_COUNT_VAL := LN_COUNT;

      IF (ln_count > 0 AND L_STATUS_MESSAGE IS NULL) --p_event != 'DELETE') -- Greater than 0 indicates that data is related to India Ledgers/Operating Units
      THEN
         --p_count_val := ln_count;
         --ln_cp_upd_ind := get_cp_count (p_prog_val);

         --         IF ln_cp_upd_ind > 0 -- Greater than 0 indicates that data was updated by concurrent program.
         --         THEN
         --            p_count_val := 0;
         --            l_status_message :=
         --               (   'Record is updated by Concurrent program p_prog_val = '
         --                || p_prog_val);
         --         ELSE
         --  ln_superuser_access_ind := get_su_update_count(p_client_id);

         --   IF ln_superuser_access_ind > 0 -- Update is from Diagnostic Menu
         --  THEN
         --     p_count_val := 1;
         --     l_status_message := 'Record is eligible and will get captured in GG';
         -- ELSE
         --      l_status_message := ( 'User is not a super user CLIEND_ID = '|| p_client_id );
         -- END IF;
         l_status_message := ('RECORD IS ELIGIBLE WILL GET CAPTURED IN GG');
      --END IF;
      ELSIF (ln_count = 0 AND l_status_message IS NULL)
      --         IF l_status_message IS NULL
      THEN
         l_status_message :=
            'UNPOSTED TRANSACTION OR RECORD IS NOT INDIA SPECIFIC';
      --END IF;
      END IF;

      xxcctt_insert_debug_log (p_table_name,
                               lc_key_value,
                               ln_count,
                               -- lc_old_val,
                               -- lc_new_val,
                               l_status_message);
      -- Initialize lists heres.
      -- BEGIN
      --   SELECT concurrent_program_name BULK COLLECT INTO g_program_list FROM fnd_concurrent_programs;
      --   SELECT concurrent_queue_name BULK COLLECT INTO g_queue_list FROM fnd_concurrent_queues;
      -- SELECT name BULK COLLECT INTO g_ou_list FROM APPS.HR_OPERATING_UNITS WHERE set_of_books_id = 3043;
      -- END;
      P_COUNT_VAL := LN_COUNT;
   EXCEPTION
      WHEN OTHERS
      THEN
         --p_count_val := 0;
         ln_count := 0;
         p_count_val := ln_count;
         -- p_err_msg   :='Error encountered for '||P_TABLE_NAME||' AND P_KEY_VALUE1,P_KEY_VALUE2,P_KEY_VALUE3 are '||P_KEY_VALUE1||' '||P_KEY_VALUE2||' '||P_KEY_VALUE3||' resptly -->'||SQLERRM;
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
         l_status_message :=
            (   'Error occured '
             || DBMS_UTILITY.format_error_backtrace
             || 'And  Error says -->'
             || SQLERRM);

         xxcctt_insert_debug_log (p_table_name,
                                  lc_key_value,
                                  ln_count,
                                  -- lc_old_val,
                                  -- lc_new_val,
                                  l_status_message);
   END xxcctt_gg_filter_condition_prc;
END xxcctt_gg_filter_condition_pkg;
/
