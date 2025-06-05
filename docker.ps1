# It does not like me 
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

