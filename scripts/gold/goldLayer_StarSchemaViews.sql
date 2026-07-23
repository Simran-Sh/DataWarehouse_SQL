/* ==========================
	DDL Script: GOLD LAYER  
=============================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
*/
USE DataWarehouse;

/* =====================================
 Create Dimension: gold.dim_customers
 ===================================== */

IF OBJECT_ID('gold.dim_customers','v') IS NOT NULL
	DROP VIEW gold.dim_customers;

CREATE VIEW gold.dim_customers
AS
SELECT	
		ROW_NUMBER() OVER(ORDER BY c_ci.cst_id) AS [Customer Key], -- Surrogate Key for Customer Table
		c_ci.cst_id             as [Customer ID],
		c_ci.cst_key            as [Customer Number],
		c_ci.cst_firstname      as [First Name],
		c_ci.cst_lastname       as [Last Name],
		s_ela.country           as [Country],
		CASE 
			WHEN c_ci.cst_gender != 'n/a' THEN c_ci.cst_gender
			ELSE COALESCE(s_ca.gender,'n/a')
		END Gender,
		c_ci.cst_marital_status as [Marital Status],
		s_ca.bdate              as [Birth Date],
		c_ci.cst_create_date    as [Create Date]
FROM silver.crm_cust_info c_ci
LEFT JOIN silver.erp_cust_az12 s_ca
	ON c_ci.cst_key = s_ca.cid 
LEFT JOIN silver.erp_loc_a101 s_ela
	ON c_ci.cst_key = s_ela.cid;
GO


/* =====================================
 Create Dimension: gold.dim_products
 ===================================== */
 IF OBJECT_ID('gold.dim_products','v') IS NOT NULL
	DROP VIEW gold.dim_products;

CREATE VIEW gold.dim_products
AS
SELECT  
		ROW_NUMBER() OVER(ORDER BY s_cpi.prd_start_dt,s_cpi.sls_prd_key) AS [Product Key], -- Surrogate key for Product Table
		s_cpi.prd_id             as [Product ID],
		s_cpi.sls_prd_key        as [Product Number],
		s_cpi.prd_name           as [Product Name],
		s_cpi.cat_id             as [Category ID],
		s_epcg.cat               as [Category],
		s_epcg.subcat            as [SubCategory],
		s_epcg.maintenance       as [Maintenance],
		s_cpi.prd_cost           as [Cost],
		s_cpi.prd_line           as [Product Line],
		s_cpi.prd_start_dt       as [Start Date]
FROM silver.crm_prd_info s_cpi -- cat_id
LEFT JOIN silver.erp_px_cat_g1v2 as s_epcg -- id
ON s_cpi.cat_id = s_epcg.id
WHERE s_cpi.prd_end_dt IS NULL

/* =====================================
 Create Fact Table: gold.fact_sales
 ===================================== */

 IF OBJECT_ID('gold.fact_sales','v') IS NOT NULL
	DROP VIEW gold.fact_sales;

CREATE VIEW gold.fact_sales
AS
SELECT 
	g_dp.[Product Key]             as [Product Key],
	g_dc.[Customer Key]            as [Customer key],
	s_sd.sls_ord_num               as [Order Number],
	s_sd.sls_price                 as [Price],
	s_sd.sls_quantity              as [Quantity],
	s_sd.sls_sales                 as [Sales],
	s_sd.sls_order_dt              as [order_dt],
	s_sd.sls_ship_dt               as [Ship_dt],
	s_sd.sls_due_dt                as [Due_dt]
FROM silver.crm_sales_details s_sd
LEFT JOIN gold.dim_customers g_dc
	ON s_sd.sls_cust_id = g_dc.[Customer ID]
LEFT JOIN gold.dim_products g_dp
	ON s_sd.sls_prd_key = g_dp.[Product ID]