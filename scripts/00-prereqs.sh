#!/bin/bash
# Instala herramientas base en Ubuntu: docker, kubectl, k3d, tkn, argocd cli
set -e

echo ">> Instalando Docker (si no esta instalado)..."
if ! command -v docker &> /dev/null; then
  curl -fsSL https://get.docker.com | sh
  sudo usermod -aG docker $USER
  echo "Cierra sesion y vuelve a entrar para usar docker sin sudo."
fi

echo ">> Instalando kubectl..."
if ! command -v kubectl &> /dev/null; then
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  rm kubectl
fi

echo ">> Instalando k3d (Kubernetes en Docker, 100% gratis)..."
if ! command -v k3d &> /dev/null; then
  curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
fi

echo ">> Instalando Tekton CLI (tkn)..."
if ! command -v tkn &> /dev/null; then
  curl -LO https://github.com/tektoncd/cli/releases/latest/download/tkn_Linux_x86_64.tar.gz
  sudo tar xvzf tkn_Linux_x86_64.tar.gz -C /usr/local/bin tkn
  rm tkn_Linux_x86_64.tar.gz
fi

echo ">> Instalando ArgoCD CLI..."
if ! command -v argocd &> /dev/null; then
  curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
  sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
  rm argocd-linux-amd64
fi

echo ">> Todo instalado."
