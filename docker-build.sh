#!/bin/bash

set -e

IMAGE_NAME="tsan-aslr-demo"
IMAGE_TAG="latest"

docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" .

