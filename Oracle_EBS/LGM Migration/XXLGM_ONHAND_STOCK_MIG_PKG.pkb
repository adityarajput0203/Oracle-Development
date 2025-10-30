CREATE OR REPLACE PACKAGE BODY APPS.XXLGM_ONHAND_STOCK_MIG_PKG
AS
   PROCEDURE XXLGM_ONHAND_STOCK_MIG_VAL_PRC (p_errbuf              OUT VARCHAR2,
                                             p_retcode             OUT NUMBER,
                                             p_organization_id       NUMBER)
   AS
      --Cursor to Fetch data from excel file directly for Validation.
      CURSOR C1
      IS
         SELECT *
           FROM ITC.XXLGM_STOCK_MIGRATION_STG_T
          WHERE ORGANIZATION_ID = P_ORGANIZATION_ID;

      CURSOR C2
      IS
         SELECT *
           FROM ITC.XXLGM_STOCK_MIGRATION_STG_T
          WHERE     ORGANIZATION_ID = p_organization_id
                AND ERROR_FLAG IS NULL
                AND ERROR_MSG IS NULL;

      V_ERROR_FLAG                   VARCHAR2(1);
      V_ERROR_MESSAGE                VARCHAR2(2000);
      V_ITEM_ID                      VARCHAR2(200);
      V_TRANSACTION_UOM              VARCHAR2(30);
      V_SUB_CODE                     VARCHAR2(30);
      V_ORGANIZATION_ID              NUMBER;
      V_INVENTORY_ITEM_ID            VARCHAR (240);
      
   BEGIN
      APPS.FND_FILE.PUT_LINE (APPS.FND_FILE.LOG, 'IN STAGE TABLE VALIDATION');

      BEGIN
         SELECT 1
           INTO V_ORGANIZATION_ID
           FROM ORG_ORGANIZATION_DEFINITIONS
          WHERE ORGANIZATION_ID = P_ORGANIZATION_ID;
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.PUT_LINE ('Organization not found  ' || P_ORGANIZATION_ID);
            fnd_file.put_line (fnd_file.output,
                               'Oraganization not found  ' || P_ORGANIZATION_ID);
      END;

      DBMS_OUTPUT.PUT_LINE ('V_ORGANIZAITON_ID ' || V_ORGANIZATION_ID);
        
      IF (V_ORGANIZATION_ID > 0)
      THEN
         FOR i IN C1
         LOOP
            DBMS_OUTPUT.PUT_LINE ('invneotry_item_id'||i.item_code);
            -- Checking if INVENTORY_ITEM_ID IS ATTACHED TO PROPER ORGANIZATION_ID
            SELECT INVENTORY_ITEM_ID
              INTO V_INVENTORY_ITEM_ID
              FROM apps.mtl_system_items_kfv msik
             WHERE     1 = 1
                   AND i.item_code = msik.CONCATENATED_SEGMENTS
                   AND msik.organization_id = p_organization_id;

            IF (V_INVENTORY_ITEM_ID IS NULL)
            THEN
               DBMS_OUTPUT.put_line (
                  'ITEM IS NOT PRESENT FOR ' || p_organization_id);

               v_error_flag := 'E';
               v_error_message := 'ITEM is NOT Present for org ';
            ELSE
                DBMS_OUTPUT.PUT_LINE ('updating custom table for inventory_item_id');
               UPDATE ITC.XXLGM_STOCK_MIGRATION_STG_T
                  SET INVENTORY_ITEM_ID = V_INVENTORY_ITEM_ID
                  WHERE ITEM_CODE = I.ITEM_CODE;
               COMMIT;
            END IF;
         END LOOP;

         FOR I IN C2
         LOOP
         
            --SETTING ERROR FLAG AS 'Y' IF ERROR ENCOUNTERED THEN IT WILL BECOME 'E'
            V_ERROR_FLAG := 'Y';
            
            DBMS_OUTPUT.PUT_LINE ('Inside cursor 2');
            DBMS_OUTPUT.PUT_LINE ('inventory_item_id' || I.INVENTORY_ITEM_ID);

            -- CHECKING IF INVENTORY_ITEM_ID IS PRESENT FOR IN INVENTORY

            SELECT INVENTORY_ITEM_ID
              INTO V_ITEM_ID
              FROM APPS.MTL_SYSTEM_ITEMS_KFV MSIK
             WHERE INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
             AND ORGANIZATION_ID = P_ORGANIZATION_ID;


            IF (V_ITEM_ID IS NULL)
            THEN
               DBMS_OUTPUT.put_line ('ITEM IS NOT PRESENT IN INVENTORY');

               V_ERROR_FLAG := 'E';
               V_ERROR_MESSAGE := 'ITEM IN NOT IN INVENOTRY';
            END IF;

            -- Checking if the UOM is matching.

            SELECT 1
              INTO V_TRANSACTION_UOM
              FROM APPS.MTL_SYSTEM_ITEMS_KFV MSIK
             WHERE     i.TRANSACTION_UOM = MSIK.PRIMARY_UOM_CODE
                   AND MSIK.ORGANIZATION_ID = p_organization_id
                   AND MSIK.INVENTORY_ITEM_ID = i.INVENTORY_ITEM_ID;

            IF (V_TRANSACTION_UOM != 1 OR V_TRANSACTION_UOM IS NULL)
            THEN
               v_error_flag := 'E';
               v_error_message := v_error_message || ' UOM Mismatched ';
            END IF;

            -- Updating serial_number_control_code in staging table.

            /*SELECT SERIAL_NUMBER_CONTROL_CODE
            INTO V_SERIAL_NUMBER_CONTROL_CODE
            FROM APPS.MTL_SYSTEM_ITEMS_KFV MSIK,
            APPS.ORG_ORGANIZATION_DEFINITIONS OOD
            WHERE OOD.ORGANIZATION_ID = MSIK.ORGANIZATION_ID
            AND MSIK.ORGANIZATION_ID = P_ORGANIZATION_ID
            AND MSIK.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID;*/


            --Checking if the item present under the subinventory

            SELECT 1
              INTO V_SUB_CODE
              FROM APPS.MTL_SECONDARY_INVENTORIES MSI
             WHERE     i.SUBINVENTORY_CODE = msi.SECONDARY_INVENTORY_NAME
                   AND i.organization_Id = msi.organization_Id;

            IF (V_SUB_CODE != 1 OR V_SUB_CODE IS NULL)
            THEN
               V_ERROR_FLAG := 'E';
               V_ERROR_MESSAGE :=
                     v_error_message
                  || ' Subinvenotry does not exist in system ';
            END IF;

            --Need to add these column in Table
            --1.error_flag,
            --2.error_message
            dbms_outpuT.put_line('updating custom table for errors: ');
            
            UPDATE ITC.XXLGM_STOCK_MIGRATION_STG_T
               SET --SERIAL_NUMBER_CONTROL_CODE= V_SERIAL_NUMBER_CONTROL_CODE,
                  ERROR_FLAG = v_error_flag, 
                  ERROR_MSG = v_error_message
                WHERE INVENTORY_ITEM_ID =I.INVENTORY_ITEM_ID
                AND ORGANIZATION_ID = P_ORGANIZATION_ID;
    END LOOP;
    END IF;
    EXCEPTION
      WHEN OTHERS
      THEN
        DBMS_OUTPUT.PUT_LINE('INSIDE EXCETPTION');
        ROLLBACK;
         p_errbuf :=
               '   Error in Proc XXLGM_ONHAND_STOCK_MIG_VAL '
            || '  '
            || SQLCODE
            || ' - '
            || SQLERRM
            || CHR (10);
         p_retcode := 2;

   END XXLGM_ONHAND_STOCK_MIG_VAL_PRC;

PROCEDURE XXLGM_ONHAND_STOCK_MIG_PRC (P_ERRBUF          OUT VARCHAR2,
                                      P_RETCODE         OUT VARCHAR2,
                                      P_ORG_CODE   IN     VARCHAR2,
                                      P_REASON     IN     VARCHAR2)
AS
   -- Cursor to fetch data from XXLGM_STOCK_MIGRATION_STG_T
   CURSOR C3
   IS
      SELECT XSMS.*, SERIAL_NUMBER_CONTROL_CODE, LOT_CONTROL_CODE
        FROM ITC.XXLGM_STOCK_MIGRATION_STG_T XSMS, APPS.MTL_SYSTEM_ITEMS_KFV MSIK
       WHERE     ORGANIZATION_CODE = P_ORG_CODE
             AND MSIK.ORGANIZATION_ID = XSMS.ORGANIZATION_ID
             AND MSIK.INVENTORY_ITEM_ID = XSMS.INVENTORY_ITEM_ID
             AND MSIK.CONCATENATED_SEGMENTS = XSMS.ITEM_CODE
             AND ERROR_FLAG = 'Y'
             AND ERROR_MSG IS NULL;

   V_TRANSACTION_ID               NUMBER;
   V_EXPIRATION_DATE              DATE;
   V_TRANSACTION_TYPE_ID          NUMBER;
   V_TRANSACTION_ACTION_ID        NUMBER;
   V_TRANSACTION_SOURCE_TYPE_ID   NUMBER;
   V_ORGANIZATION_ID               NUMBER;
   v_code_combination_id          VARCHAR2(155);
BEGIN
   BEGIN
      SELECT TRANSACTION_TYPE_ID,
             TRANSACTION_ACTION_ID,
             TRANSACTION_SOURCE_TYPE_ID
        INTO V_TRANSACTION_TYPE_ID,
             V_TRANSACTION_ACTION_ID,
             V_TRANSACTION_SOURCE_TYPE_ID
        FROM APPS.MTL_TRANSACTION_TYPES
       WHERE TRANSACTION_TYPE_NAME = 'Miscellaneous Recpt(RG Update)';
   END;
   
   BEGIN
   
   SELECT ORGANIZATION_ID
   INTO V_ORGANIZATION_ID
   FROM ORG_ORGANIZATION_DEFINITIONS
   WHERE ORGANIZATION_CODE = P_ORG_CODE;
   
   END;
   
   DBMS_OUTPUT.PUT_LINE('ORGANIZATION' || V_ORGANIZATION_ID);

   -- For non-serial and non-lot controlled items
   FOR NON_LS IN C3
   LOOP
--      IF    (NON_LS.SERIAL_NUMBER IS NULL AND NON_LS.LOT_NUMBER IS NULL)
--         OR NON_LS.SERIAL_NUMBER_CONTROL_CODE = 1
--         OR NON_LS.lot_control_code != 2
           if  ( NON_LS.SERIAL_NUMBER_CONTROL_CODE = 1)
      THEN
         BEGIN
            -- New transaction id for each row
            SELECT MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL
              INTO V_TRANSACTION_ID
              FROM DUAL;
              
              -- Code combination id to be added in interface
                            BEGIN
                                SELECT GCCK.CODE_COMBINATION_ID
                                  INTO v_code_combination_id
                                  FROM GL_CODE_COMBINATIONS_KFV GCCK
                                 WHERE GCCK.CONCATENATED_SEGMENTS =
                                       NON_LS.DISTRIBUTION_ACCOUNT_CODE;
                            EXCEPTION
                                WHEN OTHERS
                                THEN
                                    v_code_combination_id := NULL;
                            END;

            -- Inserting into mtl_transactions_interface
            INSERT
              INTO mtl_transactions_interface (source_code,
                                               source_header_id,
                                               source_line_id,
                                               process_flag,
                                               lock_flag,
                                               transaction_mode,
                                               last_update_date,
                                               last_updated_by,
                                               creation_date,
                                               created_by,
                                               organization_id,
                                               inventory_item_id,
                                               transaction_quantity,
                                               transaction_uom,
                                               transaction_date,
                                               transaction_type_id,
                                               transaction_action_id,
                                               transaction_source_type_id,
                                               distribution_account_id,
                                               transaction_interface_id,
                                               subinventory_code,
                                               dsp_segment1,
                                               dsp_segment2,
                                               dsp_segment3,
                                               dsp_segment4,
                                               dsp_segment5,
                                               transfer_organization,
                                               transfer_subinventory,
                                               locator_id)
            VALUES (P_REASON,
                    v_transaction_id,
                    v_transaction_id,
                    1,
                    2,
                    3,
                    SYSDATE,
                    999,
                    SYSDATE,
                    999,
                    non_ls.ORGANIZATION_ID,
                    non_ls.inventory_item_id,
                    non_ls.TRANSACTION_QUANTITY,
                    non_ls.transaction_uom,
                    SYSDATE,
                    V_TRANSACTION_TYPE_ID,
                    V_TRANSACTION_ACTION_ID,
                    V_TRANSACTION_SOURCE_TYPE_ID,
                    v_code_combination_id,
                    v_transaction_id,
                    non_ls.SUBINVENTORY_CODE,
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    non_ls.LOCATOR_ID);
         END;
      END IF;
   END LOOP;

   -- For Serial Controlled Items
   FOR SER IN C3
   LOOP
      IF (SER.SERIAL_NUMBER_CONTROL_CODE != 1) --(SER.SERIAL_NUMBER IS NOT NULL OR SER.SERIAL_NUMBER_CONTROL_CODE != 1)
      THEN
         BEGIN
            -- New transaction id for each row
            SELECT MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL
              INTO v_transaction_id
              FROM DUAL;
             
            -- Code combination id to be added in interface
                            BEGIN
                                SELECT GCCK.CODE_COMBINATION_ID
                                  INTO v_code_combination_id
                                  FROM GL_CODE_COMBINATIONS_KFV GCCK
                                 WHERE GCCK.CONCATENATED_SEGMENTS =
                                       SER.DISTRIBUTION_ACCOUNT_CODE;
                            EXCEPTION
                                WHEN OTHERS
                                THEN
                                    v_code_combination_id := NULL;
                            END;

            -- Inserting into mtl_transactions_interface
            INSERT
              INTO mtl_transactions_interface (source_code,
                                               source_header_id,
                                               source_line_id,
                                               process_flag,
                                               lock_flag,
                                               transaction_mode,
                                               last_update_date,
                                               last_updated_by,
                                               creation_date,
                                               created_by,
                                               organization_id,
                                               inventory_item_id,
                                               transaction_quantity,
                                               transaction_uom,
                                               transaction_date,
                                               transaction_type_id,
                                               transaction_action_id,
                                               transaction_source_type_id,
                                               distribution_account_id,
                                               transaction_interface_id,
                                               subinventory_code,
                                               dsp_segment1,
                                               dsp_segment2,
                                               dsp_segment3,
                                               dsp_segment4,
                                               dsp_segment5,
                                               transfer_organization,
                                               transfer_subinventory,
                                               locator_id)
            VALUES (P_REASON,
                    v_transaction_id,
                    v_transaction_id,
                    1,
                    2,
                    3,
                    SYSDATE,
                    999,
                    SYSDATE,
                    999,
                    SER.ORGANIZATION_ID,
                    SER.inventory_item_id,
                    SER.TRANSACTION_QUANTITY,
                    SER.transaction_uom,
                    SYSDATE,
                    V_TRANSACTION_TYPE_ID,
                    V_TRANSACTION_ACTION_ID,
                    V_TRANSACTION_SOURCE_TYPE_ID,
                    v_code_combination_id,
                    v_transaction_id,
                    SER.SUBINVENTORY_CODE,
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    SER.LOCATOR_ID);

            -- Insert into mtl_serial_numbers_interface
            INSERT
              INTO mtl_serial_numbers_interface (transaction_interface_id,
                                                 fm_serial_number,
                                                 to_serial_number,
                                                 last_update_date,
                                                 last_updated_by,
                                                 creation_date,
                                                 created_by,
                                                 source_code)
            VALUES (V_TRANSACTION_ID,
                    SER.SERIAL_NUMBER,
                    SER.SERIAL_NUMBER,
                    SYSDATE,
                    999,
                    SYSDATE,
                    999,
                    P_REASON);
         END;
      END IF;
   END LOOP;

   
   -- Commit all transactions
   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      ROLLBACK;
      P_ERRBUF := SQLERRM;
      P_RETCODE := 2;
      RAISE;
END XXLGM_ONHAND_STOCK_MIG_PRC;

END XXLGM_ONHAND_STOCK_MIG_PKG;
/
