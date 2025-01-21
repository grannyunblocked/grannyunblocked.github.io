@echo off
setlocal EnableDelayedExpansion

:: 创建临时PowerShell脚本
echo $ErrorActionPreference = 'Stop' > "%temp%\replace.ps1"
echo try { >> "%temp%\replace.ps1"
echo     # 读取JSON文件 >> "%temp%\replace.ps1"
echo     $json = Get-Content '.site.meta' -Raw ^| ConvertFrom-Json >> "%temp%\replace.ps1"
echo     # 获取所有替换对 >> "%temp%\replace.ps1"
echo     $replacePairs = @{} >> "%temp%\replace.ps1"
echo     $json.PSObject.Properties ^| ForEach-Object { >> "%temp%\replace.ps1"
echo         $replacePairs[$_.Name] = $_.Value >> "%temp%\replace.ps1"
echo     } >> "%temp%\replace.ps1"
echo     Write-Host "Loaded $($replacePairs.Count) replacement pairs" >> "%temp%\replace.ps1"
echo     # 获取所有文件 >> "%temp%\replace.ps1"
echo     $files = Get-ChildItem -Recurse -Include @('*.html', '*.xml') >> "%temp%\replace.ps1"
echo     $fileCount = 0 >> "%temp%\replace.ps1"
echo     foreach ($file in $files) { >> "%temp%\replace.ps1"
echo         $content = Get-Content $file.FullName -Raw >> "%temp%\replace.ps1"
echo         $originalContent = $content >> "%temp%\replace.ps1"
echo         $modified = $false >> "%temp%\replace.ps1"
echo         foreach ($pair in $replacePairs.GetEnumerator()) { >> "%temp%\replace.ps1"
echo             if ($content -match [regex]::Escape($pair.Key)) { >> "%temp%\replace.ps1"
echo                 $content = $content -replace [regex]::Escape($pair.Key), $pair.Value >> "%temp%\replace.ps1"
echo                 $modified = $true >> "%temp%\replace.ps1"
echo             } >> "%temp%\replace.ps1"
echo         } >> "%temp%\replace.ps1"
echo         if ($modified -and ($content -ne $originalContent)) { >> "%temp%\replace.ps1"
echo             Write-Host "Modified: $($file.FullName)" >> "%temp%\replace.ps1"
echo             $content ^| Set-Content $file.FullName -NoNewline -Encoding UTF8 >> "%temp%\replace.ps1"
echo             $fileCount++ >> "%temp%\replace.ps1"
echo         } >> "%temp%\replace.ps1"
echo     } >> "%temp%\replace.ps1"
echo     Write-Host "Completed: Modified $fileCount files" >> "%temp%\replace.ps1"
echo } catch { >> "%temp%\replace.ps1"
echo     Write-Host "Error: $_" -ForegroundColor Red >> "%temp%\replace.ps1"
echo     exit 1 >> "%temp%\replace.ps1"
echo } >> "%temp%\replace.ps1"

:: 执行PowerShell脚本
powershell -ExecutionPolicy Bypass -File "%temp%\replace.ps1"

:: 清理临时文件
del "%temp%\replace.ps1"

echo Process completed.
endlocal
