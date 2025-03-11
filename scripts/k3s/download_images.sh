#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 -v <version> -o <output_dir>"
    echo "  -v  k3s version to download"
    echo "  -o  output directory to save the files"
    exit 1
}

# Parse command-line arguments
while getopts ":v:o:" opt; do
    case ${opt} in
        v) VERSION=${OPTARG} ;;
        o) OUTPUT_DIR=${OPTARG} ;;
        *) usage ;;
    esac
done

# Check if version and output directory are provided
if [ -z "${VERSION}" ] || [ -z "${OUTPUT_DIR}" ]; then
    usage
fi

# Create the output directory if it doesn't exist
mkdir -p "${OUTPUT_DIR}"

# Download k3s binary
K3S_BINARY_URL="https://github.com/k3s-io/k3s/releases/download/${VERSION}/k3s"
curl -Lo "${OUTPUT_DIR}/k3s" "${K3S_BINARY_URL}"
chmod +x "${OUTPUT_DIR}/k3s"

# Download k3s images
K3S_IMAGES_URL="https://github.com/k3s-io/k3s/releases/download/${VERSION}/k3s-airgap-images-amd64.tar.zst"
curl -Lo "${OUTPUT_DIR}/k3s-airgap-images-amd64.tar.zst" "${K3S_IMAGES_URL}"

# Download k3s install script
K3S_INSTALL_URL="https://get.k3s.io"
curl -Lo "${OUTPUT_DIR}/k3s-install.sh" "${K3S_INSTALL_URL}"

echo "Download completed. Files are saved in ${OUTPUT_DIR}"