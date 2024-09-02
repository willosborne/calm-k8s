#!/bin/bash

set -euo pipefail

KUBERNETES_VERSION={{ kubernetes_version }}

minikube start --network-plugin=cni --cni=calico --memory=8192 --cpus=4 --kubernetes-version=$KUBERNETES_VERSION