# syntax=docker/dockerfile:1.4
FROM nvidia/cuda:12.5.0-devel-ubuntu22.04

# Set environment variables for CUDA and GPU optimization
ENV DEBIAN_FRONTEND=noninteractive
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}
ENV USE_GPU=1
ENV CUDA_VISIBLE_DEVICES=0

WORKDIR /workspace-hku

# Install system dependencies (stable - cache this layer)
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    git \
    git-lfs \
    curl \
    wget \
    vim \
    nano \
    tree \
    htop \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create symlink for python
RUN ln -s /usr/bin/python3 /usr/bin/python

# Install Python tools (stable - cache this layer)
RUN git lfs install
RUN pip3 install uv

# Install GPU frameworks (stable - cache this layer)
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
RUN pip3 install tensorflow[gpu]
RUN pip3 install cupy-cuda12x

# Install RAPIDS 25.8 (cuDF, cuML, cuGraph, cuCIM, cuVS, etc.)
RUN pip3 install --extra-index-url=https://pypi.nvidia.com \
    "cudf-cu12==25.8.*" "dask-cudf-cu12==25.8.*" "cuml-cu12==25.8.*" \
    "cugraph-cu12==25.8.*" "nx-cugraph-cu12==25.8.*" "cuxfilter-cu12==25.8.*" \
    "cucim-cu12==25.8.*" "pylibraft-cu12==25.8.*" "raft-dask-cu12==25.8.*" \
    "cuvs-cu12==25.8.*"

# Clone repos (changes frequently - put last)
RUN --mount=type=secret,id=GITHUB_TOKEN \
    GITHUB_TOKEN=$(cat /run/secrets/GITHUB_TOKEN) && \
    git clone https://$GITHUB_TOKEN@github.com/LevRoz630/hku-comp-fix.git /workspace-hku/hku-comp-fix && \
    GIT_LFS_SKIP_SMUDGE=1 git clone https://$GITHUB_TOKEN@github.com/LevRoz630/hku-data.git /workspace-hku/hku-data

# Pull LFS files (changes frequently - put last)
RUN cd /workspace-hku/hku-data && \
    echo "Verifying Git LFS installation..." && \
    git lfs version && \
    echo "Starting LFS pull with retry logic..." && \
    for i in 1 2 3; do \
        echo "Attempt $i to pull LFS files..." && \
        git lfs pull --include="*.parquet,*.csv" && \
        echo "LFS pull successful on attempt $i" && \
        break || \
        (echo "Attempt $i failed, waiting before retry..." && sleep 30); \
    done && \
    echo "Verifying LFS files were downloaded..." && \
    git lfs ls-files

# Install Python requirements (changes frequently - put last)
RUN cd /workspace-hku/hku-comp-fix && \
    git checkout main && \
    pip3 install -r requirements.txt

# Verify installations (stable - cache this layer)
RUN python3 -c "import torch; print(f'PyTorch {torch.__version__} with CUDA {torch.version.cuda}')"
RUN python3 -c "import tensorflow as tf; print(f'TensorFlow {tf.__version__}')"
RUN python3 -c "import cudf; print(f'cuDF {cudf.__version__}')"

CMD ["/bin/bash"]
