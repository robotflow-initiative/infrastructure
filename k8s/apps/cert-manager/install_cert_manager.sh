#!/bin/bash

# Function to prompt the user and get input
prompt() {
    read -p "$1" response
    echo "$response"
}

# Check if kubectl is installed
kubectl_version=$(kubectl version --client 2>&1)
if [[ $? -ne 0 ]]; then
    echo "kubectl is not installed on the target host. Please install kubectl and try again."
    exit 1
else
    echo "kubectl is present on the target host. version=$kubectl_version"
fi

# Prompt for the Cert-Manager version
certmanager_version=$(prompt "Please enter the default Cert-Manager version to install [v1.15.1]: ")
if [[ -z "$certmanager_version" ]]; then
    certmanager_version="v1.15.1"
fi

# Validate Cert-Manager version
if ! [[ $certmanager_version =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Cert-Manager version is not valid. Please enter a valid version."
    exit 1
fi

# Check if Cert-Manager is installed
kubectl get ns cert-manager &>/dev/null
if [[ $? -eq 0 ]]; then
    echo "Cert-Manager is already installed on the target host."
    exit 1
fi

# Install Cert-Manager
kubectl apply -f "https://github.com/cert-manager/cert-manager/releases/download/${certmanager_version}/cert-manager.yaml"
if [[ $? -eq 0 ]]; then
    echo "Cert-Manager is installed on the target host."
else
    echo "Cert-Manager is not installed on the target host. Please check the logs for more information."
    exit 1
fi
