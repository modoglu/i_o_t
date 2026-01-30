#!/bin/bash
set -e 

echo "--SERVER SETUP START--"

# Gerekli paketlerin kurulumu
sudo apt-get update
sudo apt-get install curl -y

# K3s Kurulumu
# --write-kubeconfig-mode: kubectl'in sudo olmadan çalışmasını sağlar
# --disable traefik: 512MB RAM için hayat kurtarır
curl -sfL https://get.k3s.io | sh -s - server \
    --node-ip=192.168.56.110 \
    --flannel-iface=eth1 \
    --write-kubeconfig-mode 644 \
    --disable traefik

# Token oluşana kadar bekle
echo "Waiting for node-token..."
until [ -f /var/lib/rancher/k3s/server/node-token ]; do
  sleep 2
done

# Token'ı paylaş
sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/node-token
sudo chmod 644 /vagrant/node-token

echo "--SERVER SETUP COMPLETE--"