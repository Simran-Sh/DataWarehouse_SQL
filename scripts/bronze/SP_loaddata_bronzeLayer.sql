/*
============================================================
STORED PROCEDURE: Load BRONZE LAYER (Source -> Bronze)
============================================================

Script purpose:
 This stored procedure loads the 'bronze' scheman from external CSV files
 It performs the following actions:
  1. Truncate the bronze tables before loading data
  2. Uses the 'bulk insert' command to load the data from CSV files to bronze tables
  3. Try Catch Block to ensure error handling, data integrity and issue logging for easier debbuging
  4. Track ETL Duration using DATEDIFF() function

  Parameters:
	None:
	This SP doesnot accept any parameters

  Example: 
		EXEC bronze.load_bronze;

	NOTE: 
		1. SQL runs TRY block and ifit fails, then it runs the CATCH block to handle the error
		2. Duration is tracked to identify bottlenecks, optimize performance, monitor trends, and detect issues
		3. Calculates the difference between two dates, returns days, months / years
 --------------------------------------------------------------
*/


USE DataWarehouse;

EXEC bronze.load_bronze

CREATE OR ALTER PROCEDURE bronze.load_bronze 
AS
BEGIN
	DECLARE 
		@start_time DATETIME,
		@end_time DATETIME,
		@CRM_batch_start_time DATETIME,
		@CRM_batch_end_time DATETIME,
		@ERP_batch_start_time DATETIME,
		@ERP_batch_end_time DATETIME;

	BEGIN TRY 

			PRINT'==================================================='
			PRINT 'LOADING BRONZE LAYER'
			PRINT '==================================================='

				/* TRUNCATE TABLE bronze.crm_cust_info;
				Use this "script line" when want to make the table empty before inserting new data/records
				*/

				-- BULK INSERT data from csv to bronze.crm_cust_info
				SET @CRM_batch_start_time = GETDATE();
				PRINT 'CRM TABLE';
				PRINT '------------';

				SET @start_time = GETDATE();
				PRINT '>> Truncating cust_info Table, incase any records already exist';
				TRUNCATE TABLE bronze.crm_cust_info;

				PRINT 'Insert data into crm_cust_info';
				BULK INSERT bronze.crm_cust_info
				FROM 'E:\DataWarehouse_SQL\datasets\source_crm\cust_info.csv'
				WITH 
					(
						FIRSTROW = 2,
						FIELDTERMINATOR =',',
						TABLOCK  --  lock the table to Improve performance
					);
				SET @end_time = GETDATE();
				PRINT 'CRM Cust info load Duration:' + CAST(DATEDIFF(second, @start_time,@end_time) AS NVARCHAR) +'seconds'

				/* CHECK QUALITY OF DATA
				SELECT * FROM bronze.crm_cust_info;

				-- Check records count
				SELECT COUNT(*) FROM bronze.crm_cust_info;
				*/


				-- BULK INSERT data from csv to bronze.crm_prd_info
				PRINT '-----------------------------------------------------------------';
				SET @start_time = GETDATE();
				PRINT '>> Truncating Table prd_info, incase any records already exist';
				TRUNCATE TABLE bronze.crm_prd_info;

				PRINT 'Insert data into prd_info';
				
				BULK INSERT bronze.crm_prd_info
				FROM 'E:\DataWarehouse_SQL\datasets\source_crm\prd_info.csv'
				WITH 
					(
						FIRSTROW = 2,
						FIELDTERMINATOR =',',
						TABLOCK
					);

				SET @end_time = GETDATE();
				PRINT 'crm_prd_info load Duration:' + CAST(DATEDIFF(second, @start_time,@end_time) AS NVARCHAR) +'seconds'


				/*CHECK QUALITY OF DATA
				SELECT * FROM bronze.crm_prd_info;

				-- Check records count
				SELECT COUNT(*) FROM bronze.crm_prd_info;
				*/

				-- BULK INSERT data from csv to bronze.crm_sales_details
				PRINT '-------------------------------------------------------------------------';
				SET @start_time = GETDATE();
				PRINT '>> Truncating Table: bronze.crm_sales_details, incase any records already exist';
				TRUNCATE TABLE bronze.crm_sales_details;
				PRINT 'Insert data into bronze.crm_sales_details';

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

				SET @CRM_batch_end_time = GETDATE();
				PRINT 'CRM DATA (BRONZE LAYER) Is loaded successfully:';
				PRINT 'Total Load Duration:' + CAST(DATEDIFF(second, @CRM_batch_start_time,@CRM_batch_end_time) AS NVARCHAR) +'seconds'

				PRINT '-------------------------------------------------------------------------';
				PRINT 'LOADING BRONZE LAYERs ERP TABLEs';
				PRINT '-------------------------------------------------------------------------';

				SET @ERP_batch_start_time = GETDATE();
				-- BULK INSERT data from csv to bronze.erp_cust_az12
				SET @start_time = GETDATE();
				PRINT '>> Truncating Table cust_az12, incase any records already exist';
				TRUNCATE TABLE bronze.erp_cust_az12;
				PRINT 'Insert data into cust_az12';

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
				PRINT '-------------------------------------------------------------------------';
				SET @start_time = GETDATE();
				PRINT '>> Truncating Table loc_a101, incase any records already exist';
				TRUNCATE TABLE bronze.erp_loc_a101;
				PRINT '>> Insert data into loc_a101';

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
				PRINT '-------------------------------------------------------------------------';
				SET @start_time = GETDATE();
				PRINT '>> Truncating Table px_cat_g1v2, incase any records already exist';
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
		SET @ERP_batch_end_time = GETDATE();
		PRINT '>> ERP DATA (BRONZE LAYER) IS loaded successfully:';
		PRINT '>> Total Load Duration:' + CAST(DATEDIFF(second, @ERP_batch_start_time,@ERP_batch_end_time) AS NVARCHAR) +'seconds'
		
		PRINT'==============================================';
		PRINT '>> Total load duaration for Bronze Layer:' + CAST(DATEDIFF(second, @CRM_batch_start_time,@ERP_batch_end_time) AS NVARCHAR) +'seconds'
		PRINT'==============================================';
		
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