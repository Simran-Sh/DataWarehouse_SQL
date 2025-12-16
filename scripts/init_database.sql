-- go to master
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