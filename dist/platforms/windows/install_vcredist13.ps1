# For some reason, Unity is failing in github actions windows runners
# due to missing Visual C++ 2013 redistributables.
# This script downloads and installs the required redistributables.

Write-Output ""
Write-Output "#########################################################"
Write-Output "#                  Checking setup  (1)                  #"
Write-Output "#########################################################"
Write-Output ""

Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* ,
                 HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Where-Object { $_.DisplayName -like "*Visual C++*" } |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
    Sort-Object DisplayName

Write-Output ""
Write-Output "#########################################################"
Write-Output "#                  Checking setup (2)                   #"
Write-Output "#########################################################"
Write-Output ""

Get-CimInstance Win32_Product | Where-Object { $_.Name -like "*Visual C++*" } |
    Select-Object Name, Version

Write-Output ""
Write-Output "#########################################################"
Write-Output "#                  Checking setup (3)                   #"
Write-Output "#########################################################"
Write-Output ""

Get-ChildItem "C:\Windows\System32" -Filter "msvcp*.dll" | Select Name, VersionInfo


Write-Output ""
Write-Output "#########################################################"
Write-Output "#     Installing Visual C++ Redistributables (2013)     #"
Write-Output "#########################################################"
Write-Output ""


winget list vcredist
winget install --id Microsoft.VCRedist.2013.x64 -e --accept-package-agreements --accept-source-agreements
winget install --id Microsoft.VCRedist.2013.x86 -e --accept-package-agreements --accept-source-agreements
winget list vcredist
