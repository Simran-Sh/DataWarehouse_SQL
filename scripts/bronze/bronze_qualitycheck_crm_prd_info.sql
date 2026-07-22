/*
====================================================
| BRONZE LAYER QUALITY CHECK || TABLE 2: crm_prd_info |
====================================================
*/
USE DataWarehouse;

SELECT * FROM bronze.crm_prd_info;
SELECT * FROM Bronze.erp_px_cat_g1v2;
SELECT * FROM Bronze.crm_sales_details;
SELECT COUNT(*) FROM bronze.crm_prd_info; -- 397 records
SELECT count(*) FROM bronze.erp_px_cat_g1v2; -- 37 records

			
/* - PRIMARY KEY MUST BE UNIQUE AND NOT NULL and NON DUPLICATES (Hence unique rows in table)
   - Expectation in output: No result */
SELECT 
	prd_key,
	prd_id,
	COUNT(*) AS [UniqueCustomers Count]
FROM bronze.crm_prd_info
GROUP BY prd_id, prd_key
HAVING COUNT(*) > 1 OR prd_id IS NULL; --- 0 records
GO


/* Unwanted spaces in string / varchar based columns 
	- Expectation in output: No result */
SELECT prd_nm, prd_key
from bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm) or
	prd_key != TRIM(prd_key)
GO

/*
1. for Nulls or/ negative numbers in Prd_num column
- Expectation in output: No result
*/

SELECT 
prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost < 0;

SELECT 
CASE 
	WHEN prd_cost IS NULL THEN '0'
	ELSE prd_cost
END prd_cost
FROM bronze.crm_prd_info

/*
- Quality Check 
1. Consistency and Data Standardization
  -> Find inconsistent records / values in low cardinality columns (fewer options in values) 
   -> Check by evaluating if original value has abbreviated or/ meaningful values 
*/

SELECT DISTINCT prd_line
FROM bronze.crm_prd_info


-- Quality check for Invalid Date Orders 

SELECT 
	count(*) invalidDateRecordCount
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt

SELECT 
	cast(prd_start_dt as date) as prd_start_dt,
	cast(prd_end_dt as Date) as prd_end_dt
FROM bronze.crm_prd_info
WHERE cast(prd_end_dt as Date) < cast(prd_start_dt as date);

SELECT 
	prd_key,prd_id,
	cast(prd_start_dt as date) as prd_start_dt,
	CASE 
		WHEN prd_end_dt IS NULL OR prd_end_dt < prd_start_dt 
		THEN CAST(lead(prd_start_dt) over(PARTITION BY prd_key order by prd_start_dt)-1 AS DATE)
	END CreatedEnd_Date,
	cast(prd_end_dt as Date) as prd_end_dt
FROM bronze.crm_prd_info
order by prd_key, prd_start_dt



/*
----------------------------------------------------------------------------------------------
Create custom column as key to connect with other table sharing common info through unique Id
----------------------------------------------------------------------------------------------
Category key from 'prd table' with 'ERP category table'

Product key -> string split to get 
- categoryID - cat_id
- Replace the '-' to '_' as required in ERP Product table cat key
----------------------------------------
*/

SELECT * FROM Bronze.erp_px_cat_g1v2
WHERE id in
(SELECT 
	replace(substring(prd_key,1,5),'-','_') as cat_id
FRom bronze.crm_prd_info)


SELECT 
REPLACE
	(SUBSTRING(prd_key,1,5),'-','_') AS cat_id
FROM bronze.crm_prd_info
WHERE 
	REPLACE(SUBSTRING(prd_key,1,5),'-','_') NOT IN 
		( 
		SELECT 
		DISTINCT ID
		FROM bronze.erp_px_cat_g1v2
		)
/*
Fetch the Product key from original full lenth Prd_key in CRM prd info table
Match with prd_key from CRM sales details table to know if our command is correct for data transformation of column
*/
SELECT * FROM Bronze.crm_sales_details
WHERE sls_prd_key IN
	(SELECT SUBSTRING(prd_key,7,len(prd_key)) as sls_prd_key
	FROM bronze.crm_prd_info)

SELECT 
	SUBSTRING(prd_key,7,len(prd_key)) as sls_prd_key
FROM bronze.crm_prd_info
WHERE SUBSTRING(prd_key,7,len(prd_key)) IN (
									SELECT sls_prd_key 
									FROM Bronze.crm_sales_details
									)



