CREATE OR REPLACE PROCEDURE APPS.ADOR_FA_MGR_PROC
(P_Username  IN VARCHAR2,
 P_respname  IN VARCHAR2)
IS
   l_trans_rec                FA_API_TYPES.trans_rec_type;
   l_dist_trans_rec           FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec            FA_API_TYPES.asset_hdr_rec_type;
   l_asset_desc_rec           FA_API_TYPES.asset_desc_rec_type;
   l_asset_cat_rec            FA_API_TYPES.asset_cat_rec_type;
   l_asset_type_rec           FA_API_TYPES.asset_type_rec_type;
   l_asset_hierarchy_rec      FA_API_TYPES.asset_hierarchy_rec_type;
   l_asset_fin_rec            FA_API_TYPES.asset_fin_rec_type;
   l_asset_deprn_rec          FA_API_TYPES.asset_deprn_rec_type;
   l_asset_dist_rec           FA_API_TYPES.asset_dist_rec_type;
   l_asset_dist_tbl           FA_API_TYPES.asset_dist_tbl_type;
   l_inv_tbl                  FA_API_TYPES.inv_tbl_type;
   l_inv_rate_tbl             FA_API_TYPES.inv_rate_tbl_type;
   l_return_status            VARCHAR2(1);     
   l_mesg_count               NUMBER;
   l_mesg                     VARCHAR2(4000);
   l_user_id                  NUMBER;
   l_resp_id                  NUMBER := 50665;  -- ENTER RESPONSIBILITY ID
   l_resp_appl_id             NUMBER := 140;    -- ENTER APPLICATION ID
   v_asset_category_id        NUMBER;
   v_code_combination_id      NUMBER;
   v_location_id              NUMBER;
   l_error_msg                VARCHAR2(100);
   l_count                    NUMBER;

CURSOR C1 IS 
SELECT * FROM CUS.ADOR_FA_MIGRATION_STG
WHERE  1=1
AND (STATUS IS NULL  OR STATUS = 'E');

BEGIN
select user_id
into l_user_id
from apps.fnd_user
where 1=1
and upper(user_name)=upper(P_username); --Enter Username
  
select responsibility_id,
application_id
into l_resp_id,
l_resp_appl_id
from apps.fnd_responsibility_tl
where 1                       =1
and upper(responsibility_name)=upper(P_respname) --Assets Stand By Super User
and responsibility_id = l_resp_id 
and application_id = l_resp_appl_id;

--======================================================================-
fnd_global.apps_initialize (user_id       => l_user_id, 
                            resp_id       => l_resp_id, 
                            resp_appl_id  => l_resp_appl_id);
--======================================================================--
FOR I IN C1 LOOP
l_return_status         := NULL;
l_mesg_count            := NULL;
l_mesg                  := NULL;
v_asset_category_id     := NULL;
v_code_combination_id   := NULL;
v_location_id           := NULL;
l_error_msg             := NULL;
l_count                 := NULL;
l_asset_hdr_rec.asset_id := NULL;
l_asset_desc_rec.asset_number := NULL;

dbms_output.enable(10000000);
FA_SRVR_MSG.Init_Server_Message; 

SELECT COUNT(*) 
INTO l_count
FROM apps.fa_additions_tl
WHERE upper(description) = upper(i.description);

IF l_count = 0 THEN
--==========================Category=========================
BEGIN
SELECT category_id 
INTO v_asset_category_id 
FROM apps.fa_categories
WHERE segment1||'.'||upper(segment2)||'.'||upper(segment3) = upper(i.category);
EXCEPTION
WHEN OTHERS THEN
l_error_msg := 'Invalid Category ';
END;
--==========================Expense Account=========================--
BEGIN
SELECT code_combination_id
INTO v_code_combination_id 
FROM apps.gl_code_combinations_kfv
WHERE concatenated_segments = i.expense_account;
EXCEPTION
WHEN OTHERS THEN
l_error_msg := 'Invalid Expense Account in Assignments ';
END;
--==========================Location=========================--
BEGIN
SELECT location_id
INTO v_location_id
FROM apps.fa_locations
WHERE segment1||'.'||segment2||'.'||segment3 = i.location;
EXCEPTION
WHEN OTHERS THEN
l_error_msg := 'Invalid Location in Assignments ';
END;
                IF l_error_msg  IS NULL THEN
--Asset Details
l_asset_desc_rec.asset_number                 := i.asset_number;
l_asset_desc_rec.description                  := i.description;
l_asset_desc_rec.in_use_flag                  := 'YES';
l_asset_desc_rec.new_used                     := 'NEW';
l_asset_desc_rec.owned_leased                 := 'OWNED';
l_asset_desc_rec.current_units                := i.current_units;
--Category
l_asset_cat_rec.category_id                   := v_asset_category_id;     
l_asset_type_rec.asset_type                   := 'CAPITALIZED';
-- Books
l_asset_hdr_rec.book_type_code                := 'ADOR FA REG';                       
l_asset_fin_rec.cost                          := i.current_cost;
l_asset_fin_rec.salvage_type                  := 'PCT';
l_asset_deprn_rec.ytd_deprn                   := i.ytd_depreciation;
l_asset_deprn_rec.deprn_reserve               := i.accumulated_depreciation;
l_asset_fin_rec.percent_salvage_value         := i.SALVAGE_VALUE_PERCENT;
--Deprication
l_asset_fin_rec.depreciate_flag               := 'YES';
l_asset_fin_rec.deprn_method_code             := 'STL';
l_asset_fin_rec.life_in_months                := i.life_years;
l_asset_fin_rec.date_placed_in_service        := TO_DATE(i.date_in_service,'DD-MON-RRRR');
l_trans_rec.transaction_date_entered          := TO_DATE(i.date_in_service,'DD-MON-RRRR');
l_asset_fin_rec.prorate_convention_code       := 'MTH-START'; 
l_trans_rec.transaction_subtype     		  :='AMORTIZED';
l_trans_rec.amortization_start_date 		  := TO_DATE(i.amortization_start_date,'DD-MON-RRRR');
l_asset_fin_rec.allowed_deprn_limit           := i.PERCENT; --Depreciation Limit Percent 

--Assignments--
l_asset_dist_rec.units_assigned               := i.units_assigned;--Units Change
l_asset_dist_rec.expense_ccid                 := v_code_combination_id;-- Expense Account ID
l_asset_dist_rec.location_ccid                := v_location_id;--Location
l_asset_dist_rec.assigned_to                  := NULL;-- Name
l_asset_dist_rec.transaction_units            := l_asset_dist_rec.units_assigned;
l_asset_dist_tbl(1)                           := l_asset_dist_rec;


   -- call the api 
           fa_addition_pub.do_addition(
           p_api_version             => 1.0,
           p_init_msg_list           => FND_API.G_FALSE,
           p_commit                  => FND_API.G_FALSE,
           p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
           p_calling_fn              => NULL,
           x_return_status           => l_return_status,
           x_msg_count               => l_mesg_count,
           x_msg_data                => l_mesg,
           px_trans_rec              => l_trans_rec,
           px_dist_trans_rec         => l_dist_trans_rec,
           px_asset_hdr_rec          => l_asset_hdr_rec,
           px_asset_desc_rec         => l_asset_desc_rec,
           px_asset_type_rec         => l_asset_type_rec,
           px_asset_cat_rec          => l_asset_cat_rec,
           px_asset_hierarchy_rec    => l_asset_hierarchy_rec,
           px_asset_fin_rec          => l_asset_fin_rec,
           px_asset_deprn_rec        => l_asset_deprn_rec,
           px_asset_dist_tbl         => l_asset_dist_tbl,
           px_inv_tbl                => l_inv_tbl
          );
          
--==============================Output Review==========================--
IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
  l_mesg_count       := fnd_msg_pub.count_msg;
  IF l_mesg_count     > 0 THEN
    l_mesg      := ';' || SUBSTR(fnd_msg_pub.get(fnd_msg_pub.g_first,fnd_api.g_false),1, 512);
    FOR J IN 1..(l_mesg_count-1)
    LOOP
      l_mesg := l_mesg || ';' || SUBSTR(fnd_msg_pub.get(fnd_msg_pub.g_next,fnd_api.g_false), 1, 512);
    END LOOP;
    fnd_msg_pub.delete_msg();
  END IF;
  UPDATE CUS.ADOR_FA_MIGRATION_STG
  SET status = 'E',
    error_msg     = l_mesg
  WHERE 1                  =1
  AND seq_no = i.seq_no;
ELSE
         UPDATE CUS.ADOR_FA_MIGRATION_STG
         SET status = 'S',error_msg = null
         where seq_no = i.seq_no;
END IF;
COMMIT;
ELSE
UPDATE CUS.ADOR_FA_MIGRATION_STG
SET status = 'E', error_msg =l_error_msg
where seq_no = i.seq_no;
COMMIT;
END IF;
ELSE
UPDATE CUS.ADOR_FA_MIGRATION_STG
SET status = 'E',error_msg = 'Aleady exists...'
where seq_no = i.seq_no;
COMMIT;
END IF;
END LOOP;
END;
--=========================================================================================--
/
