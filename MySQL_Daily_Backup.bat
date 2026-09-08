@echo off
setlocal EnableDelayedExpansion

:: ==============================================================================
:: Script Name: MySQL_Daily_Backup.bat
:: Description: Automated daily backup for MySQL and MariaDB databases using
::              mysqldump, local storage, and remote network synchronization.
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

:: MySQL Connection Configuration
if "%MYSQL_BIN%"=="" set "MYSQL_BIN=C:\Program Files\MySQL\MySQL Server 8.0\bin"
if "%MYSQL_HOST%"=="" set "MYSQL_HOST=127.0.0.1"
if "%MYSQL_PORT%"=="" set "MYSQL_PORT=3306"
if "%MYSQL_USER%"=="" set "MYSQL_USER=backup_user"
:: Example database list (replace with your databases or configure in config.local.bat)
if "%MYSQL_DATABASES%"=="" set "MYSQL_DATABASES=app_db ecommerce_db reporting_db"

:: Date stamp in yyyyMMdd format
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd"') do set TODAY=%%i

:: Paths
set "LOCAL_TODAY=%LOCAL_BACKUP_ROOT%\MySQL\%TODAY%"
set "REMOTE_TODAY=%REMOTE_BACKUP_ROOT%\MySQL_Daily_Backups\%TODAY%"

:: Setup log directory
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
set "LOG_FILE=%LOG_DIR%\MySQL_Backup_%TODAY%.log"

call :LogMessage "=================================================="
call :LogMessage "MYSQL / MARIADB BACKUP PROCEDURE STARTED"
call :LogMessage "Timestamp: %DATE% %TIME%"
call :LogMessage "Target Host: %MYSQL_HOST%:%MYSQL_PORT%"
call :LogMessage "User: %MYSQL_USER%"
call :LogMessage "Target Databases: %MYSQL_DATABASES%"
call :LogMessage "=================================================="

:: Locate mysqldump binary
set "MYSQLDUMP_EXE=%MYSQL_BIN%\mysqldump.exe"
if not exist "%MYSQLDUMP_EXE%" (
    where mysqldump >nul 2>&1
    if errorlevel 1 (
        call :LogMessage "[ERROR] 'mysqldump.exe' was not found in '%MYSQL_BIN%' or in system PATH."
        goto ERROR_EXIT
    ) else (
        set "MYSQLDUMP_EXE=mysqldump"
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

:: Step 1: Dump each specified database
for %%D in (%MYSQL_DATABASES%) do (
    set "DUMP_FILE=%LOCAL_TODAY%\%%D_%TODAY%.sql"
    call :LogMessage "--------------------------------------------------"
    call :LogMessage "[INFO] Backing up database: %%D"
    call :LogMessage "[INFO] Output file: !DUMP_FILE!"

    "%MYSQLDUMP_EXE%" --host=%MYSQL_HOST% --port=%MYSQL_PORT% --user=%MYSQL_USER% ^
        --single-transaction --quick --routines --triggers --events ^
        --result-file="!DUMP_FILE!" %%D >> "%LOG_FILE%" 2>&1

    if errorlevel 1 (
        call :LogMessage "[ERROR] mysqldump failed for database %%D"
        set HAS_ERRORS=1
    ) else (
        call :LogMessage "[SUCCESS] Database %%D backed up successfully."
    )
)

if %HAS_ERRORS% equ 1 (
    call :LogMessage "[ERROR] One or more database dumps failed. Aborting remote sync."
    goto ERROR_EXIT
)

:: Step 2: Synchronize backups to remote network share
call :LogMessage "--------------------------------------------------"
call :LogMessage "[INFO] Synchronizing backups to remote location: %REMOTE_TODAY%"

robocopy "%LOCAL_TODAY%" "%REMOTE_TODAY%" *.sql /E /XO /XN /XC /R:%ROBOCOPY_RETRY_COUNT% /W:%ROBOCOPY_WAIT_TIME% /NFL /NDL >> "%LOG_FILE%" 2>&1
if errorlevel 8 (
    call :LogMessage "[ERROR] Remote synchronization failed with exit code %ERRORLEVEL%."
    goto ERROR_EXIT
)

call :LogMessage "=================================================="
call :LogMessage "[SUCCESS] MySQL backup procedure completed successfully."
call :LogMessage "=================================================="
goto SUCCESS_EXIT

:LogMessage
set "MSG=[%DATE% %TIME%] %~1"
echo %MSG%
echo %MSG% >> "%LOG_FILE%"
exit /b 0

:ERROR_EXIT
call :LogMessage "[FAILURE] MySQL backup job terminated with errors."
endlocal
exit /b 1

:SUCCESS_EXIT
endlocal
exit /b 0
