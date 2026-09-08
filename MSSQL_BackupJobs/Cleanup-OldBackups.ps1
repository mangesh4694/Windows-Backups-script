<#
.SYNOPSIS
    Automated backup file retention and pruning utility.
.DESCRIPTION
    Scans a specified folder recursively for backup files and folders older
    than the retention threshold and removes them safely.
.PARAMETER Path
    The target directory containing backups to prune.
.PARAMETER RetentionDays
    Number of days to keep backups. Anything older will be purged. Default is 5.
.PARAMETER Filter
    Filter string for files to match. Default is "*".
.EXAMPLE
    .\Cleanup-OldBackups.ps1 -Path "E:\Backups\MSSQL\SQL2017" -RetentionDays 5
.EXAMPLE
    .\Cleanup-OldBackups.ps1 -Path "E:\Backups\MSSQL" -RetentionDays 7 -WhatIf
.NOTES
    Author:  Mangesh Mundhava
    License: MIT
    Version: 2.0.0
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Path,

    [Parameter(Mandatory = $false, Position = 1)]
    [int]$RetentionDays = 5,

    [Parameter(Mandatory = $false)]
    [string]$Filter = "*"
)

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "BACKUP CLEANUP PROCEDURE STARTED" -ForegroundColor Cyan
Write-Host "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host "Target Path: $Path" -ForegroundColor Gray
Write-Host "Retention Window: $RetentionDays days" -ForegroundColor Gray
Write-Host "==================================================" -ForegroundColor Cyan

if (-not (Test-Path -LiteralPath $Path)) {
    Write-Warning "[WARNING] Path does not exist: $Path"
    return
}

$cutoffDate = (Get-Date).AddDays(-$RetentionDays)
Write-Host "[INFO] Cutoff timestamp: $cutoffDate" -ForegroundColor Gray

# Collect items older than retention threshold
$oldItems = Get-ChildItem -LiteralPath $Path -Filter $Filter -Recurse -Force -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -lt $cutoffDate }

if ($null -eq $oldItems -or $oldItems.Count -eq 0) {
    Write-Host "[INFO] No expired backup items found matching criteria." -ForegroundColor Green
    return
}

Write-Host "[INFO] Found $($oldItems.Count) item(s) older than $RetentionDays days." -ForegroundColor Cyan

$processedCount = 0
$failedCount = 0

# Sort files first, then directories deepest first
$sortedItems = $oldItems | Sort-Object { $_.FullName.Length } -Descending

foreach ($item in $sortedItems) {
    try {
        if ($PSCmdlet.ShouldProcess($item.FullName, "Delete expired backup item")) {
            if ($item.PSIsContainer) {
                Remove-Item -LiteralPath $item.FullName -Recurse -Force -ErrorAction Stop
            }
            else {
                Remove-Item -LiteralPath $item.FullName -Force -ErrorAction Stop
            }
            Write-Host "[DELETED] $($item.FullName)" -ForegroundColor Green
        }
        $processedCount++
    }
    catch {
        Write-Host "[ERROR] Failed to delete $($item.FullName): $_" -ForegroundColor Red
        $failedCount++
    }
}

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "[COMPLETED] Cleanup finished. Processed: $processedCount item(s). Errors: $failedCount" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
