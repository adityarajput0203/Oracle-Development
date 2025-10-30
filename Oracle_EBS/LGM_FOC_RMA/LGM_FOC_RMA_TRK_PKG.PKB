CREATE OR REPLACE PACKAGE BODY APPS.LGM_FOC_RMA_TRK_PKG
AS
-- Created by Aditya R / Sandesh P on 19-Sep-2025 for LGM
-- Version 1.0 
/*******Ticket CR-10-25-00029 13 OCT 2025****************/
   PROCEDURE LGM_FOC_RMA_INSERT_PRG (
    errbuff            OUT VARCHAR2,
    retcode            OUT VARCHAR2,
    FOC_ORDER_NUMBER       VARCHAR2,
    P_DATE                 VARCHAR2
)
IS
    l_user_id NUMBER := fnd_global.user_id;
    l_rows_updated NUMBER;
    l_rows_inserted NUMBER;
BEGIN
    apps.fnd_file.put_line(apps.fnd_file.LOG, 'P_DATE - ' || P_DATE);
   

    -- Step 2: Insert new records
    -- This INSERT statement adds new records to ITC.LGM_FOC_RMA_TRACKING_DETAILS
    -- from the source subquery (C1_CUR logic) that do not already exist
    -- in the target table based on FOC_LINE_ID and FOC_SERIAL_NUMBER.
    INSERT INTO ITC.LGM_FOC_RMA_TRACKING_DETAILS (
        FOC_DEPOT_CODE, FOC_DEPOT_NAME, DEALER_CODE, DEALER_NAME,
        FOC_ORDER_NUMBER, FOC_HEADER_ID, FOC_LINE_ID, ORDER_TYPE,
        ORDER_TYPE_ID, FOC_DELIVERY_NO, FOC_MODEL_CODE, FOC_QUANTITY,
        FOC_SERIAL_NUMBER, FOC_INVOICE_NUMBER, FOC_TYPE, FOC_WARRANTY_TYPE,
        FOC_REMARK, REFERENCE_RMA, RMA_NUMBER, RMA_MODEL_CODE,
        RMA_SERIAL_NUMBER, FOC_ORD_DATE, FOC_INV_DATE,
        CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
    )
    SELECT
        R.organization_code,
        R.organization_name,
        R.account_number,
        R.party_name,
        R.order_number,
        R.header_id,
        R.line_id,
        R.ORDER_TYPE,
        R.ORDER_TYPE_ID,
        R.FOC_Delivery,
        R.ORDERED_ITEM,
        R.ORDERED_QUANTITY,
        R.serial_number,
        R.FOC_INV_NO,
        R.FOC_TYPE,
        R.FOC_W_TYPE,
        R.FOC_REMARK,
        R.REF_RMA,
        R.RMA_NO,
        CASE WHEN R.REF_RMA = 'N' THEN R.NON_REF_M_CODE ELSE R.RMA_M_CODE END,
        R.RMA_SERIAL_NO,
        R.FOC_ORD_DATE,
        R.FOC_INV_DATE,
        l_user_id,
        SYSDATE,
        l_user_id,
        SYSDATE,
        l_user_id
    FROM (
        -- Full C1_CUR query, which is the source for new inserts
        -- First part of the UNION ALL
        SELECT DISTINCT
            ood.organization_code organization_code,
            ood.Organization_name Organization_name,
            hca.account_number account_number,
            hp.party_name party_name,
            ooha.order_number order_number,
            ooha.header_id header_id,
            oola.line_id line_id,
            ott.Name ORDER_TYPE,
            OOHA.ORDER_TYPE_ID ORDER_TYPE_ID,
            wnd.Name FOC_Delivery,
            oola.ORDERED_ITEM ORDERED_ITEM,
            oola.ORDERED_QUANTITY ORDERED_QUANTITY,
            mut.serial_number serial_number,
            wdd.attribute13 FOC_INV_NO,
            ooha.ATTRIBUTE10 FOC_TYPE,
            ooha.attribute12 FOC_W_TYPE,
            ooha.attribute15 FOC_REMARK,
            oola.ATTRIBUTE11 REF_RMA,
            oola.ATTRIBUTE12 RMA_NO,
            oola.ATTRIBUTE13 RMA_M_CODE,
            oola.ATTRIBUTE17 RMA_SERIAL_NO,
            oola.attribute1 NON_REF_M_CODE,
            ooha.creation_date FOC_ORD_DATE,
            wnd.confirm_date FOC_INV_DATE
        FROM hz_parties hp,
             hz_cust_accounts hca,
             wsh_delivery_details wdd,
             wsh_new_deliveries wnd,
             wsh_delivery_assignments wda,
             wsh_serial_numbers wsn,
             oe_order_headers_all ooha,
             oe_order_lines_all oola,
             mtl_material_transactions mmt,
             mtl_unit_transactions mut,
             org_organization_definitions ood,
             oe_transaction_types_tl ott
        WHERE wsn.delivery_detail_id = wdd.delivery_detail_id
          AND wdd.SOURCE_HEADER_ID = ooha.header_id
          AND wdd.SOURCE_LINE_ID = oola.line_id
          AND wdd.delivery_detail_id = wda.delivery_detail_id
          AND wnd.delivery_id = wda.delivery_id
          AND oola.header_id = ooha.header_id
          AND ooha.SHIP_FROM_ORG_ID = ood.organization_id
          AND hca.cust_account_id(+) = ooha.sold_to_org_id
          AND hp.party_id = hca.party_id
          AND mmt.TRANSACTION_TYPE_ID = '33'
          AND oola.LINE_ID = mmt.TRX_SOURCE_LINE_ID
          AND wnd.attribute13 IS NOT NULL
          AND mmt.transaction_id = mut.transaction_id
          AND ott.TRANSACTION_TYPE_ID = ooha.order_type_id
          AND OTT.NAME IN (SELECT meaning FROM fnd_lookup_values
                           WHERE lookup_type = 'LGM_RMA_FOC_TRACKING'
                             AND LOOKUP_CODE LIKE 'FOC_ORDER_TYPE%')
          AND TO_CHAR(ooha.order_number) = NVL(TO_CHAR(FOC_ORDER_NUMBER), TO_CHAR(ooha.order_number))
          AND ooha.creation_date >= TO_DATE(P_DATE, 'YYYY-MM-DD HH24:MI:SS')
          AND ood.organization_code IN (
                    SELECT ffv.flex_value
                      FROM fnd_flex_value_sets ffvs, fnd_flex_values ffv, fnd_flex_values_tl ffvt
                     WHERE ffvs.flex_value_set_id = ffv.flex_value_set_id
                       AND ffv.flex_value_id = ffvt.flex_value_id
                       AND ffvt.language = USERENV('LANG')
                       AND ffv.enabled_flag = 'Y'
                       AND flex_value_set_name = 'LGM_AGRI_FOC_RMA_ORG')

        UNION ALL
        SELECT DISTINCT
            ood.organization_code organization_code,
            ood.Organization_name Organization_name,
            hca.account_number account_number,
            hp.party_name party_name,
            ooha.order_number order_number,
            ooha.header_id header_id,
            oola.line_id line_id,
            ott.Name ORDER_TYPE,
            OOHA.ORDER_TYPE_ID ORDER_TYPE_ID,
            wnd.Name FOC_Delivery,
            oola.ORDERED_ITEM ORDERED_ITEM,
            oola.ORDERED_QUANTITY ORDERED_QUANTITY,
            mut.serial_number serial_number,
            rct.trx_number FOC_INV_NO,
            ooha.ATTRIBUTE10 FOC_TYPE,
            ooha.attribute12 FOC_W_TYPE,
            ooha.attribute15 FOC_REMARK,
            oola.ATTRIBUTE11 REF_RMA,
            oola.ATTRIBUTE12 RMA_NO,
            oola.ATTRIBUTE13 RMA_M_CODE,
            oola.ATTRIBUTE17 RMA_SERIAL_NO,
            oola.attribute1 NON_REF_M_CODE,
            ooha.creation_date FOC_ORD_DATE,
            rct.creation_date FOC_INV_DATE
        FROM hz_parties hp,
             hz_cust_accounts hca,
             wsh_delivery_details wdd,
             wsh_new_deliveries wnd,
             wsh_delivery_assignments wda,
             wsh_serial_numbers wsn,
             oe_order_headers_all ooha,
             oe_order_lines_all oola,
             mtl_material_transactions mmt,
             mtl_unit_transactions mut,
             org_organization_definitions ood,
             oe_transaction_types_tl ott,
             ra_customer_trx_all rct,
             ra_customer_trx_lines_all rctl
        WHERE wsn.delivery_detail_id = wdd.delivery_detail_id
          AND wdd.SOURCE_HEADER_ID = ooha.header_id
          AND wdd.SOURCE_LINE_ID = oola.line_id
          AND wdd.delivery_detail_id = wda.delivery_detail_id
          AND wnd.delivery_id = wda.delivery_id
          AND oola.header_id = ooha.header_id
          AND ooha.SHIP_FROM_ORG_ID = ood.organization_id
          AND hca.cust_account_id(+) = ooha.sold_to_org_id
          AND hp.party_id = hca.party_id
          AND mmt.TRANSACTION_TYPE_ID = '33'
          AND oola.LINE_ID = mmt.TRX_SOURCE_LINE_ID
          AND rct.trx_number IS NOT NULL
          AND mmt.transaction_id = mut.transaction_id
          AND ott.TRANSACTION_TYPE_ID = ooha.order_type_id
          AND rctl.interface_line_attribute1 = TO_CHAR(ooha.order_number)
          AND rctl.interface_line_attribute6 = TO_CHAR(oola.line_id)
          AND rctl.interface_line_attribute3 = TO_CHAR(wnd.delivery_id)
          AND rctl.customer_trx_id = rct.customer_trx_id
          AND rct.interface_header_context = 'ORDER ENTRY'
          AND OTT.NAME IN (SELECT meaning FROM fnd_lookup_values
                           WHERE lookup_type = 'LGM_RMA_FOC_TRACKING'
                             AND LOOKUP_CODE LIKE 'FOC_ORDER_TYPE%')
          AND TO_CHAR(ooha.order_number) = NVL(TO_CHAR(FOC_ORDER_NUMBER), TO_CHAR(ooha.order_number))
          AND ooha.creation_date >= TO_DATE(P_DATE, 'YYYY-MM-DD HH24:MI:SS')
          AND ood.organization_code IN (
                    SELECT ffv.flex_value
                      FROM fnd_flex_value_sets ffvs, fnd_flex_values ffv, fnd_flex_values_tl ffvt
                     WHERE ffvs.flex_value_set_id = ffv.flex_value_set_id
                       AND ffv.flex_value_id = ffvt.flex_value_id
                       AND ffvt.language = USERENV('LANG')
                       AND ffv.enabled_flag = 'Y'
                       AND flex_value_set_name = 'LGM_AGRI_FOC_RMA_ORG')
    ) R
    WHERE NOT EXISTS (
        SELECT 1
        FROM ITC.LGM_FOC_RMA_TRACKING_DETAILS d_exist
        WHERE d_exist.FOC_LINE_ID = R.line_id
          AND d_exist.FOC_SERIAL_NUMBER = R.serial_number
    );

    l_rows_inserted := SQL%ROWCOUNT;
    apps.fnd_file.put_line(apps.fnd_file.LOG, l_rows_inserted || ' rows inserted.');
    COMMIT; 
    
    --updating for the rma_update procedure.
    UPDATE ITC.LGM_FOC_RMA_TRACKING_DETAILS d
    SET
        ATTRIBUTE1 = 'P',
        LAST_UPDATED_BY = l_user_id,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATE_LOGIN = l_user_id
    WHERE EXISTS (      
        SELECT 1
        FROM (
            SELECT
                oola.line_id,
                mut.serial_number
            FROM hz_parties hp,
                 hz_cust_accounts hca,
                 wsh_delivery_details wdd,
                 wsh_new_deliveries wnd,
                 wsh_delivery_assignments wda,
                 wsh_serial_numbers wsn,
                 oe_order_headers_all ooha,
                 oe_order_lines_all oola,
                 mtl_material_transactions mmt,
                 mtl_unit_transactions mut,
                 org_organization_definitions ood,
                 oe_transaction_types_tl ott
            WHERE wsn.delivery_detail_id = wdd.delivery_detail_id
              AND wdd.SOURCE_HEADER_ID = ooha.header_id
              AND wdd.SOURCE_LINE_ID = oola.line_id
              AND wdd.delivery_detail_id = wda.delivery_detail_id
              AND wnd.delivery_id = wda.delivery_id
              AND oola.header_id = ooha.header_id
              AND ooha.SHIP_FROM_ORG_ID = ood.organization_id
              AND hca.cust_account_id(+) = ooha.sold_to_org_id
              AND hp.party_id = hca.party_id
              AND mmt.TRANSACTION_TYPE_ID = '33'
              AND oola.LINE_ID = mmt.TRX_SOURCE_LINE_ID
              AND wnd.attribute13 IS NOT NULL
              AND mmt.transaction_id = mut.transaction_id
              AND ott.TRANSACTION_TYPE_ID = ooha.order_type_id
              AND OTT.NAME IN (SELECT meaning FROM fnd_lookup_values
                               WHERE lookup_type = 'LGM_RMA_FOC_TRACKING'
                                 AND LOOKUP_CODE LIKE 'FOC_ORDER_TYPE%')
              AND TO_CHAR(ooha.order_number) = NVL(TO_CHAR(FOC_ORDER_NUMBER), TO_CHAR(ooha.order_number))
              AND ooha.creation_date >= TO_DATE(P_DATE, 'YYYY-MM-DD HH24:MI:SS')
              AND ood.organization_code IN (
                        SELECT ffv.flex_value
                          FROM fnd_flex_value_sets ffvs, fnd_flex_values ffv, fnd_flex_values_tl ffvt
                         WHERE ffvs.flex_value_set_id = ffv.flex_value_set_id
                           AND ffv.flex_value_id = ffvt.flex_value_id
                           AND ffvt.language = USERENV('LANG')
                           AND ffv.enabled_flag = 'Y'
                           AND flex_value_set_name = 'LGM_AGRI_FOC_RMA_ORG')
            UNION ALL
            -- Second part of the UNION ALL: Retrieves data primarily linked via AR customer transactions
            SELECT DISTINCT
                oola.line_id,
                mut.serial_number
            FROM hz_parties hp,
                 hz_cust_accounts hca,
                 wsh_delivery_details wdd,
                 wsh_new_deliveries wnd,
                 wsh_delivery_assignments wda,
                 wsh_serial_numbers wsn,
                 oe_order_headers_all ooha,
                 oe_order_lines_all oola,
                 mtl_material_transactions mmt,
                 mtl_unit_transactions mut,
                 org_organization_definitions ood,
                 oe_transaction_types_tl ott,
                 ra_customer_trx_all rct,
                 ra_customer_trx_lines_all rctl
            WHERE wsn.delivery_detail_id = wdd.delivery_detail_id
              AND wdd.SOURCE_HEADER_ID = ooha.header_id
              AND wdd.SOURCE_LINE_ID = oola.line_id
              AND wdd.delivery_detail_id = wda.delivery_detail_id
              AND wnd.delivery_id = wda.delivery_id
              AND oola.header_id = ooha.header_id
              AND ooha.SHIP_FROM_ORG_ID = ood.organization_id
              AND hca.cust_account_id(+) = ooha.sold_to_org_id
              AND hp.party_id = hca.party_id
              AND mmt.TRANSACTION_TYPE_ID = '33'
              AND oola.LINE_ID = mmt.TRX_SOURCE_LINE_ID
              AND rct.trx_number IS NOT NULL
              AND mmt.transaction_id = mut.transaction_id
              AND ott.TRANSACTION_TYPE_ID = ooha.order_type_id
              AND rctl.interface_line_attribute1 = TO_CHAR(ooha.order_number)
              AND rctl.interface_line_attribute6 = TO_CHAR(oola.line_id)
              AND rctl.interface_line_attribute3 = TO_CHAR(wnd.delivery_id)
              AND rctl.customer_trx_id = rct.customer_trx_id
              AND rct.interface_header_context = 'ORDER ENTRY'
              AND OTT.NAME IN (SELECT meaning FROM fnd_lookup_values
                               WHERE lookup_type = 'LGM_RMA_FOC_TRACKING'
                                 AND LOOKUP_CODE LIKE 'FOC_ORDER_TYPE%')
              AND TO_CHAR(ooha.order_number) = NVL(TO_CHAR(FOC_ORDER_NUMBER), TO_CHAR(ooha.order_number))
              AND ooha.creation_date >= TO_DATE(P_DATE, 'YYYY-MM-DD HH24:MI:SS')
              AND ood.organization_code IN (
                        SELECT ffv.flex_value
                          FROM fnd_flex_value_sets ffvs, fnd_flex_values ffv, fnd_flex_values_tl ffvt
                         WHERE ffvs.flex_value_set_id = ffv.flex_value_set_id
                           AND ffv.flex_value_id = ffvt.flex_value_id
                           AND ffvt.language = USERENV('LANG')
                           AND ffv.enabled_flag = 'Y'
                           AND flex_value_set_name = 'LGM_AGRI_FOC_RMA_ORG')
        ) q
        WHERE q.line_id = d.FOC_LINE_ID
          AND q.serial_number = d.FOC_SERIAL_NUMBER
    );

    l_rows_updated := SQL%ROWCOUNT;
    apps.fnd_file.put_line(apps.fnd_file.LOG, l_rows_updated || ' rows updated.');
    COMMIT; -- Commit after update operation

EXCEPTION
    WHEN OTHERS THEN
        errbuff := SQLERRM;
        retcode := '2';
        apps.fnd_file.put_line(apps.fnd_file.LOG, 'Error FOC INSERTION - ' || SQLERRM);
        ROLLBACK;
END LGM_FOC_RMA_INSERT_PRG;
   /*Below Procedure is commented by Mandar Irle on 16th July-2025 against*/
  /* PROCEDURE LGM_FOC_RMA_INSERT_PRG (errbuff            OUT VARCHAR2,
                                      retcode            OUT VARCHAR2,
                                      FOC_ORDER_NUMBER       VARCHAR2,
                                      P_DATE                 VARCHAR2)
   IS
      lv_count         NUMBER;
      l_error_flag     VARCHAR2 (10);
      l_error_msg      VARCHAR2 (2000);
      v_count          NUMBER := 0;
      l_user_id        NUMBER;
      lv_seq_no        NUMBER;
      LV_VALUE_ITEMS   VARCHAR2 (256);


      CURSOR C1_CUR
      IS
         SELECT ood.organization_code organization_code,   --"FOC Depot Code",
                ood.Organization_name Organization_name,   --"FOC Depot Name",
                hca.account_number account_number,            --"Dealer_code",
                hp.party_name party_name,                     --"Dealer_name",
                ooha.order_number order_number,          --"FOC Order Number",
                ooha.header_id header_id,                   --"FOC_Header_ID",
                oola.line_id line_id,                         --"FOC Line ID",
                ott.Name ORDER_TYPE,                           --"Order Type",
                OOHA.ORDER_TYPE_ID ORDER_TYPE_ID,           --"Order Type ID",
                wnd.Name FOC_Delivery,                       --"FOC Delivery",
                oola.ORDERED_ITEM ORDERED_ITEM,            --"FOC Model Code",
                oola.ORDERED_QUANTITY ORDERED_QUANTITY,      --"FOC Quantity",
                mut.serial_number serial_number,        --"FOC Serial Number",
                wdd.attribute13 FOC_INV_NO,            --"FOC Invoice_number",
                ooha.ATTRIBUTE10 FOC_TYPE,                       --"FOC Type",
                ooha.attribute12 FOC_W_TYPE,            --"FOC Warranty Type",
                ooha.attribute15 FOC_REMARK,                   --"FOC Remark",
                oola.ATTRIBUTE11 REF_RMA,                   --"Reference RMA",
                oola.ATTRIBUTE12 RMA_NO,                       --"RMA Number",
                oola.ATTRIBUTE13 RMA_M_CODE,                --"RMA Model Code"
                oola.ATTRIBUTE17 RMA_SERIAL_NO,
                oola.attribute1 NON_REF_M_CODE,
                ooha.creation_date FOC_ORD_DATE,
                wnd.confirm_date FOC_INV_DATE
           FROM hz_parties hp,
                hz_cust_accounts hca,
                wsh_delivery_details wdd,
                wsh_new_deliveries wnd,
                wsh_delivery_assignments wda,
                wsh_serial_numbers wsn,
                oe_order_headers_all ooha,
                oe_order_lines_all oola,
                mtl_material_transactions mmt,
                mtl_unit_transactions mut,
                org_organization_definitions ood,
                oe_transaction_types_tl ott
          WHERE     wsn.delivery_detail_id = wdd.delivery_detail_id
                AND wdd.SOURCE_HEADER_ID = ooha.header_id
                AND wdd.SOURCE_LINE_ID = oola.line_id
                AND wdd.delivery_detail_id = wda.delivery_detail_id
                AND wnd.delivery_id = wda.delivery_id
                AND oola.header_id = ooha.header_id
                AND ooha.SHIP_FROM_ORG_ID = ood.organization_id
                AND hca.cust_account_id(+) = ooha.sold_to_org_id
                AND hp.party_id = hca.party_id
                AND mmt.TRANSACTION_TYPE_ID = '33'
                AND oola.LINE_ID = mmt.TRX_SOURCE_LINE_ID
                AND wdd.attribute13 IS NOT NULL
                --and wsn.to_serial_number = 'F08B6008'
                AND mmt.transaction_id = mut.transaction_id
                AND ott.TRANSACTION_TYPE_ID = ooha.order_type_id
                AND OTT.NAME IN
                       (SELECT (meaning)
                          FROM fnd_lookup_values
                         WHERE     lookup_type = 'LGM_RMA_FOC_TRACKING'
                               AND LOOKUP_CODE LIKE 'FOC_ORDER_TYPE%')
                AND TO_CHAR (ooha.order_number) =
                       NVL (TO_CHAR (FOC_ORDER_NUMBER),
                            TO_CHAR (ooha.order_number)) --'5370000784' --and oola.ATTRIBUTE12 = '5390000298'
                -- AND  trunc(TO_DATE(ooha.creation_date,'YYYY-MM-DD')) >= trunc(TO_DATE(P_DATE,'YYYY-MM-DD'))--TO_CHAR(P_DATE,'YYYY-MM-DD HH:MI:SS') --((TO_CHAR(P_DATE,'DD-MON-YYYY')))--TRUNC((TO_CHAR(P_DATE,'YYYY-MM-DD HH:MM:SS')))
                AND ooha.creation_date >=
                       TO_DATE (P_DATE, 'YYYY-MM-DD HH24:MI:SS')
                AND ood.organization_code IN
                       (SELECT ffv.flex_value
                          FROM fnd_flex_value_sets ffvs,
                               fnd_flex_values ffv,
                               fnd_flex_values_tl ffvt
                         WHERE     ffvs.flex_value_set_id =
                                      ffv.flex_value_set_id
                               AND ffv.flex_value_id = ffvt.flex_value_id
                               AND ffvt.language = USERENV ('LANG')
                               AND ffv.enabled_flag = 'Y'
                               AND flex_value_set_name =
                                      'LGM_AGRI_FOC_RMA_ORG')
         UNION
         SELECT DISTINCT ood.organization_code organization_code, --"FOC Depot Code",
                         ood.Organization_name Organization_name, --"FOC Depot Name",
                         hca.account_number account_number,   --"Dealer_code",
                         hp.party_name party_name,            --"Dealer_name",
                         ooha.order_number order_number, --"FOC Order Number",
                         ooha.header_id header_id,          --"FOC_Header_ID",
                         oola.line_id line_id,                --"FOC Line ID",
                         ott.Name ORDER_TYPE,                  --"Order Type",
                         OOHA.ORDER_TYPE_ID ORDER_TYPE_ID,  --"Order Type ID",
                         wnd.Name FOC_Delivery,              --"FOC Delivery",
                         oola.ORDERED_ITEM ORDERED_ITEM,   --"FOC Model Code",
                         oola.ORDERED_QUANTITY ORDERED_QUANTITY, --"FOC Quantity",
                         mut.serial_number serial_number, --"FOC Serial Number",
                         rct.trx_number FOC_INV_NO,    --"FOC Invoice_number",
                         ooha.ATTRIBUTE10 FOC_TYPE,              --"FOC Type",
                         ooha.attribute12 FOC_W_TYPE,   --"FOC Warranty Type",
                         ooha.attribute15 FOC_REMARK,          --"FOC Remark",
                         oola.ATTRIBUTE11 REF_RMA,          --"Reference RMA",
                         oola.ATTRIBUTE12 RMA_NO,              --"RMA Number",
                         oola.ATTRIBUTE13 RMA_M_CODE,       --"RMA Model Code"
                         oola.ATTRIBUTE17 RMA_SERIAL_NO,
                         oola.attribute1 NON_REF_M_CODE,
                         ooha.creation_date FOC_ORD_DATE,
                         rct.creation_date FOC_INV_DATE
           FROM hz_parties hp,
                hz_cust_accounts hca,
                wsh_delivery_details wdd,
                wsh_new_deliveries wnd,
                wsh_delivery_assignments wda,
                wsh_serial_numbers wsn,
                oe_order_headers_all ooha,
                oe_order_lines_all oola,
                mtl_material_transactions mmt,
                mtl_unit_transactions mut,
                org_organization_definitions ood,
                oe_transaction_types_tl ott,
                ra_customer_trx_all rct,
                ra_customer_trx_lines_all rctl
          WHERE     wsn.delivery_detail_id = wdd.delivery_detail_id
                AND wdd.SOURCE_HEADER_ID = ooha.header_id
                AND wdd.SOURCE_LINE_ID = oola.line_id
                AND wdd.delivery_detail_id = wda.delivery_detail_id
                AND wnd.delivery_id = wda.delivery_id
                AND oola.header_id = ooha.header_id
                AND ooha.SHIP_FROM_ORG_ID = ood.organization_id
                AND hca.cust_account_id(+) = ooha.sold_to_org_id
                AND hp.party_id = hca.party_id
                AND mmt.TRANSACTION_TYPE_ID = '33'
                AND oola.LINE_ID = mmt.TRX_SOURCE_LINE_ID
                AND rct.trx_number IS NOT NULL
                --and wsn.to_serial_number = 'F08B6008'
                AND mmt.transaction_id = mut.transaction_id
                AND ott.TRANSACTION_TYPE_ID = ooha.order_type_id
                AND rctl.interface_line_attribute1 =
                       TO_CHAR (ooha.order_number)
                AND rctl.interface_line_attribute6 = TO_CHAR (oola.line_id)
                AND rctl.interface_line_attribute3 =
                       TO_CHAR (wnd.delivery_id)
                AND rctl.customer_trx_id = rct.customer_trx_id
                AND rct.interface_header_context = 'ORDER ENTRY'
                AND OTT.NAME IN
                       (SELECT (meaning)
                          FROM fnd_lookup_values
                         WHERE     lookup_type = 'LGM_RMA_FOC_TRACKING'
                               AND LOOKUP_CODE LIKE 'FOC_ORDER_TYPE%')
                AND TO_CHAR (ooha.order_number) =
                       NVL (TO_CHAR (FOC_ORDER_NUMBER),
                            TO_CHAR (ooha.order_number)) --'5370000784' --and oola.ATTRIBUTE12 = '5390000298'
                -- AND  trunc(TO_DATE(ooha.creation_date,'YYYY-MM-DD')) >= trunc(TO_DATE(P_DATE,'YYYY-MM-DD'))--TO_CHAR(P_DATE,'YYYY-MM-DD HH:MI:SS') --((TO_CHAR(P_DATE,'DD-MON-YYYY')))--TRUNC((TO_CHAR(P_DATE,'YYYY-MM-DD HH:MM:SS')))
                AND ooha.creation_date >=
                       TO_DATE (P_DATE, 'YYYY-MM-DD HH24:MI:SS')
                AND ood.organization_code IN
                       (SELECT ffv.flex_value
                          FROM fnd_flex_value_sets ffvs,
                               fnd_flex_values ffv,
                               fnd_flex_values_tl ffvt
                         WHERE     ffvs.flex_value_set_id =
                                      ffv.flex_value_set_id
                               AND ffv.flex_value_id = ffvt.flex_value_id
                               AND ffvt.language = USERENV ('LANG')
                               AND ffv.enabled_flag = 'Y'
                               AND flex_value_set_name =
                                      'LGM_AGRI_FOC_RMA_ORG');
   BEGIN
      l_user_id := fnd_global.user_id;

      APPS.FND_FILE.PUT_LINE (apps.FND_FILE.LOG, 'P_DATE - ' || P_DATE);

      FOR R IN C1_CUR
      LOOP
         BEGIN
            SELECT COUNT (*)
              INTO lv_count
              FROM ITC.LGM_FOC_RMA_TRACKING_DETAILS
             WHERE     FOC_LINE_ID = r.line_id
                   AND FOC_SERIAL_NUMBER = R.serial_number;
         EXCEPTION
            WHEN OTHERS
            THEN
               l_error_flag := 'E';
               l_error_msg :=
                  'Error while in count - ' || r.line_id || SQLERRM;
               APPS.FND_FILE.PUT_LINE (apps.FND_FILE.LOG,
                                       'Error while in count - ' || SQLERRM);
         END;



         IF NVL (lv_count, 0) = 0
         THEN
            BEGIN
               IF R.REF_RMA = 'N'
               THEN
                  LV_VALUE_ITEMS := R.NON_REF_M_CODE;
               ELSE
                  LV_VALUE_ITEMS := R.RMA_M_CODE;
               END IF;


               SELECT ITC.LGM_FOC_RMA_TRACKING_DETAILS_SEQ.NEXTVAL
                 INTO lv_seq_no
                 FROM DUAL;


               INSERT
                 INTO ITC.LGM_FOC_RMA_TRACKING_DETAILS (
                         FOC_DEPOT_CODE,
                         FOC_DEPOT_NAME,
                         DEALER_CODE,
                         DEALER_NAME,
                         FOC_ORDER_NUMBER,
                         FOC_HEADER_ID,
                         FOC_LINE_ID,
                         ORDER_TYPE,
                         ORDER_TYPE_ID,
                         FOC_DELIVERY_NO,
                         FOC_MODEL_CODE,
                         FOC_QUANTITY,
                         FOC_SERIAL_NUMBER,
                         FOC_INVOICE_NUMBER,
                         FOC_TYPE,
                         FOC_WARRANTY_TYPE,
                         FOC_REMARK,
                         RMA_ORG_CODE,
                         REFERENCE_RMA,
                         RMA_NUMBER,
                         RMA_MODEL_CODE,
                         RMA_SERIAL_NUMBER,
                         RMA_HEADER_ID,
                         RMA_LINE_ID,
                         COMPLAINT_NUMBER,
                         DATE_OF_FAILURE,
                         MATERIAL_RECEIVED_DATE,
                         NFA_NUMBER,
                         RMA_NOTE,
                         CREATION_DATE,
                         CREATED_BY,
                         LAST_UPDATED_BY,
                         LAST_UPDATE_DATE,
                         LAST_UPDATE_LOGIN,
                         SEQ_NO,
                         FOC_ORD_DATE,
                         FOC_INV_DATE)
               VALUES (R.organization_code,
                       R.organization_NAME,
                       R.account_number,
                       R.party_name,
                       R.order_number,
                       R.header_id,
                       R.line_id,
                       R.ORDER_TYPE,
                       R.ORDER_TYPE_ID,
                       R.FOC_Delivery,
                       R.ORDERED_ITEM,
                       R.ORDERED_QUANTITY,
                       R.serial_number,
                       R.FOC_INV_NO,
                       R.FOC_TYPE,
                       R.FOC_W_TYPE,
                       R.FOC_REMARK,
                       NULL,
                       R.REF_RMA,
                       R.RMA_NO,
                       LV_VALUE_ITEMS,
                       R.RMA_SERIAL_NO,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       NULL,
                       SYSDATE,
                       l_user_id,
                       l_user_id,
                       SYSDATE,
                       l_user_id,
                       lv_seq_no,
                       R.FOC_ORD_DATE,
                       R.FOC_INV_DATE);

               IF SQL%NOTFOUND
               THEN
                  APPS.FND_FILE.PUT_LINE (APPS.FND_FILE.LOG,
                                          'HERE IN EXCEPTION ' || SQLERRM);
                  APPS.FND_FILE.PUT_LINE (APPS.FND_FILE.LOG, R.line_id);
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  APPS.FND_FILE.PUT_LINE (APPS.FND_FILE.LOG,
                                          'HERE IN EXCEPTION ' || SQLERRM);
                  APPS.FND_FILE.PUT_LINE (APPS.FND_FILE.LOG, R.line_id);
            END;

            UPDATE ITC.LGM_FOC_RMA_TRACKING_DETAILS
               SET ATTRIBUTE1 = 'P'
             WHERE     FOC_LINE_ID = r.line_id
                   AND FOC_SERIAL_NUMBER = R.serial_number;
         ELSE
            UPDATE ITC.LGM_FOC_RMA_TRACKING_DETAILS
               SET ATTRIBUTE2 = l_error_flag, ATTRIBUTE3 = l_error_msg
             WHERE     FOC_LINE_ID = R.line_id
                   AND FOC_SERIAL_NUMBER = R.serial_number;

            COMMIT;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_error_flag := 'E';
         l_error_msg := 'Error FOC INSERTION - ' || SQLERRM;

         apps.fnd_file.put_line (apps.fnd_file.LOG,
                                 'Error FOC INSERTION - ' || SQLERRM);
   END LGM_FOC_RMA_INSERT_PRG;  */
   --Above procedure commented by Mandar irle against SR-07-25-01186

   PROCEDURE LGM_RMA_INSERT_PRG (errbuff      OUT VARCHAR2,
                                  retcode      OUT VARCHAR2,
                                  RMA_NUMBER       VARCHAR2,
                                  P_DATE           VARCHAR2)
   IS
      lv_count           NUMBER;
      l_error_flag       VARCHAR2 (10);
      l_error_msg        VARCHAR2 (2000);
      v_count            NUMBER := 0;
      l_user_id          NUMBER;
      LV_RMA_HEADER_ID   NUMBER;
      LV_RMA_LINE_ID     NUMBER;
      LV_RMA_NUMBER      VARCHAR2 (100);
      LV_GRR_NUMBER      VARCHAR2 (100);
      LV_RMA_ORG_CODE    VARCHAR2 (100);
      LV_ITEM_CODE       VARCHAR2 (100);
      LV_SERIAL_NUMBER   VARCHAR2 (100);

      CURSOR C1_CUR
      IS
         SELECT DISTINCT
                ood.organization_code organization_code,       --"Depot Code",
                ood.Organization_name Organization_name,       --"Depot Name",
                hca.account_number account_number,            --"Dealer_code",
                hp.party_name party_name,                     --"Dealer_name",
                ooha.ORDER_NUMBER ORDER_NUMBER,                    --"RMA NO",
                ooha.header_id header_id,                   --"RMA_HEADER_ID",
                oola.Line_id Line_id,                         --"RMA_LINE_ID",
                OOHA.CREATION_DATE CREATION_DATE,                --"RMA_Date",
                ott.Name order_type,                           --"Order Type",
                rsh.RECEIPT_NUM,                                   --"GRR No",
                RT.TRANSACTION_DATE DELIVERY_DATE,          --"DELIVERY_DATE",
                (SELECT TRANSACTION_DATE
                   FROM rcv_transactions
                  WHERE     TRANSACTION_TYPE = 'RECEIVE'
                        AND SHIPMENT_LINE_ID = RSL.SHIPMENT_LINE_ID
                        AND SHIPMENT_HEADER_ID = RSL.SHIPMENT_HEADER_ID)
                   GRR_DATE,                 --,ac.customer_name "Delear Name"
                oola.ORDERED_ITEM ORDERED_ITEM,     -- "Defective Model Code",
                mut.serial_number serial_number, --"Defective Model Serial No.",
                OOLA.ORDERED_QUANTITY,
                RSL.QUANTITY_SHIPPED,
                RSL.QUANTITY_RECEIVED,
                TO_DATE (ooha.ATTRIBUTE10, 'YYYY-MM-DD HH24:MI:SS')
                   hdr_m_receipt_date,          --"Header Material Rcpt Date",
                ooha.ATTRIBUTE13 hdr_complaint_no,   --"Header Complaint No.",
                TO_DATE (ooha.ATTRIBUTE12, 'YYYY-MM-DD HH24:MI:SS')
                   hdr_date_of_fail,               --"Header Date Of Failure",
                ooha.ATTRIBUTE14 hdr_nfa_no,               --"Header NFA No.",
                ooha.ATTRIBUTE15 hdr_note,                    --"Header Note",
                TO_DATE (oola.ATTRIBUTE11, 'YYYY-MM-DD HH24:MI:SS')
                   line_m_recipt_date,            --"Line Material Rcpt Date",
                oola.ATTRIBUTE13 line_complaint_no,    --"Line Complaint No.",
                TO_DATE (oola.ATTRIBUTE12, 'YYYY-MM-DD HH24:MI:SS')
                   line_date_of_fail,                --"Line Date Of Failure",
                oola.ATTRIBUTE14 line_nfa_no,               -- "Line NFA No.",
                oola.ATTRIBUTE15 line_note                       --"Line Note"
           FROM hz_parties hp,
                -- hz_cust_accounts hca,
                org_organization_definitions ood,
                apps.OE_ORDER_HEADERS_ALL ooha,
                apps.OE_ORDER_LINES_ALL oola,
                apps.RCV_SHIPMENT_HEADERS rsh,
                apps.ar_customers ac,
                apps.RCV_SHIPMENT_LINES rsl,
                apps.hz_cust_accounts hca,
                rcv_transactions rt,
                mtl_material_transactions mmt,
                mtl_unit_transactions mut,
                oe_transaction_types_tl ott
          WHERE     1 = 1
                AND ooha.header_id = oola.header_id
                AND ooha.header_id = rsl.OE_ORDER_HEADER_ID
                AND rsh.shipment_header_id = rsl.shipment_header_id
                AND rsl.OE_ORDER_LINE_ID = oola.line_id
                AND TO_CHAR (ooha.order_number) =
                       NVL (TO_CHAR (RMA_NUMBER),
                            TO_CHAR (ooha.order_number))
                AND TO_CHAR (ooha.order_number) NOT IN
              (SELECT ffv.flex_value
                 FROM fnd_flex_value_sets ffvs,
                      fnd_flex_values ffv,
                      fnd_flex_values_tl ffvt
                WHERE     ffvs.flex_value_set_id = ffv.flex_value_set_id
                      AND ffv.flex_value_id = ffvt.flex_value_id
                      AND ffvt.language = USERENV ('LANG')
                      AND flex_value_set_name = 'LGM_FOC_ORDER_EXCLUSION'
                      AND ffv.enabled_flag = 'Y')            
                AND ooha.creation_date >=
                       TRUNC (TO_DATE (P_DATE, 'YYYY-MM-DD HH24:MI:SS'))
                AND ooha.sold_to_org_id = hca.cust_account_id
                AND ooha.SHIP_FROM_ORG_ID = ood.organization_id
                AND hca.cust_account_id(+) = ooha.sold_to_org_id
                AND hp.party_id = hca.party_id
                AND rsl.SOURCE_DOCUMENT_CODE = 'RMA'
                AND hca.cust_account_id = ac.customer_id
                AND rt.shipment_line_id = rsl.shipment_line_id
                AND rsl.shipment_header_id = rsh.shipment_header_id
                AND rt.TRANSACTION_TYPE = 'DELIVER'
                AND ooha.SOLD_FROM_ORG_ID = 1891
                AND mmt.rcv_transaction_id = rt.transaction_id
                AND mmt.transaction_id = mut.transaction_id
                AND ott.TRANSACTION_TYPE_ID = ooha.order_type_id
                AND ott.name IN
                       (SELECT meaning
                          FROM fnd_lookup_values
                         WHERE     lookup_type = 'LGM_RMA_FOC_TRACKING'
                               AND LOOKUP_CODE LIKE 'RMA_ORDER_TYPE%')
                AND ood.organization_code IN
                       (SELECT ffv.flex_value
                          FROM fnd_flex_value_sets ffvs,
                               fnd_flex_values ffv,
                               fnd_flex_values_tl ffvt
                         WHERE     ffvs.flex_value_set_id =
                                      ffv.flex_value_set_id
                               AND ffv.flex_value_id = ffvt.flex_value_id
                               AND ffvt.language = USERENV ('LANG')
                               AND ffv.enabled_flag = 'Y'
                               AND flex_value_set_name =
                                      'LGM_AGRI_FOC_RMA_ORG');
   BEGIN
      l_user_id := fnd_global.user_id;



      FOR R IN C1_CUR
      LOOP
         BEGIN
            SELECT COUNT (*)
              INTO lv_count
              FROM ITC.LGM_RMA_TRASACTION_DETAILS
             WHERE     RMA_LINE_ID = r.line_id
                   AND serial_number = r.serial_number;
         EXCEPTION
            WHEN OTHERS
            THEN
               l_error_flag := 'E';
               l_error_msg :=
                     'Error while in Count - '
                  || r.line_id
                  || r.serial_number
                  || SQLERRM;
               APPS.FND_FILE.PUT_LINE (apps.FND_FILE.LOG,
                                       'Error while in Count ' || SQLERRM);
         END;

         /*
                  BEGIN
                     SELECT RMA_HEADER_ID,
                            RMA_LINE_ID,
                            RMA_NUMBER,
                            GRR_NUMBER,
                            RMA_DEPOT_CODE,
                            ITEM_CODE,
                            SERIAL_NUMBER
                       INTO LV_RMA_HEADER_ID,
                            LV_RMA_LINE_ID,
                            LV_RMA_NUMBER,
                            LV_GRR_NUMBER,
                            LV_RMA_ORG_CODE,
                            LV_ITEM_CODE,
                            LV_SERIAL_NUMBER
                       FROM LGM_RMA_TRASACTION_DETAILS
                      WHERE     1 = 1                    -- RMA_NUMBER = R.order_number
                            AND ITEM_CODE = R.ORDERED_ITEM
                            AND SERIAL_NUMBER = R.SERIAL_NUMBER;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        l_error_flag := 'E';
                        l_error_msg :=
                           'Error RMA DETAILS fetcing - ' || r.line_id || SQLERRM;
                        APPS.FND_FILE.PUT_LINE (
                           apps.FND_FILE.LOG,
                           'Error RMA DETAILS fetcing ' || SQLERRM);
                  END;

         */

         IF NVL (lv_count, 0) = 0
         THEN
            BEGIN
               INSERT
                 INTO ITC.LGM_RMA_TRASACTION_DETAILS (RMA_DEPOT_CODE,
                                                       RMA_DEPOT_NAME,
                                                       RMA_DEALER_CODE,
                                                       RMA_DEALER_NAME,
                                                       RMA_NUMBER,
                                                       RMA_HEADER_ID,
                                                       RMA_LINE_ID,
                                                       RMA_DATE,
                                                       ORDER_TYPE,
                                                       GRR_NUMBER,
                                                       GRR_DATE,
                                                       DELIVERY_DATE,
                                                       ITEM_CODE,
                                                       SERIAL_NUMBER,
                                                       ORDERED_QUANTITY,
                                                       QUANTITY_SHIPPED,
                                                       QUANTITY_RECEIVED,
                                                       H_MTL_REPT_DATE,
                                                       H_COMPLAINT_NO,
                                                       H_DATE_OF_FAILURE,
                                                       H_NFA_NO,
                                                       H_NOTES,
                                                       L_MTL_REPT_DATE,
                                                       L_COMPLAINT_NO,
                                                       L_DATE_OF_FAILURE,
                                                       L_NFA_NO,
                                                       L_NOTES,
                                                       CREATION_DATE,
                                                       CREATED_BY,
                                                       UPDATED_BY,
                                                       UPDATED_DATE,
                                                       LAST_UPDATE_LOGIN)
               VALUES (R.organization_code,
                       R.organization_NAME,
                       R.account_number,
                       R.party_name,
                       R.order_number,
                       R.header_id,
                       R.line_id,
                       R.CREATION_DATE,
                       R.order_type,
                       R.RECEIPT_NUM,
                       R.DELIVERY_DATE,
                       R.GRR_DATE,
                       R.ORDERED_ITEM,
                       R.serial_number,
                       r.ORDERED_QUANTITY,
                       r.QUANTITY_SHIPPED,
                       r.QUANTITY_RECEIVED,
                       r.hdr_m_receipt_date,
                       r.hdr_complaint_no,           --"Header Complaint No.",
                       r.hdr_date_of_fail,         --"Header Date Of Failure",
                       r.hdr_nfa_no,                       --"Header NFA No.",
                       r.hdr_note,                            --"Header Note",
                       r.line_m_recipt_date,      --"Line Material Rcpt Date",
                       r.line_complaint_no,            --"Line Complaint No.",
                       r.line_date_of_fail,          --"Line Date Of Failure",
                       r.line_nfa_no,                       -- "Line NFA No.",
                       r.line_note,
                       SYSDATE,
                       l_user_id,
                       l_user_id,
                       SYSDATE,
                       l_user_id);

               IF SQL%NOTFOUND
               THEN
                  APPS.FND_FILE.PUT_LINE (APPS.FND_FILE.LOG,
                                          'HERE IN EXCEPTION ' || SQLERRM);
                  APPS.FND_FILE.PUT_LINE (APPS.FND_FILE.LOG, R.line_id);
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  APPS.FND_FILE.PUT_LINE (APPS.FND_FILE.LOG,
                                          'HERE IN EXCEPTION ' || SQLERRM);
                  APPS.FND_FILE.PUT_LINE (APPS.FND_FILE.LOG, R.line_id);
            END;

            UPDATE ITC.LGM_RMA_TRASACTION_DETAILS
               SET ATTRIBUTE1 = 'P'
             WHERE     RMA_LINE_ID = r.line_id
                   AND SERIAL_NUMBER = R.serial_number;
                   
            COMMIT;
         ELSE
            UPDATE ITC.LGM_RMA_TRASACTION_DETAILS
               SET ATTRIBUTE2 = l_error_flag, ATTRIBUTE3 = l_error_msg
             WHERE     RMA_LINE_ID = R.line_id
                   AND SERIAL_NUMBER = R.serial_number;

            COMMIT;
         END IF;
      /*    IF LV_COUNT = 1
          THEN
             UPDATE ITC.LGM_FOC_RMA_TRACKING_DETAILS
                SET RMA_ORG_CODE = LV_RMA_ORG_CODE,
                    GRR_NO = LV_GRR_NUMBER,
                    RMA_HEADER_ID = lv_RMA_HEADER_ID,
                    RMA_LINE_ID = lv_RMA_LINE_ID,
                    RMA_NUMBER = LV_RMA_NUMBER,
                    RMA_MODEL_CODE = LV_ITEM_CODE,
                    RMA_SERIAL_NUMBER = LV_SERIAL_NUMBER
              WHERE     RMA_NUMBER = R.order_number
                    AND FOC_MODEL_CODE = R.ORDERED_ITEM
                    AND ATTRIBUTE1 = 'P';

             COMMIT;
          END IF;*/
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_error_flag := 'E';
         l_error_msg := 'Error RMA INSERTION - ' || SQLERRM;

         apps.fnd_file.put_line (apps.fnd_file.LOG,
                                 'Error RMA INSERTION - ' || SQLERRM);
   END LGM_RMA_INSERT_PRG;

   PROCEDURE LGM_RMA_UPDATE_PRG (errbuff   OUT VARCHAR2,
                                  retcode   OUT VARCHAR2,
                                  RMA_NUM       VARCHAR2,
                                  P_DATE        VARCHAR2)
   IS
      lv_count                    NUMBER;
      l_error_flag                VARCHAR2 (10);
      l_error_msg                 VARCHAR2 (2000);
      v_count                     NUMBER := 0;
      l_user_id                   NUMBER;
      LV_RMA_HEADER_ID            NUMBER;
      LV_RMA_LINE_ID              NUMBER;
      LV_RMA_NUMBER               VARCHAR2 (100);
      LV_GRR_NUMBER               VARCHAR2 (100);
      LV_RMA_ORG_CODE             VARCHAR2 (100);
      LV_ITEM_CODE                VARCHAR2 (100);
      LV_SERIAL_NUMBER            VARCHAR2 (100);
      lv_COMPLAINT_NUMBER         VARCHAR2 (100);
      lv_DATE_OF_FAILURE          VARCHAR2 (100);
      lv_MATERIAL_RECEIVED_DATE   VARCHAR2 (100);
      lv_NFA_NUMBER               VARCHAR2 (100);
      lv_RMA_NOTE                 VARCHAR2 (100);

      CURSOR C1_CUR
      IS
         SELECT DISTINCT
                krtd.RMA_HEADER_ID HEADER_ID,
                krtd.RMA_LINE_ID LINE_ID,
                krtd.RMA_NUMBER RMA_NO,
                krtd.GRR_NUMBER GRR_NUM,
                krtd.RMA_DEPOT_CODE DEPOT_CODE,
                krtd.ITEM_CODE ITEM,
                krtd.SERIAL_NUMBER SERIAL_NO,
                krtd.RMA_DEPOT_CODE RMA_CODE,
                --krtd.H_MTL_REPT_DATE,
                TO_CHAR(krtd.H_MTL_REPT_DATE, 'DD-MON-YYYY')
                    H_MTL_REPT_DATE,
                krtd.H_COMPLAINT_NO,
                TO_CHAR (krtd.H_DATE_OF_FAILURE, 'DD-MON-YYYY')
                   H_DATE_OF_FAILURE,
                --krtd.H_DATE_OF_FAILURE,
                krtd.H_NFA_NO,
                krtd.H_NOTES,
                TO_CHAR(krtd.L_MTL_REPT_DATE, 'DD-MON-YYYY')
                    L_MTL_REPT_DATE,
                --krtd.L_MTL_REPT_DATE,
                krtd.L_COMPLAINT_NO,
                TO_CHAR (krtd.L_DATE_OF_FAILURE, 'DD-MON-YYYY')
                   L_DATE_OF_FAILURE,
                -- krtd.L_DATE_OF_FAILURE,
                krtd.L_NFA_NO,
                krtd.L_NOTES
           FROM ITC.LGM_FOC_RMA_TRACKING_DETAILS kfrtd,
                ITC.LGM_RMA_TRASACTION_DETAILS krtd
          WHERE     kfrtd.RMA_NUMBER = krtd.RMA_NUMBER
                AND KFRTD.RMA_MODEL_CODE = krtd.ITEM_CODE
                AND KFRTD.RMA_SERIAL_NUMBER = krtd.SERIAL_NUMBER
                AND TO_CHAR (kfrtd.RMA_NUMBER) =
                       NVL (TO_CHAR (RMA_NUM), TO_CHAR (kfrtd.RMA_NUMBER))
                AND (krtd.CREATION_DATE) >=
                       TO_DATE (P_DATE, 'YYYY-MM-DD HH24:MI:SS');


      CURSOR C2_CUR
      IS
         SELECT DISTINCT krtd.RMA_HEADER_ID HEADER_ID,
                         krtd.RMA_LINE_ID LINE_ID,
                         krtd.RMA_NUMBER RMA_NO,
                         krtd.GRR_NUMBER GRR_NUM,
                         krtd.RMA_DEPOT_CODE DEPOT_CODE,
                         krtd.ITEM_CODE ITEM,
                         krtd.SERIAL_NUMBER SERIAL_NO,
                         krtd.RMA_DEPOT_CODE RMA_CODE,
                         --krtd.H_MTL_REPT_DATE,
                         TO_CHAR(krtd.H_MTL_REPT_DATE, 'DD-MON-YYYY')
                            H_MTL_REPT_DATE,
                         krtd.H_COMPLAINT_NO,
                         --krtd.H_DATE_OF_FAILURE,
                         TO_CHAR (krtd.H_DATE_OF_FAILURE, 'DD-MON-YYYY')
                                H_DATE_OF_FAILURE,
                         krtd.H_NFA_NO,
                         krtd.H_NOTES,
                         --krtd.L_MTL_REPT_DATE,
                         TO_CHAR(krtd.L_MTL_REPT_DATE, 'DD-MON-YYYY')
                            L_MTL_REPT_DATE,
                         krtd.L_COMPLAINT_NO,
                         --krtd.L_DATE_OF_FAILURE,
                         TO_CHAR (krtd.L_DATE_OF_FAILURE, 'DD-MON-YYYY')
                            L_DATE_OF_FAILURE,
                         krtd.L_NFA_NO,
                         krtd.L_NOTES
           FROM ITC.LGM_FOC_RMA_TRACKING_DETAILS kfrtd,
                ITC.LGM_RMA_TRASACTION_DETAILS krtd
          WHERE     kfrtd.RMA_NUMBER = krtd.RMA_NUMBER
                AND KFRTD.RMA_MODEL_CODE = krtd.ITEM_CODE
                AND TO_CHAR (kfrtd.RMA_NUMBER) =
                       NVL (TO_CHAR (RMA_NUM), TO_CHAR (kfrtd.RMA_NUMBER))
                AND (krtd.CREATION_DATE) >=
                       TO_DATE (P_DATE, 'YYYY-MM-DD HH24:MI:SS');
   BEGIN
      l_user_id := fnd_global.user_id;

      FOR R IN C1_CUR
      LOOP
         /*
                  UPDATE ITC.LGM_FOC_RMA_TRACKING_DETAILS
                     SET RMA_ORG_CODE = R.RMA_CODE,
                         GRR_NO = R.GRR_NUM,
                         RMA_HEADER_ID = R.HEADER_ID
                   WHERE     RMA_NUMBER = R.RMA_NO
                         --AND RMA_MODEL_CODE = R.ITEM
                         AND ATTRIBUTE1 = 'P'
                         AND RMA_ORG_CODE IS NULL;*/

         UPDATE ITC.LGM_FOC_RMA_TRACKING_DETAILS
            SET RMA_LINE_ID = R.LINE_ID
          WHERE     RMA_NUMBER = R.RMA_NO
                AND RMA_MODEL_CODE = R.ITEM
                AND RMA_SERIAL_NUMBER = R.SERIAL_NO
                AND RMA_LINE_ID IS NULL;



         UPDATE ITC.LGM_FOC_RMA_TRACKING_DETAILS
            SET COMPLAINT_NUMBER = NVL (R.L_COMPLAINT_NO, R.H_COMPLAINT_NO)
          WHERE     RMA_NUMBER = R.RMA_NO
                AND RMA_MODEL_CODE = R.ITEM
                AND RMA_SERIAL_NUMBER = R.SERIAL_NO
                AND COMPLAINT_NUMBER IS NULL;

         UPDATE ITC.LGM_FOC_RMA_TRACKING_DETAILS
            SET DATE_OF_FAILURE =
                   NVL (R.L_DATE_OF_FAILURE, R.H_DATE_OF_FAILURE)
          WHERE     RMA_NUMBER = R.RMA_NO
                AND RMA_MODEL_CODE = R.ITEM
                AND RMA_SERIAL_NUMBER = R.SERIAL_NO
                AND DATE_OF_FAILURE IS NULL;


         UPDATE ITC.LGM_FOC_RMA_TRACKING_DETAILS
            SET MATERIAL_RECEIVED_DATE =
                   NVL (R.L_MTL_REPT_DATE, R.H_MTL_REPT_DATE)
          WHERE     RMA_NUMBER = R.RMA_NO
                AND RMA_MODEL_CODE = R.ITEM
                AND RMA_SERIAL_NUMBER = R.SERIAL_NO
                AND MATERIAL_RECEIVED_DATE IS NULL;

         UPDATE ITC.LGM_FOC_RMA_TRACKING_DETAILS
            SET NFA_NUMBER = NVL (R.L_NFA_NO, r.H_NFA_NO)
          WHERE     RMA_NUMBER = R.RMA_NO
                AND RMA_MODEL_CODE = R.ITEM
                AND RMA_SERIAL_NUMBER = R.SERIAL_NO
                AND NFA_NUMBER IS NULL;

         UPDATE ITC.LGM_FOC_RMA_TRACKING_DETAILS
            SET RMA_NOTE = NVL (R.L_NOTES, R.H_NOTES)
          WHERE     RMA_NUMBER = R.RMA_NO
                AND RMA_MODEL_CODE = R.ITEM
                AND RMA_SERIAL_NUMBER = R.SERIAL_NO
                AND RMA_NOTE IS NULL;

         COMMIT;
      END LOOP;

      FOR R1 IN C2_CUR
      LOOP
         UPDATE ITC.LGM_FOC_RMA_TRACKING_DETAILS
            SET RMA_ORG_CODE = R1.RMA_CODE,
                GRR_NO = R1.GRR_NUM,
                RMA_HEADER_ID = R1.HEADER_ID
          WHERE     RMA_NUMBER = R1.RMA_NO
                AND RMA_MODEL_CODE = R1.ITEM
                AND ATTRIBUTE1 = 'P'
                AND RMA_ORG_CODE IS NULL;

         COMMIT;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_error_flag := 'E';
         l_error_msg := 'Error while in UPDATION - ' || SQLERRM;

         apps.fnd_file.put_line (apps.fnd_file.LOG,
                                 'Error while in UPDATION - ' || SQLERRM);
   END LGM_RMA_UPDATE_PRG;

   PROCEDURE LGM_FOC_RMA_WEBADI_LOAD (
      P_FOC_NUMBER               IN VARCHAR2,
      P_SR_NO                    IN NUMBER,
      P_REMARKS                  IN VARCHAR2,
      P_DEALER_CODE              IN VARCHAR2,
      P_DEALER_NAME              IN VARCHAR2,
      P_FOC_DEPOT_CODE           IN VARCHAR2,
      P_FOC_DEPOT_NAME           IN VARCHAR2,
      P_FOC_MODEL_CODE           IN VARCHAR2,
      P_FOC_SERIAL_NUMBER        IN VARCHAR2,
      P_RMA_ORG_CODE             IN VARCHAR2,
      P_REFERENCE_RMA            IN VARCHAR2,
      P_RMA_NUMBER               IN VARCHAR2,
      P_GRR_NO                   IN VARCHAR2,
      P_RMA_MODEL_CODE           IN VARCHAR2,
      P_RMA_SERIAL_NUMBER        IN VARCHAR2,
      P_FOC_TYPE                 IN VARCHAR2,
      P_FOC_WARRANTY_TYPE        IN VARCHAR2,
      P_DATE_OF_FAILURE          IN VARCHAR2,
      P_MATERIAL_RECEIVED_DATE   IN VARCHAR2,
      P_COMPLAINT_NUMBER         IN VARCHAR2,
      P_NFA_NUMBER               IN VARCHAR2 -- P_ERROR_MESSAGE               OUT VARCHAR2
                                            )
   IS
      lv_SERIAL_NUMBER    VARCHAR2 (256);
      lv_ITEM_CODE        VARCHAR2 (256);
      lv_GRR_NUMBER       VARCHAR2 (256);
      lv_RMA_NUMBER       VARCHAR2 (256);
      lv_RMA_DEPOT_CODE   VARCHAR2 (256);
      Web_Error_MSG       VARCHAR2 (4000);
   BEGIN
      Web_Error_MSG := NULL;


      IF P_REFERENCE_RMA = 'Y' AND P_FOC_TYPE = 'Vendor FOC'
      THEN
         BEGIN
            SELECT DISTINCT SERIAL_NUMBER
              INTO lv_SERIAL_NUMBER
              FROM ITC.LGM_RMA_TRASACTION_DETAILS
             WHERE     RMA_NUMBER = P_RMA_NUMBER
                   AND ITEM_CODE = P_RMA_MODEL_CODE
                   AND SERIAL_NUMBER = P_RMA_SERIAL_NUMBER
                   AND GRR_NUMBER = P_GRR_NO;
         --   AND RMA_DEPOT_CODE = P_RMA_ORG_CODE;
         --  AND RMA_DEALER_CODE = P_DEALER_CODE;
         EXCEPTION
            WHEN OTHERS
            THEN
               Web_Error_MSG := 'Invalid RMA Serial Number';
               raise_application_error (
                  -20001,
                  'Excption-(Validation-1) ' || Web_Error_MSG);
         END;
      END IF;


      IF P_REFERENCE_RMA = 'Y' AND P_FOC_TYPE = 'Dealer FOC'
      THEN
         BEGIN
            SELECT DISTINCT SERIAL_NUMBER
              INTO lv_SERIAL_NUMBER
              FROM ITC.LGM_RMA_TRASACTION_DETAILS
             WHERE     RMA_NUMBER = P_RMA_NUMBER
                   AND ITEM_CODE = P_RMA_MODEL_CODE
                   AND SERIAL_NUMBER = P_RMA_SERIAL_NUMBER
                   AND GRR_NUMBER = P_GRR_NO
                   --   AND RMA_DEPOT_CODE = P_RMA_ORG_CODE;
                   AND RMA_DEALER_CODE = P_DEALER_CODE;
         EXCEPTION
            WHEN OTHERS
            THEN
               Web_Error_MSG := 'Invalid RMA Serial Number';
               raise_application_error (
                  -20001,
                  'Excption-(Validation-1) ' || Web_Error_MSG);
         END;
      END IF;


      IF P_REFERENCE_RMA = 'Y'
      THEN
         BEGIN
            SELECT DISTINCT ITEM_CODE
              INTO lv_ITEM_CODE
              FROM ITC.LGM_RMA_TRASACTION_DETAILS
             WHERE     RMA_NUMBER = P_RMA_NUMBER
                   AND ITEM_CODE = P_RMA_MODEL_CODE
                   AND GRR_NUMBER = P_GRR_NO
                   AND RMA_DEPOT_CODE = P_RMA_ORG_CODE;
         -- AND RMA_DEALER_CODE = P_DEALER_CODE;
         EXCEPTION
            WHEN OTHERS
            THEN
               Web_Error_MSG := 'Invalid RMA Item Code';
               raise_application_error (
                  -20001,
                  'Excption-(Validation-1) ' || Web_Error_MSG);
         END;
      END IF;

      IF P_REFERENCE_RMA = 'N'
      THEN
         BEGIN
            SELECT DISTINCT SERIAL_NUMBER
              INTO lv_SERIAL_NUMBER
              FROM mtl_serial_numbers msn, apps.mtl_system_items_kfv msi
             WHERE     msn.INVENTORY_ITEM_ID = msi.INVENTORY_ITEM_ID
                   AND msn.current_organization_id = msi.organization_id
                   AND msn.SERIAL_NUMBER = P_RMA_SERIAL_NUMBER
                   AND msi.CONCATENATED_SEGMENTS = P_RMA_MODEL_CODE;
         EXCEPTION
            WHEN OTHERS
            THEN
               Web_Error_MSG := 'Invalid RMA Serial Number';
               raise_application_error (
                  -20001,
                  'Excption-(Validation-1) ' || Web_Error_MSG);
         END;
      END IF;

      IF P_REFERENCE_RMA = 'N'
      THEN
         BEGIN
            SELECT CONCATENATED_SEGMENTS
              INTO lv_ITEM_CODE
              FROM ITC.LGM_FOC_RMA_SYSTEM_ITEMS_V
             WHERE CONCATENATED_SEGMENTS = P_RMA_MODEL_CODE;

         EXCEPTION
            WHEN OTHERS
            THEN
               Web_Error_MSG := 'Invalid RMA Item Code';
               raise_application_error (
                  -20001,
                  'Excption-(Validation-1) ' || Web_Error_MSG);
         END;
      END IF;

      IF P_REFERENCE_RMA = 'Y'
      THEN
         BEGIN
            SELECT DISTINCT GRR_NUMBER
              INTO lv_GRR_NUMBER
              FROM ITC.LGM_RMA_TRASACTION_DETAILS
             WHERE     RMA_NUMBER = P_RMA_NUMBER
                   AND ITEM_CODE = P_RMA_MODEL_CODE
                   AND GRR_NUMBER = P_GRR_NO
                   AND RMA_DEPOT_CODE = P_RMA_ORG_CODE;
         -- AND RMA_DEALER_CODE = P_DEALER_CODE;
         EXCEPTION
            WHEN OTHERS
            THEN
               Web_Error_MSG := 'Invalid GRR no';
               raise_application_error (
                  -20001,
                  'Excption-(Validation-1) ' || Web_Error_MSG);
         END;
      END IF;

      IF P_REFERENCE_RMA = 'Y' AND P_FOC_TYPE = 'Dealer FOC'
      THEN
         BEGIN
            SELECT DISTINCT (a.RMA_NUMBER)
              INTO lv_RMA_NUMBER
              FROM ITC.LGM_RMA_TRASACTION_DETAILS a,
                   ITC.LGM_FOC_RMA_TRACKING_DETAILS b
             WHERE     1 = 1
                   AND a.RMA_NUMBER = P_RMA_NUMBER
                   AND a.RMA_DEPOT_CODE = P_RMA_ORG_CODE
                   AND a.RMA_DEALER_CODE = P_DEALER_CODE
                   AND a.RMA_NUMBER = b.RMA_NUMBER
                   AND b.FOC_TYPE = 'Dealer FOC'
                   AND B.REFERENCE_RMA = 'Y';
         --AND B.RMA_SERIAL_NUMBER IS NOT NULL;
         --AND B.SEQ_NO = P_SR_NO;
         EXCEPTION
            WHEN OTHERS
            THEN
               Web_Error_MSG := 'Invalid RMA Number for Dealer FOC';
               raise_application_error (
                  -20001,
                  'Excption-(Validation-1) ' || Web_Error_MSG);
         END;
      END IF;

      IF P_REFERENCE_RMA = 'Y' AND P_FOC_TYPE = 'Vendor FOC'
      THEN
         BEGIN
            SELECT DISTINCT (a.RMA_NUMBER)
              INTO lv_RMA_NUMBER
              FROM ITC.LGM_RMA_TRASACTION_DETAILS a,
                   ITC.LGM_FOC_RMA_TRACKING_DETAILS b
             WHERE     1 = 1
                   --  AND a.RMA_DEALER_CODE = P_DEALER_CODE
                   AND a.RMA_NUMBER = P_RMA_NUMBER
                   AND a.RMA_NUMBER = b.RMA_NUMBER
                   AND b.FOC_TYPE = 'Vendor FOC'
                   AND B.REFERENCE_RMA = 'Y';
         -- AND B.SEQ_NO = P_SR_NO;
         EXCEPTION
            WHEN OTHERS
            THEN
               Web_Error_MSG := 'Invalid RMA Number for Vendor FOC';
               raise_application_error (
                  -20001,
                  'Excption-(Validation-1) ' || Web_Error_MSG);
         END;
      END IF;

      IF P_REFERENCE_RMA = 'Y'                 --AND P_FOC_TYPE = 'Dealer FOC'
      THEN
         BEGIN
            SELECT DISTINCT (a.RMA_DEPOT_CODE)
              INTO lv_RMA_DEPOT_CODE
              FROM ITC.LGM_RMA_TRASACTION_DETAILS a,
                   ITC.LGM_FOC_RMA_TRACKING_DETAILS b
             WHERE     1 = 1
                   AND a.RMA_DEPOT_CODE IN
                          (SELECT ffv.flex_value
                             FROM fnd_flex_value_sets ffvs,
                                  fnd_flex_values ffv,
                                  fnd_flex_values_tl ffvt
                            WHERE     ffvs.flex_value_set_id =
                                         ffv.flex_value_set_id
                                  AND ffv.flex_value_id = ffvt.flex_value_id
                                  AND ffvt.language = USERENV ('LANG')
                                  AND ffv.enabled_flag = 'Y'
                                  AND flex_value_set_name =
                                         'LGM_AGRI_FOC_RMA_ORG'
                                  AND A.RMA_DEPOT_CODE = P_RMA_ORG_CODE)
                   AND a.RMA_NUMBER = b.RMA_NUMBER
                   -- AND b.FOC_TYPE = 'Dealer FOC'
                   AND B.REFERENCE_RMA = 'Y';
         --AND B.SEQ_NO = P_SR_NO;
         EXCEPTION
            WHEN OTHERS
            THEN
               Web_Error_MSG := 'Invalid RMA Org Code';
               raise_application_error (
                  -20001,
                  'Excption-(Validation-1) ' || Web_Error_MSG);
         END;
      END IF;

      IF P_REFERENCE_RMA = 'N'
      THEN
         BEGIN
            SELECT DISTINCT (a.RMA_DEPOT_CODE)
              INTO lv_RMA_DEPOT_CODE
              FROM ITC.LGM_RMA_TRASACTION_DETAILS a,
                   ITC.LGM_FOC_RMA_TRACKING_DETAILS b
             WHERE     1 = 1
                   AND a.RMA_DEPOT_CODE IN
                          (SELECT ffv.flex_value
                             FROM fnd_flex_value_sets ffvs,
                                  fnd_flex_values ffv,
                                  fnd_flex_values_tl ffvt
                            WHERE     ffvs.flex_value_set_id =
                                         ffv.flex_value_set_id
                                  AND ffv.flex_value_id = ffvt.flex_value_id
                                  AND ffvt.language = USERENV ('LANG')
                                  AND ffv.enabled_flag = 'Y'
                                  AND flex_value_set_name =
                                         'LGM_AGRI_FOC_RMA_ORG'
                                  AND RMA_DEPOT_CODE = P_RMA_ORG_CODE)
                   AND a.RMA_NUMBER = b.RMA_NUMBER
                   AND B.REFERENCE_RMA = 'N';
         -- AND B.SEQ_NO = P_SR_NO;
         EXCEPTION
            WHEN OTHERS
            THEN
               Web_Error_MSG := 'Invalid RMA Org Code';
               raise_application_error (
                  -20001,
                  'Excption-(Validation-1) ' || Web_Error_MSG);
         END;
      END IF;



      UPDATE ITC.LGM_FOC_RMA_TRACKING_DETAILS
         SET RMA_NOTE = P_REMARKS,
             NFA_NUMBER = P_NFA_NUMBER,
             MATERIAL_RECEIVED_DATE = P_MATERIAL_RECEIVED_DATE,
             COMPLAINT_NUMBER = P_COMPLAINT_NUMBER,
             DATE_OF_FAILURE = P_DATE_OF_FAILURE,
             RMA_ORG_CODE = lv_RMA_DEPOT_CODE,
             RMA_NUMBER = lv_RMA_NUMBER,
             GRR_NO = lv_GRR_NUMBER,
             RMA_MODEL_CODE = lv_ITEM_CODE,
             RMA_SERIAL_NUMBER = lv_SERIAL_NUMBER
       WHERE FOC_ORDER_NUMBER = P_FOC_NUMBER AND SEQ_NO = P_SR_NO;

      COMMIT;
   -- END IF;
   END LGM_FOC_RMA_WEBADI_LOAD;
END LGM_FOC_RMA_TRK_PKG;
/
