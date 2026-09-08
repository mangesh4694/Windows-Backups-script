-- ==============================================================================
-- Script:      SQL2022.sql
-- Description: Executes full backup routine for SQL Server 2022 instance.
-- Author:      Mangesh Mundhava
-- License:     MIT
-- ==============================================================================

USE [master];
GO

EXEC [dbo].[usp_TakeAllDatabaseBackups] 'E:\Backups\MSSQL\SQL2022\';
GO