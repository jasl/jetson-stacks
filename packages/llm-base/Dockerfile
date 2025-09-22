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
    uv pip install $pkgs --index-url https://download.pytorch.org/whl/nightly/cu130

RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install numba==0.62

ARG XFORMERS_COMMIT=main
RUN git clone https://github.com/facebookresearch/xformers.git --recursive
RUN --mount=type=cache,target=/root/.cache/ccache \
     --mount=type=cache,target=/root/.cache/uv \
    cd xformers \
    && git fetch origin \
    && git checkout ${XFORMERS_COMMIT} \
    && git submodule update --init --recursive \
    && echo 'finish git clone xformers...' \
    && rm -rf build \
    && python3 setup.py bdist_wheel --dist-dir=../xformers-dist --verbose \
    && cd .. \
    && rm -rf xformers

RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install --system xformers-dist/*.whl --verbose
