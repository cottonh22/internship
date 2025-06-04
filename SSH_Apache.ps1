#Now you are ready to Configure Ubuntu SSH
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
