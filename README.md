# docker-quantch
Author: Pavlo Shkuropatskyi

Docker setup file for Quantchallenge 2025

This Docker image sets up a shared dev environment for the HKU competition projects, cloning repos via HTTPS with a GitHub token.

What is this?
Clones both hku-data and hku-comp-fix repos automatically on build using a GitHub token
Python 3.11 with all required dependencies pre-installed in a uv venv
GPU acceleration support with CUDA 12.1, PyTorch, TensorFlow, and CuPy
Everyone works in the same environment
Git LFS support for large data files
What's inside
CUDA 12.1 runtime for GPU acceleration
Python 3.11 and essential packages
Git and Git LFS configured
Pre-installed: pandas, numpy, scikit-learn, pyarrow, psutil, jupyter
GPU frameworks: PyTorch (CUDA), TensorFlow (GPU), CuPy (CUDA)
RAPIDS 25.8: cuDF, cuML, cuGraph, cuxfilter, cuCIM, cuVS
Tools: vim, nano, curl, wget, tree, htop
Both repos cloned into /workspace-hku/
Quick Start
Build the GPU-enabled image (using buildkit and secret token):

Windows PowerShell:
$env:DOCKER_BUILDKIT=1; docker build --secret id=GITHUB_TOKEN,src=./token.txt -t hku-docker-env-gpu  .

Linux:
DOCKER_BUILDKIT=1 docker build --secret id=GITHUB_TOKEN,src=./token.txt -t hku-docker-env-gpu  .

# Run the container with GPU access:
docker run --gpus all -it --rm hku-docker-env-gpu

# Test GPU acceleration:
python gpu_test.py

# Test RAPIDS (cuDF/cuML):
python -c "import cudf, cuml; print('cuDF', cudf.__version__, 'cuML', cuml.__version__)"
