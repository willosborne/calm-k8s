# CALM Kubernetes Generator

## Prerequisites

- Node 20+
- Docker desktop

### A note about Docker Desktop on Mac

Version 4.34.0 of Docker Desktop has as a bug on Mac OS X that breaks Minikube.
You should downgrade to the previous version.
See https://github.com/docker/cli/issues/5412 for more information.

## Installation

```shell
npm install
npm run build
```

## Run the CLI

Either:

```shell
node dist/index.js
```

Or, after the link process has completed:

```shell
npx calm-k8s
```

## Make it globally available

```shell
sudo npm link
```

Then it will be available everywhere as `calm-k8s`.

## Example usage with Kubernetes

### Minikube setup - Manually

Follow the steps for your platform here: <https://minikube.sigs.k8s.io/docs/start/>

You may also need to install `kubectl` on some Linux platforms.

Then start your cluster with the [Calico CNI](https://www.tigera.io/project-calico/) enabled.

```sh
minikube start --network-plugin=cni --cni=calico --kubernetes-version=1.30.0
```

### Minikube setup - CALM + CLI

First run the CALM K8s CLI against the minikube templates.
From the root of the project (same level as this `README`):

```shell
mkdir output
npx calm-k8s generate --templates templates/k8s-cluster-minikube --output output/minikube calm/instantiation.json
```

This will generate a script to set up the minikube cluster.
Then run this script, again from the project root:

```shell
./output/minikube/initialise-cluster.sh
```

### Generate & apply the resources

The `templates/k8s-application` directory contains templates to generate a set of Kubernetes resources for the application from the CALM instantiation.
It also generates a `kustomize` script that makes applying the documents to your cluster easy.

From the project root, run the CLI against the `k8s-application` templates and output to the `output/k8s-application` directory:

```sh
npx calm-k8s generate --templates templates/k8s-application --output output/k8s-application calm/instantiation.json
```

You can now inspect the Kustomization with `kubectl`:

```sh
kubectl kustomize output/k8s-application
```

To apply the Kustomization:
Note: `--kustomize` or `'k` instead of `-f` - this is to apply a Kustomization.
Provide the _directory_ when running with the `-k` argument.

```sh
kubectl apply --kustomize output/k8s-application
```

Example output:

```sh
namespace/application created
service/application-svc created
service/db created
deployment.apps/application created
deployment.apps/postgres-database created
networkpolicy.networking.k8s.io/allow-egress-from-app-to-db created
networkpolicy.networking.k8s.io/allow-external-ingress-to-app created
networkpolicy.networking.k8s.io/allow-ingress-to-db-from-app created
```

You can verify the resources created with:

```sh
kubectl get all --namespace application
```

Example output:

```sh
NAME                              READY   STATUS    RESTARTS   AGE
pod/application-7bc585b64-b9nvj   1/1     Running   0          16s
pod/application-7bc585b64-dsz87   1/1     Running   0          16s
pod/application-7bc585b64-ltl47   1/1     Running   0          16s

NAME                      TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
service/application-svc   LoadBalancer   10.105.153.121   <pending>     8080:31005/TCP   17s

NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/application   3/3     3            3           16s

NAME                                    DESIRED   CURRENT   READY   AGE
replicaset.apps/application-7bc585b64   3         3         3       16s
```

### Access the service

The deployed application can be accessed via the load balancer using `minikube tunnel`.
Details of how to use this: <https://minikube.sigs.k8s.io/docs/handbook/accessing/#loadbalancer-access>

Once the tunnel is active, the Swagger UI for the API of the application can be accessed locally at <http://127.0.0.1:8080/q/swagger-ui/index.html>.
