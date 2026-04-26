#!/bin/bash
sudo apt-get update -y

# Install Java 17 (required for Jenkins SSH), Git, and Docker
sudo apt-get install -y openjdk-17-jre git docker.io unzip
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install