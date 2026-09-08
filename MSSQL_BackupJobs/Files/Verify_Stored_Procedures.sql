-- ==============================================================================
-- Script:      Verify_Stored_Procedures.sql
-- Description: Diagnostic queries to verify and inspect backup stored procedures
--              installed in the master database.
-- Author:      Mangesh Mundhava
-- License:     MIT
-- ==============================================================================

USE [master];
GO

-- 1. List all user stored procedures in the master database
SELECT 
    ROUTINE_SCHEMA AS [Schema],
    ROUTINE_NAME   AS [ProcedureName],
    CREATED        AS [DateCreated],
    LAST_ALTERED   AS [DateModified]
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_TYPE = 'PROCEDURE'
ORDER BY ROUTINE_NAME;
GO

-- 2. View the definition of usp_TakeAllDatabaseBackups
EXEC sp_helptext N'dbo.usp_TakeAllDatabaseBackups';
GO

-- 3. View the definition of usp_BackupDatabases (if installed)
IF OBJECT_ID('dbo.usp_BackupDatabases', 'P') IS NOT NULL
BEGIN
    EXEC sp_helptext N'dbo.usp_BackupDatabases';
END
GO
