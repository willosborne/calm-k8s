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