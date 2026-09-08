-- ==============================================================================
-- Script:      SQL2019.sql
-- Description: Executes full backup routine for SQL Server 2019 instance.
-- Author:      Mangesh Mundhava
-- License:     MIT
-- ==============================================================================

USE [master];
GO

EXEC [dbo].[usp_TakeAllDatabaseBackups] 'E:\Backups\MSSQL\SQL2019\';
GO