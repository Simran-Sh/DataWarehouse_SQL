
/* Create DDL's for bronze using name convention i.e <sourcesystem>_entity>
<sourcesystem> - is the name of the source system i.e CRM / ERP, etc
<entity> - is the extract table name from the source system 
Example - crm_customer_infp - Customerinfo from CRM System

*/

/*
 IF OBJECT_ID ('bronze.crm_cust_info', 'U') IS NOT NULL
	DROP TABLE bronze.crm_cust_info;
 this command will drop the existing table with same name if already exists 
	*/

USE DataWarehouse;

-- DDL for customer info table of CRM 
CREATE TABLE bronze.crm_cust_info
(
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gnder NVARCHAR(50),
	cst_create_date DATE
);
GO
-- DDL for product info table of CRM 

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

CREATE TABLE bronze.erp_cust_az12
(
	CID NVARCHAR(50),
	BDATE DATE,
	GEN NVARCHAR(50)
);
GO
-- DDL for Loc info table of ERP 



CREATE TABLE bronze.erp_loc_a101
(
	CID NVARCHAR(50),
	CNTRY NVARCHAR(50)
);
GO
-- DDL for PX Category info table of ERP 



CREATE TABLE bronze.erp_px_cat_g1v2
(
	ID NVARCHAR(50),
	CAT NVARCHAR(50),
	SUBCAT NVARCHAR(50),
	MAINTENANCE NVARCHAR(50)
);
GO


