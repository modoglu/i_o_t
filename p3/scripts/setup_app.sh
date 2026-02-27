#!/bin/bash

# Çalışma dizini Makefile'ın bulunduğu yer olduğu için ./confs kullanıyoruz
kubectl apply -f ./confs/namespace.yaml

# CRD boyut sınırına takılmamak için --server-side eklendi
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml --server-side

echo "Argo CD bilesenleri yuklemesini bekliyor..."
# available doğru yazıldı ve süre 600 saniye (10 dakika) yapıldı
kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd

kubectl apply -f ./confs/application.yaml

echo "Kurulum Tamamlandi"
echo "Kullanici Adi : admin"
echo -n "Password " && kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo