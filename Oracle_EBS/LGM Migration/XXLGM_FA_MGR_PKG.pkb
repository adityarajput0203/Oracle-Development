CREATE OR REPLACE PACKAGE BODY APPS.XXLGM_FA_MGR_PKG
IS
   PROCEDURE XXLGM_FA_INSERT_PRC (P_Username   IN VARCHAR2,     --ACTINLGM_SCM
                                  P_respname   IN VARCHAR2)            --63073
   IS
      l_trans_rec             FA_API_TYPES.trans_rec_type;
      l_dist_trans_rec        FA_API_TYPES.trans_rec_type;
      l_asset_hdr_rec         FA_API_TYPES.asset_hdr_rec_type;
      l_asset_desc_rec        FA_API_TYPES.asset_desc_rec_type;
      l_asset_cat_rec         FA_API_TYPES.asset_cat_rec_type;
      l_asset_type_rec        FA_API_TYPES.asset_type_rec_type;
      l_asset_hierarchy_rec   FA_API_TYPES.asset_hierarchy_rec_type;
      l_asset_fin_rec         FA_API_TYPES.asset_fin_rec_type;
      l_asset_deprn_rec       FA_API_TYPES.asset_deprn_rec_type;
      l_asset_dist_rec        FA_API_TYPES.asset_dist_rec_type;
      l_asset_dist_tbl        FA_API_TYPES.asset_dist_tbl_type;
      l_inv_tbl               FA_API_TYPES.inv_tbl_type;
      l_inv_rate_tbl          FA_API_TYPES.inv_rate_tbl_type;
      l_return_status         VARCHAR2 (1);
      l_mesg_count            NUMBER;
      l_mesg                  VARCHAR2 (4000);
      l_user_id               NUMBER;
      l_resp_id               NUMBER := 63073;      -- ENTER RESPONSIBILITY ID
      l_resp_appl_id          NUMBER := 140;           -- ENTER APPLICATION ID
      v_asset_category_id     NUMBER;
      v_code_combination_id   NUMBER;
      v_location_id           NUMBER;
      v_asset_key_ccid        NUMBER;
      v_person_id             NUMBER;
      l_error_msg             VARCHAR2 (100);
      l_count                 NUMBER;

      CURSOR C1
      IS
         SELECT *
           FROM ITC.XXLGM_FA_MIGRATION_STG_T
          WHERE 1 = 1 AND (STATUS IS NULL OR STATUS = 'E');
   BEGIN
      SELECT user_id
        INTO l_user_id
        FROM apps.fnd_user
       WHERE 1 = 1 AND UPPER (user_name) = UPPER (P_username); --Enter Username

      SELECT responsibility_id, application_id
        INTO l_resp_id, l_resp_appl_id
        FROM apps.fnd_responsibility_tl
       WHERE     1 = 1
             AND UPPER (responsibility_name) = UPPER (P_respname) --Assets Stand By Super User
             AND responsibility_id = l_resp_id
             AND application_id = l_resp_appl_id;

      --======================================================================-
      fnd_global.apps_initialize (user_id        => l_user_id,
                                  resp_id        => l_resp_id,
                                  resp_appl_id   => l_resp_appl_id);

      --======================================================================--
      FOR I IN C1
      LOOP
         l_return_status := NULL;
         l_mesg_count := NULL;
         l_mesg := NULL;
         v_asset_category_id := NULL;
         v_code_combination_id := NULL;
         v_location_id := NULL;
         l_error_msg := NULL;
         l_count := NULL;
         l_asset_hdr_rec.asset_id := NULL;
         l_asset_desc_rec.asset_number := NULL;

         DBMS_OUTPUT.PUT_LINE ('Start');

         DBMS_OUTPUT.enable (10000000);
         FA_SRVR_MSG.Init_Server_Message;

         SELECT COUNT (*)
           INTO l_count
           FROM apps.fa_additions_tl
          WHERE UPPER (description) = UPPER (i.description);

         IF l_count = 0
         THEN
            --==========================Category=========================
            BEGIN
               SELECT category_id
                 INTO v_asset_category_id
                 FROM apps.fa_categories_kfv
                WHERE concatenated_segments = UPPER (i.category);
            EXCEPTION
               WHEN OTHERS
               THEN
                  l_error_msg := 'Invalid Category ';
            END;

            --==========================Expense Account=========================--
            BEGIN
               SELECT code_combination_id
                 INTO v_code_combination_id
                 FROM apps.gl_code_combinations_kfv
                WHERE concatenated_segments = i.expense_account;
            EXCEPTION
               WHEN OTHERS
               THEN
                  l_error_msg := 'Invalid Expense Account in Assignments ';
            END;

            --==========================Location=========================--
            BEGIN
               SELECT location_id
                 INTO v_location_id
                 FROM apps.fa_locations_kfv
                WHERE concatenated_segments = i.location;
            EXCEPTION
               WHEN OTHERS
               THEN
                  l_error_msg := 'Invalid Location in Assignments ';
            END;

            --==========================Asset Key=========================--
            BEGIN
               SELECT CODE_COMBINATION_ID
                 INTO v_asset_key_ccid
                 FROM apps.FA_ASSET_KEYWORDS_KFV
                WHERE concatenated_segments = i.ASSET_KEY;
            EXCEPTION
               WHEN OTHERS
               THEN
                  l_error_msg := 'Invalid Asset Key in Assignments ';
            END;

            --==========================Employee=========================--
            SELECT PERSON_ID
              INTO v_person_id
              FROM PER_ALL_PEOPLE_F
             WHERE     1 = 1
                   AND EMPLOYEE_NUMBER = i.EMPLOYEE_NUMBER
                   AND EFFECTIVE_END_DATE >= SYSDATE;

            DBMS_OUTPUT.PUT_LINE ('error Message: ' || l_error_msg);


            IF l_error_msg IS NULL
            THEN
               --Asset Details
               l_asset_desc_rec.asset_number := i.asset_number;
               l_asset_desc_rec.description := i.description;
               l_asset_desc_rec.asset_key_ccid := v_asset_key_ccid;
               l_asset_desc_rec.in_use_flag := i.use_flag;
               l_asset_desc_rec.new_used := i.NEW_USED;
               l_asset_desc_rec.owned_leased := i.OWNED_LEASED;
               l_asset_desc_rec.current_units := i.current_units;

               --Category
               l_asset_cat_rec.category_id := v_asset_category_id;
               l_asset_type_rec.asset_type := i.ASSET_TYPE;
               l_asset_cat_rec.desc_flex.context := i.context;
               l_asset_cat_rec.desc_flex.attribute10 := i.EMPLOYEE_NUMBER;

               -- Books
               l_asset_hdr_rec.book_type_code := i.BOOK;
               l_asset_fin_rec.cost := i.current_cost;
               l_asset_fin_rec.original_cost := i.current_cost; --Added by Sandesh
               l_asset_fin_rec.salvage_type := i.SALVAGE_TYPE;
               l_asset_deprn_rec.ytd_deprn := i.ytd_depreciation;
               l_asset_deprn_rec.deprn_reserve := i.accumulated_depreciation;
               l_asset_fin_rec.percent_salvage_value :=
                  i.percent_salvage_value;

               --Deprication
               l_asset_fin_rec.depreciate_flag := i.depreciate_flag;
               l_asset_fin_rec.deprn_method_code := i.method;
               l_asset_fin_rec.life_in_months := i.life_years;
               l_asset_fin_rec.date_placed_in_service :=
                  TO_DATE (i.date_in_service, 'DD-MON-RRRR');
               l_trans_rec.transaction_date_entered :=
                  TO_DATE (i.date_in_service, 'DD-MON-RRRR');
               l_asset_fin_rec.prorate_convention_code := i.prorate_convention;
               l_trans_rec.transaction_subtype := i.transaction_subtype;
               l_trans_rec.amortization_start_date :=
                  TO_DATE (i.amortization_start_date, 'DD-MON-RRRR');
               l_asset_fin_rec.allowed_deprn_limit := i.allowed_deprn_limit;
               l_asset_fin_rec.salvage_value := i.salvage_value;

               --Assignments--
               l_asset_dist_rec.units_assigned := i.units_assigned; --Units Change
               l_asset_dist_rec.expense_ccid := v_code_combination_id; -- Expense Account ID
               l_asset_dist_rec.location_ccid := v_location_id;     --Location
               l_asset_dist_rec.assigned_to := v_person_id;            -- Name
               l_asset_dist_rec.transaction_units :=
                  l_asset_dist_rec.units_assigned;
               l_asset_dist_tbl (1) := l_asset_dist_rec;

               DBMS_OUTPUT.PUT_LINE (
                     'Calling API Now''transaction_units: '
                  || CHR (13)
                  || 'transaction_units:'
                  || l_asset_dist_rec.transaction_units
                  || 'assigned_to:'
                  || l_asset_dist_rec.assigned_to
                  || 'location_ccid:'
                  || l_asset_dist_rec.location_ccid
                  || 'expense_ccid:'
                  || l_asset_dist_rec.expense_ccid
                  || 'units_assigned:'
                  || l_asset_dist_rec.units_assigned
                  || 'salvage_value:'
                  || l_asset_fin_rec.salvage_value
                  || 'allowed_deprn_limit:'
                  || l_asset_fin_rec.allowed_deprn_limit
                  || 'amortization_start_date:'
                  || l_trans_rec.amortization_start_date
                  || 'transaction_subtype:'
                  || l_trans_rec.transaction_subtype
                  || 'prorate_convention_code:'
                  || l_asset_fin_rec.prorate_convention_code
                  || 'transaction_date_entered:'
                  || l_trans_rec.transaction_date_entered
                  || 'date_placed_in_service:'
                  || l_asset_fin_rec.date_placed_in_service
                  || 'life_in_months:'
                  || l_asset_fin_rec.life_in_months
                  || 'deprn_method_code:'
                  || l_asset_fin_rec.deprn_method_code
                  || 'depreciate_flag:'
                  || l_asset_fin_rec.depreciate_flag
                  || 'percent_salvage_value:'
                  || l_asset_fin_rec.percent_salvage_value
                  || 'deprn_reserve:'
                  || l_asset_deprn_rec.deprn_reserve
                  || 'ytd_deprn:'
                  || l_asset_deprn_rec.ytd_deprn
                  || 'salvage_type:'
                  || l_asset_fin_rec.salvage_type
                  || 'cost:'
                  || l_asset_fin_rec.cost
                  || 'book_type_code:'
                  || l_asset_hdr_rec.book_type_code
                  || 'asset_type:'
                  || l_asset_type_rec.asset_type
                  || 'category_id:'
                  || l_asset_cat_rec.category_id
                  || 'current_units:'
                  || l_asset_desc_rec.current_units
                  || 'owned_leased:'
                  || l_asset_desc_rec.owned_leased
                  || 'new_used:'
                  || l_asset_desc_rec.new_used
                  || 'in_use_flag:'
                  || l_asset_desc_rec.in_use_flag
                  || 'description:'
                  || l_asset_desc_rec.description
                  || 'asset_number:'
                  || l_asset_desc_rec.asset_number);

               -- call the api
               fa_addition_pub.do_addition (
                  p_api_version            => 1.0,
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_commit                 => FND_API.G_FALSE,
                  p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
                  p_calling_fn             => NULL,
                  x_return_status          => l_return_status,
                  x_msg_count              => l_mesg_count,
                  x_msg_data               => l_mesg,
                  px_trans_rec             => l_trans_rec,
                  px_dist_trans_rec        => l_dist_trans_rec,
                  px_asset_hdr_rec         => l_asset_hdr_rec,
                  px_asset_desc_rec        => l_asset_desc_rec,
                  px_asset_type_rec        => l_asset_type_rec,
                  px_asset_cat_rec         => l_asset_cat_rec,
                  px_asset_hierarchy_rec   => l_asset_hierarchy_rec,
                  px_asset_fin_rec         => l_asset_fin_rec,
                  px_asset_deprn_rec       => l_asset_deprn_rec,
                  px_asset_dist_tbl        => l_asset_dist_tbl,
                  px_inv_tbl               => l_inv_tbl);

               --==============================Output Review==========================--
               DBMS_OUTPUT.PUT_LINE (
                     'The Status is: '
                  || l_return_status
                  || ' message: '
                  || l_mesg
                  || 'msg count: '
                  || l_mesg_count);

               IF (l_return_status <> fnd_api.g_ret_sts_success)
               THEN
                  l_mesg_count := fnd_msg_pub.count_msg;

                  IF l_mesg_count > 0
                  THEN
                     l_mesg :=
                           ';'
                        || SUBSTR (
                              fnd_msg_pub.get (fnd_msg_pub.g_first,
                                               fnd_api.g_false),
                              1,
                              512);

                     FOR J IN 1 .. (l_mesg_count - 1)
                     LOOP
                        l_mesg :=
                              l_mesg
                           || ';'
                           || SUBSTR (
                                 fnd_msg_pub.get (fnd_msg_pub.g_next,
                                                  fnd_api.g_false),
                                 1,
                                 512);
                     END LOOP;

                     fnd_msg_pub.delete_msg ();
                  END IF;

                  UPDATE ITC.XXLGM_FA_MIGRATION_STG_T
                     SET status = 'E', error_msg = l_mesg
                   WHERE 1 = 1 AND seq_no = i.seq_no;
               ELSE
                  UPDATE ITC.XXLGM_FA_MIGRATION_STG_T
                     SET status = 'S', error_msg = NULL
                   WHERE seq_no = i.seq_no;
               END IF;

               COMMIT;
            ELSE
               UPDATE ITC.XXLGM_FA_MIGRATION_STG_T
                  SET status = 'E', error_msg = l_error_msg
                WHERE seq_no = i.seq_no;

               COMMIT;
            END IF;
         ELSE
            UPDATE ITC.XXLGM_FA_MIGRATION_STG_T
               SET status = 'E', error_msg = 'Aleady exists...'
             WHERE seq_no = i.seq_no;

            COMMIT;
         END IF;
      END LOOP;
   END;
END XXLGM_FA_MGR_PKG;
/
