@echo off
setlocal EnableDelayedExpansion

:: ==============================================================================
:: Script Name: PostgreSQL_Daily_Backup.bat
:: Description: Automated daily backup for PostgreSQL databases using pg_dump
::              custom format (-F c), local staging, and remote network sync.
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
if "%LOCAL_BACKUP_ROOT%"=="" set "LOCAL_BACKUP_ROOT=E:\Backups"
if "%REMOTE_BACKUP_ROOT%"=="" set "REMOTE_BACKUP_ROOT=\\192.168.1.100\Backups"
if "%LOG_DIR%"=="" set "LOG_DIR=%~dp0logs"
if "%ROBOCOPY_RETRY_COUNT%"=="" set "ROBOCOPY_RETRY_COUNT=2"
if "%ROBOCOPY_WAIT_TIME%"=="" set "ROBOCOPY_WAIT_TIME=2"

:: PostgreSQL Settings
if "%PG_BIN%"=="" set "PG_BIN=C:\Program Files\PostgreSQL\16\bin"
if "%PG_HOST%"=="" set "PG_HOST=127.0.0.1"
if "%PG_PORT%"=="" set "PG_PORT=5432"
if "%PG_USER%"=="" set "PG_USER=postgres"
:: Sample database list (customize to your requirements or define in config.local.bat)
if "%PG_DATABASES%"=="" set "PG_DATABASES=app_db analytics_db auth_db postgres"

:: Date stamp in yyyyMMdd format
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd"') do set TODAY=%%i

:: Paths
set "LOCAL_TODAY=%LOCAL_BACKUP_ROOT%\PostgreSQL\%TODAY%"
set "REMOTE_TODAY=%REMOTE_BACKUP_ROOT%\PostgreSQL_Daily_Backups\%TODAY%"

:: Setup log directory
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
set "LOG_FILE=%LOG_DIR%\PostgreSQL_Backup_%TODAY%.log"

call :LogMessage "=================================================="
call :LogMessage "POSTGRESQL DATABASE BACKUP PROCEDURE STARTED"
call :LogMessage "Timestamp: %DATE% %TIME%"
call :LogMessage "Target Host: %PG_HOST%:%PG_PORT%"
call :LogMessage "User: %PG_USER%"
call :LogMessage "Databases: %PG_DATABASES%"
call :LogMessage "=================================================="

:: Locate pg_dump executable
set "PG_DUMP_EXE=%PG_BIN%\pg_dump.exe"
if not exist "%PG_DUMP_EXE%" (
    where pg_dump >nul 2>&1
    if errorlevel 1 (
        call :LogMessage "[ERROR] 'pg_dump.exe' not found at '%PG_BIN%' or in system PATH."
        goto ERROR_EXIT
    ) else (
        set "PG_DUMP_EXE=pg_dump"
    )
)

:: Ensure local destination directory exists
if not exist "%LOCAL_TODAY%" (
    mkdir "%LOCAL_TODAY%"
    if errorlevel 1 (
        call :LogMessage "[ERROR] Failed to create local directory: %LOCAL_TODAY%"
        goto ERROR_EXIT
    )
)

set HAS_ERRORS=0

:: Step 1: Backup each specified database
for %%D in (%PG_DATABASES%) do (
    set "BACKUP_FILE=%LOCAL_TODAY%\%%D_%TODAY%.backup"
    call :LogMessage "--------------------------------------------------"
    call :LogMessage "[INFO] Backing up database: %%D"
    call :LogMessage "[INFO] Destination: !BACKUP_FILE!"

    "%PG_DUMP_EXE%" -h %PG_HOST% -p %PG_PORT% -U %PG_USER% ^
        -F c -b -v -f "!BACKUP_FILE!" %%D >> "%LOG_FILE%" 2>&1

    if errorlevel 1 (
        call :LogMessage "[ERROR] pg_dump failed for database %%D"
        set HAS_ERRORS=1
    ) else (
        call :LogMessage "[SUCCESS] Database %%D backed up successfully."
    )
)

if %HAS_ERRORS% equ 1 (
    call :LogMessage "[ERROR] One or more database backups failed. Aborting remote transfer."
    goto ERROR_EXIT
)

:: Step 2: Synchronize backups to remote network share
call :LogMessage "--------------------------------------------------"
call :LogMessage "[INFO] Synchronizing backups to remote storage: %REMOTE_TODAY%"

robocopy "%LOCAL_TODAY%" "%REMOTE_TODAY%" *.backup /E /XO /XN /XC /R:%ROBOCOPY_RETRY_COUNT% /W:%ROBOCOPY_WAIT_TIME% /NFL /NDL >> "%LOG_FILE%" 2>&1
if errorlevel 8 (
    call :LogMessage "[ERROR] Remote synchronization failed with exit code %ERRORLEVEL%."
    goto ERROR_EXIT
)

call :LogMessage "=================================================="
call :LogMessage "[SUCCESS] PostgreSQL backup procedure completed successfully."
call :LogMessage "=================================================="
goto SUCCESS_EXIT

:LogMessage
set "MSG=[%DATE% %TIME%] %~1"
echo %MSG%
echo %MSG% >> "%LOG_FILE%"
exit /b 0

:ERROR_EXIT
call :LogMessage "[FAILURE] PostgreSQL backup job terminated with errors."
endlocal
exit /b 1

:SUCCESS_EXIT
endlocal
exit /b 0
