

/*
------------------------------------
SILVER LAYER QUALITY CHECK and ETL PROCESS
----------------------------------------
TABLE 1: crm_cust_info
========================================

*/

Use DataWarehouse;

INSERT INTO silver.crm_cust_info(
cst_id,
cst_key,
cst_firstname,
cst_lastname,
cst_marital_status,
cst_gnder,
cst_create_date)
SELECT 
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_firstname,
TRIM(cst_lastname) AS cst_lastname,
CASE WHEN UPPER(TRIM(cst_marital_status)) ='M' THEN 'Married'
	 WHEN UPPER(TRIM(cst_marital_status)) ='S' THEN 'Single'
	 ELSE 'n/a'
END cst_marital_status,
CASE WHEN UPPER(TRIM(cst_gnder)) ='F' THEN 'Female'
	 WHEN UPPER(TRIM(cst_gnder)) ='M' THEN 'Male'
	 ELSE 'n/a'
END cst_gnder,
cst_create_date
	FROM 
	(SELECT
		*,
		ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
		FROM bronze.crm_cust_info
		WHERE cst_id IS NOT NULL
	)t WHERE flag_last = 1;


/*
- ROW_NUMBER() - Window function assigns unique number to each row in a result set based on a defined order

- flag_last != 1: It means that records have duplicates hence are ranked
- flag_last = 1: It means records are unique and hence no further rank. This is because the function is partitioned by Primary key, which should be unique

*/

/*
----------------------------------------
TABLE 2: crm_prd_info
========================================
*/

SELECT 
prd_id,
prd_key,
REPLACE
	(
	SUBSTRING(prd_key,1,5),'-','_') 
	AS cat_id,
SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
prd_nm,
ISNULL(prd_cost,0) AS prd_cost,
CASE UPPER(TRIM(prd_line))
	 WHEN 'M' THEN 'Mountain'
	 WHEN 'R' THEN 'Roads'
	 WHEN 'S' THEN 'Other Sales'
	 WHEN 'T' THEN 'Touring'
ELSE 'n/a'
END AS prd_line,
prd_start_dt,
prd_end_dt
FROM bronze.crm_prd_info;