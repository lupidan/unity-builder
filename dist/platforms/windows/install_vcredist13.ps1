# For some reason, Unity is failing in github actions windows runners
# due to missing Visual C++ 2013 redistributables.
# This script downloads and installs the required redistributables.

Write-Output ""
Write-Output "#########################################################"
Write-Output "#         Visual C++ Redistributables (2013)            #"
Write-Output "#########################################################"
Write-Output ""

Write-Output "Checking for Microsoft Visual C++ 2013 Redistributables..."

# --- Check for DLLs directly ---
$dllPaths = @(
    "C:\Windows\System32\msvcr120.dll",
    "C:\Windows\System32\msvcp120.dll",
    "C:\Windows\SysWOW64\msvcr120.dll",
    "C:\Windows\SysWOW64\msvcp120.dll"
)

$dllsFound = $dllPaths | Where-Object { Test-Path $_ }
if ($dllsFound.Count -ge 2) {
    Write-Output "Found Visual C++ 2013 runtime DLLs:"
    $dllsFound | ForEach-Object { Write-Output "  - $_" }
    return
}

Write-Output "DLLs not found; checking registry entries..."

# --- Check registry uninstall entries ---
$vc2013 = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" `
          | Get-ItemProperty `
          | Where-Object { $_.DisplayName -like "Microsoft Visual C++ 2013*" }

if ($vc2013) {
    Write-Output "Found Visual C++ 2013 Redistributables via registry:"
    $vc2013 | ForEach-Object { Write-Output "  - $($_.DisplayName) ($($_.DisplayVersion))" }
    return
}

Write-Warning "Visual C++ 2013 Redistributables not detected."

# --- Install via Chocolatey if available ---
$choco = Get-Command choco -ErrorAction SilentlyContinue
if ($choco) {
    Write-Output "Chocolatey detected. Installing vcredist2013..."
    choco install vcredist2013 -y --no-progress
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to install Visual C++ 2013 Redistributables via Chocolatey."
        exit 1
    } else {
        Write-Output "Successfully installed Visual C++ 2013 Redistributables."
    }
}
else {
    Write-Warning "Chocolatey not available. Please install Microsoft Visual C++ 2013 Redistributables manually."
    exit 1
}

