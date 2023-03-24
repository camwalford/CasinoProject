USE master;
GO
IF DB_ID (N'casino') IS NOT NULL
DROP DATABASE casino;
GO
CREATE DATABASE casino;
GO

SELECT name, size, size*1.0/128 AS [Size in MBs]
FROM sys.master_files
WHERE name = N'casino';
GO
