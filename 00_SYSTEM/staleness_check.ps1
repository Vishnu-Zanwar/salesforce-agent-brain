<#
  staleness_check.ps1
  Scans every real note/code-sample under 01_SALESFORCE for a "Last Verified" date
  and flags anything older than the threshold, or missing the field entirely.

  Usage:
    .\00_SYSTEM\staleness_check.ps1                  (uses 180-day default threshold)
    .\00_SYSTEM\staleness_check.ps1 -ThresholdDays 90
#>
param (
    [int]$ThresholdDays = 180
)

Set-Location (Split-Path $PSScriptRoot -Parent)

$today = Get-Date
$files = Get-ChildItem -Path "01_SALESFORCE" -Recurse -Include "*.md","*.cls" |
    Where-Object { $_.Name -ne ".gitkeep" }

$stale   = @()
$missing = @()
$draft   = @()
$fresh   = @()

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw

    if ($content -match '(?i)status\s*[:*]*\s*[:\*]*\s*draft') {
        $draft += $file.FullName
        continue
    }

    if ($content -match '(?i)Last Verified[:\*\s]+(\d{4}-\d{2}-\d{2})') {
        $verifiedDate = [datetime]::ParseExact($Matches[1], "yyyy-MM-dd", $null)
        $ageDays = ($today - $verifiedDate).Days

        if ($ageDays -gt $ThresholdDays) {
            $stale += [PSCustomObject]@{ File = $file.FullName; LastVerified = $Matches[1]; AgeDays = $ageDays }
        } else {
            $fresh += [PSCustomObject]@{ File = $file.FullName; LastVerified = $Matches[1]; AgeDays = $ageDays }
        }
    } else {
        $missing += $file.FullName
    }
}

$freshCount = $fresh.Count
$staleCount = $stale.Count
$missingCount = $missing.Count
$draftCount = $draft.Count

Write-Host ""
Write-Host "Staleness Audit (threshold: $ThresholdDays days)" -ForegroundColor Cyan
Write-Host "-------------------------------------------------" -ForegroundColor DarkGray

if ($freshCount -gt 0) {
    Write-Host ""
    Write-Host "OK - up to date ($freshCount):" -ForegroundColor Green
    foreach ($item in $fresh) {
        $line = "   {0}  [verified {1}, {2}d ago]" -f $item.File, $item.LastVerified, $item.AgeDays
        Write-Host $line -ForegroundColor White
    }
}

if ($staleCount -gt 0) {
    Write-Host ""
    Write-Host "NEEDS_REVIEW - older than $ThresholdDays days ($staleCount):" -ForegroundColor Yellow
    foreach ($item in $stale) {
        $line = "   {0}  [verified {1}, {2}d ago]" -f $item.File, $item.LastVerified, $item.AgeDays
        Write-Host $line -ForegroundColor Yellow
    }
}

if ($missingCount -gt 0) {
    Write-Host ""
    Write-Host "NO_VERIFICATION_DATE - missing 'Last Verified' field ($missingCount):" -ForegroundColor Red
    foreach ($item in $missing) {
        Write-Host "   $item" -ForegroundColor Red
    }
}

if ($draftCount -gt 0) {
    Write-Host ""
    Write-Host "DRAFT - not yet written, excluded from staleness tracking ($draftCount):" -ForegroundColor DarkGray
    foreach ($item in $draft) {
        Write-Host "   $item" -ForegroundColor DarkGray
    }
}

Write-Host ""
