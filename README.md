# Windows Server Backup Scripts

A collection of Windows batch scripts for automating daily backups of IIS, MSSQL, MySQL, and PostgreSQL. All scripts copy backups locally and then push them to a remote network share.

---

## Scripts Overview

| Script | Purpose |
|---|---|
| `IIS_Daily_Backups.bat` | Backs up IIS configuration using `appcmd` |
| `MSSQLBackup.bat` | Runs SQL backup jobs for SQL2017, SQL2019, SQL2022 |
| `MySQL_Daily_Remote_Backup.bat` | Copies today's MSSQL backups to a remote share |
| `PostgressSQL_Daily_script.bat` | Backs up selected PostgreSQL databases and copies to remote |

---

## Requirements

- Windows Server with administrative privileges
- IIS installed (for `IIS_Daily_Backups.bat`)
- SQL Server instances: `SQL2017`, `SQL2019`, `SQL2022` (for MSSQL scripts)
- PostgreSQL 16 installed at `C:\Program Files\PostgreSQL\16\` (for PostgreSQL script)
- Network access to `\\192.168.0.70\` for remote backup storage
- Drive `E:\` available for local backup storage

---

## Configuration

Before running, update the following variables inside each script as needed:

**IIS_Daily_Backups.bat**
```
LOCAL_BACKUP  = E:\Backups\IIS_Backup_Daily\
REMOTE_BACKUP = \\192.168.0.70\IIS_Backups\
```

**MySQL_Daily_Remote_Backup.bat**
```
LOCAL_BASE  = E:\Backups\MSSQL
REMOTE_BASE = \\192.168.0.70\MYSQL_Daily_Backups\MSSQL
SQL_VERSIONS = SQL2017 SQL2019 SQL2022
```

**PostgressSQL_Daily_script.bat**
```
PG_BIN      = C:\Program Files\PostgreSQL\16\bin
PG_HOST     = localhost
PG_PORT     = 5432
PG_USER     = postgres
LOCAL_BASE  = E:\Backups\PostgreSQL
REMOTE_BASE = \\192.168.0.70\PostgreSQL_Daily_Backups
DBS         = 
```

---

## Scheduling with Task Scheduler

To run these scripts automatically each day:

1. Open **Task Scheduler** and click **Create Basic Task**
2. Set the trigger to **Daily** at your preferred time
3. Set the action to **Start a Program** and browse to the `.bat` file
4. Set **Start in** to the folder containing the script
5. Run the task with an account that has administrator privileges

---

## Folder Structure

```
E:\Backups\
    IIS_Backup_Daily\
        YYYY-MM-DD\
    MSSQL\
        SQL2017\
            YYYYMMDD\
        SQL2019\
            YYYYMMDD\
        SQL2022\
            YYYYMMDD\
    PostgreSQL\
        YYYYMMDD\
            <database>_YYYYMMDD.backup
```

---

## Notes

- All scripts use `robocopy` for reliable file transfers with retry logic (`/R:2 /W:2`)
- PostgreSQL backups use the custom format (`-F c`) via `pg_dump`
- Remote copy uses `/XO /XN /XC` flags to skip unchanged files and avoid redundant transfers
- If a remote copy fails (robocopy exit code 8 or higher), the script reports an error

---

## License

MIT License. Free to use and modify.
