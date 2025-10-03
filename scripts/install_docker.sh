#!/bin/bash
set -e

echo ">>> Updating system..."
sudo apt-get update

echo ">>> Installing prerequisites..."
sudo apt-get install -y ca-certificates curl gnupg lsb-release

echo ">>> Adding Docker GPG key..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo ">>> Setting up Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo ">>> Installing Docker & Docker Compose..."
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo ">>> Adding current user to docker group..."
sudo usermod -aG docker $USER

echo ">>> Done!"
echo "⚠️ Please log out and log back in, or run: newgrp docker"
