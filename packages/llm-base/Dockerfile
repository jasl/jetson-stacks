# syntax=docker/dockerfile:1

ARG BASE_IMAGE=jetson-stacks/base
FROM --platform=$BUILDPLATFORM ${BASE_IMAGE}

WORKDIR /root/tmp

ENV TORCH_NVCC_FLAGS="-Xfatbin -compress-all"
ENV TORCH_CUDA_ARCH_LIST="8.9;9.0;10.0;11.0;12.0;12.1"
ENV MAX_JOBS=16

RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install torch==2.9.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/test/cu130

RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install numba==0.62

COPY ./xformers ./xformers
RUN --mount=type=cache,target=/root/.cache/ccache \
      --mount=type=cache,target=/root/.cache/uv \
    uv pip install -v --no-build-isolation -U ./xformers
