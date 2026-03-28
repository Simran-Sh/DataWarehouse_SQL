# DataWarehouse_SQL
Built a modern data warehouse using SQL Server to consolidate sales data, enabling analytical reporting and informed decision-making.

## Specifications
	- Data Sources: Import data from two source systems (ERP and CRM) provided as CSV files.
	- Data Quality: Cleanse and resolve data quality issues prior to analysis.
	- Integration: Combine both sources into a single, user-friendly data model designed for analytical queries.
	- Scope: Focus on the latest dataset only; historization of data is not required.
	- Documentation: Provide clear documentation of the data model to support both business stakeholders and analytics teams.

# Project Overview
This project involves:
	- Data Architecture: Designing a Modern Data Warehouse using Medallion Architecture with 3 schema's - 'gold', 'silver', 'bronze'
	- ETL Pipelines: Extracting, transforming, and loading data from source systems into the warehouse.
	- Data Modeling: Developing fact and dimension tables optimized for analytical queries.
	- Analytics & Reporting: Creating SQL-based reports and dashboards for actionable insights.

## Architecture
Following **Medallion Architecture** 
	- Its a data design pattern used in lakehouse environments to organize data into three distinct layers—Bronze, Silver, and Gold—that progressively improve data quality and structure
	-  The architecture supports ELT (Extract, Load, Transform) workflows, allowing light transformations in the Silver layer and advanced business logic in the Gold layer.

![DataAcrchitectureFlow](Screenshots\DataAcrchitectureFlow.png)

---

## Naming Convention with lowercase and underscore to seperate the words
![snake_case](Screenshots\snake_case.png)

## Columns 
### Surrogate Keys
	- All primary keys in dim tables use the suffic _key
	- <table_name>_key - customer_key
		- <table_name>: 
		-<key>: indication of surrogate key
		- "customer_key" in dim customer table is a surrogate key

### Technical Columns
	- All calculated new columns have prefix dwn_ followed by description name(columm purpose)
	- dwh_<column_name>

### Stored Procedure 
	- Stored Procedure for loading data follow load_<layer> pattern
	- <layer> loaded layer. Ex. load_bronze
	
---

### DataWarehouse_layers
![DataWarehouse_layers](Screenshots\dwh_layers.png)

---

## Naming Convention - BRONZE LAYER 
	- All names must start with source system name
	- Tables must match their original names without renaming
	- <sourcesystem>_><entity> - crm_customer_info
		- **<sourcesystem>** Name of sources folder. Ex. CRM, ERP 
		- ***<entity>*** Name of the tables from source system. 


## Working on bronze layer of the schema:
- **Analysing**: Interview source system experts 
- Coding: Data Ingestion
- Validating (Quality Control): Data Completness and schema checks
- Docs and version - Data documenting versioning in Git

# Few  Questions to ask about:

+ Business Context and ownership 
	- Who owns the data?
	- System and data documentation
	- Data model and data catalog
	
+ Architecture and Technology stack
	- How is data stored? (SQL Server, Oracle, etc)
	- What are the integration capabilities? (API, Kafta, file extract, etc)
	
+ Extract and load
	- Incremental vs/ full load?
	- Data scope and historical needs?
	- Expected size of the extracts?
	- Any data volume limitations?
	- How to avoid impacting the source system's performance?
	- Authentication and authorization (token, SSH, VPN, etc)
	
# BUILD BRONZE LAYER
## Create DDL for Tables

**Definition** Raw unprocessed data as is from sources
Objective Traceability and debugging 
**Object Type** Tables 
** Load Method ** Full Load (Truncate and insert)
** Data Transformation** None (as_is)
** Data Modeling** None (as_is)
** Target Audience** Data Engineers


lOADED DATA FROM CSV FIlE sources directly using command.
18493 rows inserted into Bronze schema's table 

Screenshots/
Screenshots/


---

## Naming Convention - SILVER LAYER 
	- All names must start with source system name
	- Tables must match their original names without renaming
	- <sourcesystem>_><entity> - crm_customer_info
		- **<sourcesystem>** Name of sources folder. Ex. CRM, ERP 
		- ***<entity>*** Name of the tables from source system. 
		
---

## Naming Convention - GOLD LAYER 
	- All names must start with category prefix
	- <category>_><entity> - dim_customer
		- **<category>** Describes the role of table. Ex. dim, fact, report, aggre, view, etc 
		- ***<entity>*** Name of the tables aligned with business domain






	
	

	






