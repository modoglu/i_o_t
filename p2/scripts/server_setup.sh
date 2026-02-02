#!/bin/bash
set -e 

echo "-- SERVER SETUP START --"

sudo apt-get update
sudo apt-get install -y curl
sudo apt-get install -y net-tools

export INSTALL_K3S_EXEC="--node-ip=192.168.56.110 --flannel-iface=eth1 --write-kubeconfig-mode 644"
curl -sfL https://get.k3s.io | sh -

until sudo kubectl get nodes; do
  sleep 1
done

echo "alias k='kubectl'" >> /home/vagrant/.bashrc
echo "export PATH=\$PATH:/sbin" >> /home/vagrant/.bashrc

sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/node-token
sudo chmod 644 /vagrant/node-token

sudo kubectl apply -f /vagrant/confs/app1.yaml
sudo kubectl apply -f /vagrant/confs/app2.yaml
sudo kubectl apply -f /vagrant/confs/app3.yaml
sudo kubectl apply -f /vagrant/confs/ingress.yaml

echo "-- SERVER SETUP COMPLETE --"