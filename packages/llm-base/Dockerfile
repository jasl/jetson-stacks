# syntax=docker/dockerfile:1

ARG BASE_IMAGE=jetson-stacks/base
FROM --platform=$BUILDPLATFORM ${BASE_IMAGE}

# install torch nightly
ARG PINNED_TORCH_VERSION
RUN --mount=type=cache,target=/root/.cache/uv \
    if [ -n "$PINNED_TORCH_VERSION" ]; then \
      pkgs="$PINNED_TORCH_VERSION"; \
    else \
      pkgs="torch torchaudio torchvision"; \
    fi && \
    uv pip install --system $pkgs --index-url https://download.pytorch.org/whl/nightly/cu130

RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install --system numba==0.62
