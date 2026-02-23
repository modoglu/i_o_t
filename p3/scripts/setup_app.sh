#!/bin/bash

kubectl apply -f ../confs/namespace.yaml

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Argo CD bilesenleri yuklemesini bekliyor..."
kubectl wait --for=condition=avaliable --timeout=600ms deployment/argocd-server -n argocd

kubectl apply -f ../confs/application.yaml

echo "Kurulum Tamamlandi"
echo "Kullanici Adi : admin"
echo -n "Password " && kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo