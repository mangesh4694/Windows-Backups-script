@echo off
:: ==============================================================================
:: Script Name: PostgressSQL_Daily_script.bat (Compatibility Wrapper)
:: Notice:      This file exists for backward compatibility with existing scheduled tasks.
::              Please use PostgreSQL_Daily_Backup.bat directly.
:: Author:      Mangesh Mundhava
:: License:     MIT
:: ==============================================================================

echo [NOTICE] Forwarding execution to PostgreSQL_Daily_Backup.bat...
call "%~dp0PostgreSQL_Daily_Backup.bat" %*
exit /b %ERRORLEVEL%
