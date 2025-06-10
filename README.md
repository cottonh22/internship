#This project documents the complete setup of an Ubuntu web server running in a Hyper-V virtual machine, accessible via SSH with Apache web server configured.
1. #Deploy a new Hyper-V VM + Install Ubuntu -
#I use powershell as administator to do this step, and use this code to set it up.
#NOTE - You may have to make changes to this code 
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

#When this is done loading you should get a question where you should be able to answer yes ("y)
#After a Virtual Machine screen should pop up on your screen
#Following the installation pages, I just click through without really looking
#Then at some point you should get to a page where it askes you to fill in:
  #Your Name
  #Server Name
  #Username
  3Password
#Whatever you type in doesn't matter, BUT you will have to remember your username and password
#At some point it will ask you to reboot the VM, do that
  #If it doesn't work right away there should be a turn off button close to the top left corner, click that then start ir again
  
2. #Now you are ready to Configure Ubuntu SSH
#First still in the VM you need to install ssh on your virtual machine since your VM doesn't have it installed:
  #To do that you use the command:
    sudo apt install ssh
#Next use this command: 
  ip addr show
#So you can see the VM IP address

4. #SSH in 
#After getting the IP address from the VM, go back to powershell and ssh to the VM:
  ssh 000.00.000.000
#For me it won't stay as administrator so I have to, ctrl ^C
#Next ssh to the username you made (in the VM it should be the first word in your command prompt):
  #It should look like this just with your info;
    ssh username@000.00.000.000
#It will likely ask you for your password, type it in and you should see your command prompt like the one in your VM
#YAY! Now you have SSH in

6. #Next you will configure Apache, still in powershell
#I use these commands to install Apache:
# Update packages
sudo apt update

# Install Apache
sudo apt install apache2 -y

# Start Apache
sudo systemctl start apache2

# Enable Apache to start automatically
sudo systemctl enable apache2

# Check if it's running
sudo systemctl status apache2
#If at any point it askes you to type in your password, do so
#Apache has now been downloaded.
#Now use this command so you can edit the apache page;
  # Edit the main Apache page
  sudo nano /var/www/html/index.html
#Scroll way down until you find the where is says something like "Apache Main Page"
#If you go to that line, you can chnage that text to be whatever you want it to say. 
#When finished follow the directions at the bottom on the screen to save your changes;
  #The keys to hit are usually; 
    Ctrl + X - This starts the exit process
    Y - This confirms you want to save the changes
    Enter - This confirms the filename
    
5. #Test your website outside the VM
#Now open any search application on your local device, I like chrome, and type in the IP address for your VM
#You should see an Ubuntu Page with the Chnages you made to it.









How to Install Docker Engine on Ubuntu

1. #Install using the 'apt' repository
   #This code is the official Docker installation instructions for Ubuntu:
       # Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

#To install the latest version, run:
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

#Verify that the installation is successful 
 sudo docker run hello-world

2. #Run apache container on docker on ubuntu
#Pull the image
sudo docker pull ubuntu/apache2
#Run the container
sudo docker run -d --name apache2-container -p 8080:80 ubuntu/apache2:2.4-22.04_beta
#To check if your container is running:
sudo docker ps
#This command should get you the container id (ex. 8521e50a652f)
#Then do this command
 docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <container_id>
#Forward incoming traffic on port 8080 to your container's Apache server:
sudo iptables -t nat -A PREROUTING -p tcp --dport 8080 -j DNAT --to-destination 172.17.0.2:80
#Enable IP Forwarding (So Traffic Can Flow Properly)
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
#Allow Traffic to Exit the Ubuntu VM
#Apply a masquerading rule so return traffic works:
sudo iptables -t nat -A POSTROUTING -p tcp --dport 80 -j MASQUERADE
#Find Your Ubuntu VM’s IP
#This is the IP you’ll use to access the server from your Windows host:
ip a
#Modify the Apache Webpage Title
sudo nano /var/www/html/index.html
#Find the <title> tag and update it: <title>My Custom Apache Page</title>
#Save and exit (Ctrl + X, then Y, then Enter).
#Access Apache From Your Web Browser
#On your Windows machine, open your browser and go to:
http://000.000.000.000:8080 (ex: http://192.168.239.231:8080)









1. #Apache Docker container on one VM, transferring it, and running it on another VM.
#Commit the Container to an Image
sudo docker commit apache-container my-custom-apache
#Save the Image as a .tar File
sudo docker save -o my-apache-image.tar my-custom-apache
#Transfer the Image to Another VM (Replace 192.168.X.X with the target VM’s IP.)
scp my-apache-image.tar user@192.168.X.X:/home/user/
#Load the Image on the New VM
sudo docker load -i /home/user/my-apache-image.tar
#Run the Container on the New VM
sudo docker run -d --name apache-container -p 8080:80 my-custom-apache
#Check if it's running:
sudo docker ps
#Access Apache in a Browser
http://192.168.X.X:8080






