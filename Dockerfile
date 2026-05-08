# Multi-stage Dockerfile to build P-Coder for Windows and Linux
# Usage: docker build -t p-coder-builder .
#        docker run --rm -v $(pwd):/workspace p-coder-builder

FROM rust:latest

# Install cross-compilation toolchains and dependencies
RUN apt-get update && apt-get install -y \
    mingw-w64 \
    mingw-w64-tools \
    build-essential \
    pkg-config \
    libssl-dev \
    zip \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Setup Rust targets
RUN rustup target add \
    x86_64-pc-windows-gnu \
    x86_64-unknown-linux-gnu \
    && rustup update

# Set working directory
WORKDIR /workspace

# Default command: build both platforms
ENTRYPOINT ["/bin/bash", "/workspace/docker-build.sh"]
