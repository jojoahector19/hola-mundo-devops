#!/bin/bash
set -e
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml

echo ">> Instalando ClusterTask git-clone del catalogo oficial..."
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-clone/0.9/git-clone.yaml

echo ">> Tekton instalado. Verifica con: kubectl get pods -n tekton-pipelines"
