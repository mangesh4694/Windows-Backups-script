@echo off
:: ==============================================================================
:: Script Name: MySQL_Daily_Remote_Backup.bat (Compatibility Wrapper)
:: Notice:      This file exists for backward compatibility.
::              - For copying MSSQL backups to remote storage, use: MSSQL_Daily_Remote_Backup.bat
::              - For performing MySQL backups and remote copy, use: MySQL_Daily_Backup.bat
:: Author:      Mangesh Mundhava
:: License:     MIT
:: ==============================================================================

echo [NOTICE] Forwarding execution to MSSQL_Daily_Remote_Backup.bat...
call "%~dp0MSSQL_Daily_Remote_Backup.bat" %*
exit /b %ERRORLEVEL%
