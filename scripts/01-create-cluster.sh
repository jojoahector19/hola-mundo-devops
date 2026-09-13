#!/bin/bash
# Crea un cluster local de Kubernetes con k3d + registro local de imagenes
set -e

echo ">> Creando registro local de Docker en localhost:5000..."
k3d registry create registry.localhost --port 5000 || true

echo ">> Creando cluster k3d 'hola-mundo' (1 server + 2 agentes)..."
k3d cluster create hola-mundo \
  --servers 1 \
  --agents 2 \
  --registry-use k3d-registry.localhost:5000 \
  --port "8080:80@loadbalancer" \
  --port "30080:30080@loadbalancer"

kubectl create namespace hola-mundo || true

echo ">> Cluster listo. Verifica con: kubectl get nodes"
