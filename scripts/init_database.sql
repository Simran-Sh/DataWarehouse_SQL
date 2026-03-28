/*
===================================================================
| CREATE DATABASE AND SCHEMA's here in this init_database sql file |
===================================================================
SCRIPT PURPOSE:
	1. Creates new database, after checking, if it doesnot already exist
	2. If database exists already, then drop and recreate it
	3. Script will setup 3 schema's within the database  - "bronze", "silver", "gold"

WARNING:
	1. Running this script will drop entire datawarehouse and delete all data it contains 

NOTE: 
	1. Always use "GO" to separate batches when working with multiple SQL statements
*/



-- go to master database
Use master;
GO

-- Drop and recreate database (script to run, only if working from scratch)
IF EXISTS(SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
		ALTER DATABASE DataWarehouse 
		SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
END;
GO

-- Create database 'DataWarehouse'
CREATE DATABASE DataWarehouse;
GO 

USE DataWarehouse;
GO

-- Create schema'as for the project
CREATE SCHEMA bronze;
GO            

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO