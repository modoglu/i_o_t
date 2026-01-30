#!/bin/bash
set -e 

echo "--WORKER SETUP START--"

# Gerekli paketlerin kurulumu
sudo apt-get update
sudo apt-get install curl -y

# Token dosyasının sunucudan gelmesini bekle (Race Condition engelleme)
echo "Waiting for node-token from server..."
while [ ! -f /vagrant/node-token ]; do
  sleep 2
done

# K3s Agent Kurulumu
# K3S_URL: Sunucu IP'si (Dokümandaki 110 IP'si)
# K3S_TOKEN: Paylaşılan dosyadan okunan token
export K3S_URL="https://192.168.56.110:6443"
export K3S_TOKEN=$(cat /vagrant/node-token)

curl -sfL https://get.k3s.io | K3S_URL=${K3S_URL} K3S_TOKEN=${K3S_TOKEN} sh -s - --node-ip=192.168.56.111 --flannel-iface=eth1

echo "--WORKER SETUP COMPLETE--"