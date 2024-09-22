#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

KUBERNETES_VERSION=1.30.0

echo "Starting Minikube..."
minikube start --network-plugin=cni --cni=calico --kubernetes-version=$KUBERNETES_VERSION

echo "Installing Prometheus Operator..."
LATEST=$(curl -s https://api.github.com/repos/prometheus-operator/prometheus-operator/releases/latest | jq -cr .tag_name)
curl -sL https://github.com/prometheus-operator/prometheus-operator/releases/download/${LATEST}/bundle.yaml | kubectl create -f -

sleep 30
echo "Waiting for Prometheus Operator to be ready..."
kubectl wait --for=condition=Ready pods -l app.kubernetes.io/name=prometheus-operator -n default

echo "Installing Prometheus..."
kubectl apply --filename "${SCRIPT_DIR}/prometheus.yaml"