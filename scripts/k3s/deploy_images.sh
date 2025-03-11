#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 -i <images_tar> -b <binary> -d <deploy_dir>"
    echo "  -i  path to the k3s images tar file"
    echo "  -b  path to the k3s binary"
    echo "  -d  deployment directory (default: /var/lib/rancher/k3s)"
    exit 1
}

# Default deployment directory
DEPLOY_DIR="/var/lib/rancher/k3s"

# Parse command-line arguments
while getopts ":i:b:d:" opt; do
    case ${opt} in
        i) IMAGES_TAR=${OPTARG} ;;
        b) BINARY=${OPTARG} ;;
        d) DEPLOY_DIR=${OPTARG} ;;
        *) usage ;;
   esac
done

# Check if images tar and binary are provided
if [ -z "${IMAGES_TAR}" ] || [ -z "${BINARY}" ]; then
    usage
fi

# Create the deployment directory if it doesn't exist
mkdir -p "${DEPLOY_DIR}/agent/images"

# Deploy k3s binary
install -m 755 "${BINARY}" "/usr/local/bin/k3s"

# Deploy k3s images
cp "${IMAGES_TAR}" "${DEPLOY_DIR}/agent/images/"

echo "Deployment completed. Files are deployed to ${DEPLOY_DIR}"