#!/bin/bash

sudo apt-get update
sudo apt-get install docker.io -y

sudo apt-get install curl -y
sudo apt-get install wget -y

curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64 kubectl

if lsof -i :8888 > /dev/null; then
    echo "8888 portu dolu !!!!"
    exit 1
else
    echo "8888 portu müsait. Cluster olusturuluyor..."
    # mycluster ismi eklendi
    k3d cluster create mycluster -p "8888:8888@loadbalancer"
fi