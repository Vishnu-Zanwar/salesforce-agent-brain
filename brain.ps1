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

Set-Location "D:\salesforce-agent-brain"
$registryPath = "D:\salesforce-agent-brain\00_SYSTEM\pincode_registry.json"

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

        # Save updated registry
        $reg | ConvertTo-Json -Depth 10 | Set-Content $registryPath

        # Create the stub file if folder exists
        if ($folder -ne "" -and (Test-Path $folder)) {
            $stub = "# [$pincode] $title`n`n- **PINCODE:** ``#$pincode```n- **Date:** $(Get-Date -Format 'yyyy-MM-dd')`n- **Status:** active`n`n## Description`n`n(Fill in details here)"
            Set-Content -Path "$folder\$fileName.md" -Value $stub
            Write-Host "?? Stub file created: $folder\$fileName.md" -ForegroundColor Blue
        }

        Write-Host "? PINCODE #$pincode registered successfully!" -ForegroundColor Green
        Write-Host "   Title:  $title" -ForegroundColor White
        Write-Host "   File:   $folder/$fileName.md" -ForegroundColor White
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
        Write-Host "?? Syncing all branches to GitHub..." -ForegroundColor Cyan
        git add .
        $msg = "chore(sync): auto brain sync [$(Get-Date -Format 'yyyy-MM-dd HH:mm')]"
        git commit -m $msg 2>$null
        git push --all origin
        Write-Host "? All branches synced to GitHub!" -ForegroundColor Green
    }

    "branches" {
        Write-Host "?? Active Git Branch Tree:" -ForegroundColor Yellow
        git branch -a
    }

    default {
        Write-Host ""
        Write-Host "?? Salesforce Brain CLI — Available Commands:" -ForegroundColor Cyan
        Write-Host "  .\brain.ps1 status                                    ? Health dashboard" -ForegroundColor White
        Write-Host "  .\brain.ps1 new-pincode [PREFIX] [TITLE] [FOLDER]    ? Register new PINCODE" -ForegroundColor White
        Write-Host "  .\brain.ps1 check-pincode [CODE]                     ? Check if PINCODE exists" -ForegroundColor White
        Write-Host "  .\brain.ps1 sync                                      ? Push all to GitHub" -ForegroundColor White
        Write-Host "  .\brain.ps1 branches                                  ? List all branches" -ForegroundColor White
        Write-Host ""
    }
}
