CREATE OR REPLACE PACKAGE BODY APPS.ADOR_STOCK_TRANSFER_PKG
AS
    PROCEDURE ADOR_STAGE_DATA_VALIDATION_PRC (P_ORGANIZATION_ID NUMBER)
    AS
        CURSOR C1 IS
            SELECT *
              FROM CUS.ADOR_STOCK_MIGRATION_STG
             WHERE ORGANIZATION_ID = P_ORGANIZATION_ID;
             --AND ERR_CODE != 'N';

        CURSOR C2 IS
            SELECT *
              FROM CUS.ADOR_STOCK_MIGRATION_STG
             WHERE     ORGANIZATION_ID = p_organization_id
                   AND ERROR_CODE IS NULL
                   AND ERROR_MSG IS NULL;

        v_error_flag          VARCHAR2 (1);
        v_error_message       VARCHAR2 (240);
        V_CHECK               NUMBER;
        V_TRANSACTION_UOM     VARCHAR2 (3);
        V_INVENTORY_ITEM_ID   VARCHAR (240);
        V_ITEM_COST           NUMBER;
    BEGIN
        apps.fnd_file.put_line (apps.fnd_file.LOG,
                                'In Stage Table Validation');
                                
        DBMS_OUTPUT.put_line ('In Stage Table Validation');

        apps.fnd_file.put_line (apps.fnd_file.LOG, 
                        'Checking and Updating Inventory item id');
        
        FOR i IN C1
        LOOP
            DBMS_OUTPUT.put_line ('IN FIRST_LOOP');

            -- Checking if INVENTORY_ITEM_ID IS ATTACHED TO PROPER ORGANIZATION_ID
            SELECT INVENTORY_ITEM_ID
              INTO V_INVENTORY_ITEM_ID
              FROM mtl_system_items_kfv msik
             WHERE     1 = 1
                   AND i.item_code = msik.CONCATENATED_SEGMENTS
                   AND msik.organization_id = p_organization_id;

            DBMS_OUTPUT.put_line (
                   'V_INVENTORY_ITEM_ID '
                || V_INVENTORY_ITEM_ID
                || ' AND '
                || i.item_code);

            IF (V_INVENTORY_ITEM_ID IS NULL)
            THEN
                DBMS_OUTPUT.put_line (
                    'ITEM IS NOT PRESENT FOR ' || p_organization_id);

                v_error_flag := 'Y';
                v_error_message := 'ITEM is NOT Present for org ';

                UPDATE CUS.ADOR_STOCK_MIGRATION_STG ASMS
                   SET ERROR_CODE = v_error_flag, ERROR_MSG = v_error_message
                 WHERE     ASMS.organization_id = P_ORGANIZATION_ID
                       AND ASMS.ITEM_CODE = i.item_code;
            ELSE
                UPDATE CUS.ADOR_STOCK_MIGRATION_STG ASMS
                   SET INVENTORY_ITEM_ID = V_INVENTORY_ITEM_ID
                 WHERE     ASMS.ITEM_CODE = i.item_code
                       AND ASMS.organization_id = P_ORGANIZATION_ID;
            END IF;
        END LOOP;

        COMMIT;
        
        apps.fnd_file.put_line (apps.fnd_file.LOG, 'Inventory item id Updated in staging table');

        -- INVENTORY_ITEM_ID UPDATED NOW CHECKING FOR UOM,SERIAL_NUMBER_CONTROL_CODE, LOT_CONTROL_CODE, SUBINVENTORY
        
        apps.fnd_file.put_line (apps.fnd_file.LOG, 'Checking cost, uom, subinventory for item');

        FOR i IN C2
        LOOP
            v_error_flag := NULL;
            v_error_message := NULL;
            V_CHECK := NULL;
            V_ITEM_COST := NULL;

            BEGIN
                DBMS_OUTPUT.put_line (
                    'Inside the cost validation for ' || i.inventory_item_id);

                SELECT ITEM_COST
                  INTO V_ITEM_COST
                  FROM cst_item_costs
                 WHERE     INVENTORY_ITEM_ID = i.Inventory_item_id
                       AND ORGANIZATION_ID = P_ORGANIZATION_ID
                       AND COST_TYPE_ID = 2;

                DBMS_OUTPUT.PUT_LINE (
                       'ITEM COST FOR '
                    || i.Inventory_item_id
                    || ' is '
                    || v_item_cost);

                IF (V_ITEM_COST > 0)
                THEN
                    -- Checking if the UOM is matching.
                    BEGIN
                        SELECT 1
                          INTO V_CHECK
                          FROM MTL_SYSTEM_ITEMS_KFV MSIK
                         WHERE     i.TRANSACTION_UOM = MSIK.PRIMARY_UOM_CODE
                               AND MSIK.ORGANIZATION_ID = p_organization_id
                               AND MSIK.INVENTORY_ITEM_ID =
                                   i.INVENTORY_ITEM_ID
                               AND i.ITEM_CODE = MSIK.CONCATENATED_SEGMENTS;
                    EXCEPTION
                        WHEN OTHERS
                        THEN
                            V_CHECK := NULL;
                    END;

                    IF (V_CHECK IS NULL)
                    THEN
                        v_error_flag := 'Y';
                        v_error_message := 'UOM Mismatched ';
                    END IF;

                    --Checking if the item present under the subinventory
                    V_CHECK := NULL;

                    BEGIN
                        SELECT 1
                          INTO V_CHECK
                          FROM MTL_SECONDARY_INVENTORIES MSI
                         WHERE     i.SUBINVENTORY_CODE =
                                   msi.SECONDARY_INVENTORY_NAME
                               AND i.organization_Id = msi.organization_Id;
                    EXCEPTION
                        WHEN OTHERS
                        THEN
                            V_CHECK := NULL;
                    END;

                    IF V_CHECK = NULL
                    THEN
                        V_ERROR_FLAG := 'Y';
                        V_ERROR_MESSAGE :=
                               v_error_message
                            || ' subinvenotry does not exist in system ';
                    END IF;
                    
                    DBMS_OUTPUT.PUT_LINE('Before inserting in stagin for updation of errorcode to N');
                    DBMS_OUTPUT.PUT_LINE('flag : ' || v_error_flag || ' v_error_message ' || v_error_message );
                    
                    
                    IF (nvl(v_error_flag,'N') != 'Y' AND v_error_message IS NULL)
                    THEN
                    UPDATE CUS.ADOR_STOCK_MIGRATION_STG ASMS
                       SET ERROR_CODE = 'N',
                           ERROR_MSG = 'PROCESSED'
                     WHERE     ASMS.ITEM_CODE = i.ITEM_CODE
                           AND organization_id = P_ORGANIZATION_ID
                           AND inventory_item_id = i.inventory_item_id;
                    ELSE
                    --Updating current row
                    UPDATE CUS.ADOR_STOCK_MIGRATION_STG ASMS
                       SET ERROR_CODE = v_error_flag,
                           ERROR_MSG = v_error_message
                     WHERE     ASMS.ITEM_CODE = i.ITEM_CODE
                           AND organization_id = P_ORGANIZATION_ID
                           AND inventory_item_id = i.inventory_item_id;
                    END IF;
                ELSE
                    v_error_flag := 'Y';
                    v_error_message := 'ITEM Cost not present.';

                    DBMS_OUTPUT.PUT_LINE (
                        'item cost not present for : ' || i.Inventory_item_id);
                        
                    apps.fnd_file.put_line (apps.fnd_file.LOG, 
                        'item cost not present for : ' || i.Inventory_item_id);
                   
                    --Updating current row for error msg of item not present
                    UPDATE CUS.ADOR_STOCK_MIGRATION_STG ASMS
                       SET ERROR_CODE = v_error_flag,
                           ERROR_MSG = v_error_message
                     WHERE     ASMS.ITEM_CODE = i.ITEM_CODE
                           AND organization_id = P_ORGANIZATION_ID
                           AND inventory_item_id = i.inventory_item_id;
                   
                END IF;
            EXCEPTION
                WHEN OTHERS
                THEN
                    apps.fnd_file.put_line (
                        apps.fnd_file.LOG,
                           '   Error in Proc Validation in cursor C2 '
                        || SQLCODE
                        || ' - '
                        || SQLERRM
                        || CHR (10));
            END;
        END LOOP;
        
        apps.fnd_file.put_line (apps.fnd_file.LOG, 'Cost, Uom, Subinventory Checked and flags Updated.') ;

        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            apps.fnd_file.put_line (
                apps.fnd_file.LOG,
                   '   Error in Proc ADOR_STAGE_DATA_VALIDATION_PRC '
                || SQLCODE
                || ' - '
                || SQLERRM
                || CHR (10));
    END ADOR_STAGE_DATA_VALIDATION_PRC;

    PROCEDURE ADOR_NEW_STOCK_TRANSFER_PROC (ERRBUF          OUT VARCHAR2,
                                            RETCODE         OUT VARCHAR2,
                                            P_ORG_CODE   IN     VARCHAR2)
                                            --P_REASON     IN     VARCHAR2)
    AS
        -- Cursor to fetch data from ADOR_STOCK_MIGRATION_STG
        CURSOR C1 IS
            SELECT ASTS.*, SERIAL_NUMBER_CONTROL_CODE, lot_control_code
              FROM CUS.ADOR_STOCK_MIGRATION_STG  ASTS,
                   MTL_SYSTEM_ITEMS_KFV          MSIK
             WHERE     ORGANIZATION_CODE = P_ORG_CODE
                   AND MSIK.ORGANIZATION_ID = ASTS.ORGANIZATION_ID
                   AND MSIK.INVENTORY_ITEM_ID = ASTS.INVENTORY_ITEM_ID
                   AND MSIK.CONCATENATED_SEGMENTS = ASTS.ITEM_CODE
                   AND ERROR_CODE = 'N'
                   AND ERROR_MSG = 'PROCESSED';

        V_TRANSACTION_ID               NUMBER;
        V_EXPIRATION_DATE              DATE;
        V_TRANSACTION_TYPE_ID          NUMBER;
        V_TRANSACTION_ACTION_ID        NUMBER;
        V_TRANSACTION_SOURCE_TYPE_ID   NUMBER;
        V_CODE_COMBINATION_ID          VARCHAR2 (155);
        V_ORG_ID                       NUMBER;
        V_INVENTORY_LOCATOR_ID         Number;
        
    BEGIN
        -- Checking if organization exists
        
        DBMS_OUTPUT.PUT_LINE('Checking if organization exists for org code ' || P_ORG_CODE);
        apps.fnd_file.put_line (apps.fnd_file.LOG, 'Checking if organization exists for code ' || P_ORG_CODE );
        
        BEGIN
            SELECT ORGANIZATION_ID
              INTO V_ORG_ID
              FROM ORG_ORGANIZATION_DEFINITIONS
             WHERE ORGANIZATION_CODE = P_ORG_CODE;
        EXCEPTION
            WHEN OTHERS
            THEN
                APPS.FND_FILE.PUT_LINE (
                    FND_FILE.LOG,
                    'Error while fetching organization id');
        END;
        
        DBMS_OUTPUT.PUT_LINE('Organization for the: ' || P_ORG_CODE || ' is: ' || v_org_id );
        apps.fnd_file.put_line (apps.fnd_file.LOG,' Organization for the: ' || P_ORG_CODE || ' is: ' || v_org_id );
        apps.fnd_file.put_line (apps.fnd_file.LOG, ' Updating the oraganization id in staging table ');
        
        UPDATE CUS.ADOR_STOCK_MIGRATION_STG
           SET ORGANIZATION_ID = V_ORG_ID
         WHERE ORGANIZATION_CODE = P_ORG_CODE;
         
        COMMIT;

        DBMS_OUTPUT.put_line (
            'V_ORG_ID updated in staging table' || V_ORG_ID);
        
        apps.fnd_file.put_line (apps.fnd_file.LOG, ' Updated the oraganization id in staging table ');

        IF (V_ORG_ID IS NOT NULL)
        THEN
            DBMS_OUTPUT.put_line ('V_ORG_ID exists --> calling validation procedure');
            apps.fnd_file.put_line (apps.fnd_file.LOG,  V_ORG_ID  || ': exists --> calling validation procedure ' );

            -- Calling validation procedure
            ADOR_STAGE_DATA_VALIDATION_PRC (V_ORG_ID);

            DBMS_OUTPUT.put_line ('After validation procedure executed.');
            apps.fnd_file.put_line (apps.fnd_file.LOG, 'After validation procedure executed ' );

            BEGIN
                SELECT TRANSACTION_TYPE_ID,
                       TRANSACTION_ACTION_ID,
                       TRANSACTION_SOURCE_TYPE_ID
                  INTO V_TRANSACTION_TYPE_ID,
                       V_TRANSACTION_ACTION_ID,
                       V_TRANSACTION_SOURCE_TYPE_ID
                  FROM MTL_TRANSACTION_TYPES
                 WHERE TRANSACTION_TYPE_NAME =
                       'Miscellaneous Recpt(RG Update)';
            END;
            
            
            DBMS_OUTPUT.put_line ('Transaction Type Id: ' || V_TRANSACTION_TYPE_ID || ' Action_id :' || V_TRANSACTION_ACTION_ID || ' Source Type id : ' || V_TRANSACTION_SOURCE_TYPE_ID);
            apps.fnd_file.put_line (apps.fnd_file.LOG, 'Transaction Type Id: ' || V_TRANSACTION_TYPE_ID || ' Action_id :' || V_TRANSACTION_ACTION_ID || ' Source Type id : ' || V_TRANSACTION_SOURCE_TYPE_ID );
            
            apps.fnd_file.put_line (apps.fnd_file.LOG,' going inside non-serial and lot controlled items ');
            DBMS_OUTPUT.put_line ('Checking and inserting for Non-serial and Non-lot Controlled Items');
            
            -- For non-serial and non-lot controlled items
            FOR K IN C1
            LOOP
            
                v_inventory_locator_id :=NULL;
                v_code_combination_id := NULL;
                
                DBMS_OUTPUT.put_line(K.SERIAL_NUMBER_CONTROL_CODE || ' // '  ||K.lot_control_code );
                
                BEGIN
                    IF ( K.SERIAL_NUMBER_CONTROL_CODE = 1 AND K.lot_control_code = 1)
                    THEN
                        BEGIN
                            DBMS_OUTPUT.put_line (
                                'In non serial and lot controlled items');

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
                                       K.DISTRIBUTION_ACCOUNT_CODE;
                            EXCEPTION
                                WHEN OTHERS
                                THEN
                                    v_code_combination_id := NULL;
                            END;
                            
                            -- Fetching locator_id
                            BEGIN
                            SELECT INVENTORY_LOCATION_ID
                            into v_inventory_locator_id
                            FROM apps.MTL_ITEM_LOCATIONS_KFV
                                    WHERE  ORGANIZATION_ID = V_ORG_ID
                                    AND SUBINVENTORY_CODE = K.SUBINVENTORY_CODE
                                    AND CONCATENATED_SEGMENTS = K.LOCATOR_NAME;
                            EXCEPTION 
                            WHEN OTHERS
                            THEN 
                                DBMS_OUTPUT.put_line ('Locator id error. ' ||v_inventory_locator_id );
                            END;

                            -- Inserting into mtl_transactions_interface
                            INSERT INTO mtl_transactions_interface (
                                            source_code,
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
                                            locator_id,
                                            attribute5,
                                            TRANSACTION_REFERENCE)
                                 VALUES (K.SOURCE_CODE,
                                         v_transaction_id,
                                         v_transaction_id,
                                         1,
                                         2,
                                         3,
                                         SYSDATE,
                                         fnd_global.user_id,
                                         SYSDATE,
                                         fnd_global.user_id,
                                         K.ORGANIZATION_ID,
                                         K.inventory_item_id,
                                         K.TRANSACTION_QUANTITY,
                                         K.transaction_uom,
                                         TO_DATE('31-03-2025','DD-MM-YYYY'), --SYSDATE,
                                         V_TRANSACTION_TYPE_ID,
                                         V_TRANSACTION_ACTION_ID,
                                         V_TRANSACTION_SOURCE_TYPE_ID,
                                         v_code_combination_id, --code_combination_id in gl
                                         v_transaction_id,
                                         K.SUBINVENTORY_CODE,
                                         '',
                                         '',
                                         '',
                                         '',
                                         '',
                                         '',
                                         '',
                                         v_inventory_locator_id,
                                         k.attribute5,
                                         k.TRANSACTION_REFERENCE);
                        END;
                    END IF;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        DBMS_OUTPUT.put_line (
                            'In non-lot and non-serial insert exception ' || SQLERRM);
                        apps.fnd_file.put_line (apps.fnd_file.LOG, 
                            'In non-lot and non-serial insert exception ' || SQLERRM);
                END;
            END LOOP;
            
            apps.fnd_file.put_line (apps.fnd_file.LOG,' Checking and inserting for Serial  controlled items ');
            DBMS_OUTPUT.put_line ('Checking and inserting for Serial controlled items');
            
            -- For Serial Controlled Items
            FOR SER IN C1
            LOOP
                v_inventory_locator_id :=NULL;
                v_code_combination_id := NULL;
                BEGIN
                    IF (SER.SERIAL_NUMBER_CONTROL_CODE != 1)
                    THEN
                        BEGIN
                            DBMS_OUTPUT.put_line (
                                'In  serial controlled items');

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
                                    apps.fnd_file.put_line (apps.fnd_file.LOG, 
                                    'V_CODE_COMBINATION_ID ERROR (IN SERIAL CONTROL): ' ||v_inventory_locator_id  ||  ' ' || SQLERRM);
                            END;
                            
                            -- Fetching locator_id
                            BEGIN
                            SELECT INVENTORY_LOCATION_ID
                            into v_inventory_locator_id
                            FROM apps.MTL_ITEM_LOCATIONS_KFV
                                    WHERE  ORGANIZATION_ID = V_ORG_ID
                                    AND SUBINVENTORY_CODE = SER.SUBINVENTORY_CODE
                                    AND CONCATENATED_SEGMENTS = SER.LOCATOR_NAME;
                            EXCEPTION 
                            WHEN OTHERS
                            THEN 
                                DBMS_OUTPUT.put_line ('Locator id error. ' ||v_inventory_locator_id );
                                apps.fnd_file.put_line (apps.fnd_file.LOG, 'Locator id error ' ||v_inventory_locator_id);
                            END;

                            -- Inserting into mtl_transactions_interface
                            INSERT INTO mtl_transactions_interface (
                                            source_code,
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
                                            locator_id,
                                            attribute5,
                                            TRANSACTION_REFERENCE)
                                 VALUES (SER.SOURCE_CODE,
                                         v_transaction_id,
                                         v_transaction_id,
                                         1,
                                         2,
                                         3,
                                         SYSDATE,
                                         fnd_global.user_id,
                                         SYSDATE,
                                         fnd_global.user_id,
                                         SER.ORGANIZATION_ID,
                                         SER.inventory_item_id,
                                         SER.TRANSACTION_QUANTITY,
                                         SER.transaction_uom,
                                         TO_DATE('31-03-2025','DD-MM-YYYY'), --SYSDATE,
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
                                         v_inventory_locator_id,
                                         ser.attribute5,
                                         ser.TRANSACTION_REFERENCE);

                            -- Insert into mtl_serial_numbers_interface
                            INSERT INTO mtl_serial_numbers_interface (
                                            transaction_interface_id,
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
                                         fnd_global.user_id,
                                         SYSDATE,
                                         fnd_global.user_id,
                                         SER.SOURCE_CODE);
                        END;
                    END IF;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        DBMS_OUTPUT.put_line (
                            'In Serial items insert Exception ' || SQLERRM);
                        apps.fnd_file.put_line (apps.fnd_file.LOG,
                            'In Serial items insert Exception ' || SQLERRM);
                END;
            END LOOP;


            apps.fnd_file.put_line (apps.fnd_file.LOG,' Checking and inserting for lot controlled items ');
            DBMS_OUTPUT.put_line ('Checking and inserting for lot controlled items');
            
            -- For Lot Controlled Items
            FOR LOT IN C1
            LOOP
            
                v_inventory_locator_id :=NULL;
                v_code_combination_id:=NULL;
                
                BEGIN
                    IF (LOT.lot_control_code = 2)
                    THEN
                        BEGIN
                            DBMS_OUTPUT.put_line (
                                   'In  lot controlled item : '
                                || lot.locator_id);
                                
                            --apps.fnd_file.put_line (apps.fnd_file.LOG,' Inside lot controlled item ');

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
                                       LOT.DISTRIBUTION_ACCOUNT_CODE
                                    and ENABLED_FLAG = 'Y';
                            EXCEPTION
                                WHEN OTHERS
                                THEN
                                    --v_code_combination_id := NULL;
                                    DBMS_OUTPUT.put_line ('V_CODE_COMBNATION_ID error');
                                    APPS.FND_FILE.PUT_LINE (FND_FILE.LOG,
                                                            'V_CODE_COMBNATION_ID error' || SQLERRM);
                                    
                            END;
                            
                            -- Fetching locator_id
                            BEGIN
                            SELECT INVENTORY_LOCATION_ID
                            into v_inventory_locator_id
                            FROM apps.MTL_ITEM_LOCATIONS_KFV
                                    WHERE  ORGANIZATION_ID = V_ORG_ID
                                    AND SUBINVENTORY_CODE = LOT.SUBINVENTORY_CODE
                                    AND CONCATENATED_SEGMENTS = LOT.LOCATOR_NAME;
                            EXCEPTION 
                            WHEN OTHERS
                            THEN 
                                DBMS_OUTPUT.put_line ('Locator id error. ' ||v_inventory_locator_id || 'Locator Name:' || LOT.LOCATOR_NAME || ' Sub name : ' || LOT.SUBINVENTORY_CODE);
                                apps.fnd_file.put_line (apps.fnd_file.LOG, 'Locator Id Error ' || v_inventory_locator_id || 'Locator Name:' || LOT.LOCATOR_NAME || ' Sub name : ' || LOT.SUBINVENTORY_CODE);
                            END;
                            
                          --  DBMS_OUTPUT.put_line('locator id ' || v_inventory_locator_id);
                            

                            -- Insert into mtl_transactions_interface
                            INSERT INTO mtl_transactions_interface (
                                            source_code,
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
                                            locator_id,
                                            attribute5,
                                            TRANSACTION_REFERENCE)
                                 VALUES (LOT.SOURCE_CODE,
                                         V_TRANSACTION_ID,
                                         V_TRANSACTION_ID,
                                         1,
                                         2,
                                         3,
                                         SYSDATE,
                                         fnd_global.user_id,
                                         SYSDATE,
                                         fnd_global.user_id,
                                         LOT.ORGANIZATION_ID,
                                         LOT.INVENTORY_ITEM_ID,
                                         LOT.TRANSACTION_QUANTITY,
                                         LOT.TRANSACTION_UOM,
                                         TO_DATE('31-03-2025','DD-MM-YYYY'), --SYSDATE,
                                         V_TRANSACTION_TYPE_ID,
                                         V_TRANSACTION_ACTION_ID,
                                         V_TRANSACTION_SOURCE_TYPE_ID,
                                         V_CODE_COMBINATION_ID,
                                         V_TRANSACTION_ID,
                                         LOT.SUBINVENTORY_CODE,
                                         '',
                                         '',
                                         '',
                                         '',
                                         '',
                                         '',
                                         '',
                                         V_INVENTORY_LOCATOR_ID,
                                         LOT.attribute5,
                                         LOT.TRANSACTION_REFERENCE);

                            -- Fetch expiration date for lot-controlled items
--                            BEGIN
--                                SELECT (TO_DATE(LOT.LOT_CREATION_DATE) + SHELF_LIFE_DAYS)
--                                  INTO V_EXPIRATION_DATE
--                                  FROM MTL_SYSTEM_ITEMS_KFV
--                                 WHERE     LOT_CONTROL_CODE = 2
--                                       AND inventory_item_id =
--                                           LOT.inventory_item_id
--                                       AND ORGANIZATION_ID = V_ORG_ID;
--                            EXCEPTION
--                            WHEN OTHERS
--                            THEN
--                            APPS.FND_FILE.PUT_LINE (
--                                            FND_FILE.LOG, 'Error while fetching organization id');
--                            DBMS_OUTPUT.put_line (
--                            'In lot controlled insert exception ' || SQLERRM);
--                            END;

                            -- Insert into MTL_TRANSACTION_LOTS_INTERFACE
                            DBMS_OUTPUT.PUT_LINE('BEFORE INSERTING IN LOT' || LOT.LOT_NUMBER);
                            DBMS_OUTPUT.PUT_LINE('LOT CREATION DATE: ' || LOT.LOT_CREATION_DATE);
                            
                            INSERT INTO MTL_TRANSACTION_LOTS_INTERFACE (
                                            TRANSACTION_INTERFACE_ID,
                                            LOT_NUMBER,
                                           -- LOT_EXPIRATION_DATE,
                                            TRANSACTION_QUANTITY,
                                            SOURCE_CODE,
                                            last_update_date,
                                            last_updated_by,
                                            creation_date,
                                            ORIGINATION_DATE,
                                            created_by)
                                 VALUES (V_TRANSACTION_ID,
                                         LOT.LOT_NUMBER,
                                        -- V_EXPIRATION_DATE,
                                         LOT.TRANSACTION_QUANTITY,
                                         LOT.SOURCE_CODE,
                                         SYSDATE,
                                         fnd_global.user_id,
                                         sysdate,
                                         LOT.LOT_CREATION_DATE,
                                         fnd_global.user_id);
                        END;
                    END IF;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        DBMS_OUTPUT.put_line (
                            'In lot controlled insert exception ' || SQLERRM);
                        apps.fnd_file.put_line (apps.fnd_file.LOG, 'In Lot Controlled Insert Exception ' || SQLERRM);
                END;
            END LOOP;

            -- Commit all transactions
            COMMIT;
            
            apps.fnd_file.put_line (apps.fnd_file.LOG,'Inserted data in the interfaces.');
            
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;
            ERRBUF := SQLERRM;
            RETCODE := 2;
            RAISE;
    END ADOR_NEW_STOCK_TRANSFER_PROC;
END ADOR_STOCK_TRANSFER_PKG;
/
