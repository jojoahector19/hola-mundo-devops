#!/bin/bash
# Dispara manualmente los pipelines de Tekton (build + push + actualizar manifest)
set -e
kubectl apply -f ../tekton/tasks/task-build-push.yaml
kubectl apply -f ../tekton/tasks/task-update-manifest.yaml
kubectl apply -f ../tekton/pipeline-backend.yaml
kubectl apply -f ../tekton/pipeline-frontend.yaml

echo ">> Lanzando pipeline de backend..."
kubectl create -f ../tekton/pipelinerun-backend.yaml

echo ">> Lanzando pipeline de frontend..."
kubectl create -f ../tekton/pipelinerun-frontend.yaml

echo ">> Sigue el progreso con: tkn pipelinerun logs --last -f -n hola-mundo"
