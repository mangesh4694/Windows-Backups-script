-- ==============================================================================
-- Script:      SQL2017.sql
-- Description: Executes full backup routine for SQL Server 2017 instance.
-- Author:      Mangesh Mundhava
-- License:     MIT
-- ==============================================================================

USE [master];
GO

EXEC [dbo].[usp_TakeAllDatabaseBackups] 'E:\Backups\MSSQL\SQL2017\';
GO