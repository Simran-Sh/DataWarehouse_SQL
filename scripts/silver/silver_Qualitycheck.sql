
/*
------------------------------------
SILVER LAYER QUALITY CHECK and ETL PROCESS
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
FROM silver.crm_cust_info
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
FROM silver.crm_cust_info
WHERE flag_last != 1;
GO

/*
- Quality Check 
1. for unwanted spaces in primary key in string / varchar based columns 
   -> Check by evaluating if original value is not equal to same value after triming.
   If not,the resulting output records have spaces

- Expectation in output: No result
*/
SELECT cst_firstname
from silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);
GO

SELECT cst_lastname
from silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

/*
- Quality Check 
1. Consistency and Data Standardization
  -> Find inconsistent records / values in low cardinality columns (fewer options in values) 
   -> Check by evaluating if original value has abbreviated or/ meaningful values 

- Expectation in output: No result
*/

SELECT DISTINCT cst_gnder
FROM silver.crm_cust_info;
GO

SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;
GO