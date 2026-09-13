#!/bin/bash
set -e
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml

echo ">> Instalando ClusterTask git-clone del catalogo oficial..."

echo ">> Tekton instalado. Verifica con: kubectl get pods -n tekton-pipelines"
