<#
  health_check.ps1
  Runs every integrity check the devops-agent role is responsible for, in one
  command, and reports PASS/FAIL per check. This is what makes "maintain this
  repository" a checkable job rather than a vague responsibility - see
  00_SYSTEM/DEVOPS_PROTOCOL.md for what each check means and how to fix a
  failure.

  Usage:
    .\00_SYSTEM\health_check.ps1
#>

$repoRoot = Split-Path $PSScriptRoot -Parent
Set-Location $repoRoot

$registryPath = Join-Path $repoRoot "00_SYSTEM\pincode_registry.json"
$indexPath    = Join-Path $repoRoot "00_SYSTEM\pincode_index.json"

$failures = @()
$passes = 0

function Check($name, [bool]$ok, $detail = "") {
    if ($ok) {
        Write-Host "  PASS  $name" -ForegroundColor Green
        $script:passes++
    } else {
        Write-Host "  FAIL  $name" -ForegroundColor Red
        if ($detail) { Write-Host "        $detail" -ForegroundColor Yellow }
        $script:failures += $name
    }
}

Write-Host "H-AKOS Health Check" -ForegroundColor Cyan
Write-Host "--------------------" -ForegroundColor DarkGray

# 1. Registry integrity: every registered PINCODE's file actually exists
# (this is exactly the LWE001/APC001 phantom-entry bug found in the original audit)
$reg = Get-Content $registryPath -Raw | ConvertFrom-Json
$phantoms = @()
foreach ($prefixProp in $reg.registry.PSObject.Properties) {
    foreach ($codeProp in $prefixProp.Value.assigned.PSObject.Properties) {
        $filePath = Join-Path $repoRoot ($codeProp.Value.file -replace '/', '\')
        if (-not (Test-Path $filePath)) {
            $phantoms += "$($codeProp.Name) -> $($codeProp.Value.file)"
        }
    }
}
Check "No phantom registry entries (registered but file missing)" ($phantoms.Count -eq 0) ($phantoms -join "; ")

# 2. No unfilled stub notes left in place (files explicitly marked status:
# draft are exempt - that's the intentional "registered but not yet written"
# state, not a stale stub someone forgot about)
$stubFiles = Get-ChildItem -Path "01_SALESFORCE","02_SYSTEM_DESIGN","03_AI_ENGINEERING","04_CAREER_LEADERSHIP" -Recurse -Filter "*.md" -ErrorAction SilentlyContinue |
    Where-Object {
        $content = Get-Content $_.FullName -Raw
        ($content -match '\(Fill in details here') -and ($content -notmatch '(?i)status\s*[:*]*\s*[:\*]*\s*draft')
    }
Check "No unfilled stub notes (excluding intentional drafts)" ($stubFiles.Count -eq 0) (($stubFiles | ForEach-Object { $_.FullName }) -join "; ")

# 3. Keyword index is in sync with the registry (regenerate if drifted)
$totalRegistered = 0
foreach ($prefixProp in $reg.registry.PSObject.Properties) {
    $totalRegistered += @($prefixProp.Value.assigned.PSObject.Properties).Count
}
$indexCount = 0
if (Test-Path $indexPath) {
    $idx = Get-Content $indexPath -Raw | ConvertFrom-Json
    $indexCount = $idx._meta.total_pincodes
}
Check "Keyword index matches registry count ($totalRegistered)" ($indexCount -eq $totalRegistered) "index has $indexCount, registry has $totalRegistered - run .\brain.ps1 reindex"

# 4. No hardcoded absolute paths reintroduced into the PowerShell scripts
# (excludes this file itself, which necessarily contains the literal string
# in order to detect it elsewhere)
$hardcoded = Get-ChildItem -Path $repoRoot -Filter "*.ps1" -Recurse |
    Where-Object { $_.FullName -ne $PSCommandPath } |
    Select-String -Pattern 'D:\\salesforce-agent-brain' -SimpleMatch |
    Select-Object -ExpandProperty Path -Unique
Check "No hardcoded absolute repo paths in *.ps1" (-not $hardcoded) ($hardcoded -join "; ")

# 5. Storage policy: no tracked file over 5MB
$bigFiles = git ls-files | ForEach-Object {
    if (Test-Path $_ -PathType Leaf) { Get-Item $_ }
} | Where-Object { $_.Length -gt 5MB }
Check "No tracked file exceeds the 5MB storage policy" (-not $bigFiles) (($bigFiles | ForEach-Object { $_.FullName }) -join "; ")

# 6. No stranded commits on the current branch: it should either be `main`
# itself, or have an open PR tracking it. This is the exact failure that
# hit this repo for real - PR #1 merged with only 2 of 9 commits, and the
# other 7 sat stranded on the branch with no open PR for several turns
# before anyone noticed nothing had actually shipped.
$ghExe = (Get-Command gh -ErrorAction SilentlyContinue).Source
if (-not $ghExe -and (Test-Path "C:\Program Files\GitHub CLI\gh.exe")) {
    $ghExe = "C:\Program Files\GitHub CLI\gh.exe"
}

$currentBranch = git branch --show-current
if ($currentBranch -eq "main") {
    Check "No stranded commits (on main)" $true
} elseif ($ghExe) {
    git fetch origin --quiet 2>$null
    $openPRBranches = @()
    try {
        $prJson = & $ghExe pr list --state open --json headRefName 2>$null | ConvertFrom-Json
        $openPRBranches = @($prJson | ForEach-Object { $_.headRefName })
    } catch {}

    $strandedCommits = git log "origin/main..origin/$currentBranch" --oneline 2>$null
    $hasOpenPR = $openPRBranches -contains $currentBranch
    $isStranded = $strandedCommits -and (-not $hasOpenPR)

    Check "No stranded commits on '$currentBranch'" (-not $isStranded) $(if ($isStranded) { "$(@($strandedCommits).Count) commit(s) ahead of main, no open PR tracking them - open one" })
} else {
    Write-Host "  SKIP  Stranded-commit check (gh CLI not found)" -ForegroundColor DarkGray
}

# 7. Working tree is clean or explicable - not a pass/fail, just surfaced
$dirty = git status --porcelain
if ($dirty) {
    Write-Host "  INFO  Working tree has uncommitted changes ($(($dirty | Measure-Object).Count) file(s)) - not necessarily a problem, just worth knowing before a sync." -ForegroundColor DarkYellow
}

Write-Host ""
Write-Host "$passes check(s) passed, $($failures.Count) failed." -ForegroundColor $(if ($failures.Count -eq 0) { "Green" } else { "Red" })
if ($failures.Count -gt 0) {
    Write-Host "Failed: $($failures -join ', ')" -ForegroundColor Red
    exit 1
}
