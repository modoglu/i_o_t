#!/bin/bash
set -e 

echo "-- WORKER SETUP START --"

sudo apt-get update
sudo apt-get install -y curl

while [ ! -r /vagrant/node-token ]; do
  sleep 1
done

export K3S_URL="https://192.168.56.110:6443"
export K3S_TOKEN=$(cat /vagrant/node-token)
export INSTALL_K3S_EXEC="--node-ip=192.168.56.111 --flannel-iface=eth1"

curl -sfL https://get.k3s.io | sh -

echo "-- WORKER SETUP COMPLETE --"