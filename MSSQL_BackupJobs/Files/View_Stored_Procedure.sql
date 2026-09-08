-- ==============================================================================
-- Script:      View_Stored_Procedure.sql
-- Description: Displays the source definition of the backup stored procedure.
-- Author:      Mangesh Mundhava
-- License:     MIT
-- ==============================================================================

USE [master];
GO

EXEC sp_helptext N'dbo.usp_TakeAllDatabaseBackups';
GO
