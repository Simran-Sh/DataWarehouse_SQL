/*
============================================================
DDL FOR SILVER LAYER
============================================================
Bronze layer rules:
1. Create DDL's for silver using name convention i.e <sourcesystem>_entity>

Means:
<sourcesystem> - Is the name of the source system i.e CRM / ERP, etc
<entity> - Is the extract table name from the source system 

Example
	crm_customer_info - Customerinfo from CRM System
-------------------------------------------------------------
*/


USE DataWarehouse;

 IF OBJECT_ID ('silver.crm_cust_info', 'U') IS NOT NULL
	DROP TABLE silver.crm_cust_info;
 -- this command will drop the existing table with same name if already exists 


-- DDL (create table command) for customer info table of CRM 
CREATE TABLE silver.crm_cust_info
(
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gnder NVARCHAR(50),
	cst_create_date DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO


 IF OBJECT_ID ('silver.crm_prd_info', 'U') IS NOT NULL
	DROP TABLE silver.crm_prd_info;

-- DDL for product info table of CRM 
CREATE TABLE silver.crm_prd_info
(
	prd_id INT,
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATETIME,
	prd_end_dt DATETIME,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

 IF OBJECT_ID ('silver.crm_sales_details', 'U') IS NOT NULL
	DROP TABLE silver.crm_sales_details;

-- DDL for sales info table of CRM 
CREATE TABLE silver.crm_sales_details
(
	sls_ord_num NVARCHAR(50),
	sls_prd_key NVARCHAR(50),
	sls_cust_id INT,
	sls_order_dt INT,
	sls_ship_dt INT,
	sls_due_dt INT,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

 IF OBJECT_ID ('silver.erp_cust_az12', 'U') IS NOT NULL
	DROP TABLE silver.erp_cust_az12;

-- DDL for customer info table of ERP 
CREATE TABLE silver.erp_cust_az12
(
	CID NVARCHAR(50),
	BDATE DATE,
	GEN NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

 IF OBJECT_ID ('silver.erp_loc_a101', 'U') IS NOT NULL
	DROP TABLE silver.erp_loc_a101;

-- DDL for Loc info table of ERP
CREATE TABLE silver.erp_loc_a101
(
	CID NVARCHAR(50),
	CNTRY NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

 IF OBJECT_ID ('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
	DROP TABLE silver.erp_px_cat_g1v2;

-- DDL for PX Category info table of ERP 
CREATE TABLE silver.erp_px_cat_g1v2
(
	ID NVARCHAR(50),
	CAT NVARCHAR(50),
	SUBCAT NVARCHAR(50),
	MAINTENANCE NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO


