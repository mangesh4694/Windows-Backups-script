-- ==============================================================================
-- Stored Procedure: [dbo].[usp_BackupDatabases]
-- Description:      Standard procedure for automated Full, Differential, or Log
--                   backups across all databases on SQL Server / SQLExpress.
-- Reference:        Microsoft Public License (MS-PL)
-- Parameters:       @databaseName - Optional single database name (NULL for all)
--                   @backupType   - 'F' = Full, 'D' = Differential, 'L' = Log
--                   @backupLocation - Destination directory (e.g. 'E:\Backups\MSSQL\')
-- ==============================================================================

USE [master];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID('dbo].[usp_BackupDatabases', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[usp_BackupDatabases];
GO

CREATE PROCEDURE [dbo].[usp_BackupDatabases]   
    @databaseName   sysname = NULL, 
    @backupType     CHAR(1), 
    @backupLocation NVARCHAR(200)  
AS  
BEGIN
    SET NOCOUNT ON;  

    DECLARE @DBs TABLE 
    ( 
        ID INT IDENTITY PRIMARY KEY, 
        DBNAME NVARCHAR(500) 
    );

    -- Ensure trailing backslash in path
    IF RIGHT(@backupLocation, 1) <> '\'
        SET @backupLocation = @backupLocation + '\';

    -- Pick only databases which are ONLINE
    INSERT INTO @DBs (DBNAME) 
    SELECT name 
    FROM sys.databases 
    WHERE state = 0 
      AND name = ISNULL(@databaseName, name)
    ORDER BY name;

    -- Filter out system databases that should not be backed up under specific types
    IF @backupType = 'F' 
    BEGIN 
        DELETE FROM @DBs WHERE DBNAME IN ('tempdb', 'Northwind', 'pubs', 'AdventureWorks');
    END 
    ELSE IF @backupType = 'D' 
    BEGIN 
        DELETE FROM @DBs WHERE DBNAME IN ('tempdb', 'Northwind', 'pubs', 'master', 'AdventureWorks');
    END 
    ELSE IF @backupType = 'L' 
    BEGIN 
        DELETE FROM @DBs WHERE DBNAME IN ('tempdb', 'Northwind', 'pubs', 'master', 'AdventureWorks');
    END 
    ELSE 
    BEGIN 
        RAISERROR('Invalid backup type. Use F (Full), D (Differential), or L (Log).', 16, 1);
        RETURN;
    END 

    DECLARE @BackupName NVARCHAR(100);
    DECLARE @BackupFile NVARCHAR(500);
    DECLARE @DBNAME     NVARCHAR(300);
    DECLARE @sqlCommand NVARCHAR(2000);
    DECLARE @dateTime   NVARCHAR(20);
    DECLARE @Loop       INT;

    SELECT @Loop = MIN(ID) FROM @DBs;

    WHILE @Loop IS NOT NULL 
    BEGIN 
        SET @DBNAME = '[' + (SELECT DBNAME FROM @DBs WHERE ID = @Loop) + ']';
        SET @dateTime = REPLACE(CONVERT(VARCHAR, GETDATE(), 101), '/', '') + '_' + REPLACE(CONVERT(VARCHAR, GETDATE(), 108), ':', '');

        IF @backupType = 'F' 
            SET @BackupFile = @backupLocation + REPLACE(REPLACE(@DBNAME, '[', ''), ']', '') + '_FULL_' + @dateTime + '.BAK';
        ELSE IF @backupType = 'D' 
            SET @BackupFile = @backupLocation + REPLACE(REPLACE(@DBNAME, '[', ''), ']', '') + '_DIFF_' + @dateTime + '.BAK';
        ELSE IF @backupType = 'L' 
            SET @BackupFile = @backupLocation + REPLACE(REPLACE(@DBNAME, '[', ''), ']', '') + '_LOG_' + @dateTime + '.TRN';

        IF @backupType = 'F' 
            SET @BackupName = REPLACE(REPLACE(@DBNAME, '[', ''), ']', '') + ' full backup for ' + @dateTime;
        IF @backupType = 'D' 
            SET @BackupName = REPLACE(REPLACE(@DBNAME, '[', ''), ']', '') + ' differential backup for ' + @dateTime;
        IF @backupType = 'L' 
            SET @BackupName = REPLACE(REPLACE(@DBNAME, '[', ''), ']', '') + ' log backup for ' + @dateTime;

        IF @backupType = 'F'  
            SET @sqlCommand = 'BACKUP DATABASE ' + @DBNAME + ' TO DISK = ''' + @BackupFile + ''' WITH INIT, NAME = ''' + @BackupName + ''', NOSKIP, NOFORMAT';
        IF @backupType = 'D' 
            SET @sqlCommand = 'BACKUP DATABASE ' + @DBNAME + ' TO DISK = ''' + @BackupFile + ''' WITH DIFFERENTIAL, INIT, NAME = ''' + @BackupName + ''', NOSKIP, NOFORMAT';
        IF @backupType = 'L'  
            SET @sqlCommand = 'BACKUP LOG ' + @DBNAME + ' TO DISK = ''' + @BackupFile + ''' WITH INIT, NAME = ''' + @BackupName + ''', NOSKIP, NOFORMAT';

        PRINT '[EXECUTING] ' + @sqlCommand;
        EXEC (@sqlCommand);

        SELECT @Loop = MIN(ID) FROM @DBs WHERE ID > @Loop;
    END;
END;
GO