
/*
==============================================
SILVER LAYER Quality check after ETL process |
==============================================
TABLE 1: crm_cust_info
-----------------------

1.PRIMARY KEY MUST BE UNIQUE AND NOT NULL
- Expectation in output: No result
*/

Use DataWarehouse;

SELECT * FROM SILVER.crm_cust_info;
SELECT COUNT(*) FROM SILVER.crm_cust_info; -- 18484

SELECT 
cst_id,
COUNT(*) AS [UniqueCustomers Count]
FROM silver.crm_cust_info
GROUP BY cst_id 
HAVING COUNT(*) = 1 OR cst_id IS NOT NULL;
GO

/*
flag_last != 1: It means that records have duplicates hence are ranked
flag_last = 1: It means records are unique and hence no further rank. 
			This is because the function is partitioned by Primary key, which should be unique
*/
SELECT *
FROM (
	SELECT
	*,
	ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
	FROM silver.crm_cust_info
	)T
WHERE flag_last != 1
GO

/*
- Quality Check 
1. for unwanted spaces in primary key in string / varchar based columns 
   -> Check by evaluating if original value is not equal to same value after triming.
   If not,the resulting output records have spaces

- Expectation in output: No result
*/
SELECT 
	cst_firstname,
	cst_lastname
from silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname) or
	cst_lastname != TRIM(cst_lastname)
GO
/*
- Quality Check 
1. Consistency and Data Standardization
  -> Find inconsistent records / values in low cardinality columns (fewer options in values) 
   -> Check by evaluating if original value has abbreviated or/ meaningful values 

- Expectation in output: No result
*/

SELECT DISTINCT cst_gender
FROM silver.crm_cust_info; -- 3 cardinality
GO

SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info; -- 2 cardinality
GO

/*-----------------------
TABLE 2: crm_prd_info
----------------------- */
SELECT * FROM SILVER.crm_prd_info;
SELECT COUNT(*) FROM SILVER.crm_prd_info; -- 397 records count

SELECT prd_id,prd_start_dt, prd_end_dt
FROM SILVER.crm_prd_info
where prd_end_dt < prd_start_dt; -- No records


/*-----------------------
TABLE 3: crm_sales_details
----------------------- */
SELECT * FROM SILVER.crm_sales_details;
SELECT COUNT(*) FROM SILVER.crm_sales_details; -- 60398

SELECT count(*) FROM SILVER.crm_sales_details -- 60398
where sls_sales = sls_quantity * sls_price

SELECT count(*) FROM SILVER.crm_sales_details --60378
where 
sls_order_dt < sls_ship_dt or sls_order_dt < sls_due_dt;

SELECT count(*) FROM SILVER.crm_sales_details --0
where  sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt;

SELECT count(*) FROM SILVER.crm_sales_details -- 19
where 
sls_order_dt is null

/*----------------
TABLE 4: erp_cus
----------------- */
SELECT * FROM silver.erp_cust_az12;

SELECT COUNT(*) FROM silver.erp_cust_az12 -- 18483 records

SELECT COUNT(bdate)
FROM silver.erp_cust_az12
WHERE bdate> getdate();  -- = records

SELECT distinct gender FROM silver.erp_cust_az12;
SELECT distinct gender FROM bronze.erp_cust_az12;

/*----------------
TABLE 5: erp_loc
----------------- */
SELECT * FROM silver.erp_loc_a101;

SELECT distinct country FROM silver.erp_loc_a101;

/*---------------
TABLE 6: erp_cat
------------------ */
SELECT * FROM silver.erp_px_cat_g1v2
SELECT count(*) FROM silver.erp_px_cat_g1v2 -- 37