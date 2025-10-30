CREATE OR REPLACE PACKAGE BODY APPS.ADOR_COST_MIGRATION_PKG
AS
    PROCEDURE ADOR_STAGE_DATA_VALIDATION_PRC (p_organization_id NUMBER)
    AS
        v_error_flag          VARCHAR2 (1);
        v_error_message       VARCHAR2 (240);
        V_CHECK               NUMBER;
        V_INVENTORY_ITEM_ID   NUMBER;
        V_ITEM_COST           NUMBER;

        CURSOR C1 IS
            SELECT *
              FROM CUS.ADOR_COST_MIGRATION_STG
             WHERE ORGANIZATION_ID = p_organization_id;

        CURSOR C2 IS
            SELECT *
              FROM CUS.ADOR_COST_MIGRATION_STG
             WHERE     ORGANIZATION_ID = p_organization_id
                   AND ERROR_CODE IS NULL
                   AND ERROR_MSG IS NULL;
    BEGIN
        apps.fnd_file.put_line (apps.fnd_file.LOG,
                                'In Stage Table Validation');
        DBMS_OUTPUT.put_line ('In Stage Table Validation');

        apps.fnd_file.put_line (apps.fnd_file.LOG,
                                'Checking and Updating Inventory item id');

        FOR i IN C1
        LOOP
            v_error_flag := NULL;
            v_error_message := NULL;

            -- Checking if INVENTORY_ITEM_ID is present for given ORGANIZATION_ID

            BEGIN
                SELECT INVENTORY_ITEM_ID
                  INTO V_INVENTORY_ITEM_ID
                  FROM apps.mtl_system_items_kfv msik
                 WHERE     1 = 1
                       AND msik.organization_id = p_organization_id
                       AND i.ITEM_SEGMENT1 = msik.CONCATENATED_SEGMENTS;
            EXCEPTION
                WHEN OTHERS
                THEN
                    V_INVENTORY_ITEM_ID := NULL;
            END;

            IF V_INVENTORY_ITEM_ID IS NULL
            THEN
                DBMS_OUTPUT.put_line (
                    'ITEM IS NOT PRESENT FOR ' || p_organization_id);

                v_error_flag := 'Y';
                v_error_message := 'ITEM is NOT Present for org ';

                UPDATE CUS.ADOR_COST_MIGRATION_STG acms
                   SET ERROR_CODE = v_error_flag, ERROR_MSG = v_error_message
                 WHERE     acms.organization_id = p_organization_id
                       AND acms.ITEM_SEGMENT1 = i.ITEM_SEGMENT1;
            ELSE
                UPDATE CUS.ADOR_COST_MIGRATION_STG acms
                   SET INVENTORY_ITEM_ID = V_INVENTORY_ITEM_ID
                 WHERE     acms.organization_id = p_organization_id
                       AND acms.ITEM_SEGMENT1 = i.ITEM_SEGMENT1;
            END IF;
        END LOOP;


        COMMIT;

        -- Check the UOM for the rows which have INVENTORY_ITEM_ID
        apps.fnd_file.put_line (
            apps.fnd_file.LOG,
            'Inventory Item ID updated for items, checking UOM');
        DBMS_OUTPUT.put_line (
            'Inventory Item ID updated for items, checking UOM');

        FOR i IN C2
        LOOP
            v_error_flag := NULL;
            v_error_message := NULL;
            V_CHECK := NULL;

            --Checking the item cost > 0 or not
            BEGIN
                SELECT ITEM_COST
                  INTO V_ITEM_COST
                  FROM cst_item_costs
                 WHERE     INVENTORY_ITEM_ID = i.Inventory_item_id
                       AND ORGANIZATION_ID = i.organization_id;
            EXCEPTION
                WHEN OTHERS
                THEN
                    V_ITEM_COST := 0;
            END;

            IF (V_ITEM_COST = 0 OR V_ITEM_COST IS NULL)
            THEN
                -- Checking if the UOM is matching.
                BEGIN
                    SELECT 1
                      INTO V_CHECK
                      FROM APPS.MTL_SYSTEM_ITEMS_KFV MSIK
                     WHERE     1 = 1
                           AND i.PRIMARY_UOM_CODE = MSIK.PRIMARY_UOM_CODE
                           AND MSIK.ORGANIZATION_ID = p_organization_id
                           AND MSIK.INVENTORY_ITEM_ID = i.INVENTORY_ITEM_ID
                           AND i.ITEM_SEGMENT1 = msik.CONCATENATED_SEGMENTS;
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        V_CHECK := NULL;
                END;

                IF V_CHECK IS NULL
                THEN
                    v_error_flag := 'Y';
                    v_error_message := 'UOM Mismatched ';
                --Updating current row
					UPDATE CUS.ADOR_COST_MIGRATION_STG acms
					SET ERROR_CODE = v_error_flag, ERROR_MSG = v_error_message
					WHERE     acms.organization_id = p_organization_id
                       AND acms.ITEM_SEGMENT1 = i.ITEM_SEGMENT1
                       AND acms.INVENTORY_ITEM_ID = i.INVENTORY_ITEM_ID;
                END IF;

			ELSE
                v_error_flag := 'Y';
                v_error_message := 'Item Cost is present.';
 
                DBMS_OUTPUT.PUT_LINE (
                    'item cost is present for ' || i.Inventory_item_id);
					
                --Updating current row for error msg of item present
                UPDATE CUS.ADOR_COST_MIGRATION_STG ACMS
                   SET ERROR_CODE = v_error_flag,
                       ERROR_MSG = v_error_message
                 WHERE     acms.ITEM_SEGMENT1 = i.ITEM_SEGMENT1
                       AND ACMS.organization_id = P_ORGANIZATION_ID
                       AND ACMS.inventory_item_id = i.inventory_item_id;
            END IF;
        END LOOP;

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

PROCEDURE ADOR_COST_MMT_INTERFACE (errbuf          OUT VARCHAR2,
                                  retcode         OUT VARCHAR2,
                                  P_ORG_CODE   IN     VARCHAR2)
AS
    ln_next_val                     NUMBER := 0;
    ln_transaction_action_id        NUMBER := 0;
    ln_transaction_source_type_id   NUMBER := 0;
    ln_transaction_type_id          NUMBER := 0;
    ln_material_account             NUMBER := 0;
    ln_material_overhead_account    NUMBER := 0;
    ln_resource_account             NUMBER := 0;
    ln_outside_processing_account   NUMBER := 0;
    ln_overhead_account             NUMBER := 0;
    ln_cost_group_id                NUMBER := 0;
    v_organization_id               NUMBER;

    CURSOR cur1 IS
        SELECT inventory_item_id,
               organization_id,
               ITEM_SEGMENT1,
               material_cost,
               material_overhead_cost,
               resource_cost,
               outside_processing_cost,
               overhead_cost,
               PRIMARY_UOM_CODE,
               SOURCE_CODE,
               TRANSACTION_REFERENCE
          FROM CUS.ADOR_COST_MIGRATION_STG
         WHERE     ORGANIZATION_CODE = P_ORG_CODE
               AND ERROR_CODE IS NULL
               AND ERROR_MSG IS NULL;
BEGIN
    BEGIN
        SELECT ORGANIZATION_ID
          INTO v_organization_id
          FROM ORG_ORGANIZATION_DEFINITIONS
         WHERE ORGANIZATION_CODE = P_ORG_CODE;
    EXCEPTION
        WHEN OTHERS
        THEN
            APPS.FND_FILE.PUT_LINE (FND_FILE.LOG,
                                    'Error while fetching organization id');
            DBMS_OUTPUT.put_line ('Error while fetching organization id');
    END;

    --Checking if organization is defined
    IF (v_organization_id IS NOT NULL)
    THEN
        APPS.FND_FILE.PUT_LINE (FND_FILE.LOG,
                                'Updating organization id in Staging table');
        DBMS_OUTPUT.put_line ('Updating organization id in Staging table');

        --Update the organization_id in the staging table
        UPDATE CUS.ADOR_COST_MIGRATION_STG
           SET ORGANIZATION_ID = v_organization_id
         WHERE ORGANIZATION_CODE = P_ORG_CODE;

        COMMIT;

        --Calling the Procedure to check the validations
        APPS.FND_FILE.PUT_LINE (FND_FILE.LOG,
                                'Calling the Validation check procedure');
        DBMS_OUTPUT.put_line ('Calling the Validation check procedure');

        APPS.ADOR_COST_MIGRATION_PKG.ADOR_STAGE_DATA_VALIDATION_PRC (
            v_organization_id);

        APPS.FND_FILE.PUT_LINE (FND_FILE.LOG,
                                'Validation procedure completed');
        DBMS_OUTPUT.put_line ('Validation procedure completed');

        BEGIN
            SELECT TRANSACTION_TYPE_ID,
                   TRANSACTION_ACTION_ID,
                   TRANSACTION_SOURCE_TYPE_ID
              INTO ln_transaction_type_id,
                   ln_transaction_action_id,
                   ln_transaction_source_type_id
              FROM APPS.MTL_TRANSACTION_TYPES
             WHERE TRANSACTION_TYPE_NAME = 'Average cost update';

            SELECT MATERIAL_ACCOUNT,
                   MATERIAL_OVERHEAD_ACCOUNT,
                   RESOURCE_ACCOUNT,
                   OUTSIDE_PROCESSING_ACCOUNT,
                   OVERHEAD_ACCOUNT,
                   default_COST_GROUP_ID
              INTO ln_material_account,
                   ln_material_overhead_account,
                   ln_resource_account,
                   ln_outside_processing_account,
                   ln_overhead_account,
                   ln_cost_group_id
              FROM APPS.mtl_parameters
             WHERE organization_id = v_organization_id;
        EXCEPTION
            WHEN OTHERS
            THEN
                NULL;
        END;

        --Inserting lines in the interface for the material cost

        APPS.FND_FILE.PUT_LINE (FND_FILE.LOG, 'Adding the material Cost');
        DBMS_OUTPUT.put_line ('Adding the material Cost');

        FOR mat_rec_cur1 IN cur1
        LOOP
            IF mat_rec_cur1.material_cost IS NOT NULL
            THEN
                BEGIN
                    SELECT mtl_material_transactions_s.NEXTVAL
                      INTO ln_next_val
                      FROM DUAL;

                    INSERT INTO inv.MTL_TRANSACTIONS_INTERFACE (
                                    transaction_interface_id,
                                    transaction_header_id,
                                    source_code,
                                    source_line_id,
                                    source_header_id,
                                    process_flag,
                                    transaction_mode,
                                    last_update_date,
                                    last_updated_by,
                                    creation_date,
                                    created_by,
                                    inventory_item_id,
                                    organization_id,
                                    transaction_date,
                                    transaction_source_id,
                                    TRANSACTION_ACTION_ID,
                                    TRANSACTION_SOURCE_TYPE_ID,
                                    TRANSACTION_TYPE_ID,
                                    MATERIAL_ACCOUNT,
                                    MATERIAL_OVERHEAD_ACCOUNT,
                                    RESOURCE_ACCOUNT,
                                    OUTSIDE_PROCESSING_ACCOUNT,
                                    OVERHEAD_ACCOUNT,
                                    COST_GROUP_ID,
                                    new_average_cost,
                                    transaction_quantity,
                                    transaction_UOM,
                                    TRANSACTION_REFERENCE)
                         VALUES (ln_next_val,
                                 ln_next_val + 1,
                                 'Inventory', --Need to add different value before executing the program
                                 '1',
                                 '1',
                                 '1',
                                 '3',
                                 SYSDATE,                           --Run date
                                 apps.fnd_global.user_id,            --user_id
                                 SYSDATE,                           --Run date
                                 apps.fnd_global.user_id,            --user_id
                                 mat_rec_cur1.inventory_item_id, --Inventory Item Id
                                 v_organization_id,          --Organization Id
                                 SYSDATE,                     --batch_run_date
                                 NULL,               --distribution acct alias
                                 ln_transaction_action_id,
                                 ln_transaction_source_type_id,
                                 ln_transaction_type_id,
                                 ln_material_account,
                                 ln_material_overhead_account,
                                 ln_resource_account,
                                 ln_outside_processing_account,
                                 ln_overhead_account,
                                 ln_cost_group_id,
                                 mat_rec_cur1.material_cost,    --new avg cost
                                 0,                                 --Quantity
                                 mat_rec_cur1.primary_uom_code,          --UOM
                                 mat_rec_cur1.TRANSACTION_REFERENCE);

                    INSERT INTO inv.MTL_TXN_COST_DET_INTERFACE (
                                    transaction_interface_id,
                                    last_update_date,
                                    last_updated_by,
                                    creation_date,
                                    created_by,
                                    organization_id,
                                    level_type,
                                    new_average_cost,
                                    cost_element_id)
                         VALUES (ln_next_val,
                                 SYSDATE,                           --Run date
                                 apps.fnd_global.user_id,            --user_id
                                 SYSDATE,                           --Run date
                                 apps.fnd_global.user_id,            --user_id
                                 v_organization_id,          --Organization Id
                                 1,                               --Level Type
                                 mat_rec_cur1.material_cost,    --new avg cost
                                 1                           --Cost element Id
                                  );
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        DBMS_OUTPUT.put_line (
                            'In mat insert exception ' || SQLERRM);
                END;
            END IF;
        END LOOP;

        COMMIT;
        --Inserting lines in the interface for the material overhead cost

        APPS.FND_FILE.PUT_LINE (FND_FILE.LOG,
                                'Adding the Material Overhead Cost');
        DBMS_OUTPUT.put_line ('Adding the Material Overhead Cost');

        FOR moh_rec_cur1 IN cur1
        LOOP
            IF moh_rec_cur1.material_overhead_cost IS NOT NULL
            THEN
                BEGIN
                    SELECT mtl_material_transactions_s.NEXTVAL
                      INTO ln_next_val
                      FROM DUAL;

                    INSERT INTO inv.MTL_TRANSACTIONS_INTERFACE (
                                    transaction_interface_id,
                                    transaction_header_id,
                                    source_code,
                                    source_line_id,
                                    source_header_id,
                                    process_flag,
                                    transaction_mode,
                                    last_update_date,
                                    last_updated_by,
                                    creation_date,
                                    created_by,
                                    inventory_item_id,
                                    organization_id,
                                    transaction_date,
                                    transaction_source_id,
                                    transaction_action_id,
                                    transaction_source_type_id,
                                    transaction_type_id,
                                    material_account,
                                    MATERIAL_OVERHEAD_ACCOUNT,
                                    RESOURCE_ACCOUNT,
                                    OUTSIDE_PROCESSING_ACCOUNT,
                                    OVERHEAD_ACCOUNT,
                                    cost_group_id,
                                    new_average_cost,
                                    transaction_quantity,
                                    transaction_UOM,
                                    TRANSACTION_REFERENCE)
                         VALUES (ln_next_val,
                                 ln_next_val + 1,
                                 'Inventory', --Need to add different value before executing the program
                                 '1',
                                 '1',
                                 '1',
                                 '3',
                                 SYSDATE,                           --Run date
                                 apps.fnd_global.user_id,            --user_id
                                 SYSDATE,                           --Run date
                                 apps.fnd_global.user_id,            --user_id
                                 moh_rec_cur1.inventory_item_id, --Inventory Item Id
                                 v_organization_id,          --Organization Id
                                 SYSDATE,                     --batch_run_date
                                 NULL,               --distribution acct alias
                                 ln_transaction_action_id,
                                 ln_transaction_source_type_id,
                                 ln_transaction_type_id,
                                 ln_material_account,
                                 ln_material_overhead_account,
                                 ln_resource_account,
                                 ln_outside_processing_account,
                                 ln_overhead_account,
                                 ln_cost_group_id,
                                 moh_rec_cur1.material_overhead_cost, --new avg cost
                                 0,                                 --Quantity
                                 moh_rec_cur1.primary_uom_code,          --UOM
                                 moh_rec_cur1.TRANSACTION_REFERENCE);

                    INSERT INTO inv.MTL_TXN_COST_DET_INTERFACE (
                                    transaction_interface_id,
                                    last_update_date,
                                    last_updated_by,
                                    creation_date,
                                    created_by,
                                    organization_id,
                                    level_type,
                                    new_average_cost,
                                    cost_element_id)
                         VALUES (ln_next_val,
                                 SYSDATE,                           --Run date
                                 apps.fnd_global.user_id,            --user_id
                                 SYSDATE,                           --Run date
                                 apps.fnd_global.user_id,            --user_id
                                 v_organization_id,          --Organization Id
                                 1,                               --Level Type
                                 moh_rec_cur1.material_overhead_cost, --new avg cost
                                 2                           --Cost element Id
                                  );
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        DBMS_OUTPUT.put_line (
                            'In moh insert exception ' || SQLERRM);
                END;
            END IF;
        END LOOP;

        COMMIT;
        --Inserting lines in the interface for the Outside Processing Cost

        APPS.FND_FILE.PUT_LINE (FND_FILE.LOG,
                                'Adding the Outside Processing Cost');
        DBMS_OUTPUT.put_line ('Adding the Outside Processing Cost');


        FOR osp_rec_cur1 IN cur1
        LOOP
            IF osp_rec_cur1.OUTSIDE_PROCESSING_COST IS NOT NULL
            THEN
                BEGIN
                    SELECT mtl_material_transactions_s.NEXTVAL
                      INTO ln_next_val
                      FROM DUAL;

                    INSERT INTO inv.MTL_TRANSACTIONS_INTERFACE (
                                    transaction_interface_id,
                                    transaction_header_id,
                                    source_code,
                                    source_line_id,
                                    source_header_id,
                                    process_flag,
                                    transaction_mode,
                                    last_update_date,
                                    last_updated_by,
                                    creation_date,
                                    created_by,
                                    inventory_item_id,
                                    organization_id,
                                    transaction_date,
                                    transaction_source_id,
                                    transaction_action_id,
                                    transaction_source_type_id,
                                    transaction_type_id,
                                    material_account,
                                    MATERIAL_OVERHEAD_ACCOUNT,
                                    RESOURCE_ACCOUNT,
                                    OUTSIDE_PROCESSING_ACCOUNT,
                                    OVERHEAD_ACCOUNT,
                                    cost_group_id,
                                    new_average_cost,
                                    transaction_quantity,
                                    transaction_UOM,
                                    TRANSACTION_REFERENCE)
                         VALUES (ln_next_val,
                                 ln_next_val + 1,
                                 'Inventory', --Need to add different value before executing the program
                                 '1',
                                 '1',
                                 '1',
                                 '3',
                                 SYSDATE,                           --Run date
                                 apps.fnd_global.user_id,            --user_id
                                 SYSDATE,                           --Run date
                                 apps.fnd_global.user_id,            --user_id
                                 osp_rec_cur1.inventory_item_id, --Inventory Item Id
                                 v_organization_id,          --Organization Id
                                 SYSDATE,                     --batch_run_date
                                 NULL,               --distribution acct alias
                                 ln_transaction_action_id,
                                 ln_transaction_source_type_id,
                                 ln_transaction_type_id,
                                 ln_material_account,
                                 ln_material_overhead_account,
                                 ln_resource_account,
                                 ln_outside_processing_account,
                                 ln_overhead_account,
                                 ln_cost_group_id,
                                 osp_rec_cur1.outside_processing_cost, --new avg cost
                                 0,                                 --Quantity
                                 osp_rec_cur1.primary_uom_code,          --UOM
                                 osp_rec_cur1.TRANSACTION_REFERENCE);

                    INSERT INTO inv.MTL_TXN_COST_DET_INTERFACE (
                                    transaction_interface_id,
                                    last_update_date,
                                    last_updated_by,
                                    creation_date,
                                    created_by,
                                    organization_id,
                                    level_type,
                                    new_average_cost,
                                    cost_element_id)
                         VALUES (ln_next_val,
                                 SYSDATE,                           --Run date
                                 apps.fnd_global.user_id,            --user_id
                                 SYSDATE,                           --Run date
                                 apps.fnd_global.user_id,            --user_id
                                 v_organization_id,          --Organization Id
                                 1,                               --Level Type
                                 osp_rec_cur1.outside_processing_cost, --new avg cost
                                 4                           --Cost element Id
                                  );
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        DBMS_OUTPUT.put_line (
                            'In osp insert exception ' || SQLERRM);
                END;
            END IF;
        END LOOP;

        COMMIT;
        --Inserting lines in the interface for the Resource Cost

        APPS.FND_FILE.PUT_LINE (FND_FILE.LOG, 'Adding the Resource Cost');
        DBMS_OUTPUT.put_line ('Adding the Resource Cost');

        FOR res_rec_cur1 IN cur1
        LOOP
            IF res_rec_cur1.resource_cost IS NOT NULL
            THEN
                BEGIN
                    SELECT mtl_material_transactions_s.NEXTVAL
                      INTO ln_next_val
                      FROM DUAL;

                    INSERT INTO inv.MTL_TRANSACTIONS_INTERFACE (
                                    transaction_interface_id,
                                    transaction_header_id,
                                    source_code,
                                    source_line_id,
                                    source_header_id,
                                    process_flag,
                                    transaction_mode,
                                    last_update_date,
                                    last_updated_by,
                                    creation_date,
                                    created_by,
                                    inventory_item_id,
                                    organization_id,
                                    transaction_date,
                                    transaction_source_id,
                                    transaction_action_id,
                                    transaction_source_type_id,
                                    transaction_type_id,
                                    material_account,
                                    MATERIAL_OVERHEAD_ACCOUNT,
                                    RESOURCE_ACCOUNT,
                                    OUTSIDE_PROCESSING_ACCOUNT,
                                    OVERHEAD_ACCOUNT,
                                    cost_group_id,
                                    new_average_cost,
                                    transaction_quantity,
                                    transaction_UOM,
                                    TRANSACTION_REFERENCE)
                         VALUES (ln_next_val,
                                 ln_next_val + 1,
                                 'Inventory', --Need to add different value before executing the program
                                 '1',
                                 '1',
                                 '1',
                                 '3',
                                 SYSDATE,                           --Run date
                                 apps.fnd_global.user_id,            --user_id
                                 SYSDATE,                           --Run date
                                 apps.fnd_global.user_id,            --user_id
                                 res_rec_cur1.inventory_item_id, --Inventory Item Id
                                 v_organization_id,          --Organization Id
                                 SYSDATE,                     --batch_run_date
                                 NULL,               --distribution acct alias
                                 ln_transaction_action_id,
                                 ln_transaction_source_type_id,
                                 ln_transaction_type_id,
                                 ln_material_account,
                                 ln_material_overhead_account,
                                 ln_resource_account,
                                 ln_outside_processing_account,
                                 ln_overhead_account,
                                 ln_cost_group_id,
                                 res_rec_cur1.resource_cost,    --new avg cost
                                 0,                                 --Quantity
                                 res_rec_cur1.primary_uom_code,          --UOM
                                 res_rec_cur1.TRANSACTION_REFERENCE);

                    INSERT INTO inv.MTL_TXN_COST_DET_INTERFACE (
                                    transaction_interface_id,
                                    last_update_date,
                                    last_updated_by,
                                    creation_date,
                                    created_by,
                                    organization_id,
                                    level_type,
                                    new_average_cost,
                                    cost_element_id)
                         VALUES (ln_next_val,
                                 SYSDATE,                           --Run date
                                 apps.fnd_global.user_id,            --user_id
                                 SYSDATE,                           --Run date
                                 apps.fnd_global.user_id,            --user_id
                                 v_organization_id,          --Organization Id
                                 1,                               --Level Type
                                 res_rec_cur1.resource_cost,    --new avg cost
                                 3                           --Cost element Id
                                  );
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        DBMS_OUTPUT.put_line (
                            'In res insert exception ' || SQLERRM);
                END;
            END IF;
        END LOOP;

        COMMIT;
        --Inserting lines in the interface for the Overhead Cost
        APPS.FND_FILE.PUT_LINE (FND_FILE.LOG, 'Adding the Overhead Cost');
        DBMS_OUTPUT.put_line ('Adding the Overhead Cost');

        FOR oh_rec_cur1 IN cur1
        LOOP
            IF oh_rec_cur1.overhead_cost IS NOT NULL
            THEN
                BEGIN
                    SELECT mtl_material_transactions_s.NEXTVAL
                      INTO ln_next_val
                      FROM DUAL;

                    INSERT INTO inv.MTL_TRANSACTIONS_INTERFACE (
                                    transaction_interface_id,
                                    transaction_header_id,
                                    source_code,
                                    source_line_id,
                                    source_header_id,
                                    process_flag,
                                    transaction_mode,
                                    last_update_date,
                                    last_updated_by,
                                    creation_date,
                                    created_by,
                                    inventory_item_id,
                                    organization_id,
                                    transaction_date,
                                    transaction_source_id,
                                    transaction_action_id,
                                    transaction_source_type_id,
                                    transaction_type_id,
                                    material_account,
                                    MATERIAL_OVERHEAD_ACCOUNT,
                                    RESOURCE_ACCOUNT,
                                    OUTSIDE_PROCESSING_ACCOUNT,
                                    OVERHEAD_ACCOUNT,
                                    cost_group_id,
                                    new_average_cost,
                                    transaction_quantity,
                                    transaction_UOM,
                                    TRANSACTION_REFERENCE)
                         VALUES (ln_next_val,
                                 ln_next_val + 1,
                                 'Inventory', --Need to add different value before executing the program
                                 '1',
                                 '1',
                                 '1',
                                 '3',
                                 SYSDATE,                           --Run date
                                 apps.fnd_global.user_id,            --user_id
                                 SYSDATE,                           --Run date
                                 apps.fnd_global.user_id,            --user_id
                                 oh_rec_cur1.inventory_item_id, --Inventory Item Id
                                 v_organization_id,          --Organization Id
                                 SYSDATE,                     --batch_run_date
                                 NULL,               --distribution acct alias
                                 ln_transaction_action_id,
                                 ln_transaction_source_type_id,
                                 ln_transaction_type_id,
                                 ln_material_account,
                                 ln_material_overhead_account,
                                 ln_resource_account,
                                 ln_outside_processing_account,
                                 ln_overhead_account,
                                 ln_cost_group_id,
                                 oh_rec_cur1.overhead_cost,     --new avg cost
                                 0,                                 --Quantity
                                 oh_rec_cur1.primary_uom_code,           --UOM
                                 oh_rec_cur1.TRANSACTION_REFERENCE);

                    INSERT INTO inv.MTL_TXN_COST_DET_INTERFACE (
                                    transaction_interface_id,
                                    last_update_date,
                                    last_updated_by,
                                    creation_date,
                                    created_by,
                                    organization_id,
                                    level_type,
                                    new_average_cost,
                                    cost_element_id)
                         VALUES (ln_next_val,
                                 SYSDATE,                           --Run date
                                 apps.fnd_global.user_id,            --user_id
                                 SYSDATE,                           --Run date
                                 apps.fnd_global.user_id,            --user_id
                                 v_organization_id,          --Organization Id
                                 1,                               --Level Type
                                 oh_rec_cur1.overhead_cost,     --new avg cost
                                 5                           --Cost element Id
                                  );
                EXCEPTION
                    WHEN OTHERS
                    THEN
                        DBMS_OUTPUT.put_line (
                            'In oh insert exception ' || SQLERRM);
                END;
            END IF;
        END LOOP;

        COMMIT;
        APPS.FND_FILE.PUT_LINE (FND_FILE.LOG, 'Adding in the backup table');
        DBMS_OUTPUT.put_line ('Adding in the backup table');

        INSERT INTO CUS.ADOR_INTERFACE_DATA
            SELECT *
              FROM MTL_TRANSACTIONS_INTERFACE
             WHERE     organization_id = v_organization_id
                   AND transaction_action_id = ln_transaction_action_id
                   AND transaction_source_type_id =
                       ln_transaction_source_type_id
                   AND transaction_type_id = ln_transaction_type_id;

        COMMIT;
    END IF;
END ADOR_COST_MMT_INTERFACE;

END ADOR_COST_MIGRATION_PKG;
/
