@echo off
setlocal EnableDelayedExpansion

:: ==============================================================================
:: Script Name: MSSQLBackup.bat
:: Description: Automated runner for Microsoft SQL Server database backup jobs.
::              Executes backup stored procedures across configured SQL instances.
:: Author:      Mangesh Mundhava
:: Repository:  https://github.com/mangesh4694/Windows-Backups-script
:: License:     MIT
:: Version:     2.0.0
:: ==============================================================================

:: Load custom local configuration if available
if exist "%~dp0config.local.bat" (
    call "%~dp0config.local.bat"
)

:: ----- Default Configuration -----
if "%LOG_DIR%"=="" set "LOG_DIR=%~dp0logs"
if "%MSSQL_INSTANCES%"=="" set "MSSQL_INSTANCES=SQL2017 SQL2019 SQL2022"

:: Date stamp
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd"') do set TODAY=%%i

:: Setup log directory
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
set "LOG_FILE=%LOG_DIR%\MSSQL_Backup_%TODAY%.log"

:: Jobs directory resolution
set "JOBS_DIR=%~dp0MSSQL_BackupJobs"
if not exist "%JOBS_DIR%" (
    set "JOBS_DIR=%~dp0"
)

call :LogMessage "=================================================="
call :LogMessage "MSSQL DATABASE BACKUP PROCEDURE STARTED"
call :LogMessage "Timestamp: %DATE% %TIME%"
call :LogMessage "Jobs Directory: %JOBS_DIR%"
call :LogMessage "Target Instances: %MSSQL_INSTANCES%"
call :LogMessage "=================================================="

:: Pre-flight check: Check if sqlcmd is available
where sqlcmd >nul 2>&1
if errorlevel 1 (
    call :LogMessage "[ERROR] 'sqlcmd' command not found in system PATH."
    call :LogMessage "[ERROR] Please install SQL Server Command Line Utilities or update PATH."
    goto ERROR_EXIT
)

set HAS_ERRORS=0

:: Iterate over SQL instances
for %%I in (%MSSQL_INSTANCES%) do (
    set "SQL_SCRIPT=%JOBS_DIR%\%%I.sql"
    call :LogMessage "--------------------------------------------------"
    call :LogMessage "[INFO] Initiating backup for SQL Instance: .\%%I"

    if exist "!SQL_SCRIPT!" (
        call :LogMessage "[INFO] Executing script: !SQL_SCRIPT!"
        sqlcmd -S .\%%I -i "!SQL_SCRIPT!" -b >> "%LOG_FILE%" 2>&1
        if errorlevel 1 (
            call :LogMessage "[ERROR] Backup failed for instance .\%%I (Exit Code: !ERRORLEVEL!)"
            set HAS_ERRORS=1
        ) else (
            call :LogMessage "[SUCCESS] Backup succeeded for instance .\%%I"
        )
    ) else (
        call :LogMessage "[WARNING] SQL backup script not found: !SQL_SCRIPT!"
    )
)

call :LogMessage "--------------------------------------------------"
if %HAS_ERRORS% equ 1 (
    call :LogMessage "[WARNING] One or more SQL instance backups encountered errors."
    call :LogMessage "Please inspect the log file for details: %LOG_FILE%"
    goto ERROR_EXIT
)

call :LogMessage "=================================================="
call :LogMessage "[SUCCESS] All configured MSSQL backups completed successfully."
call :LogMessage "=================================================="
goto SUCCESS_EXIT

:LogMessage
set "MSG=[%DATE% %TIME%] %~1"
echo %MSG%
echo %MSG% >> "%LOG_FILE%"
exit /b 0

:ERROR_EXIT
endlocal
exit /b 1

:SUCCESS_EXIT
endlocal
exit /b 0
