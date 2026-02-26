@echo off
setlocal EnableDelayedExpansion

echo ==================================
echo COPYING TODAY'S MSSQL BACKUPS ONLY
echo ==================================

:: ===== DATE (yyyyMMdd) =====
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd"') do set TODAY=%%i

:: ===== LOCAL MSSQL BACKUP ROOT =====
set LOCAL_BASE=E:\Backups\MSSQL

:: ===== REMOTE MSSQL BACKUP ROOT =====
set REMOTE_BASE=\\192.168.0.70\MYSQL_Daily_Backups\MSSQL

:: ===== SQL VERSIONS =====
set SQL_VERSIONS=SQL2017 SQL2019 SQL2022

for %%V in (%SQL_VERSIONS%) do (
    set "LOCAL_TODAY=%LOCAL_BASE%\%%V\%TODAY%"
    set "REMOTE_TODAY=%REMOTE_BASE%\%%V\%TODAY%"

    if exist "!LOCAL_TODAY!" (
        echo.
        echo Copying %%V backup...
        echo ----------------------------------

        robocopy "!LOCAL_TODAY!" "!REMOTE_TODAY!" /E /Z /XO /XN /XC /R:2 /W:2

        if errorlevel 8 (
            echo ERROR: %%V copy failed
        ) else (
            echo %%V copy completed successfully
        )
    ) else (
        echo WARNING: %%V backup for %TODAY% not found
    )
)

echo.
echo ==================================
echo MSSQL COPY PROCESS COMPLETED
echo ==================================

:END
endlocal
exit /b 0

