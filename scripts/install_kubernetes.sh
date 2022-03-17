#!/bin/bash

#set -x

# Setup kube config -> /home/ubuntu/.kube/config

export OCI_CLI_AUTH=instance_principal
oci ce cluster create-kubeconfig --cluster-id ${oke_cluster_id} --auth instance_principal

# Download kubectl
curl -LO https://dl.k8s.io/release/${kubectlVersion}/bin/linux/amd64/kubectl

# Checksum verification
curl -LO "https://dl.k8s.io/${kubectlVersion}/bin/linux/amd64/kubectl.sha256"
echo "$(<kubectl.sha256)  kubectl" | sha256sum --check

if [ $? -ne 0 ]
then
    echo 'Invalid checksum for the for downloaded kubectl installtion file.'
    exit 1
fi

# Install kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Make sure head node can use kubectl.
kubectl get pods

if [ $? -ne 0 ]
then
    echo '[ERROR] kubectl failed to get pods.'
fi

echo 'applying oraclek8s...'

kubectl apply -f /tmp/oraclek8s.yaml
if [ $? -ne 0 ]
then
    echo '[ERROR] kubectl failed to apply oraclek8s'
else
    echo 'successfully applied oraclek8s'
fi

# Deploy Metrics Server to OKE
# Ref Oracle Doc:
# https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengdeployingmetricsserver.htm#Deploying_Kubernetes_Metrics_Server_Using_Kubectl

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.5.0/components.yaml
if [ $? -ne 0 ]
then
    echo '[ERROR] kubectl failed to deploy metrics-server'
fi

# Deploy Cronjob to delete failed pods
kubectl apply -f /tmp/cleanup_pods.yaml
if [ $? -ne 0 ]
then
    echo '[ERROR] kubectl failed to apply cleanup_pods cronjob'
fi

rm kubectl
