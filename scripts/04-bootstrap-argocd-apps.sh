#!/bin/bash
# Registra los 3 Applications de ArgoCD (uno por cada proyecto/microservicio)
set -e
kubectl apply -f ../argocd/project.yaml
kubectl apply -f ../argocd/app-database.yaml
kubectl apply -f ../argocd/app-backend.yaml
kubectl apply -f ../argocd/app-frontend.yaml

echo ">> Applications creadas. Revisa con: argocd app list"
