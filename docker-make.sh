#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USE_SETARCH=false

# Parse flags
while [[ $# -gt 0 ]]; do
    case "$1" in
        --setarch|-R)
            USE_SETARCH=true
            shift
            ;;
        *)
            break
            ;;
    esac
done

run_docker() {
    local docker_opts=""
    if [ "$USE_SETARCH" = true ]; then
        docker_opts="--security-opt seccomp=unconfined"
    fi

    docker run --rm --platform linux/amd64 \
        ${docker_opts} \
        -v "${SCRIPT_DIR}":/workspace \
        -w /workspace \
        tsan-aslr-demo:latest \
        "$@"
}

if [ "$USE_SETARCH" = true ]; then
    run_docker bash -c "setarch \$(uname -m) -R make ${*:-all}"
else
    run_docker make "${@:-all}"
fi
