/*
========================================================
| BRONZE LAYER QUALITY CHECK || TABLE 1: crm_cust_info |
========================================================
QUALITY PARAMETERS:
	1. Check for nulls and duplicates in column to be marked as primary key 
	2. Unwanted spaces in desriptive columns specially
	3. Find inconsistent records with low cardinality, if any
	4. Missing values or Blank handling
*/

Use DataWarehouse;

SELECT * FROM bronze.crm_cust_info; --- Display all the rows
SELECT COUNT(*) FROM bronze.crm_cust_info; -- -- Check records count (18493 records)
SELECT DISTINCT COUNT(*) FROM bronze.crm_cust_info; -- 18493 records


/* 
Check for nulls or/ duplicates in primary key 
REASON: PRIMARY KEY MUST BE UNIQUE AND NOT NULL
Expectation in O/P: No result, else fix the data
*/

SELECT 
	cst_id,
	COUNT(*) AS [UniqueCustomers Count]
FROM bronze.crm_cust_info
GROUP BY cst_id 
HAVING COUNT(*)>1 OR cst_id IS NULL;
GO

SELECT *
FROM (
	SELECT 
		cst_id,
		cst_key,
		count(*) as CustCount
	FROM bronze.crm_cust_info
	Group by cst_key,cst_id
	)t
Where CustCount != 1 or cst_id is null or cst_key is null;

SELECT *
FROM 
	( SELECT *,
		row_number() over(partition by cst_id order by cst_create_date) as rn
	FROM bronze.crm_cust_info
	)t
WHERE rn = 1 and cst_id is not null;
GO

SELECT *
FROM (
	SELECT 
		cst_id,
		ROW_NUMBER() over(partition by cst_id order by cst_create_date DESC) rn_CustCount
	FROM bronze.crm_cust_info
	)t
Where rn_CustCount != 1

/*
flag_last != 1: It means that records have duplicates hence are ranked
flag_last = 1: It means records are unique and hence no further rank.
This is because the function is partitioned by Primary key, which should be unique
*/
SELECT
*,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
FROM bronze.crm_cust_info
WHERE cst_id = 29449;
GO

/*
Check for unwanted spaces in primary key in string / varchar based columns
Check by evaluating if original value is not equal to same value after triming.
EXPECTATION in O/P: No result, If not,the resulting output records have spaces
*/
SELECT 
	cst_firstname,
	cst_lastname
FROM  bronze.crm_cust_info
WHERE cst_firstname != trim(cst_firstname) or 
	 cst_lastname != trim(cst_lastname)
GO

/*
- Quality Check 
1. Consistency and Data Standardization
  -> Find inconsistent records / values in low cardinality columns (fewer options in values) 
   -> Check by evaluating if original value has abbreviated or/ meaningful values 

- Expectation in output: No result
*/
	 
SELECT DISTINCT cst_gender,cst_marital_status
FROM bronze.crm_cust_info

SELECT 
	cst_marital_status as Old_Marital_status,
	CASE TRIM(UPPER(cst_marital_status))
		WHEN 'M' THEN 'Married'
		WHEN 'S' THEN 'Single'
		ELSE 'unknown'
	END cst_marital_status,
	cst_gender as old_gender,
	CASE TRIM(UPPER(cst_gender))
		WHEN 'M' THEN 'Male'
		WHEN 'F' THEN 'Female'
		ELSE 'unknown'
	END cst_gender
FROM  bronze.crm_cust_info





