@echo off
setlocal EnableDelayedExpansion

:: ==============================================================================
:: Script Name: IIS_Daily_Backups.bat
:: Description: Automated daily backup of IIS web server configuration via appcmd
::              with local archiving and remote network redundancy.
:: Author:      Mangesh Mundhava
:: Repository:  https://github.com/mangesh4694/Windows-Backups-script
:: License:     MIT
:: Version:     2.0.0
:: ==============================================================================

:: Load custom local configuration if available
if exist "%~dp0config.local.bat" (
    call "%~dp0config.local.bat"
)

:: ----- Default Configuration (Overrides if config.local.bat not present) -----
if "%LOCAL_BACKUP_ROOT%"=="" set "LOCAL_BACKUP_ROOT=E:\Backups"
if "%REMOTE_BACKUP_ROOT%"=="" set "REMOTE_BACKUP_ROOT=\\192.168.1.100\Backups"
if "%LOG_DIR%"=="" set "LOG_DIR=%~dp0logs"
if "%ROBOCOPY_RETRY_COUNT%"=="" set "ROBOCOPY_RETRY_COUNT=2"
if "%ROBOCOPY_WAIT_TIME%"=="" set "ROBOCOPY_WAIT_TIME=2"

:: Date stamp in yyyy-MM-dd format
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd"') do set TODAY=%%i

:: Paths
set "IIS_APPCMD=%windir%\system32\inetsrv\appcmd.exe"
set "LOCAL_BACKUP=%LOCAL_BACKUP_ROOT%\IIS_Backup_Daily\%TODAY%"
set "REMOTE_BACKUP=%REMOTE_BACKUP_ROOT%\IIS_Backups\%TODAY%"
set "BACKUP_NAME=DailyBackup_%TODAY%"
set "APPCMD_BACKUP_DIR=%windir%\system32\inetsrv\backup\%BACKUP_NAME%"

:: Setup log directory
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
set "LOG_FILE=%LOG_DIR%\IIS_Backup_%TODAY%.log"

call :LogMessage "=================================================="
call :LogMessage "IIS AUTOMATED BACKUP PROCEDURE STARTED"
call :LogMessage "Timestamp: %DATE% %TIME%"
call :LogMessage "Backup Identifier: %BACKUP_NAME%"
call :LogMessage "=================================================="

:: Pre-flight verification: Check if appcmd.exe exists
if not exist "%IIS_APPCMD%" (
    call :LogMessage "[ERROR] IIS management utility 'appcmd.exe' was not found at '%IIS_APPCMD%'."
    call :LogMessage "[ERROR] Please ensure Internet Information Services is installed."
    goto ERROR_EXIT
)

:: Ensure local destination directory exists
if not exist "%LOCAL_BACKUP%" (
    mkdir "%LOCAL_BACKUP%" 2>nul
    if not exist "%LOCAL_BACKUP%" (
        call :LogMessage "[ERROR] Failed to create local directory: %LOCAL_BACKUP%"
        goto ERROR_EXIT
    )
)

:: Step 1: Create IIS configuration backup using appcmd
call :LogMessage "[INFO] Creating IIS configuration backup snapshot..."
"%IIS_APPCMD%" add backup "%BACKUP_NAME%" >> "%LOG_FILE%" 2>&1
if errorlevel 1 (
    call :LogMessage "[WARNING] appcmd returned an exit code. Backup snapshot may already exist for today."
)

:: Step 2: Copy IIS backup to local backup storage
call :LogMessage "[INFO] Staging backup files to local path: %LOCAL_BACKUP%"
robocopy "%APPCMD_BACKUP_DIR%" "%LOCAL_BACKUP%" /E /R:%ROBOCOPY_RETRY_COUNT% /W:%ROBOCOPY_WAIT_TIME% >> "%LOG_FILE%" 2>&1
if errorlevel 8 (
    call :LogMessage "[ERROR] Robocopy local staging failed with exit code %ERRORLEVEL%."
    goto ERROR_EXIT
)

:: Step 3: Copy backup to remote network share
call :LogMessage "[INFO] Syncing backup to remote network location: %REMOTE_BACKUP%"
robocopy "%LOCAL_BACKUP%" "%REMOTE_BACKUP%" /E /Z /R:%ROBOCOPY_RETRY_COUNT% /W:%ROBOCOPY_WAIT_TIME% >> "%LOG_FILE%" 2>&1
if errorlevel 8 (
    call :LogMessage "[ERROR] Remote synchronization failed with exit code %ERRORLEVEL%."
    goto ERROR_EXIT
)

call :LogMessage "=================================================="
call :LogMessage "[SUCCESS] IIS backup process finished successfully."
call :LogMessage "=================================================="
goto SUCCESS_EXIT

:LogMessage
set "MSG=[%DATE% %TIME%] %~1"
echo %MSG%
if defined LOG_FILE echo %MSG% >> "%LOG_FILE%"
exit /b 0

:ERROR_EXIT
call :LogMessage "[FAILURE] IIS backup job terminated with errors."
endlocal
exit /b 1

:SUCCESS_EXIT
endlocal
exit /b 0
