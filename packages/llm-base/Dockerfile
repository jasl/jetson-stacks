# syntax=docker/dockerfile:1

ARG BASE_IMAGE=jetson-stacks/base
FROM --platform=$BUILDPLATFORM ${BASE_IMAGE}

WORKDIR /root/tmp

RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install torch==2.9.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/test/cu130

RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install numba==0.62

COPY ./xformers ./xformers
ARG XFORMERS_DISABLE_FLASH_ATTN_3=1
ARG XFORMERS_MORE_DETAILS=1
# RUN --mount=type=cache,target=/root/.cache/ccache \
#       --mount=type=cache,target=/root/.cache/uv \
#     uv pip install --no-build-isolation -U ./xformers
RUN --mount=type=cache,target=/root/.cache/ccache \
      --mount=type=cache,target=/root/.cache/uv \
    cd xformers \
    && rm -rf build \
    && python3 setup.py bdist_wheel --dist-dir=./dist --verbose \
    && uv pip install ./dist/*.whl --verbose
