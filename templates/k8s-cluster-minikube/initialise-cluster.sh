#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

KUBERNETES_VERSION={{ kubernetesVersion }}

minikube start --network-plugin=cni --cni=calico --kubernetes-version=$KUBERNETES_VERSION

kubectl apply --namespace calico-system --filename "${SCRIPT_DIR}/calico-global-deny.yaml"