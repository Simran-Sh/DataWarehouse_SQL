/*
------------------------------------
BRONZE LAYER QUALITY CHECK
----------------------------------------
TABLE 1: crm_cust_info
========================================

- Quality Check 
1. for nulls or/ duplicates in primary key since 
 -> PRIMARY KEY MUST BE UNIQUE AND NOT NULL

- Expectation in output: No result
*/

Use DataWarehouse;

SELECT 
cst_id,
COUNT(*) AS [UniqueCustomers Count]
FROM bronze.crm_cust_info
GROUP BY cst_id 
HAVING COUNT(*)>1 OR cst_id IS NULL;
GO

/*
flag_last != 1: It means that records have duplicates hence are ranked
flag_last = 1: It means records are unique and hence no further rank. This is because the function is partitioned by Primary key, which should be unique
*/
SELECT
*,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
FROM bronze.crm_cust_info
WHERE cst_id = 29449;
GO

/*
- Quality Check 
1. for unwanted spaces in primary key in string / varchar based columns 
   -> Check by evaluating if original value is not equal to same value after triming.
   If not,the resulting output records have spaces

- Expectation in output: No result
*/
SELECT cst_firstname
from bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);
GO

/*
- Quality Check 
1. Consistency and Data Standardization
  -> Find inconsistent records / values in low cardinality columns (fewer options in values) 
   -> Check by evaluating if original value has abbreviated or/ meaningful values 

- Expectation in output: No result
*/

SELECT DISTINCT cst_gnder,cst_marital_status
FROM bronze.crm_cust_info


/*
------------------------------------
BRONZE LAYER QUALITY CHECK
----------------------------------------
TABLE 2: crm_prd_info
========================================
- Quality Check 
 -> PRIMARY KEY MUST BE UNIQUE AND NOT NULL and NON DUPLICATES (Hence unique rows in table)
- Expectation in output: No result
*/

Use DataWarehouse;

SELECT 
prd_id,
COUNT(*) AS [UniqueCustomers Count]
FROM bronze.crm_prd_info
GROUP BY prd_id 
HAVING COUNT(*)>1 OR prd_id IS NULL;
GO

/*
----------------------------------------
Match fetched cat key from 'prd table' with ERP cat table - Refer to Data Model table in Draw.io

Product key - string split to get 
- categoryID - cat_id
- Change the '-' to '_' as required in ERP Product table cat key
----------------------------------------
*/

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

SELECT 
SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key
FROM bronze.crm_prd_info
WHERE SUBSTRING(prd_key,7,LEN(prd_key)) IN 
(
	SELECT 
	sls_prd_key
	FROM bronze.crm_sales_details
)

/*
- Quality Check 
1. for unwanted spaces in string / varchar based columns 
   -> Check by evaluating if original value is not equal to same value after triming.
   If not,the resulting output records have spaces

- Expectation in output: No result
*/
SELECT prd_nm
from bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);
GO

/*
- Quality Check 
1. for Nulls or/ negative numbers in Prd_num column

- Expectation in output: No result
*/

SELECT 
prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost <0;

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
prd_start_dt,
prd_end_dt
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt





