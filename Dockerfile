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
        make \
        util-linux \
        ca-certificates && \
    ln -s /usr/bin/clang-14 /usr/bin/clang && \
    ln -s /usr/bin/clang++-14 /usr/bin/clang++ && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Verify installations
RUN clang++ --version && \
    make --version && \
    setarch --version

# Set working directory
WORKDIR /demo
