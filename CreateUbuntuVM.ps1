# Create Ubuntu VM in Hyper-V
# Run as Administrator

param(
    [string]$VMName = "Bob2",
    [string]$ISOPath = "C:\ISOs\ubuntu-24.04.2-live-server-amd64.iso",
    [int64]$MemoryStartupBytes = 2GB,
    [int64]$VHDSizeBytes = 40GB,
    [string]$SwitchName = "Default Switch",
    [string]$VMPath = "C:\ProgramData\Microsoft\Windows\Hyper-V",
    [int]$ProcessorCount = 2
)

# Validate prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

# Check if running as admin
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be run as Administrator"
    exit 1
}

# Check if Hyper-V is enabled
$hypervFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
if ($hypervFeature.State -ne "Enabled") {
    Write-Error "Hyper-V is not enabled. Enable it first and restart."
    exit 1
}

# Check if ISO exists
if (-not (Test-Path $ISOPath)) {
    Write-Error "ISO file not found at: $ISOPath"
    exit 1
}

# Check if VM name already exists
if (Get-VM -Name $VMName -ErrorAction SilentlyContinue) {
    Write-Error "VM with name '$VMName' already exists"
    exit 1
}

# Check if switch exists
$switch = Get-VMSwitch -Name $SwitchName -ErrorAction SilentlyContinue
if (-not $switch) {
    Write-Error "Virtual switch '$SwitchName' not found"
    Write-Host "Available switches:" -ForegroundColor Cyan
    Get-VMSwitch | Select-Object Name, SwitchType
    exit 1
}

Write-Host "Prerequisites validated!" -ForegroundColor Green

# Step 1: Create the VM
Write-Host "`nStep 1: Creating VM '$VMName'..." -ForegroundColor Yellow
try {
    $vm = New-VM -Name $VMName -MemoryStartupBytes $MemoryStartupBytes -Path $VMPath -Generation 2
    Write-Host "VM created successfully" -ForegroundColor Green
} catch {
    Write-Error "Failed to create VM: $_"
    exit 1
}

# Step 2: Create and attach VHD
Write-Host "`nStep 2: Creating virtual hard disk..." -ForegroundColor Yellow
try {
    $vhdPath = Join-Path $VMPath "$VMName\Virtual Hard Disks\$VMName.vhdx"
    $vhd = New-VHD -Path $vhdPath -SizeBytes $VHDSizeBytes -Dynamic
    Add-VMHardDiskDrive -VMName $VMName -Path $vhdPath
    Write-Host "VHD created and attached: $vhdPath" -ForegroundColor Green
} catch {
    Write-Error "Failed to create/attach VHD: $_"
    Remove-VM -Name $VMName -Force
    exit 1
}

# Step 3: Configure VM settings
Write-Host "`nStep 3: Configuring VM settings..." -ForegroundColor Yellow
try {
    # Set processor count
    Set-VMProcessor -VMName $VMName -Count $ProcessorCount
    
    # Enable dynamic memory (optional)
    Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $true -MinimumBytes 1GB -MaximumBytes 4GB
    
    # Connect to virtual switch
    Connect-VMNetworkAdapter -VMName $VMName -SwitchName $SwitchName
    
    # Enable secure boot (Generation 2 VMs)
    Set-VMFirmware -VMName $VMName -EnableSecureBoot On -SecureBootTemplate MicrosoftUEFICertificateAuthority
    
    # Disable automatic checkpoints (optional)
    Set-VM -Name $VMName -AutomaticCheckpointsEnabled $false
    
    Write-Host "VM configuration completed" -ForegroundColor Green
} catch {
    Write-Error "Failed to configure VM: $_"
    Remove-VM -Name $VMName -Force
    exit 1
}

# Step 4: Attach ISO file
Write-Host "`nStep 4: Attaching Ubuntu ISO..." -ForegroundColor Yellow
try {
    Add-VMDvdDrive -VMName $VMName -Path $ISOPath
    
    # Set boot order to DVD first for installation
    $dvdDrive = Get-VMDvdDrive -VMName $VMName
    $hardDrive = Get-VMHardDiskDrive -VMName $VMName
    Set-VMFirmware -VMName $VMName -BootOrder $dvdDrive, $hardDrive
    
    Write-Host "ISO attached and boot order set" -ForegroundColor Green
} catch {
    Write-Error "Failed to attach ISO: $_"
    Remove-VM -Name $VMName -Force
    exit 1
}

# Step 5: Display VM information
Write-Host "`nStep 5: VM Creation Summary" -ForegroundColor Yellow
Write-Host "=========================" -ForegroundColor Yellow
Write-Host "VM Name: $VMName" -ForegroundColor Cyan
Write-Host "Memory: $($MemoryStartupBytes / 1GB) GB (Dynamic: 1-4 GB)" -ForegroundColor Cyan
Write-Host "Processors: $ProcessorCount" -ForegroundColor Cyan
Write-Host "VHD Size: $($VHDSizeBytes / 1GB) GB" -ForegroundColor Cyan
Write-Host "VHD Path: $vhdPath" -ForegroundColor Cyan
Write-Host "Network: $SwitchName" -ForegroundColor Cyan
Write-Host "ISO: $ISOPath" -ForegroundColor Cyan

Write-Host "`n✅ VM '$VMName' created successfully!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Start the VM: Start-VM -Name '$VMName'" -ForegroundColor White
Write-Host "2. Connect to VM: vmconnect localhost '$VMName'" -ForegroundColor White
Write-Host "3. Install Ubuntu following the setup wizard" -ForegroundColor White
Write-Host "4. After installation, remove ISO: Remove-VMDvdDrive -VMName '$VMName'" -ForegroundColor White

# Optional: Ask if user wants to start the VM now
$startNow = Read-Host "`nWould you like to start the VM now? (y/n)"
if ($startNow -eq 'y' -or $startNow -eq 'Y') {
    Write-Host "Starting VM..." -ForegroundColor Yellow
    Start-VM -Name $VMName
    Write-Host "VM started! Opening VM Connect..." -ForegroundColor Green
    vmconnect localhost $VMName
}