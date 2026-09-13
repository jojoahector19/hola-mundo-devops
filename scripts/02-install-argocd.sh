#!/bin/bash
set -e
kubectl create namespace argocd || true
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo ">> Esperando que ArgoCD este listo..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

echo ">> Password inicial del usuario admin:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""
echo ">> Para entrar a la UI: kubectl port-forward svc/argocd-server -n argocd 8081:443"
echo ">> Luego abre https://localhost:8081  (usuario: admin)"
