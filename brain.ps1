param (
    [Parameter(Position=0)]
    [string]$Action = "status",
    [Parameter(Position=1)]
    [string]$Arg1 = "",
    [Parameter(Position=2)]
    [string]$Arg2 = "",
    [Parameter(Position=3)]
    [string]$Arg3 = ""
)

$repoRoot = $PSScriptRoot
Set-Location $repoRoot
$registryPath = Join-Path $repoRoot "00_SYSTEM\pincode_registry.json"
$indexPath    = Join-Path $repoRoot "00_SYSTEM\pincode_index.json"

$stopWords = @('a','an','the','and','or','of','in','on','to','for','with','via','vs','is','are')

function Get-Tokens($text) {
    ($text -split '[^a-zA-Z0-9]+') |
        Where-Object { $_.Length -gt 2 } |
        ForEach-Object { $_.ToLower() } |
        Where-Object { $stopWords -notcontains $_ } |
        Select-Object -Unique
}

switch ($Action.ToLower()) {

    "status" {
        Write-Host "?? Second Brain Repository Health:" -ForegroundColor Cyan
        Write-Host "----------------------------------" -ForegroundColor DarkGray
        $errorsCount  = (Get-ChildItem -Path "01_SALESFORCE" -Recurse -Filter "*.md" | Where-Object { $_.DirectoryName -like "*01_ERRORS*" }).Count
        $learnCount   = (Get-ChildItem -Path "01_SALESFORCE" -Recurse -Filter "*.md" | Where-Object { $_.DirectoryName -like "*02_LEARNING*" }).Count
        $samplesCount = (Get-ChildItem -Path "01_SALESFORCE" -Recurse | Where-Object { $_.DirectoryName -like "*03_CODE_SAMPLES*" -and $_.Name -ne ".gitkeep" }).Count
        $reg = Get-Content $registryPath | ConvertFrom-Json
        $totalPincodes = ($reg.registry.PSObject.Properties | ForEach-Object { $_.Value.last_id } | Measure-Object -Sum).Sum
        Write-Host "?? Errors Logged:      $errorsCount" -ForegroundColor Red
        Write-Host "?? Concepts Mastered:  $learnCount" -ForegroundColor Green
        Write-Host "?? Code Samples:       $samplesCount" -ForegroundColor Blue
        Write-Host "???  Total PINcodes:     $totalPincodes" -ForegroundColor Magenta
        Write-Host "?? Current Branch:     $(git branch --show-current)" -ForegroundColor Yellow
    }

    "new-pincode" {
        # Usage: .\brain.ps1 new-pincode LWE "Wire adapter crash on null data" "01_SALESFORCE/LWC/01_ERRORS"
        if ($Arg1 -eq "") { Write-Host "Usage: .\brain.ps1 new-pincode [PREFIX] [TITLE] [FOLDER_PATH]" -ForegroundColor Yellow; exit }
        $prefix = $Arg1.ToUpper()
        $title  = $Arg2
        $folder = $Arg3

        $reg = Get-Content $registryPath | ConvertFrom-Json

        if (-not $reg.registry.PSObject.Properties[$prefix]) {
            Write-Host "? Unknown prefix '$prefix'. Add it to pincode_registry.json first." -ForegroundColor Red
            exit
        }

        $nextId    = $reg.registry.$prefix.last_id + 1
        $pincode   = "$prefix" + $nextId.ToString("D3")
        $safeTitle = $title -replace '[^a-zA-Z0-9\s]', '' -replace '\s+', '_'
        $fileName  = "${pincode}_${safeTitle}"

        # Collision check
        if ($reg.registry.$prefix.assigned.PSObject.Properties[$pincode]) {
            Write-Host "?? COLLISION DETECTED! $pincode is already assigned to: $($reg.registry.$prefix.assigned.$pincode.title)" -ForegroundColor Red
            exit
        }

        # Register the new PINCODE
        $reg.registry.$prefix.last_id = $nextId
        $newEntry = [PSCustomObject]@{
            title  = $title
            file   = "$folder/$fileName.md"
            date   = (Get-Date -Format "yyyy-MM-dd")
            status = "active"
        }
        $reg.registry.$prefix.assigned | Add-Member -NotePropertyName $pincode -NotePropertyValue $newEntry

        # Save updated registry. Explicit UTF8 (no BOM) - Set-Content defaults
        # to the system ANSI codepage on Windows PowerShell 5.1, which silently
        # corrupts any title with a non-ASCII character (em-dash, curly quote,
        # accented letter) into invalid UTF-8 for every other reader (Python,
        # git diff, etc). Found for real: #LWL003's title had an em-dash and
        # broke strict UTF-8 parsing until this fix.
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($registryPath, ($reg | ConvertTo-Json -Depth 10), $utf8NoBom)

        # Create the stub file if folder exists
        if ($folder -ne "" -and (Test-Path $folder)) {
            $stub = "# [$pincode] $title`n`n- **PINCODE:** ``#$pincode```n- **Date:** $(Get-Date -Format 'yyyy-MM-dd')`n- **Status:** active`n`n## Description`n`n(Fill in details here)"
            [System.IO.File]::WriteAllText("$folder\$fileName.md", $stub, $utf8NoBom)
            Write-Host "?? Stub file created: $folder\$fileName.md" -ForegroundColor Blue
        }

        Write-Host "? PINCODE #$pincode registered successfully!" -ForegroundColor Green
        Write-Host "   Title:  $title" -ForegroundColor White
        Write-Host "   File:   $folder/$fileName.md" -ForegroundColor White

        & $PSCommandPath reindex | Out-Null
    }

    "reindex" {
        Write-Host "Rebuilding pincode_index.json from registry..." -ForegroundColor Cyan
        $reg = Get-Content $registryPath | ConvertFrom-Json

        $keywords = [ordered]@{}
        $pincodes = [ordered]@{}
        $count = 0

        foreach ($prefixProp in $reg.registry.PSObject.Properties) {
            foreach ($codeProp in $prefixProp.Value.assigned.PSObject.Properties) {
                $code  = $codeProp.Name
                $entry = $codeProp.Value
                $count++

                $pincodes[$code] = [ordered]@{
                    title  = $entry.title
                    file   = $entry.file
                    date   = $entry.date
                    status = $entry.status
                }

                $tokens = Get-Tokens $entry.title
                foreach ($tok in $tokens) {
                    if (-not $keywords.Contains($tok)) { $keywords[$tok] = @() }
                    $keywords[$tok] = @($keywords[$tok]) + $code
                }
            }
        }

        $index = [ordered]@{
            _meta = [ordered]@{
                version     = "1.0.0"
                generated   = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                description = "Inverted keyword index over pincode_registry.json titles. Regenerate with '.\brain.ps1 reindex' after adding PINCODEs."
                total_pincodes = $count
            }
            keywords = $keywords
            pincodes = $pincodes
        }

        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($indexPath, ($index | ConvertTo-Json -Depth 10), $utf8NoBom)
        Write-Host "Indexed $count PINCODE(s), $($keywords.Count) keyword(s) -> $indexPath" -ForegroundColor Green
    }

    "search" {
        # Usage: .\brain.ps1 search "wire mutation"
        if ($Arg1 -eq "") { Write-Host "Usage: .\brain.ps1 search `"query text`"" -ForegroundColor Yellow; exit }

        if (-not (Test-Path $indexPath)) {
            Write-Host "No index found. Run '.\brain.ps1 reindex' first." -ForegroundColor Red
            exit
        }
        $index = Get-Content $indexPath | ConvertFrom-Json

        # Direct PINCODE hit, e.g. "search LWE001"
        $directCode = $Arg1.ToUpper()
        if ($index.pincodes.PSObject.Properties[$directCode]) {
            $entry = $index.pincodes.$directCode
            Write-Host "Direct match #$directCode :" -ForegroundColor Green
            Write-Host "   Title: $($entry.title)" -ForegroundColor White
            Write-Host "   File:  $($entry.file)" -ForegroundColor White
            exit
        }

        $queryTokens = Get-Tokens $Arg1
        if ($queryTokens.Count -eq 0) { Write-Host "Query too short/generic." -ForegroundColor Yellow; exit }

        $scores = @{}
        foreach ($tok in $queryTokens) {
            foreach ($kw in $index.keywords.PSObject.Properties) {
                if ($kw.Name -like "*$tok*") {
                    foreach ($code in @($kw.Value)) {
                        if (-not $scores.ContainsKey($code)) { $scores[$code] = 0 }
                        $scores[$code]++
                    }
                }
            }
        }

        if ($scores.Count -eq 0) {
            Write-Host "No matches for '$Arg1'." -ForegroundColor Yellow
            exit
        }

        Write-Host "Search results for '$Arg1':" -ForegroundColor Cyan
        $scores.GetEnumerator() | Sort-Object -Property Value -Descending | ForEach-Object {
            $entry = $index.pincodes.($_.Key)
            Write-Host "   #$($_.Key)  [$($_.Value) hit(s)]  $($entry.title)" -ForegroundColor White
            Write-Host "        $($entry.file)" -ForegroundColor DarkGray
        }
    }

    "show" {
        # Usage: .\brain.ps1 show LWE001
        # Dumps the full content of a registered note in one call, so an
        # agent doesn't need a separate file-read round trip after search.
        if ($Arg1 -eq "") { Write-Host "Usage: .\brain.ps1 show [PINCODE]" -ForegroundColor Yellow; exit }
        $code = $Arg1.ToUpper()
        $prefix = $code.Substring(0, 3)
        $reg = Get-Content $registryPath | ConvertFrom-Json

        if (-not $reg.registry.$prefix.assigned.PSObject.Properties[$code]) {
            Write-Host "NOT_FOUND: #$code is not registered." -ForegroundColor Yellow
            exit
        }

        $entry = $reg.registry.$prefix.assigned.$code
        $filePath = Join-Path $repoRoot $entry.file

        if (-not (Test-Path $filePath)) {
            Write-Host "REGISTERED_BUT_MISSING: #$code points to $($entry.file), which does not exist on disk." -ForegroundColor Red
            exit
        }

        Write-Host "===== #$code : $($entry.title) =====" -ForegroundColor Cyan
        Write-Host "File: $($entry.file)" -ForegroundColor DarkGray
        Write-Host ""
        try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}
        $rawText = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)
        Write-Host $rawText
    }

    "check-pincode" {
        # Usage: .\brain.ps1 check-pincode LWE007
        $code = $Arg1.ToUpper()
        $prefix = $code.Substring(0, 3)
        $reg = Get-Content $registryPath | ConvertFrom-Json
        if ($reg.registry.$prefix.assigned.PSObject.Properties[$code]) {
            $entry = $reg.registry.$prefix.assigned.$code
            Write-Host "? #$code is REGISTERED:" -ForegroundColor Green
            Write-Host "   Title:  $($entry.title)" -ForegroundColor White
            Write-Host "   File:   $($entry.file)" -ForegroundColor White
            Write-Host "   Date:   $($entry.date)" -ForegroundColor White
            Write-Host "   Status: $($entry.status)" -ForegroundColor White
        } else {
            Write-Host "? #$code is NOT registered. Safe to use!" -ForegroundColor Yellow
        }
    }

    "sync" {
        # STORAGE_POLICY.md gate: block the sync if a large/binary file
        # (recording, PDF, dataset) is about to be committed.
        $bigFiles = git status --porcelain |
            ForEach-Object { $_.Substring(3).Trim('"') } |
            Where-Object { Test-Path $_ -PathType Leaf } |
            Get-Item |
            Where-Object { $_.Length -gt 5MB }

        if ($bigFiles) {
            Write-Host "?? Sync blocked - large file(s) staged for commit (see 00_SYSTEM/STORAGE_POLICY.md):" -ForegroundColor Red
            $bigFiles | ForEach-Object {
                $sizeMB = [math]::Round($_.Length / 1MB, 1)
                Write-Host "   $($_.FullName)  ($sizeMB MB)" -ForegroundColor Red
            }
            Write-Host "Move it to Google Drive and link it from the note instead, then re-run sync." -ForegroundColor Yellow
            exit
        }

        # Refresh the semantic index too, if the Python layer is available.
        # Non-fatal on purpose: git sync must not depend on the ML stack
        # being installed/working.
        $vectorScript = Join-Path $repoRoot "00_SYSTEM\vector_search.py"
        if (Get-Command python -ErrorAction SilentlyContinue) {
            Write-Host "Refreshing semantic vector index..." -ForegroundColor Cyan
            try { python $vectorScript build } catch { Write-Host "Semantic reindex skipped: $_" -ForegroundColor DarkYellow }
        }

        Write-Host "?? Syncing all branches to GitHub..." -ForegroundColor Cyan
        git add .
        $msg = "chore(sync): auto brain sync [$(Get-Date -Format 'yyyy-MM-dd HH:mm')]"
        git commit -m $msg 2>$null
        git push --all origin
        Write-Host "? All branches synced to GitHub!" -ForegroundColor Green
    }

    "vector-reindex" {
        Write-Host "Rebuilding semantic vector index (loads an ML model, may take a bit)..." -ForegroundColor Cyan
        python (Join-Path $repoRoot "00_SYSTEM\vector_search.py") build
    }

    "search-semantic" {
        # Usage: .\brain.ps1 search-semantic "screen freezing after save"
        if ($Arg1 -eq "") { Write-Host "Usage: .\brain.ps1 search-semantic `"query text`"" -ForegroundColor Yellow; exit }
        python (Join-Path $repoRoot "00_SYSTEM\vector_search.py") query $Arg1
    }

    "branches" {
        Write-Host "?? Active Git Branch Tree:" -ForegroundColor Yellow
        git branch -a
    }

    default {
        Write-Host ""
        Write-Host "?? Salesforce Brain CLI ï¿½ Available Commands:" -ForegroundColor Cyan
        Write-Host "  .\brain.ps1 status                                    ? Health dashboard" -ForegroundColor White
        Write-Host "  .\brain.ps1 new-pincode [PREFIX] [TITLE] [FOLDER]    ? Register new PINCODE" -ForegroundColor White
        Write-Host "  .\brain.ps1 check-pincode [CODE]                     ? Check if PINCODE exists" -ForegroundColor White
        Write-Host "  .\brain.ps1 search `"query text`"                      ? Search PINCODE index" -ForegroundColor White
        Write-Host "  .\brain.ps1 show [PINCODE]                            ? Dump a note's full content" -ForegroundColor White
        Write-Host "  .\brain.ps1 search-semantic `"query text`"             ? Fuzzy/meaning-based search (needs Python)" -ForegroundColor White
        Write-Host "  .\brain.ps1 vector-reindex                            ? Rebuild the semantic index" -ForegroundColor White
        Write-Host "  .\brain.ps1 reindex                                   ? Rebuild pincode_index.json" -ForegroundColor White
        Write-Host "  .\brain.ps1 sync                                      ? Push all to GitHub" -ForegroundColor White
        Write-Host "  .\brain.ps1 branches                                  ? List all branches" -ForegroundColor White
        Write-Host ""
    }
}
