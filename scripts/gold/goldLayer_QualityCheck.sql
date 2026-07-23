/* ==============================
	GOLD LAYER QUALITY CHECK 
=================================
Script Purpose: 
	To perform quality checks to validate the integrity, consistency and accuracy of Gold Layer. 

These checks ensure:
	1. Uniqueness of surrogate keys in dim tables 
	2. Referential Integrity between fact and dim tables
	3. Validation of relationship in data model for analytical purposes

Usage Notes:
	- Run these checks after creating 'gold' layer views
	- Investigate and reolve any discrepancies found during checks
*/

USE DataWarehouse;

-- Customers Dim Table Data
SELECT * FROM silver.crm_cust_info -- cst_id 
SELECT * FROM silver.erp_cust_az12 -- cid
SELECT * FROM silver.erp_loc_a101 --cid

-- Sales and Transactional Data 
SELECT * FROM silver.crm_sales_details

-- Products Dim Table Data 
SELECT * FROM silver.crm_prd_info; -- cat_id
SELECT * FROM silver.erp_px_cat_g1v2; -- id

-- Check for gender 
SELECT c_ci.cst_key,
		c_ci.cst_gender,
		CASE 
			WHEN c_ci.cst_gender != 'n/a' THEN c_ci.cst_gender
			ELSE COALESCE(s_ca.gender,'n/a')
		END Gender,
		s_ca.gender
FROM silver.crm_cust_info c_ci
LEFT JOIN silver.erp_cust_az12 s_ca
ON c_ci.cst_key = s_ca.cid 
left join silver.erp_loc_a101 s_ela
ON c_ci.cst_key = s_ela.cid 
where s_ca.gender is null -- Null exists because no data found of same customer in ERP Table 
OR  s_ca.gender != c_ci.cst_gender;