# syntax=docker/dockerfile:1

FROM --platform=$BUILDPLATFORM ubuntu:24.04

WORKDIR /root/tmp

# Base system

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get -y --no-install-recommends install \
        apt-utils apt-transport-https ca-certificates lsb-release software-properties-common \
        binutils curl wget gnupg gnupg2 nano vim zip unzip xz-utils time sshpass ssh-client \
        libnuma-dev libibverbs-dev \
        python3 python-is-python3 python3-pip python3-venv python3-setuptools python3-dev \
        git git-lfs ccache build-essential ccache cmake llvm-20 clang-20 libclang-20-dev && \
    apt-get -y autoremove

# Setup CCACHE

ENV CCACHE_DIR=/root/.cache/ccache

# UV

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
RUN uv venv --python 3.12 --seed "/root/.venv"

# This timeout (in seconds) is necessary when installing some dependencies via uv since it's likely to time out
# Reference: https://github.com/astral-sh/uv/pull/1694
ENV UV_REQUEST_TIMEOUT=300
ENV UV_INDEX_STRATEGY="unsafe-best-match"
# Use copy mode to avoid hardlink failures with Docker cache mounts
ENV UV_LINK_MODE=copy

ENV VIRTUAL_ENV="/root/.venv"
ENV PATH="/root/.venv/bin:${PATH}"

RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install -U setuptools packaging pytest wheel build ninja cmake pybind11 lit filelock requests responses

# Nvidia APT source
ADD https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/sbsa/cuda-keyring_1.1-1_all.deb ./sbsa-cuda-keyring_1.1-1_all.deb
ADD https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb ./x86_64-cuda-keyring_1.1-1_all.deb
RUN <<EOF
case $(uname -m) in
    "aarch64")
        dpkg -i sbsa-cuda-keyring_1.1-1_all.deb
        ;;
    "x86_64")
        dpkg -i x86_64-cuda-keyring_1.1-1_all.deb
        ;;
    *)
        echo "Unsupported arch $(uname -m)"
        exit 1
        ;;
esac
EOF
RUN apt-get update

# CUDA 13.0

ENV CUDA_VERSION_MAJOR=13
ENV CUDA_VERSION_MINOR=0

RUN apt-get install -y --no-install-recommends \
    cuda-cudart-${CUDA_VERSION_MAJOR}-${CUDA_VERSION_MINOR} \
    cuda-compat-${CUDA_VERSION_MAJOR}-${CUDA_VERSION_MINOR} \
    cuda-libraries-${CUDA_VERSION_MAJOR}-${CUDA_VERSION_MINOR} \
    libnpp-${CUDA_VERSION_MAJOR}-${CUDA_VERSION_MINOR} \
    cuda-nvtx-${CUDA_VERSION_MAJOR}-${CUDA_VERSION_MINOR} \
    libcusparse-${CUDA_VERSION_MAJOR}-${CUDA_VERSION_MINOR} \
    libcublas-${CUDA_VERSION_MAJOR}-${CUDA_VERSION_MINOR} \
    libnccl2-${CUDA_VERSION_MAJOR}-${CUDA_VERSION_MINOR}

RUN apt-get install -y --no-install-recommends \
    cuda-cudart-dev-${CUDA_VERSION_MAJOR}-${CUDA_VERSION_MINOR} \
    cuda-minimal-build-${CUDA_VERSION_MAJOR}-${CUDA_VERSION_MINOR} \
    cuda-command-line-tools-${CUDA_VERSION_MAJOR}-${CUDA_VERSION_MINOR} \
    cuda-libraries-dev-${CUDA_VERSION_MAJOR}-${CUDA_VERSION_MINOR} \
    cuda-nvml-dev-${CUDA_VERSION_MAJOR}-${CUDA_VERSION_MINOR} \
    libnpp-dev-${CUDA_VERSION_MAJOR}-${CUDA_VERSION_MINOR} \
    libcusparse-dev-${CUDA_VERSION_MAJOR}-${CUDA_VERSION_MINOR} \
    libcublas-dev-${CUDA_VERSION_MAJOR}-${CUDA_VERSION_MINOR} \
    libnccl-dev-${CUDA_VERSION_MAJOR}-${CUDA_VERSION_MINOR} \
    cuda-nsight-compute-${CUDA_VERSION_MAJOR}-${CUDA_VERSION_MINOR}


RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install cuda-python nvidia-cublas nvidia-nccl-cu${CUDA_VERSION_MAJOR}

ENV CUDA_HOME="/usr/local/cuda"
ENV CUDA_TOOLKIT_PATH="${CUDA_HOME}"
ENV CUDA_TOOLKIT_ROOT_DIR="${CUDA_HOME}"
ENV CUDA_BIN_PATH="${CUDA_HOME}/bin"
ENV NVCC_PATH="${CUDA_BIN_PATH}/nvcc"
ENV CMAKE_CUDA_COMPILER="${NVCC_PATH}"
ENV CUDA_NVCC_EXECUTABLE="${NVCC_PATH}"
ENV CUDACXX="${NVCC_PATH}"

ENV LD_LIBRARY_PATH="${CUDA_HOME}/compat:${CUDA_HOME}/lib64"
ENV LDFLAGS="-L${CUDA_HOME}/lib64"

# Required for nvidia-docker v1
RUN echo "/usr/local/cuda/lib64" >> /etc/ld.so.conf.d/nvidia.conf

# === Fix -lcuda and CCCL includes ===
# Ensure that the linker searches stubs first and keeps previous flags
# CUDA 13 moved thrust/cub to include/cccl

ENV PATH="${CUDA_BIN_PATH}:${PATH}"
ENV LD_LIBRARY_PATH="${CUDA_HOME}/lib64/stubs:${LD_LIBRARY_PATH}"
ENV LIBRARY_PATH="${CUDA_HOME}/lib64/stubs"
ENV LDFLAGS="-L${CUDA_HOME}/lib64/stubs -Wl,-rpath,${CUDA_HOME}/lib64"
ENV CPLUS_INCLUDE_PATH="${CUDA_HOME}/include/cccl"
ENV C_INCLUDE_PATH="${CUDA_HOME}/include/cccl"

# Create symbolic links so that libcuda.so and libcuda.so.1 point to the CUDA stub libraries.
# This allows linking against CUDA when the actual driver libraries are not available at build time.
# The '-f' flag forces overwrite if the link or file already exists, and '|| true' prevents the build from failing if linking fails.
RUN ln -sf ${CUDA_HOME}/lib64/stubs/libcuda.so ${CUDA_HOME}/lib64/libcuda.so || true \
    && ln -sf ${CUDA_HOME}/lib64/stubs/libcuda.so.1 ${CUDA_HOME}/lib64/libcuda.so || true

# CUDNN

RUN apt-get -y --no-install-recommends install \
        libcudnn9-cuda-${CUDA_VERSION_MAJOR} libcudnn9-dev-cuda-${CUDA_VERSION_MAJOR}
RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install nvidia-cudnn-cu${CUDA_VERSION_MAJOR} nvidia-cutlass-dsl nvidia-cudnn-frontend

## cuSPARSELt

RUN apt-get -y --no-install-recommends install \
        cusparselt-cuda-${CUDA_VERSION_MAJOR}
RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install nvidia-cusparselt-cu${CUDA_VERSION_MAJOR}

RUN ln -s /usr/lib/$(uname -m)-linux-gnu/libcusparseLt.a /usr/lib/$(uname -m)-linux-gnu/libcusparseLt_static.a

## cuDSS

# # TODO: cuDSS doesn't support CUDA 13 yet
# RUN apt-get -y --no-install-recommends install \
#         cudss

## cuTensor
RUN apt-get -y --no-install-recommends install \
        cutensor-cuda-${CUDA_VERSION_MAJOR}
RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install cutensor-cu${CUDA_VERSION_MAJOR}

## NVSHMEM

RUN apt-get -y --no-install-recommends install \
        nvshmem-cuda-${CUDA_VERSION_MAJOR} openmpi-bin libopenmpi-dev
RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install nvidia-nvshmem-cu${CUDA_VERSION_MAJOR} nvshmem4py-cu${CUDA_VERSION_MAJOR}

# GDRCopy

ADD https://developer.download.nvidia.com/compute/redist/gdrcopy/CUDA%2013.0/ubuntu24_04/aarch64/libgdrapi_2.5.1-1_arm64.Ubuntu24_04.deb ./
ADD https://developer.download.nvidia.com/compute/redist/gdrcopy/CUDA%2013.0/ubuntu24_04/x64/libgdrapi_2.5.1-1_amd64.Ubuntu24_04.deb ./
RUN <<EOF
case $(uname -m) in
    "aarch64")
        dpkg -i libgdrapi_2.5.1-1_arm64.Ubuntu24_04.deb
        ;;
    "x86_64")
        dpkg -i libgdrapi_2.5.1-1_amd64.Ubuntu24_04.deb
        ;;
    *)
        echo "Unsupported arch $(uname -m)"
        exit 1
        ;;
esac
EOF

## NVPL

RUN <<EOF
if [ "$(uname -m)" = aarch64 ]; then
    apt-get -y --no-install-recommends install \
        nvpl
fi
EOF
RUN --mount=type=cache,target=/root/.cache/uv <<EOF
if [ "$(uname -m)" = aarch64 ]; then
    uv pip install nvpl
fi
EOF

# Clean up

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /root/tmp

# Setup ENVs

ENV CUDA_ARCH_LIST="89;100;110;120;121"
ENV CUDAARCHS="${CUDA_ARCH_LIST}"
ENV CUDA_ARCHITECTURES="${CUDA_ARCH_LIST}"
ENV NVCC_GENCODE="-gencode=arch=compute_89,code=sm_89 \
    -gencode=arch=compute_100f,code=sm_100 \
    -gencode=arch=compute_110f,code=sm_110 \
    -gencode=arch=compute_120f,code=sm_120"

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

WORKDIR /root

ENTRYPOINT [ "/bin/bash" ]
