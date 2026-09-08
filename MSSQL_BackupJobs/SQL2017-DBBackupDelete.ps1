<#
.SYNOPSIS
    Prunes SQL Server 2017 backups older than 5 days.
.NOTES
    Author: Mangesh Mundhava
    License: MIT
#>

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
& "$ScriptDir\Cleanup-OldBackups.ps1" -Path "E:\Backups\MSSQL\SQL2017" -RetentionDays 5
