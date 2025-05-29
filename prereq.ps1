# Enable WinRM service
Enable-PSRemoting -Force

# Configure WinRM for HTTP
winrm quickconfig -q

# Set WinRM to allow unencrypted traffic (for HTTP)
winrm set winrm/config/service '@{AllowUnencrypted="true"}'

# Set authentication methods
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service/auth '@{Negotiate="true"}'

# Configure client settings
winrm set winrm/config/client '@{AllowUnencrypted="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'

# Add localhost to trusted hosts
winrm set winrm/config/client '@{TrustedHosts="localhost,127.0.0.1"}'

# Start WinRM service
Start-Service WinRM
Set-Service WinRM -StartupType Automatic
# Enable WinRM firewall rules
Enable-NetFirewallRule -DisplayName "Windows Remote Management (HTTP-In)"
# Test WinRM connectivity
Test-WSMan -ComputerName localhost -Port 5985
