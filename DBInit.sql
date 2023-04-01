-- Create Database

USE master;
GO

IF EXISTS (
	SELECT name
	FROM sys.databases
	WHERE name = N'CASINO'
)
DROP DATABASE CASINO;
GO

CREATE DATABASE CASINO;
GO



-- Create Tables


-- Fill in Tables with values
