# TSan ASLR Demo

Minimal example showing ThreadSanitizer (TSan) failure on modern Linux due to ASLR conflicts.

## The Problem

TSan crashes on Linux 6.6+ with high ASLR entropy:
```
FATAL: ThreadSanitizer: unexpected memory mapping 0x...
```

TSan supports 30-bit ASLR, but modern kernels use 32-bit by default. Shared libraries map into TSan's shadow memory space and it aborts. This was fixed in LLVM 18.1.0+ (2024), which auto-retries without randomization.

## The Fix

Disable ASLR for the test process:
```bash
setarch $(uname -m) -R ./your_test
```

Or in Docker, add `--security-opt seccomp=unconfined` to allow the personality syscall.

## Quick Start

Build and run locally:
```bash
make all
make run-setarch
```

Or use Docker:
```bash
./docker-build.sh
./docker-make.sh build
./docker-make.sh --setarch run-pie  # Run with ASLR disabled
```

## Files

- `simple_test.cpp` - Minimal test with intentional data race
- `Makefile` - Builds PIE/non-PIE versions
- `Dockerfile` - Ubuntu 24.04 + clang-14 setup
- `docker-make.sh` - Build helper script

## Reference

GitHub issue: https://github.com/google/sanitizers/issues/1716

Fixed automatically in clang 18.1.0+, but the `setarch` workaround works with any version.
