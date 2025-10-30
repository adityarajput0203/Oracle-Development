CREATE OR REPLACE PROCEDURE APPS.ADOR_ORIGINAL_AGE_MIGRATION (
    ERRBUF    OUT VARCHAR2,
    ERRCODE   OUT VARCHAR2)
AS
    CURSOR CUR1 IS
        SELECT AOAS.*,
               MSIK.SHELF_LIFE_CODE,
               MSIK.LOT_CONTROL_CODE,
               MSIK.SHELF_LIFE_DAYS
          FROM CUS.ADOR_ORIGINAL_AGE_STG AOAS, MTL_SYSTEM_ITEMS_KFV MSIK
         WHERE     AOAS.ITEM_code = MSIK.CONCATENATED_SEGMENTS
               AND AOAS.ORGANIZATION_ID = MSIK.ORGANIZATION_ID;

    V_CNT        NUMBER;
    V_EXP_DATE   DATE;
BEGIN
    -- Block: Update Inventory Item IDs from master table
    DBMS_OUTPUT.PUT_LINE('Starting inventory_item_id update...');
    BEGIN
        UPDATE CUS.ADOR_ORIGINAL_AGE_STG AOAS
           SET INVENTORY_ITEM_ID =
                   (SELECT INVENTORY_ITEM_ID
                      FROM MTL_SYSTEM_ITEMS_KFV
                     WHERE     CONCATENATED_SEGMENTS = AOAS.ITEM_CODE
                           AND ORGANIZATION_ID = AOAS.ORGANIZATION_ID);
        DBMS_OUTPUT.PUT_LINE('inventory_item_id update completed.');
    EXCEPTION
        WHEN OTHERS THEN
            APPS.FND_FILE.PUT_LINE (
                FND_FILE.LOG,
                'Error while updating inventory_item_id: ' || SQLERRM);
            DBMS_OUTPUT.PUT_LINE('Error while updating inventory_item_id: ' || SQLERRM);
            ROLLBACK;
    END;

    -- Block: Count staging table records
    DBMS_OUTPUT.PUT_LINE('Counting records in staging table...');
    SELECT COUNT(*) INTO V_CNT FROM CUS.ADOR_ORIGINAL_AGE_STG;
    DBMS_OUTPUT.PUT_LINE('Total records in staging table: ' || V_CNT);

    IF V_CNT > 0 THEN
        -- Block: Process each record
        DBMS_OUTPUT.PUT_LINE('Starting record-by-record processing...');
        FOR C1 IN CUR1 LOOP

            -- Condition: Non-lot controlled, no shelf life
            IF (C1.SHELF_LIFE_CODE = 1 AND C1.LOT_CONTROL_CODE = 1) THEN
                DBMS_OUTPUT.PUT_LINE('Processing non-lot-controlled, no shelf life item: ' || C1.ITEM_CODE);
                
                UPDATE MTL_ONHAND_QUANTITIES_DETAIL MOQ
                   SET ORIG_DATE_RECEIVED =
                           (SELECT ORIGINAL_ORIG_DATE
                              FROM CUS.ADOR_ORIGINAL_AGE_STG AOAS
                             WHERE     AOAS.CREATE_TRANSACTION_ID = MOQ.ONHAND_QUANTITIES_ID
                                   AND AOAS.ORGANIZATION_ID = MOQ.ORGANIZATION_ID)
                 WHERE EXISTS (
                           SELECT 1
                             FROM CUS.ADOR_ORIGINAL_AGE_STG AOAS
                            WHERE     AOAS.CREATE_TRANSACTION_ID = MOQ.ONHAND_QUANTITIES_ID
                                  AND AOAS.ORGANIZATION_ID = MOQ.ORGANIZATION_ID);

            -- Condition: Lot controlled, no shelf life
            ELSIF C1.SHELF_LIFE_CODE = 1 AND C1.LOT_CONTROL_CODE = 2 THEN
                --DBMS_OUTPUT.PUT_LINE();
                DBMS_OUTPUT.PUT_LINE('Processing lot-controlled, no shelf life item: ' || C1.ITEM_CODE || ' Shelf_code:' ||C1.SHELF_LIFE_CODE
                 ||' lot_control_code : ' || C1.LOT_CONTROL_CODE );

                UPDATE MTL_ONHAND_QUANTITIES_DETAIL MOQ
                   SET ORIG_DATE_RECEIVED =
                           (SELECT ORIGINAL_ORIG_DATE
                              FROM CUS.ADOR_ORIGINAL_AGE_STG AOAS
                             WHERE     AOAS.CREATE_TRANSACTION_ID = MOQ.ONHAND_QUANTITIES_ID
                                   AND AOAS.ORGANIZATION_ID = MOQ.ORGANIZATION_ID)
                 WHERE EXISTS (
                           SELECT 1
                             FROM CUS.ADOR_ORIGINAL_AGE_STG AOAS
                            WHERE     AOAS.CREATE_TRANSACTION_ID = MOQ.ONHAND_QUANTITIES_ID
                                  AND AOAS.ORGANIZATION_ID = MOQ.ORGANIZATION_ID);

            -- Condition: Lot controlled and has shelf life
            ELSIF (C1.SHELF_LIFE_CODE = 2 AND C1.LOT_CONTROL_CODE = 2) THEN
                DBMS_OUTPUT.PUT_LINE('Processing lot-controlled with shelf life item: ' || C1.ITEM_CODE  || ' Shelf_code:' ||C1.SHELF_LIFE_CODE
                 ||' lot_control_code : ' || C1.LOT_CONTROL_CODE );

                V_EXP_DATE := C1.ORIGINAL_ORIG_DATE + C1.SHELF_LIFE_DAYS;

                UPDATE MTL_ONHAND_QUANTITIES_DETAIL MOQ
                   SET ORIG_DATE_RECEIVED =
                           (SELECT ORIGINAL_ORIG_DATE
                              FROM CUS.ADOR_ORIGINAL_AGE_STG AOAS
                             WHERE     AOAS.CREATE_TRANSACTION_ID = MOQ.ONHAND_QUANTITIES_ID
                                   AND AOAS.ORGANIZATION_ID = MOQ.ORGANIZATION_ID)
                 WHERE EXISTS (
                           SELECT 1
                             FROM CUS.ADOR_ORIGINAL_AGE_STG AOAS
                            WHERE     AOAS.CREATE_TRANSACTION_ID = MOQ.ONHAND_QUANTITIES_ID
                                  AND AOAS.ORGANIZATION_ID = MOQ.ORGANIZATION_ID);

                -- Lot number table update
                DBMS_OUTPUT.PUT_LINE('Updating MTL_LOT_NUMBERS for item: ' || C1.ITEM_CODE || ' Organization_id: ' || c1.organization_id);

                UPDATE MTL_LOT_NUMBERS MLN
                   SET ORIGINATION_DATE = C1.ORIGINAL_ORIG_DATE,
                       EXPIRATION_DATE = V_EXP_DATE
                 WHERE     C1.INVENTORY_ITEM_ID = MLN.INVENTORY_ITEM_ID
                       AND C1.ORGANIZATION_ID = MLN.ORGANIZATION_ID
                       AND C1.LOT_NUMBER = MLN.LOT_NUMBER;
            END IF;

            COMMIT;
            DBMS_OUTPUT.PUT_LINE('Committed updates for item: ' || C1.ITEM_CODE);
        END LOOP;

        -- Block: Completion message
        APPS.FND_FILE.PUT_LINE (
            FND_FILE.LOG,
            'Data has been updated for total records: ' || V_CNT);
        DBMS_OUTPUT.PUT_LINE('Data update completed for all records.');
    ELSE
        APPS.FND_FILE.PUT_LINE(FND_FILE.LOG, 'No records found in staging table.');
        DBMS_OUTPUT.PUT_LINE('No records found in staging table.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        APPS.FND_FILE.PUT_LINE (
            FND_FILE.LOG,
            'Unhandled error occurred: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Unhandled error occurred: ' || SQLERRM);
        ROLLBACK;
        ERRBUF := SQLERRM;
        ERRCODE := 'ERROR';
END;
/
