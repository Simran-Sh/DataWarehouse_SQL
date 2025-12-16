# DataWarehouse_SQL
Building a DataWarehouse with 3 schema's - 'gold', 'silver', 'bronze'
This project is developed using SQL Server, including ETL processes, data modeling and analytics


Working on bronze layer of the schema:
- Analysing: Interview source system experts 
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







	
	

	






