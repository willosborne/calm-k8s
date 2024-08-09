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

### Minikube setup

Follow the steps for your platform here: <https://minikube.sigs.k8s.io/docs/start/>

Then start your cluster with the [Calico CNI](https://www.tigera.io/project-calico/) enabled.

```sh
minikube start --network-plugin=cni --cni=calico
```

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
kubectl get all
```

Exanmple output:

```sh
NAME                               READY   STATUS             RESTARTS   AGE
pod/application-66765b6b8c-nqnpj   0/1     ImagePullBackOff   0          30s
pod/application-66765b6b8c-pp8d8   0/1     ImagePullBackOff   0          30s
pod/application-66765b6b8c-s8pv8   0/1     ErrImagePull       0          30s

NAME                      TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
service/application-svc   LoadBalancer   10.99.36.253   <pending>     8080:32257/TCP   30s
service/kubernetes        ClusterIP      10.96.0.1      <none>        443/TCP          6m59s

NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/application   0/3     3            0           30s

NAME                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/application-66765b6b8c   3         3         0       30s
```
