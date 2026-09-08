@echo off
:: ==============================================================================
:: Configuration Template: Windows Server Backup Suite
:: Author:  Mangesh Mundhava
:: License: MIT
:: Notice:  Copy this file to "config.local.bat" to customize your environment.
::          Ensure confidential settings in config.local.bat are never committed.
:: ==============================================================================

:: ==============================================================================
:: 1. GLOBAL & STORAGE SETTINGS
:: ==============================================================================
:: Base drive or directory for local staging of backups
set "LOCAL_BACKUP_ROOT=E:\Backups"

:: Remote NAS / SMB network share for secondary redundancy (Example format)
:: Example: \\192.168.1.100\Backups or \\backup-server.local\Storage
set "REMOTE_BACKUP_ROOT=\\192.168.1.100\Backups"

:: Log files storage directory
set "LOG_DIR=%~dp0logs"

:: Default retention period in days for historical backup cleanup
set "RETENTION_DAYS=7"

:: Robocopy tuning flags (R: number of retries, W: wait time between retries in seconds)
set "ROBOCOPY_RETRY_COUNT=2"
set "ROBOCOPY_WAIT_TIME=2"

:: ==============================================================================
:: 2. IIS WEB SERVER SETTINGS
:: ==============================================================================
set "IIS_APPCMD=%windir%\system32\inetsrv\appcmd.exe"
set "IIS_LOCAL_PATH=%LOCAL_BACKUP_ROOT%\IIS_Backup_Daily"
set "IIS_REMOTE_PATH=%REMOTE_BACKUP_ROOT%\IIS_Backups"

:: ==============================================================================
:: 3. MICROSOFT SQL SERVER SETTINGS
:: ==============================================================================
set "MSSQL_LOCAL_PATH=%LOCAL_BACKUP_ROOT%\MSSQL"
set "MSSQL_REMOTE_PATH=%REMOTE_BACKUP_ROOT%\MSSQL"
set "MSSQL_INSTANCES=SQL2017 SQL2019 SQL2022"

:: ==============================================================================
:: 4. MYSQL / MARIADB SETTINGS
:: ==============================================================================
set "MYSQL_BIN=C:\Program Files\MySQL\MySQL Server 8.0\bin"
set "MYSQL_HOST=127.0.0.1"
set "MYSQL_PORT=3306"
set "MYSQL_USER=backup_user"
:: TIP: Set password via MYSQL_PWD environment variable or MySQL login-path
:: set "MYSQL_PWD=your_secure_password_here"
set "MYSQL_LOCAL_PATH=%LOCAL_BACKUP_ROOT%\MySQL"
set "MYSQL_REMOTE_PATH=%REMOTE_BACKUP_ROOT%\MySQL_Daily_Backups"
:: List of databases separated by space, or leave empty for all databases
set "MYSQL_DATABASES=app_db ecommerce_db reporting_db"

:: ==============================================================================
:: 5. POSTGRESQL SETTINGS
:: ==============================================================================
set "PG_BIN=C:\Program Files\PostgreSQL\16\bin"
set "PG_HOST=127.0.0.1"
set "PG_PORT=5432"
set "PG_USER=postgres"
:: TIP: Recommended to use %APPDATA%\postgresql\pgpass.conf or set PGPASSWORD
:: set "PGPASSWORD=your_secure_password_here"
set "PG_LOCAL_PATH=%LOCAL_BACKUP_ROOT%\PostgreSQL"
set "PG_REMOTE_PATH=%REMOTE_BACKUP_ROOT%\PostgreSQL_Daily_Backups"
:: List of PostgreSQL databases to backup separated by space
set "PG_DATABASES=app_db analytics_db auth_db postgres"
