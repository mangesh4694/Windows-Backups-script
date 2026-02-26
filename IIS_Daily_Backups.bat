@echo off
setlocal EnableDelayedExpansion

echo ================================
echo IIS BACKUP STARTED
echo ================================

:: Date
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd"') do set TODAY=%%i

:: Paths
set LOCAL_BACKUP=E:\Backups\IIS_Backup_Daily\%TODAY%
set REMOTE_BACKUP=\\192.168.0.70\IIS_Backups\%TODAY%

:: Create local folder
if not exist "%LOCAL_BACKUP%" mkdir "%LOCAL_BACKUP%"

echo Creating IIS backup...
%windir%\system32\inetsrv\appcmd add backup "DailyBackup_%TODAY%"

echo Copying IIS backup locally...
robocopy "%windir%\system32\inetsrv\backup\DailyBackup_%TODAY%" "%LOCAL_BACKUP%" /E /R:2 /W:2

echo Copying backup to remote server...
robocopy "%LOCAL_BACKUP%" "%REMOTE_BACKUP%" /E /Z /R:2 /W:2

if errorlevel 8 (
    echo ERROR: Remote copy failed
    goto END
)

echo ================================
echo BACKUP COMPLETED SUCCESSFULLY
echo ================================

:END
endlocal
exit /b 0

