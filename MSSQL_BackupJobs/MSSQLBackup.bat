@echo off
setlocal EnableDelayedExpansion

:: ==============================================================================
:: Script Name: MSSQLBackup.bat
:: Description: Executes SQL backup scripts for SQL Server 2017, 2019, and 2022.
:: Author:      Mangesh Mundhava
:: Repository:  https://github.com/mangesh4694/Windows-Backups-script
:: License:     MIT
:: Version:     2.0.0
:: ==============================================================================

:: Check if sqlcmd is available
where sqlcmd >nul 2>&1
if errorlevel 1 (
    echo [ERROR] 'sqlcmd' command not found in PATH.
    exit /b 1
)

set "SCRIPT_DIR=%~dp0"
pushd "%SCRIPT_DIR%"

echo [INFO] Running SQL Server 2017 Backup...
sqlcmd -S .\SQL2017 -i "%SCRIPT_DIR%SQL2017.sql" -b
if errorlevel 1 echo [ERROR] SQL2017 backup failed.

echo [INFO] Running SQL Server 2019 Backup...
sqlcmd -S .\SQL2019 -i "%SCRIPT_DIR%SQL2019.sql" -b
if errorlevel 1 echo [ERROR] SQL2019 backup failed.

echo [INFO] Running SQL Server 2022 Backup...
sqlcmd -S .\SQL2022 -i "%SCRIPT_DIR%SQL2022.sql" -b
if errorlevel 1 echo [ERROR] SQL2022 backup failed.

popd
endlocal
exit /b 0
