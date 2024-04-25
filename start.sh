#!/bin/bash

# Update the package index
sudo apt-get update

# Allow apt to use repositories over HTTPS
sudo apt-get install -y \
            apt-transport-https \
                ca-certificates \
                    curl \
                        software-properties-common

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Verify that you now have the key with the fingerprint
sudo apt-key fingerprint 0EBFCD88

# Set up the stable repository
sudo add-apt-repository \
           "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
              $(lsb_release -cs) \
                 stable"

# Update the package index
sudo apt-get update

# Install the latest version of Docker CE, Docker CE CLI, and Containerd.io
yes | sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Add the current user to the docker group so you don't have to use sudo every time
sudo usermod -aG docker $USER

# Output Docker version information to verify installation was successful
docker --version

# Pull the titan-edge image from Docker Hub
docker pull nezha123/titan-edge

# Create a directory for titan-edge configuration
mkdir ~/.titanedge

# Run the titan-edge container in detached mode with restart policy set to always
docker run -d --restart=always --name titan -v ~/.titanedge:/root/.titanedge nezha123/titan-edge

# Wait for the container to start
sleep 5

# Prompt the user to enter the hash value for titan-edge binding
read -p "Enter the hash value for titan-edge bind: " user_hash

# Execute commands within the container using the user-provided hash value
docker exec titan titan-edge bind --hash="$user_hash" https://api-test1.container1.titannet.io/api/v2/device/binding
docker exec titan titan-edge config set --storage-size 15GB
docker exec titan titan-edge daemon stop

# Restart the container (if needed)
docker stop titan
docker rm titan
docker run -d --restart=always --name titan -v ~/.titanedge:/root/.titanedge nezha123/titan-edge
