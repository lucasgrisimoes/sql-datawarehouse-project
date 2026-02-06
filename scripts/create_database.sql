/*
==============
Creating the Database and Schemas
==============
*/

USE master;
GO

-- Create and use  the Database
CREATE DATABASE DataWarehouse;

USE DataWarehouse;

-- Creating database Schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
