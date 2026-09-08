<#
.SYNOPSIS
    Prunes backup archives older than 4 days.
.NOTES
    Author: Mangesh Mundhava
    License: MIT
#>

$ScriptDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$TargetDir = "E:\Backups\MSSQL"
$CleanupScript = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "Cleanup-OldBackups.ps1"

if (Test-Path $CleanupScript) {
    & $CleanupScript -Path $TargetDir -RetentionDays 4
} else {
    Write-Host "[INFO] Scanning for expired backups older than 4 days in $TargetDir..."
    $cutoff = (Get-Date).AddDays(-4)
    Get-ChildItem -Path $TargetDir -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -lt $cutoff } |
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}