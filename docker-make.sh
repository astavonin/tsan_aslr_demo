#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_docker() {
    docker run --rm --platform linux/amd64 \
        -v "${SCRIPT_DIR}":/workspace \
        -w /workspace \
        tsan-aslr-demo:latest \
        "$@"
}

case "${1:-build}" in
    build)
        run_docker make all
        ;;
    clean)
        run_docker make clean
        ;;
    *)
        echo "Unknown command: $1"
        echo "Usage: $0 [build|clean]"
        exit 1
        ;;
esac
