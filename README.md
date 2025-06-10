#This project documents the complete setup of an Ubuntu web server running in a Hyper-V virtual machine, accessible via SSH with Apache web server configured.
#Hello
1. #Deploy a new Hyper-V VM + Install Ubuntu -
#I use powershell as administator to do this step
# use CreateUbuntuVM.ps1 
#NOTE - You may have to make changes to this code 
#When this is done loading you should get a question where you should be able to answer yes ("y)
#After a Virtual Machine screen should pop up on your screen
#Following the installation pages, I just click through without really looking
#Then at some point you should get to a page where it askes you to fill in:
  #Your Name
  #Server Name
  #Username
  #Password
#Whatever you type in doesn't matter, BUT you will have to remember your username and password
#At some point it will ask you to reboot the VM, do that
  #If it doesn't work right away there should be a turn off button close to the top left corner, click that #then start ir again
  
2. #Now you are ready to Configure Ubuntu SSH
#First still in the VM you need to install ssh on your virtual machine since your VM doesn't have it installed
#Go to SSH_Apache.ps1 to find the commands

3. #Now you will SSH into the VM using powershell
#After getting the IP address from the VM, go to a administrator powershell
#Use SSH_Apache.ps1 to find the commands to ssh in 
#For me it won't stay as administrator so I have to, ctrl ^C
#Next ssh to the username you made (in the VM it should be the first word in your command prompt):
#Use SSH_Apache.ps1 to find the commands to ssh in
#It will likely ask you for your password, type it in and you should see your command prompt like the one in your VM.


4. #Next you will configure Apache, still in powershell:
#Use SSH_Apache.ps1 to find the commands to download Apache
#If at any point it askes you to type in your password, do so
#Use the command in SSH_Apache.ps1 to edit the apache page;
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









#How to Install Docker Engine on Ubuntu

1. #Install using the 'apt' repository
   #This code is the official Docker installation instructions for Ubuntu:
    #Use the commands in docker.ps1 

2. #Run apache container on docker on ubuntu
#Use the commands in docker.ps1 









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




