/*
==============================================
Bronze LAYER Quality check after ETL process |
==============================================
TABLE 3: crm_sales_details
-----------------------
*/
USE DataWarehouse;

SELECT * FROM bronze.crm_sales_details; 
SELECT distinct COUNT(*) FROM bronze.crm_sales_details; --60398

SELECT COUNT(*) as slsCount, sls_prd_key
FROM bronze.crm_sales_details
group by sls_prd_key
having COUNT(*) > 1 
order by sls_prd_key

SELECT
	sls_ord_num,
	sls_prd_key
FROM bronze.crm_sales_details
WHERE TRIM(sls_ord_num) != sls_ord_num OR
	TRIM(sls_prd_key) != sls_prd_key;

-- Type casting Transformation 
SELECT 
	CASE 
		WHEN sls_order_dt = 0 OR LEN(sls_order_dt) !=8
		THEN NULL 
		ELSE cast(CAST(sls_order_dt AS varchar)AS date) 
	END Sls_Order_Date,
	CASE 
		WHEN sls_due_dt = 0 OR LEN(sls_due_dt) !=8
		THEN NULL 
		ELSE cast(CAST(sls_due_dt AS varchar)AS date) 
	END sls_due_date,
	CASE 
		WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) !=8
		THEN NULL 
		ELSE cast(CAST(sls_ship_dt AS varchar)AS date) 
	END sls_ship_date
FROM bronze.crm_sales_details

/* Quantitative column fixation for any negative and vague values with factual data
 Rule_1: If sales is negative, 0, null, then derive using quantity * price
 Rule_2: If price is zero, null - calculate using sales and quality
 Rule_3: If price is negative, convert to positive
*/
SELECT 
	sls_ord_num,
	sls_price,
	sls_quantity,
	sls_sales
FROM bronze.crm_sales_details
WHERE sls_sales != sls_price * sls_quantity
or sls_sales is null or sls_sales <= 0 
or sls_price is null or sls_price <= 0  
or sls_quantity is null or sls_quantity <= 0 
ORDER BY sls_sales, sls_quantity, sls_price;

SELECT 
	sls_ord_num,
	sls_price,
	CASE 
		WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales/NULLIF(sls_quantity,0)
		WHEN (sls_price != sls_sales/sls_quantity) then sls_price
		ELSE sls_price
	end sls_price_new,
	sls_quantity,
	sls_sales,
	CASE 
		WHEN sls_sales is null OR sls_sales <= 0 OR sls_sales!= abs(sls_price) * sls_quantity
			THEN abs(sls_price) * sls_quantity
		ELSE sls_sales
	end AS sls_sales_new
FROM bronze.crm_sales_details
WHERE sls_price != sls_sales/sls_quantity



