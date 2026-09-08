-- ==============================================================================
-- Stored Procedure: dbo.usp_TakeAllDatabaseBackups
-- Description:      Dynamically backs up all online databases on the SQL Server
--                   instance to a date-stamped folder under the specified root path.
-- Author:           Mangesh Mundhava
-- License:          MIT
-- ==============================================================================

USE [master];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('dbo.usp_TakeAllDatabaseBackups', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_TakeAllDatabaseBackups;
GO

CREATE PROCEDURE [dbo].[usp_TakeAllDatabaseBackups]
    @path VARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @name VARCHAR(128);
    DECLARE @fileName VARCHAR(512);
    DECLARE @fileDate VARCHAR(20);
    DECLARE @mkdirCmd VARCHAR(512);

    -- Ensure trailing backslash
    IF RIGHT(@path, 1) <> '\'
        SET @path = @path + '\';

    -- Format date stamp as yyyyMMdd
    SET @fileDate = CONVERT(VARCHAR(8), GETDATE(), 112);
    SET @path = @path + @fileDate + '\';

    -- Create directory using xp_cmdshell (ensure xp_cmdshell is enabled)
    SET @mkdirCmd = 'mkdir "' + @path + '"';
    EXEC xp_cmdshell @mkdirCmd, no_output;

    -- Cursor to iterate through all online databases (excluding system tempdb)
    DECLARE db_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT name
    FROM sys.databases
    WHERE state_desc = 'ONLINE'
      AND name NOT IN ('tempdb')
    ORDER BY name;

    OPEN db_cursor;
    FETCH NEXT FROM db_cursor INTO @name;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @fileName = @path + @name + '_' + @fileDate + '.BAK';
        
        PRINT '[BACKUP] Starting backup for: ' + @name;
        BACKUP DATABASE @name TO DISK = @fileName WITH NOFORMAT, NOINIT, SKIP, NOREWIND, NOUNLOAD, STATS = 10;
        
        FETCH NEXT FROM db_cursor INTO @name;
    END;

    CLOSE db_cursor;
    DEALLOCATE db_cursor;

    PRINT '[COMPLETED] All database backups completed to directory: ' + @path;
    SELECT @path AS BackupLocation;
END;
GO