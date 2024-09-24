#!/bin/bash

export BAT_THEME="zenburn"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GENERATED_DIR="generated/k8s-application"

# ANSI color codes
YELLOW='\033[0;33m'
YELLOW_BOLD='\033[1;33m'
RED='\033[0;31m'
# Reset color
NC='\033[0m'

heading() {
    clear
    local text=$1
    echo -e "${YELLOW_BOLD}${text}${NC}\n"
}

info() {
    local text=$1
    echo -e "${YELLOW}${text}${NC}\n"
}

error() {
    local text=$1
    echo -e "${RED}${text}\033[0m\n"
}

success() {
    local text=$1
    echo -e "\033[1;32m${text}\033[0m\n"
}

command() {
    local text=$1
    echo -e "> ${text}\n"
}

heading "Preparing the environment for the demo..."

info "Checking minikube is running..."
minikube_running=$(minikube status | grep "apiserver: Running")
if [ -z "$minikube_running" ]; then
    info "Minikube is not running. Starting Minikube..."
    ${SCRIPT_DIR}/cluster/initialise-cluster.sh
fi

info "Checking for previous deployment..."
directory="${SCRIPT_DIR}/${GENERATED_DIR}/"
if [ -d "${directory}" ]; then
    info "Deleting previous deployment..."
    command "kubectl delete --kustomize ${directory}"
    kubectl delete --kustomize ${directory}
    rm -rf ${directory}
fi

info "Checking minikube tunnel is running..."
minikube_tunnel_is_running=$(ps | grep "minikube tunnel" | grep -v grep)
while [ -z "$minikube_tunnel_is_running" ]; do
    error "Please start 'minikube tunnel' in a separate terminal before continuing."
    read
    # Optionally, re-check the condition here if it can change during the loop
    minikube_tunnel_is_running=$(ps | grep "minikube tunnel" | grep -v grep)
done

success "Ready to go..."
read

cd ${SCRIPT_DIR}

set -euo pipefail

heading "ScotSoft 2024 - Deploying Architecture as Code"

kitty icat ${SCRIPT_DIR}/demo.png

read

heading "Environment setup"

info "Minikube Kubernetes cluster..."

command "minikube status"
minikube status
read

info " ...with only default namespaces..."
command "kubectl get namespaces"
kubectl get namespaces
read

heading "Kubernetes Resource Generator - a proof-of-concept CLI tool"

info "Example - generate deployable Kubernetes resources from an architecture pattern..."
command "calm-k8s generate architecture.json --templates templates/k8s-application/ --output ${GENERATED_DIR}"
read

clear
bat architecture.json

clear
bat templates/k8s-application/*

clear
info "Generate Kubernetes resources from the architecture as code..."
command "calm-k8s generate architecture.json --templates templates/k8s-application/ --output ${GENERATED_DIR}"
calm-k8s generate architecture.json --templates templates/k8s-application/ --output ${GENERATED_DIR}
echo
command "tree ${GENERATED_DIR}"
tree ${GENERATED_DIR}
read

info "Kustomized resources..."
command "kubectl kustomize ${GENERATED_DIR}"
read
kubectl kustomize ${GENERATED_DIR} | bat --language yaml --file-name "Kustomize Deployment"

heading "Deploying the generated Kubernetes resources"

info "Applying the kustomizations..."
command "kubectl apply --kustomize ${GENERATED_DIR}"
kubectl apply --kustomize ${GENERATED_DIR}
read

info "Applied resources..."
command "kubectl get deployment,service,networkpolicy --namespace application "
kubectl get deployment,service,networkpolicy --namespace application
read

heading "Verify the running application"

info "Access the application... http://127.0.0.1:8080/q/swagger-ui/"
read

clear
heading "Back to the slides..."
read

heading "ScotSoft 2024 - Patterns & Controls"
read

info "Previously applied resources..."
command "kubectl get deployment,service,networkpolicy --namespace application "
kubectl get deployment,service,networkpolicy --namespace application
read

clear
info "Network micro-segmentation controls for the cluster..."
bat architecture.json --line-range 49:70
read

info "How do we apply this control?"

clear
info "Applying cluster micro-segmentation controls on Kubernetes"

info "Network connectivity is managed using the Calico CNI plugin..."
command "kubectl get pods --namespace kube-system --selector k8s-app=calico-node"
kubectl get pods --namespace kube-system --selector k8s-app=calico-node
read

info " ...with a default-deny Calico GlobalNetworkPolicy"
command "kubectl describe globalnetworkpolicy deny-app-policy --namespace kube-system"
kubectl describe globalnetworkpolicy deny-app-policy --namespace kube-system  | bat --language yaml --file-name "GlobalNetworkPolicy default-deny"
read

clear
info "Applying application micro-segmentation controls"

info "Network micro-segmentation controls for the application..."
bat architecture.json --line-range 122:145
read

clear
info "Application-to-database network policies..."
command "kubectl describe networkpolicy allow-egress-from-app-to-db --namespace application"
kubectl describe networkpolicy allow-egress-from-app-to-db --namespace application  | bat --language yaml --style=numbers,grid
read

command "kubectl describe networkpolicy allow-ingress-to-db-from-app --namespace application"
kubectl describe networkpolicy allow-ingress-to-db-from-app --namespace application | bat --language yaml --style=numbers,grid
read

clear
heading "Verifying micro-segmentation"

info "Find the database IP..."
command "kubectl get pod --namespace application --selector db=postgres-database --output wide"
kubectl get pod --namespace application --selector db=postgres-database --output wide
echo

echo
info "Verify the permitted connection between the application and database pods..."
POD=$(kubectl get pods --namespace application -o=jsonpath='{.items[0].metadata.name}')
command "kubectl debug --stdin --tty $POD --image=busybox:1.28 --namespace application --target=app"
kubectl debug -it $POD --image=busybox:1.28 --namespace application --target=app

clear
info "Verify that connections from an unrelated are not permitted..."
command "kubectl run --stdin --tty --rm --image=busybox:1.28 --namespace application test-pod"
kubectl run --stdin --tty --rm --image=busybox:1.28 --namespace application test-pod

clear
heading "Back to the slides..."
read