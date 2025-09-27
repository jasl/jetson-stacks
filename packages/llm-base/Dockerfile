# syntax=docker/dockerfile:1

ARG BASE_IMAGE=jetson-stacks/base
FROM --platform=$BUILDPLATFORM ${BASE_IMAGE}

ENV TORCH_CUDA_ARCH_LIST="8.9;10.0;11.0;12.0"
# ENV UV_TORCH_BACKEND=cu130

ARG max_jobs=16
ENV MAX_JOBS=${max_jobs}
ENV CMAKE_BUILD_PARALLEL_LEVEL=${max_jobs}

ARG nvcc_threads=1
ENV NVCC_THREADS=${nvcc_threads}

WORKDIR /root/tmp

RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install -U mpi4py apache-tvm-ffi numpy scipy numba einops

RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install --pre -U torch==2.9.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/test/cu130

COPY ./triton ./triton
RUN --mount=type=cache,target=/root/.cache/ccache \
      --mount=type=cache,target=/root/.cache/uv \
      --mount=type=cache,target=/root/.cache/.triton \
    TRITON_HOME=/root/.cache/.triton \
    TRITON_BUILD_WITH_CCACHE=true \
    uv pip install --no-build-isolation --verbose -U ./triton

COPY ./xformers ./xformers
RUN --mount=type=cache,target=/root/.cache/ccache \
      --mount=type=cache,target=/root/.cache/uv \
    uv pip install --no-build-isolation --verbose -U ./xformers

COPY ./flash-attention ./flash-attention
RUN --mount=type=cache,target=/root/.cache/ccache \
      --mount=type=cache,target=/root/.cache/uv \
    FLASH_ATTN_CUDA_ARCHS=${CUDA_ARCH_LIST} \
    uv pip install --no-build-isolation --verbose -U ./flash-attention

COPY ./flashinfer ./flashinfer
RUN --mount=type=cache,target=/root/.cache/ccache \
      --mount=type=cache,target=/root/.cache/uv \
    cd ./flashinfer \
    && FLASHINFER_CUDA_ARCH_LIST=${TORCH_CUDA_ARCH_LIST//;/ } \
        python -m flashinfer.aot \
    && FLASHINFER_CUDA_ARCH_LIST=${TORCH_CUDA_ARCH_LIST//;/ } \
        uv pip install --no-build-isolation --verbose -U .

COPY ./transformers ./transformers
RUN --mount=type=cache,target=/root/.cache/ccache \
      --mount=type=cache,target=/root/.cache/uv \
    uv pip install --no-build-isolation --verbose -U "./transformers[torch]"

# Ensure use newer versions
RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install -U \
        mpi4py apache-tvm-ffi numpy scipy numba einops \
        cuda-python nvidia-cublas nvidia-nccl-cu${CUDA_VERSION_MAJOR} nvidia-cutlass-dsl nvidia-ml-py \
        nvidia-cudnn-cu${CUDA_VERSION_MAJOR} nvidia-cudnn-frontend \
        nvidia-cusparselt-cu${CUDA_VERSION_MAJOR} \
        cutensor-cu${CUDA_VERSION_MAJOR} \
        nvidia-nvshmem-cu${CUDA_VERSION_MAJOR} nvshmem4py-cu${CUDA_VERSION_MAJOR}

WORKDIR /root

# Clean up

RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /root/tmp && \
    && rm -rf /root/.cache

ENTRYPOINT [ "/bin/bash" ]
