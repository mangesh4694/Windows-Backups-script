-- ==============================================================================
-- Script:      Enable_xp_cmdshell.sql
-- Description: Enables the xp_cmdshell feature in SQL Server.
--              Required if usp_TakeAllDatabaseBackups uses xp_cmdshell to 
--              dynamically create target date-stamped backup folders.
-- Security:    xp_cmdshell provides shell access to the host operating system.
--              Ensure only authorized DBAs/administrators have access.
-- Author:      Mangesh Mundhava
-- License:     MIT
-- ==============================================================================

USE [master];
GO

-- Step 1: Enable advanced configuration options
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
GO

-- Step 2: Enable xp_cmdshell
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;
GO

PRINT '[SUCCESS] xp_cmdshell has been enabled on this SQL Server instance.';
GO
