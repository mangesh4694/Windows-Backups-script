<#
.SYNOPSIS
    Prunes SQL Server 2022 backups older than 5 days.
.NOTES
    Author: Mangesh Mundhava
    License: MIT
#>

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
& "$ScriptDir\Cleanup-OldBackups.ps1" -Path "E:\Backups\MSSQL\SQL2022" -RetentionDays 5
