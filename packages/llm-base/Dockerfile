# syntax=docker/dockerfile:1

ARG BASE_IMAGE=jetson-stacks/base
FROM --platform=$BUILDPLATFORM ${BASE_IMAGE}

ENV TRITON_PTXAS_PATH="${CUDA_HOME}/bin/ptxas"

ENV TORCH_CUDA_ARCH_LIST="8.9;9.0;10.0;11.0;12.0"
ENV FLASHINFER_CUDA_ARCH_LIST=${TORCH_CUDA_ARCH_LIST}
# ENV UV_TORCH_BACKEND=cu130

ARG max_jobs=16
ENV MAX_JOBS=${max_jobs}
ENV CMAKE_BUILD_PARALLEL_LEVEL=${max_jobs}

WORKDIR /root/tmp

RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install --pre torch==2.9.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/test/cu130

COPY ./triton ./triton
RUN --mount=type=cache,target=/root/.cache/ccache \
      --mount=type=cache,target=/root/.cache/uv \
    uv pip install --no-build-isolation --verbose -U ./triton

COPY ./xformers ./xformers
RUN --mount=type=cache,target=/root/.cache/ccache \
      --mount=type=cache,target=/root/.cache/uv \
    uv pip install --no-build-isolation --verbose -U ./xformers

COPY ./flash-attention ./flash-attention
RUN --mount=type=cache,target=/root/.cache/ccache \
      --mount=type=cache,target=/root/.cache/uv \
    uv pip install --no-build-isolation --verbose -U ./flash-attention

COPY ./flashinfer ./flashinfer
RUN --mount=type=cache,target=/root/.cache/ccache \
      --mount=type=cache,target=/root/.cache/uv \
    cd ./flashinfer \
    && python -m flashinfer.aot \
    && uv pip install --no-build-isolation --verbose -U .

COPY ./transformers ./transformers
RUN --mount=type=cache,target=/root/.cache/ccache \
      --mount=type=cache,target=/root/.cache/uv \
    uv pip install --no-build-isolation --verbose -U ./transformers[torch]

RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install -U "huggingface_hub[cli]"

RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install -U modelscope

WORKDIR /root

# Clean up

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /root/tmp

ENTRYPOINT [ "/bin/bash" ]
