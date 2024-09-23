rm -rf output/k8s-application

echo "Generate your k8s resources from Architecture as Code..."
echo
read
echo "npx calm-k8s generate --templates templates/k8s-application/ --output output/k8s-application calm/instantiation.json"
echo
read
npx calm-k8s generate --templates templates/k8s-application/ --output output/k8s-application calm/instantiation.json
read 
echo 
echo "Inspect the generated resources with kubectl kustomize..."
echo "kubectl kustomize output/k8s-application"
echo 
read 
kubectl kustomize output/k8s-application
echo 
read 

echo "Apply the kustomization..."
read 
echo "kubectl apply -k output/k8s-application"

kubectl apply -k output/k8s-application

echo
read 
echo "See the generated resources in the new namespace"
echo 
echo "kubectl get all --namespace application"
echo 
read 

kubectl get all --namespace application 

