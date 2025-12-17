/*
============================================================
STORED PROCEDURE: Load BRONZE LAYER (Source -> Bronze)
============================================================

Script purpose:
 This stored procedure loads the 'bronze' scheman from external CSV files
 It performs the following actions:
  1. Truncate the bronze tables before loading data
  2. Uses the 'bulk insert' command to load the data from CSV files to bronze tables

  Parameters:
	None:
	This SP doesnot accept any parameters

  Example: 
		EXEC bronze.load_bronze;
 --------------------------------------------------------------
*/


USE DataWarehouse;

EXEC bronze.load_bronze

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME,@batch_end_time DATETIME;
	BEGIN TRY 

			PRINT'==================================================='
			PRINT 'LOADING BRONZE LAYER'
			PRINT '==================================================='

				/* TRUNCATE TABLE bronze.crm_cust_info;
				Use this "script line" when want to make the table empty before inserting new data/records
				*/

				-- BULK INSERT data from csv to bronze.crm_cust_info
				SET @batch_start_time = GETDATE();
				PRINT '--------------------------------------------------';
				PRINT 'LOADING BRONZE LAYERs CRM TABLEs';
				PRINT '--------------------------------------------------';

				SET @start_time = GETDATE();
				PRINT '>> Truncating Table: bronze.crm_cust_info, incase any records already exist';
				TRUNCATE TABLE bronze.crm_cust_info;

				PRINT '>> Insert data into bronze.crm_cust_info';
				BULK INSERT bronze.crm_cust_info
				FROM 'E:\DataWarehouse_SQL\datasets\source_crm\cust_info.csv'
				WITH 
					(
						FIRSTROW = 2,
						FIELDTERMINATOR =',',
						TABLOCK
					);
				SET @end_time = GETDATE();
				PRINT '>> CRM Cust info load Duration:' + CAST(DATEDIFF(second, @start_time,@end_time) AS NVARCHAR) +'seconds'

				/* CHECK QUALITY OF DATA
				SELECT * FROM bronze.crm_cust_info;

				-- Check records count
				SELECT COUNT(*) FROM bronze.crm_cust_info;
				*/


				-- BULK INSERT data from csv to bronze.crm_prd_info
				PRINT '>> Truncating Table: bronze.crm_prd_info, incase any records already exist';
				TRUNCATE TABLE bronze.crm_prd_info;

				PRINT '>> Insert data into bronze.crm_prd_info';
				
				BULK INSERT bronze.crm_prd_info
				FROM 'E:\DataWarehouse_SQL\datasets\source_crm\prd_info.csv'
				WITH 
					(
						FIRSTROW = 2,
						FIELDTERMINATOR =',',
						TABLOCK
					);

				/*CHECK QUALITY OF DATA
				SELECT * FROM bronze.crm_prd_info;

				-- Check records count
				SELECT COUNT(*) FROM bronze.crm_prd_info;
				*/

				-- BULK INSERT data from csv to bronze.crm_sales_details
				PRINT '>> Truncating Table: bronze.crm_sales_details, incase any records already exist';
				TRUNCATE TABLE bronze.crm_sales_details;
				PRINT '>> Insert data into bronze.crm_sales_details';

				BULK INSERT bronze.crm_sales_details
				FROM 'E:\DataWarehouse_SQL\datasets\source_crm\sales_details.csv'
				WITH 
					(
						FIRSTROW = 2,
						FIELDTERMINATOR =',',
						TABLOCK
					);

				/* CHECK QUALITY OF DATA
				SELECT * FROM bronze.crm_sales_details;

				 Check records count
				SELECT COUNT(*) FROM bronze.crm_sales_details;
				*/

				PRINT '--------------------------------------------------';
				PRINT 'LOADING BRONZE LAYERs ERP TABLEs';
				PRINT '--------------------------------------------------';

				-- BULK INSERT data from csv to bronze.erp_cust_az12
				PRINT '>> Truncating Table: bronze.erp_cust_az12, incase any records already exist';
				TRUNCATE TABLE bronze.erp_cust_az12;
				PRINT '>> Insert data into bronze.erp_cust_az12';

				BULK INSERT bronze.erp_cust_az12
				FROM 'E:\DataWarehouse_SQL\datasets\source_erp\cust_az12.csv'
				WITH 
					(
						FIRSTROW = 2,
						FIELDTERMINATOR =',',
						TABLOCK
					);

				/* CHECK QUALITY OF DATA
				SELECT * FROM bronze.erp_cust_az12;

				-- Check records count
				SELECT COUNT(*) FROM bronze.erp_cust_az12;

				*/

				-- BULK INSERT data from csv to bronze.erp_loc_a101
				PRINT '>> Truncating Table: bronze.erp_loc_a101, incase any records already exist';
				TRUNCATE TABLE bronze.erp_loc_a101;
				PRINT '>> Insert data into bronze.erp_loc_a101';

				BULK INSERT bronze.erp_loc_a101
				FROM 'E:\DataWarehouse_SQL\datasets\source_erp\loc_a101.csv'
				WITH 
					(
						FIRSTROW = 2,
						FIELDTERMINATOR =',',
						TABLOCK
					);

				/* CHECK QUALITY OF DATA
				SELECT * FROM bronze.erp_loc_a101;

				-- Check records count
				SELECT COUNT(*) FROM bronze.erp_loc_a101;
				*/

				-- BULK INSERT data from csv to bronze.erp_px_cat_g1v2
				PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2, incase any records already exist';
				TRUNCATE TABLE bronze.erp_px_cat_g1v2;
				PRINT '>> Insert data into bronze.erp_px_cat_g1v2';

				BULK INSERT bronze.erp_px_cat_g1v2
				FROM 'E:\DataWarehouse_SQL\datasets\source_erp\px_cat_g1v2.csv'
				WITH 
					(
						FIRSTROW = 2,
						FIELDTERMINATOR =',',
						TABLOCK
					);

				/* CHECK QUALITY OF DATA
				SELECT * FROM bronze.erp_px_cat_g1v2;

				-- Check records count
				SELECT COUNT(*) FROM bronze.erp_px_cat_g1v2;
				*/
		SET @batch_end_time = GETDATE();
		PRINT '>> CRM and ERP DATA (BRONZE LAYER) IS loaded successfully:';
		PRINT '>> Total Load Duration:' + CAST(DATEDIFF(second, @batch_start_time,@batch_end_time) AS NVARCHAR) +'seconds'

		END TRY 
		BEGIN CATCH 
			PRINT'==============================================';
			PRINT'ERROR OCCURED DURING LOADING BRONZE LAYER'
			PRINT'Error Message' + ERROR_MESSAGE();
			PRINT'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
			PRINT'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
			PRINT'==============================================';
		END CATCH
END