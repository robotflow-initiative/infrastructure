#!/bin/bash

# Prompt for user input
read -p "Enter the name for the Conda environment: " env_name
read -p "Enter the Python version to install (e.g., 3.10): " python_version
python_version=${python_version:-3.10}
read -p "Enter the CUDA version to install (e.g., 11.8.0): " cuda_version
cuda_version=${cuda_version:-11.8.0}

# Create Conda environment with specified Python version
if [[ -d $CONDA_PREFIX/envs/$env_name ]]; then
    echo "Conda environment '$env_name' already exists, skipping creation..."
else
    echo "Creating Conda environment '$env_name' with Python $python_version..."
    conda create -y -n $env_name python=$python_version
fi

# Install CUDA toolkit in the Conda environment
echo "Installing CUDA toolkit $cuda_version in environment '$env_name'..."
conda install -y -n $env_name nvidia/label/cuda-$cuda_version::cuda

# Verify the Conda environment and list installed packages
echo "Listing installed packages in environment '$env_name'..."
conda_list=$(conda list -n $env_name)

# Print the list of installed packages
echo "$conda_list"
