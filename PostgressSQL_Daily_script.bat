@echo off
setlocal EnableDelayedExpansion

echo ==================================
echo POSTGRESQL SELECTED DB BACKUP
echo ==================================

:: ===== DATE =====
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd"') do set TODAY=%%i

:: ===== POSTGRES CONFIG =====
set PG_BIN=C:\Program Files\PostgreSQL\16\bin
set PG_HOST=localhost
set PG_PORT=5432
set PG_USER=postgres

:: ===== LOCAL BACKUP PATH =====
set LOCAL_BASE=E:\Backups\PostgreSQL
set LOCAL_TODAY=%LOCAL_BASE%\%TODAY%

:: ===== REMOTE BACKUP PATH =====
set REMOTE_BASE=\\192.168.0.70\PostgreSQL_Daily_Backups
set REMOTE_TODAY=%REMOTE_BASE%\%TODAY%

:: ===== DATABASE LIST (FIXED) =====
set DBS=dify dify_Trainees dify_Trainees1 dify_Trainees2 MyBuddy-dump-dev postgres

:: ===== CREATE LOCAL DIR =====
if not exist "%LOCAL_TODAY%" mkdir "%LOCAL_TODAY%"

echo Starting PostgreSQL backups...

:: ===== BACKUP EACH DATABASE =====
for %%D in (%DBS%) do (
    echo Backing up database: %%D
    "%PG_BIN%\pg_dump.exe" -h %PG_HOST% -p %PG_PORT% -U %PG_USER% ^
    -F c -b -v -f "%LOCAL_TODAY%\%%D_%TODAY%.backup" %%D

    if errorlevel 1 (
        echo ERROR: Backup failed for %%D
        goto END
    )
)

echo Local backups completed successfully

:: ===== COPY TO REMOTE (NEW FILES ONLY) =====
echo Copying backups to remote server...

robocopy "%LOCAL_TODAY%" "%REMOTE_TODAY%" *.backup /E /XO /XN /XC /R:2 /W:2 /NFL /NDL

if errorlevel 8 (
    echo ERROR: Remote copy failed
    goto END
)

echo ==================================
echo POSTGRESQL BACKUP COMPLETED
echo ==================================

:END
endlocal
exit /b 0

