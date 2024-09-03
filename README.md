# CALM Kubernetes Generator

## Prerequisites

- Node 20+

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

Then start your cluster with the [Calico CNI](https://www.tigera.io/project-calico/) enabled.

```sh
minikube start --network-plugin=cni --cni=calico --kubernetes-version=1.30.0
```

### Minikube setup - CALM + CLI

TBC

### Generate & apply the resources

The `stdout` stream from the generate command can be piped directly into `kubectl`:

```sh
npx calm-k8s generate calm/instantiation.json | kubectl apply -f -
```

Example output:

```sh
service/application-svc created
deployment.apps/application created
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

Once the tunnel is active, the Swagger UI for the API of the application can be accessed locally at <http://127.0.0.1:8080/swagger-ui/index.html>.
