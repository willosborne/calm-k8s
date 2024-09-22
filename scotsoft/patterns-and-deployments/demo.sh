#!/bin/bash

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

heading "ScotSoft 2024 - Patterns & Deployment"

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

info " ...and Calico CNI plugin..."
command "kubectl get pods --namespace kube-system --selector k8s-app=calico-node"
kubectl get pods --namespace kube-system --selector k8s-app=calico-node
read

# info " ...with a global Calico default-deny network policy"
# command "kubectl describe globalnetworkpolicy deny-app-policy --namespace kube-system "
# read
# kubectl describe globalnetworkpolicy deny-app-policy --namespace kube-system  | bat --language yaml --file-name GlobalNetworkPolicy
# read

heading "CALM -> Kubernetes Resource Generator: https://github.com/willosborne/calm-k8s"

info "NodeJS based CLI tool..."
command "calm-k8s help"
calm-k8s help
read

info "Example - generate deployable Kubernetes resources from a CALM pattern instantiation..."
command "calm-k8s generate calm/instantiation.json --templates templates/k8s-application/ --output ${GENERATED_DIR}"
read

clear
info "Kubernetes resource templates..."
bat templates/k8s-application/*

clear
info "CALM pattern instantiation..."
bat calm/pattern-instantiation.json

clear
info "Generating the Kubernetes resources..."
command "calm-k8s generate calm/pattern-instantiation.json --templates templates/k8s-application/ --output ${GENERATED_DIR}"
read
calm-k8s generate calm/pattern-instantiation.json --templates templates/k8s-application/ --output ${GENERATED_DIR}
bat ${GENERATED_DIR}/*

heading "Deploying the generated Kubernetes resources"

info "Kustomized resources..."
command "kubectl kustomize ${GENERATED_DIR}"
read

kubectl kustomize ${GENERATED_DIR} | bat --language yaml --file-name "Kustomize Deployment"

info "Applying the deployment..."
command "kubectl apply --kustomize ${GENERATED_DIR}"
kubectl apply --kustomize ${GENERATED_DIR}
read

info "Deployed resources..."
command "kubectl get svc,deployment,networkpolicy --namespace application "
kubectl get svc,deployment,networkpolicy --namespace application
read

heading "Verify the running application"

info "Access the application... http://127.0.0.1:8080/q/swagger-ui/"
read

heading "Verifying micro-segmentation"

info "Default-deny NetworkPolicy resource"
command "kubectl describe networkpolicy default-deny-all --namespace application"
kubectl describe networkpolicy default-deny-all --namespace application  | bat --language yaml --style=numbers,grid
read

clear
info "Allow DNS NetworkPolicy resource"
command "kubectl describe networkpolicy allow-dns --namespace application"
kubectl describe networkpolicy allow-dns --namespace application  | bat --language yaml --style=numbers,grid
read

info "Application-to-database NetworkPolicy resources"
command "kubectl describe networkpolicy allow-egress-from-app-to-db --namespace application"
kubectl describe networkpolicy allow-egress-from-app-to-db --namespace application  | bat --language yaml --style=numbers,grid

command "kubectl describe networkpolicy allow-ingress-to-db-from-app --namespace application"
kubectl describe networkpolicy allow-ingress-to-db-from-app --namespace application | bat --language yaml --style=numbers,grid
read

clear
info "Discover the database IP..."
command "kubectl get pod --namespace application --selector db=postgres-database --output wide"
kubectl get pod --namespace application --selector db=postgres-database --output wide
echo

echo
info "\nExecute some connectivity tests from the application pod..."
POD=$(kubectl get pods --namespace application -o=jsonpath='{.items[0].metadata.name}')
command "kubectl debug --stdin --tty $POD --image=busybox:1.28 --namespace application --target=app"
kubectl debug -it $POD --image=busybox:1.28 --namespace application --target=app

clear
info "Execute some connectivity tests from another pod..."
command "kubectl run --stdin --tty --rm --image=busybox:1.28 --namespace application test-pod"
kubectl run --stdin --tty --rm --image=busybox:1.28 --namespace application test-pod

clear
success "Demo complete!"
read