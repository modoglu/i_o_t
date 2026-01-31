#!/bin/bash
set -e 

echo "-- SERVER SETUP START --"

sudo apt-get update
sudo apt-get install -y curl
sudo apt-get install -y net-tools

export INSTALL_K3S_EXEC="--node-ip=192.168.56.110 --flannel-iface=eth1 --write-kubeconfig-mode 644 --disable traefik"
curl -sfL https://get.k3s.io | sh -

while [ ! -f /var/lib/rancher/k3s/server/node-token ]; do
  sleep 1
done

echo "alias k='kubectl'" >> /home/vagrant/.bashrc
echo "export PATH=\$PATH:/sbin" >> /home/vagrant/.bashrc

sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/node-token
sudo chmod 644 /vagrant/node-token

echo "-- SERVER SETUP COMPLETE --"