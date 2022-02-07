#!/bin/bash

# Setup kube config -> /home/ubuntu/.kube/config

export OCI_CLI_AUTH=instance_principal
oci ce cluster create-kubeconfig --cluster-id ${oke_cluster_id} --auth instance_principal
