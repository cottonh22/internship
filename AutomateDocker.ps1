VM1="user@192.168.1.100"
VM2="user@192.168.1.101"
IMAGE_NAME="my-custom-apache"
TAR_FILE="my-apache-image.tar"

# Install Docker on VM1
ssh $VM1 <<EOF
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  echo "deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  \$(. /etc/os-release && echo "\${UBUNTU_CODENAME:-\$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo systemctl enable docker
  sudo systemctl start docker
EOF

# Run Apache container on VM1
ssh $VM1 <<EOF
sudo docker pull ubuntu/apache2
  sudo docker run -d --name apache-container -p 8080:80 ubuntu/apache2
  sudo docker commit apache-container $IMAGE_NAME
  sudo docker save -o $TAR_FILE $IMAGE_NAME
EOF

# Transfer the container image to VM2
scp $VM1:/home/user/$TAR_FILE $VM2:/home/user/

# Load and run the container on VM2
ssh $VM2 <<EOF
  sudo docker load -i /home/user/$TAR_FILE
  sudo docker run -d --name apache-container -p 8080:80 $IMAGE_NAME
EOF

echo "Automation complete!"
