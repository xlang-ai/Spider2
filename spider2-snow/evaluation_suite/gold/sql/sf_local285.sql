SELECT 
    EXTRACT(YEAR FROM TO_DATE(w."whsle_date")) as year,
    c."category_name",
    ROUND(AVG(w."whsle_px_rmb-kg"), 2) as avg_wholesale_price,
    ROUND(MAX(w."whsle_px_rmb-kg"), 2) as max_wholesale_price,
    ROUND(MIN(w."whsle_px_rmb-kg"), 2) as min_wholesale_price,
    ROUND(MAX(w."whsle_px_rmb-kg") - MIN(w."whsle_px_rmb-kg"), 2) as wholesale_price_difference,
    ROUND(SUM(w."whsle_px_rmb-kg" * t."qty_sold(kg)"), 2) as total_wholesale_price,
    ROUND(SUM(t."unit_selling_px_rmb/kg" * t."qty_sold(kg)"), 2) as total_selling_price,
    ROUND(AVG(l."loss_rate_%"), 2) as avg_loss_rate,
    ROUND(SUM(w."whsle_px_rmb-kg" * t."qty_sold(kg)" * l."loss_rate_%" / 100), 2) as total_loss,
    ROUND(SUM(t."unit_selling_px_rmb/kg" * t."qty_sold(kg)") - 
          SUM(w."whsle_px_rmb-kg" * t."qty_sold(kg)") - 
          SUM(w."whsle_px_rmb-kg" * t."qty_sold(kg)" * l."loss_rate_%" / 100), 2) as profit
FROM "BANK_SALES_TRADING"."BANK_SALES_TRADING"."VEG_WHSLE_DF" w
JOIN "BANK_SALES_TRADING"."BANK_SALES_TRADING"."VEG_TXN_DF" t ON w."item_code" = t."item_code" AND w."whsle_date" = t."txn_date"
JOIN "BANK_SALES_TRADING"."BANK_SALES_TRADING"."VEG_CAT" c ON w."item_code" = c."item_code"
JOIN "BANK_SALES_TRADING"."BANK_SALES_TRADING"."VEG_LOSS_RATE_DF" l ON w."item_code" = l."item_code"
WHERE EXTRACT(YEAR FROM TO_DATE(w."whsle_date")) BETWEEN 2020 AND 2023
    AND t."sale/return" = 'sale'
GROUP BY EXTRACT(YEAR FROM TO_DATE(w."whsle_date")), c."category_name"
ORDER BY year, c."category_name"