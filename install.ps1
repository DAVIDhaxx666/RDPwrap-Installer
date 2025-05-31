# RDP Wrapper Library Installer
Write-Host "[*] Starting RDP Wrapper installation..." -ForegroundColor Cyan

# Define download URLs and installation paths
$downloadUrl = "https://github.com/stascorp/rdpwrap/releases/latest/download/rdpwrap.zip"
$installPath = "$env:ProgramFiles\RDP Wrapper"

# Create installation directory
if (!(Test-Path $installPath)) {
    New-Item -ItemType Directory -Path $installPath | Out-Null
    Write-Host "[+] Created installation directory: $installPath"
}

# Download RDPWrap zip package
Write-Host "[*] Downloading RDP Wrapper..."
$zipFile = "$env:TEMP\rdpwrap.zip"
Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile

# Extract files
Write-Host "[*] Extracting files..."
Expand-Archive -Path $zipFile -DestinationPath $installPath -Force
Write-Host "[+] Files extracted to: $installPath"

# Modify registry to register RDP Wrapper
Write-Host "[*] Modifying registry settings..."
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\TermService\Parameters" -Name "ServiceDll" -Value "$installPath\rdpwrap.dll"

# Configure firewall rules
Write-Host "[*] Configuring firewall..."
New-NetFirewallRule -DisplayName "Remote Desktop TCP" -Direction Inbound -Protocol TCP -LocalPort 3389 -Action Allow
New-NetFirewallRule -DisplayName "Remote Desktop UDP" -Direction Inbound -Protocol UDP -LocalPort 3389 -Action Allow
Write-Host "[+] Firewall rules applied."

# Start TermService
Write-Host "[*] Starting Remote Desktop Service..."
Set-Service -Name "TermService" -StartupType Automatic
Start-Service -Name "TermService"

Write-Host "[+] Installation complete! You may need to reboot or restart TermService manually." -ForegroundColor Green
