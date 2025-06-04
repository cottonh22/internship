#Apache Docker container on one VM, transferring it, and running it on another VM.
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
