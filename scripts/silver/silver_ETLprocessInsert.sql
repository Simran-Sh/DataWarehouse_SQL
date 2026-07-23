/* ========================
SILVER LAYER -  ETL PROCESS
============================
Script Purspose: 
	This SP performs the ETL (extract, transform, load) process to populate the 'silver' schema tables from the 'bronze' schema tables

Action Performed:
	- Truncate Silver Tables from CRM and ERP source systerms
	- Record the batch and each table load time
	- Insert the transformed and cleansed data from Bronze into silver layer

Parameters:
	No parametrs are accepted by this SP. 
	No retun values
------------------------------------*/
Use DataWarehouse;

EXEC silver.load_silver;

CREATE OR ALTER PROCEDURE silver.load_silver 
AS
BEGIN
 DECLARE @starttime DATETIME,
		@endtime DATETIME,
		@batch_starttime DATETIME,
		@batch_endtime DATETIME;

 BEGIN TRY
		SET @batch_starttime = GETDATE();
		PRINT '======================';
		PRINT 'lOADING SILVER LAYER';
		PRINT '======================';
		PRINT 'SILVER LAYER: CRM SOURCE SYSTEM LOADING';
		PRINT '-------------------------';

		/* ---------------------
		TABLE 1: crm_cust_info
        ----------------------*/
		PRINT 'Truncating crm_cust_info table';
		TRUNCATE TABLE silver.crm_cust_info;
		
		PRINT 'inserting data into crm_cust_info table';
		SET @starttime = GETDATE();
		INSERT INTO silver.crm_cust_info
		(
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gender,
			cst_create_date
		)
		SELECT 
			cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname,
			CASE WHEN UPPER(TRIM(cst_marital_status)) ='M' THEN 'Married'
				 WHEN UPPER(TRIM(cst_marital_status)) ='S' THEN 'Single'
				 ELSE 'n/a'
			END cst_marital_status,
			CASE UPPER(TRIM(cst_gender))
				WHEN 'F' THEN 'Female'
				WHEN 'M' THEN 'Male'
				ELSE 'n/a'
			END cst_gnder,
			cst_create_date
		FROM 
		(
		SELECT
			*,
			ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL
		)t 
		WHERE flag_last = 1;

		SET @endtime = GETDATE();
		PRINT 'load Duration is'+ cast(datediff(second,@starttime,@endtime) as varchar)+'seconds';
		PRINT '-------------------------';
		/*
		----------------------
		TABLE 2: crm_prd_info
		----------------------
		*/
		PRINT 'Truncating crm_prd_info table';
		TRUNCATE TABLE silver.crm_prd_info;

		PRINT 'inserting data into crm_prd_info table';
		SET @starttime = GETDATE();
		INSERT INTO silver.crm_prd_info 
			(prd_id,
			cat_id,
			sls_prd_key,
			prd_name,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
			)
		SELECT 
			prd_id,
			REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
			SUBSTRING(prd_key,7,LEN(prd_key)) AS sls_prd_key,
			trim(prd_nm) as prd_name,
			ISNULL(prd_cost,0) AS prd_cost,
			CASE UPPER(TRIM(prd_line))
				 WHEN 'M' THEN 'Mountain'
				 WHEN 'R' THEN 'Roads'
				 WHEN 'S' THEN 'Other Sales'
				 WHEN 'T' THEN 'Touring'
				 ELSE 'n/a'
			END AS prd_line,
			cast(prd_start_dt as date) as prd_start_dt,
			CASE -- Casting end date as one day n
				WHEN prd_end_dt IS NULL OR prd_end_dt < prd_start_dt 
					THEN CAST(lead(prd_start_dt) over(PARTITION BY prd_key order by prd_start_dt)-1 AS DATE)
				ELSE CAST(prd_end_dt AS DATE)
			END prd_end_dt
		FROM bronze.crm_prd_info;

		SET @endtime = GETDATE();
		PRINT 'load Duration is'+ cast(datediff(second,@starttime,@endtime) as varchar)+'seconds';
		PRINT '-------------------------';

		/*
		----------------------
		TABLE 3: crm_sales_details
		----------------------
		*/
		PRINT 'Truncating crm_sales_details table';
		TRUNCATE TABLE silver.crm_sales_details;

		PRINT 'inserting data into crm_sales_details table';
		SET @starttime = GETDATE();
		INSERT INTO silver.crm_sales_details(	
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
			)
		SELECT 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE 
				WHEN sls_order_dt = 0 OR LEN(sls_order_dt) !=8
				THEN NULL 
				ELSE cast(CAST(sls_order_dt AS varchar)AS date) 
			END sls_order_dt,
			CASE 
				WHEN sls_due_dt = 0 OR LEN(sls_due_dt) !=8
				THEN NULL 
				ELSE cast(CAST(sls_due_dt AS varchar)AS date) 
			END sls_due_dt,
			CASE 
				WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) !=8
				THEN NULL 
				ELSE cast(CAST(sls_ship_dt AS varchar)AS date) 
			END sls_ship_dt,
			CASE 
				WHEN sls_sales is null OR sls_sales <= 0 OR sls_sales!= abs(sls_price) * sls_quantity
					THEN abs(sls_price) * sls_quantity
				ELSE sls_sales
			END AS sls_sales,
			sls_quantity,
			CASE 
				WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales/NULLIF(sls_quantity,0)
				WHEN (sls_price != sls_sales/sls_quantity) then sls_price
				ELSE sls_price
			END sls_price
		FROM bronze.crm_sales_details;

		SET @endtime = GETDATE();
		PRINT 'load Duration is'+ cast(datediff(second,@starttime,@endtime) as varchar)+'seconds';
		PRINT '-------------------------';
		/*----------------
		TABLE 4: erp_cus
		----------------- */
		PRINT '======================';
		PRINT 'SILVER LAYER: ERP SOURCE SYSTEM LOADING';
		PRINT '-------------------------';

		PRINT 'Truncating erp_cust_az12 table';
		TRUNCATE TABLE silver.erp_cust_az12;

		PRINT 'inserting data into erp_cust_az12 table';
		SET @starttime = GETDATE();
		INSERT INTO silver.erp_cust_az12 (cid,bdate,gender)
		SELECT 
			CASE 
				WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
				else cid
			END cid,
			CASE 
				WHEN bdate> getdate() THEN null
				else bdate
			END bdate,
			CASE 
				WHEN UPPER(TRIM(GENDER)) IN ('F','Female') THEN 'Female'
				WHEN UPPER(TRIM(GENDER)) IN ('M','Male') THEN 'Male'
				when GENDER is null then 'n/a'
				ELSE 'n/a'
			END gender
		from bronze.erp_cust_az12;

		SET @endtime = GETDATE();
		PRINT 'load Duration is'+ cast(datediff(second,@starttime,@endtime) as varchar)+'seconds';
		PRINT '-------------------------';

		/*----------------
		TABLE 5: erp_loc
		----------------- */
		PRINT 'Truncating erp_loc_a101 table';
		TRUNCATE TABLE silver.erp_loc_a101;

		PRINT 'inserting data into erp_loc_a101 table';
		SET @starttime = GETDATE();
		INSERT INTO silver.erp_loc_a101 (cid,country)
		SELECT 
			REPLACE(CID,'-','') as cid,
			CASE 
				WHEN country in ('DE','Germany') THEN 'Germany'
				WHEN country in ('United States','US','USA') THEN 'United States'
				WHEN country = '' or country is null then 'n/a'
				ELSE trim(country)
			END country
		from bronze.erp_loc_a101;

		SET @endtime = GETDATE();
		PRINT 'load Duration is'+ cast(datediff(second,@starttime,@endtime) as varchar)+'seconds';
		PRINT '-------------------------';

		/*---------------
		TABLE 6: erp_cat
		------------------ */
		PRINT 'Truncating erp_px_cat_g1v2 table';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;

		PRINT 'inserting data into erp_px_cat_g1v2 table';
		SET @starttime = GETDATE();
		INSERT INTO silver.erp_px_cat_g1v2 (id,cat,subcat,maintenance)
		SELECT 
			id,
			trim(cat),
			trim(subcat),
			trim(maintenance) 
		from bronze.erp_px_cat_g1v2;

		SET @endtime = GETDATE();
		PRINT 'load Duration is'+ cast(datediff(second,@starttime,@endtime) as varchar)+'seconds';
		PRINT '-------------------------';
		SET @batch_endtime = GETDATE();
		PRINT '-------------------------------------------------------';
		PRINT 'Silver layer load Duration is'+ cast(datediff(second,@batch_starttime,@batch_endtime) as varchar)+'seconds';
		PRINT '--------------------------------------------------------';

	END TRY
	BEGIN CATCH
		PRINT '======================';
		PRINT 'ERROR OCCURED DURING LOADING OF SILVER LAYER: CRM AND ERP SOURCE SYSTEMS FROM BRONZE LAYER';
		PRINT 'Error Message' + error_message();
		PRINT 'Error Number' + CAST(Error_number() AS vARCHAR);
		PRINT 'Error STATE' + CAST(eRROR_STATE() AS VARCHAR);
		PRINT '======================';
	END CATCH
END