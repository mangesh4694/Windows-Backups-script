@echo off
:: ==============================================================================
:: Script Name: DBCopy_19_NAS.bat
:: Description: Copy SQL Server 2019 backups to NAS / Remote storage.
:: Author:      Mangesh Mundhava
:: License:     MIT
:: ==============================================================================

set "SOURCE_DIR=E:\Backups\MSSQL\SQL2019"
set "TARGET_DIR=\\192.168.1.100\Server_Backups\MSSQL\SQL2019"

echo [INFO] Syncing SQL2019 backups to NAS: %TARGET_DIR%
robocopy "%SOURCE_DIR%" "%TARGET_DIR%" /E /Z /XO /XN /XC /R:2 /W:2

if errorlevel 8 (
    echo [ERROR] Robocopy failed for SQL2019 with exit code %ERRORLEVEL%
    exit /b 1
)

echo [SUCCESS] SQL2019 NAS copy finished.
exit /b 0
