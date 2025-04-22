#!/bin/bash
sudo apt update -y
sudo apt install -y \
    docker.io \
    docker-compose \
    git

sudo usermod -aG docker ubuntu
newgrp docker