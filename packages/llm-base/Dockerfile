# syntax=docker/dockerfile:1

ARG BASE_IMAGE=jetson-stacks/base
FROM --platform=$BUILDPLATFORM ${BASE_IMAGE}

WORKDIR /root/tmp

# install torch nightly
ARG PINNED_TORCH_VERSION
RUN --mount=type=cache,target=/root/.cache/uv \
    if [ -n "$PINNED_TORCH_VERSION" ]; then \
      pkgs="$PINNED_TORCH_VERSION"; \
    else \
      pkgs="torch torchaudio torchvision"; \
    fi && \
    uv pip install $pkgs --pre --index-url https://download.pytorch.org/whl/nightly/cu130

RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install numba==0.62

ARG MAX_JOBS=16
COPY ./xformers ./xformers
RUN --mount=type=cache,target=/root/.cache/ccache \
      --mount=type=cache,target=/root/.cache/uv \
    uv pip install -v --no-build-isolation -U ./xformers
