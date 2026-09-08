@echo off
setlocal EnableDelayedExpansion

:: ==============================================================================
:: Script Name: MSSQL_Daily_Remote_Backup.bat
:: Description: Synchronizes today's local MSSQL instance backups to remote
::              network storage (NAS/SMB share) using robocopy.
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
if "%MSSQL_INSTANCES%"=="" set "MSSQL_INSTANCES=SQL2017 SQL2019 SQL2022"
if "%ROBOCOPY_RETRY_COUNT%"=="" set "ROBOCOPY_RETRY_COUNT=2"
if "%ROBOCOPY_WAIT_TIME%"=="" set "ROBOCOPY_WAIT_TIME=2"

:: Date stamp in yyyyMMdd format
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd"') do set TODAY=%%i

:: Setup paths
set "LOCAL_BASE=%LOCAL_BACKUP_ROOT%\MSSQL"
set "REMOTE_BASE=%REMOTE_BACKUP_ROOT%\MSSQL"

:: Setup log directory
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
set "LOG_FILE=%LOG_DIR%\MSSQL_RemoteSync_%TODAY%.log"

call :LogMessage "=================================================="
call :LogMessage "MSSQL REMOTE BACKUP SYNCHRONIZATION STARTED"
call :LogMessage "Timestamp: %DATE% %TIME%"
call :LogMessage "Date Filter: %TODAY%"
call :LogMessage "Local Root:  %LOCAL_BASE%"
call :LogMessage "Remote Root: %REMOTE_BASE%"
call :LogMessage "=================================================="

set HAS_ERRORS=0

for %%V in (%MSSQL_INSTANCES%) do (
    set "LOCAL_TODAY=%LOCAL_BASE%\%%V\%TODAY%"
    set "REMOTE_TODAY=%REMOTE_BASE%\%%V\%TODAY%"

    call :LogMessage "--------------------------------------------------"
    call :LogMessage "[INFO] Processing instance: %%V"

    if exist "!LOCAL_TODAY!" (
        call :LogMessage "[INFO] Source directory: !LOCAL_TODAY!"
        call :LogMessage "[INFO] Target directory: !REMOTE_TODAY!"

        robocopy "!LOCAL_TODAY!" "!REMOTE_TODAY!" /E /Z /XO /XN /XC /R:%ROBOCOPY_RETRY_COUNT% /W:%ROBOCOPY_WAIT_TIME% >> "%LOG_FILE%" 2>&1

        if errorlevel 8 (
            call :LogMessage "[ERROR] Robocopy failed for instance %%V with exit code !ERRORLEVEL!."
            set HAS_ERRORS=1
        ) else (
            call :LogMessage "[SUCCESS] %%V backup synchronization completed successfully."
        )
    ) else (
        call :LogMessage "[WARNING] Local backup folder not found for %%V: !LOCAL_TODAY!"
    )
)

call :LogMessage "=================================================="
if %HAS_ERRORS% equ 1 (
    call :LogMessage "[WARNING] Remote synchronization finished with errors."
    call :LogMessage "Review the log file for details: %LOG_FILE%"
    endlocal
    exit /b 1
)

call :LogMessage "[SUCCESS] MSSQL remote synchronization completed successfully."
call :LogMessage "=================================================="
endlocal
exit /b 0

:LogMessage
set "MSG=[%DATE% %TIME%] %~1"
echo %MSG%
echo %MSG% >> "%LOG_FILE%"
exit /b 0
