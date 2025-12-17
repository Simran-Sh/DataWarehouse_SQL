Use DataWarehouse;

-- CRM TABLES
SELECT TOP 1000 * FROM [DataWarehouse].[bronze].[crm_cust_info]
SELECT TOP (1000) * FROM [DataWarehouse].[bronze].[crm_prd_info]
SELECT TOP (1000) * FROM [DataWarehouse].[bronze].[crm_sales_details]

-- ERP TABLES
SELECT TOP (1000) * FROM [DataWarehouse].[bronze].[erp_cust_az12]
SELECT TOP (1000) * FROM [DataWarehouse].[bronze].[erp_loc_a101]
SELECT TOP (1000) * FROM [DataWarehouse].[bronze].erp_px_cat_g1v2



  
  