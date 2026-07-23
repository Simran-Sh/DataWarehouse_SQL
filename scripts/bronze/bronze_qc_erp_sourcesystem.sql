/*
====================================================
| BRONZE LAYER QUALITY CHECK || ERP Source System |
===================================================
QUALITY PARAMETERS:
	1. Check for nulls and duplicates in column to be marked as primary key 
	2. Unwanted spaces in desriptive columns specially
	3. Find inconsistent records with low cardinality, if any
	4. Missing values or Blank handling
*/

USE DataWarehouse;
/*----------------
TABLE 4: erp_cus
----------------- */

-- Check for cid, if has nulls for empty values
SELECT * FROM bronze.erp_cust_az12
where cid is null or cid = ''; -- 0 records

-- check for cid, if has connection with customer CRM Table Id's. 
SELECT count(*) FROM bronze.erp_cust_az12 
WHERE cid LIKE 'NAS%'; -- 11042

SELECT COUNT(*) FROM bronze.erp_cust_az12 -- 7441
WHERE cid LIKE 'AW000%';

SELECT COUNT(*) FROM bronze.erp_cust_az12 -- 7441
WHERE cid IN (SELECT cst_key 
				FROM bronze.crm_cust_info) 

SELECT COUNT(*) 
FROM bronze.erp_cust_az12
WHERE SUBSTRING(cid, 4, LEN(cid)) LIKE 'AW%' or cid LIKE 'AW%'; --18483 records

SELECT cid,
	CASE 
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
		else cid
	END cid_NEW
FROM bronze.erp_cust_az12

-- Check for birth date inaccuracy - invalid, empty, null, etc
SELECT bdate
FROM bronze.erp_cust_az12
WHERE bdate IS NULL OR bdate <'1930-01-01';

SELECT COUNT(bdate)
FROM bronze.erp_cust_az12
WHERE bdate> getdate(); -- 16 records to be fixed with future birthdate in data (imposibble fact)

SELECT bdate,
	CASE 
		WHEN bdate> getdate() THEN null
		else bdate
	END bdate_NEW
FROM bronze.erp_cust_az12
where bdate> getdate() 

-- Check for cardinality and standardization in Gender column
SELECT distinct gender FROM bronze.erp_cust_az12 -- has null, F, M, Male, Female and empty string

SELECT 
	gender, 
	CASE UPPER(TRIM(GENDER))
		WHEN 'F' THEN 'Female'
		WHEN 'M' THEN 'Male'
		WHEN '' THEN 'n/a'
		WHEN null THEN 'n/a'
		ELSE GENDER
	END GENDER_fixed
from bronze.erp_cust_az12
where gender in('F','M','',NULL)

SELECT 
	gender, 
	CASE 
		WHEN UPPER(TRIM(GENDER)) IN ('F','Female') THEN 'Female'
		WHEN UPPER(TRIM(GENDER)) IN ('M','Male') THEN 'Male'
		ELSE 'n/a'
	END GENDER_fixed
from bronze.erp_cust_az12
where gender in('F','M','',NULL)

/*----------------
TABLE 5: erp_loc
----------------- */
SELECT * FROM bronze.erp_loc_a101;
SELECT COUNT(*) FROM bronze.erp_loc_a101; -- 18484 RECORDS

-- Check for issues in the id fix the unmatching format
SELECT cid,
		REPLACE(CID,'-','')
FROM bronze.erp_loc_a101
WHERE CID LIKE '%-%';

SELECT COUNT(REPLACE(CID,'-',''))
FROM bronze.erp_loc_a101
WHERE CID LIKE '%-%'; -- 18484 RECORDS

-- Check for country cardinality and fix the issues 
SELECT distinct country FROM bronze.erp_loc_a101;

SELECT country,
	CASE 
		WHEN country in ('DE','Germany') THEN 'Germany'
		WHEN country in ('United States','US','USA') THEN 'United States'
		WHEN country = '' or country is null then 'n/a'
		ELSE trim(country)
	END country_fixed
FROM bronze.erp_loc_a101;

/*---------------
TABLE 6: erp_cat
------------------ */
SELECT * FROM bronze.erp_px_cat_g1v2; -- matching id with silver cust table's cat_id
select * from silver.crm_prd_info; 
SELECT count(*) FROM bronze.erp_px_cat_g1v2 -- 37 records

SELECT distinct cat FROM bronze.erp_px_cat_g1v2
where trim(cat) != cat; -- No faulty records

SELECT distinct subcat FROM bronze.erp_px_cat_g1v2
where trim(subcat) != subcat; -- No faulty records

SELECT distinct maintenance FROM bronze.erp_px_cat_g1v2
where trim(maintenance) != maintenance; -- No faulty records
