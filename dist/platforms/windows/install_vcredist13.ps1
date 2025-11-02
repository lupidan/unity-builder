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

Write-Output "Visual C++ 2013 Redistributables DLLs not found."

# --- Check registry uninstall entries ---
$vc2013 = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" `
          | Get-ItemProperty `
          | Where-Object { $_.DisplayName -like "Microsoft Visual C++ 2013*" }

if ($vc2013) {
    Write-Output "Found Visual C++ 2013 Redistributables via registry:"
    $vc2013 | ForEach-Object { Write-Output "  - $($_.DisplayName) ($($_.DisplayVersion))" }
    return
}

Write-Output "Visual C++ 2013 Redistributables registries not found."

# --- Install via Chocolatey if available ---
$downloads = @{
    "x86" = "https://download.microsoft.com/download/9/3/F/93FCF1E7-E6A4-478B-96E7-D4B285925B00/vcredist_x86.exe"
    "x64" = "https://download.microsoft.com/download/9/3/F/93FCF1E7-E6A4-478B-96E7-D4B285925B00/vcredist_x64.exe"
}

foreach ($arch in $downloads.Keys) {
    $url = $downloads[$arch]
    $file = Join-Path $temp "vcredist2013_$arch.exe"

    Write-Output "Downloading Visual C++ 2013 Redistributable ($arch)..."
    Invoke-WebRequest -Uri $url -OutFile $file -UseBasicParsing

    Write-Output "Installing Visual C++ 2013 Redistributable ($arch)..."
    Start-Process $file -ArgumentList "/install", "/quiet", "/norestart" -Wait

    if ($LASTEXITCODE -eq 0) {
        Write-Output "Successfully installed VC++ 2013 Redistributable ($arch)."
    } else {
        Write-Error "Failed to install VC++ 2013 Redistributable ($arch). Exit code: $LASTEXITCODE"
        exit 1
    }
}

Write-Output ""
Write-Output "Microsoft Visual C++ 2013 Redistributables installation complete."

