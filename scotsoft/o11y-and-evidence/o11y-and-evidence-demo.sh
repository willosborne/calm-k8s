#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ANSI color code for yellow
YELLOW='\033[0;33m'
YELLOW_BOLD='\033[1;33m'
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

command() {
    local text=$1
    echo -e "> ${text}\n"
}

error() {
    local text=$1
    echo -e "\033[0;31m${text}\033[0m\n"
}

heading "Preparing the environment for the demo..."

minikube_running=$(minikube status | grep "apiserver: Running")
if [ -z "$minikube_running" ]; then
    error "Minikube is not running. Please start Minikube first."
    exit
fi

app_deployed=$(kubectl get pods -n application | grep sapplication-)
if [ -z "$app_deployed" ]; then
    error "Application is not deployed. Please deploy the application first."
    exit
fi

read

heading "ScotSoft 2024 - Observabilty & Evidence"
read

heading "Monitoring with Prometheus"

info "Prometheus Operator..."

info "ServiceMonitor..."

info "Prometheus..."

heading "Controls in the CALM pattern"

info "Micro-segmented cluster..."
bat calm/pattern-instantiation.json --line-range 49:72 
read

info "Global Calico default-deny policy..."
command "kubectl describe globalnetworkpolicy deny-app-policy --namespace kube-system "
read
kubectl describe globalnetworkpolicy deny-app-policy --namespace kube-system  | bat --language yaml --file-name GlobalNetworkPolicy


# bat calm/pattern-instantiation.json --line-range 73:97 
# read

# bat calm/pattern-instantiation.json --line-range 122:145
# read