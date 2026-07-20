
/* 
==============================
| BRONZE LAYER SPECIFICATIONS|
==============================
DDL's Name Convention: 
<sourcesystem>_entity>
		<sourcesystem> - is the name of the source system i.e CRM / ERP, etc
		<entity> - is the extract table name from the source system 
		Example - crm_customer_infp - Customerinfo from CRM System

NOTE:
		 Create Tables with proper naming conventions for both source system 
			- CRM 
			- ERP

		 Kept the column names same as that of from the csv files

		 Checked if the SQL Table exist or/ not using 
			"OBJECT_ID  passing table name 
			specifying that its a "User define table (U) as parameter
		
THE OBJ COMMAND's WILL
		drop the existing table with same name if already exists
		And then recreate from scratch in same schema

*/

USE DataWarehouse;

/*
=======================================
Data Definition Language Script (DDL)
=======================================
*/


-- DDL for customer info table of CRM 
IF OBJECT_ID ('bronze.crm_cust_info', 'U') IS NOT NULL
	DROP TABLE bronze.crm_cust_info;

CREATE TABLE bronze.crm_cust_info
(
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gender NVARCHAR(50),
	cst_create_date DATE
);
GO


-- DDL for product info table of CRM 
IF OBJECT_ID ('bronze.crm_prd_info', 'U') IS NOT NULL
	DROP TABLE bronze.crm_prd_info;

CREATE TABLE bronze.crm_prd_info
(
	prd_id INT,
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATETIME,
	prd_end_dt DATETIME
);
GO


-- DDL for sales info table of CRM 
IF OBJECT_ID ('bronze.crm_sales_details', 'U') IS NOT NULL
	DROP TABLE bronze.crm_sales_details;

CREATE TABLE bronze.crm_sales_details
(
	sls_ord_num NVARCHAR(50),
	sls_prd_key NVARCHAR(50),
	sls_cust_id INT,
	sls_order_dt INT,
	sls_ship_dt INT,
	sls_due_dt INT,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT
);
GO

-- DDL for customer info table of ERP 
IF OBJECT_ID ('bronze.erp_cust_az12', 'U') IS NOT NULL
	DROP TABLE bronze.erp_cust_az12;

CREATE TABLE bronze.erp_cust_az12
(
	cid NVARCHAR(50),
	bdate DATE,
	gender NVARCHAR(50)
);
GO

-- DDL for Loc info table of ERP 
IF OBJECT_ID ('bronze.erp_loc_a101', 'U') IS NOT NULL
	DROP TABLE bronze.erp_loc_a101;

CREATE TABLE bronze.erp_loc_a101
(
	cid NVARCHAR(50),
	country NVARCHAR(50)
);
GO


-- DDL for PX Category info table of ERP 
IF OBJECT_ID ('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
	DROP TABLE bronze.erp_px_cat_g1v2;

CREATE TABLE bronze.erp_px_cat_g1v2
(
	id NVARCHAR(50),
	cat NVARCHAR(50),
	subcat NVARCHAR(50),
	maintenance NVARCHAR(50)
);
GO


