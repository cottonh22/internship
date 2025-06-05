#Install ssh sueing this command:
    sudo apt install ssh
#Use this command to see what the VMs IP address is: 
  ip addr show

#Use this command to ssh to the VM:
  ssh 000.00.000.000
#Use this command to ssh to the VM username(use your info):
    ssh username@000.00.000.000


#Use these commands to install Apache:
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

#Use this command to edit the apache page:
  sudo nano /var/www/html/index.html

