# Minimal Docker image for reproducing TSan ASLR issue
# Based on Ubuntu with only essential tools for building and running TSan tests

FROM ubuntu:24.04

LABEL description="Minimal environment for demonstrating ThreadSanitizer ASLR issue"
LABEL maintainer="TSan ASLR Demo"

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install only essential packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        clang-14 \
        libclang-rt-14-dev \
        llvm-14 \
        make \
        util-linux \
        ca-certificates \
        sudo && \
    ln -s /usr/bin/clang-14 /usr/bin/clang && \
    ln -s /usr/bin/clang++-14 /usr/bin/clang++ && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Verify installations
RUN clang++ --version && \
    make --version && \
    setarch --version

RUN groupadd -g 1000 -o builder && \
    useradd -u 1000 -g 1000 -o --create-home --shell /bin/bash builder && \
    usermod -aG sudo builder && \
    echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/builder && \
    chmod 0440 /etc/sudoers.d/builder

USER builder
WORKDIR /workspace

ENV TSAN_OPTIONS="symbolize=1:external_symbolizer_path=/usr/lib/llvm-14/bin/llvm-symbolizer"
