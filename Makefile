CXX = clang++
CXXFLAGS = -std=c++17 -Wall -g
TSAN_FLAGS = -fsanitize=thread -fno-omit-frame-pointer
TSAN_LDFLAGS = -fsanitize=thread

# Targets
BINARY = simple_test
BINARY_PIE = simple_test_pie
BINARY_NO_PIE = simple_test_nopie

.PHONY: all clean run run-pie run-nopie run-setarch check-env help

all: $(BINARY_PIE) $(BINARY_NO_PIE)

# Build with PIE (default, will likely fail with TSan on high ASLR systems)
$(BINARY_PIE): simple_test.cpp
	$(CXX) $(CXXFLAGS) $(TSAN_FLAGS) $(TSAN_LDFLAGS) -o $@ $<

# Build without PIE (helps but may not be sufficient)
$(BINARY_NO_PIE): simple_test.cpp
	$(CXX) $(CXXFLAGS) $(TSAN_FLAGS) -fno-PIE $(TSAN_LDFLAGS) -no-pie -o $@ $<

# Check current ASLR settings
check-env:
	@echo "=== Environment Information ==="
	@echo "Clang version:"
	@$(CXX) --version | head -1
	@echo ""
	@echo "Current ASLR entropy (if accessible):"
	@cat /proc/sys/vm/mmap_rnd_bits 2>/dev/null || echo "  [Permission denied - run as root to check]"
	@echo ""
	@echo "Binary types:"
	@if [ -f $(BINARY_PIE) ]; then \
		echo "  $(BINARY_PIE): $$(readelf -h $(BINARY_PIE) 2>/dev/null | grep Type | awk '{print $$2}')"; \
	fi
	@if [ -f $(BINARY_NO_PIE) ]; then \
		echo "  $(BINARY_NO_PIE): $$(readelf -h $(BINARY_NO_PIE) 2>/dev/null | grep Type | awk '{print $$2}')"; \
	fi

# Run with PIE (likely to fail)
run-pie: $(BINARY_PIE)
	./$(BINARY_PIE) || echo "Exit code: $$?"

# Run without PIE (may still fail)
run-nopie: $(BINARY_NO_PIE)
	./$(BINARY_NO_PIE) || echo "Exit code: $$?"

# Run with setarch workaround (should work)
run-setarch: $(BINARY_NO_PIE)
	setarch $$(uname -m) -R ./$(BINARY_NO_PIE) || echo "Exit code: $$?"

# Run all scenarios
run: run-pie run-nopie run-setarch

# Default target
$(BINARY): $(BINARY_NO_PIE)
	cp $(BINARY_NO_PIE) $(BINARY)

clean:
	rm -f $(BINARY) $(BINARY_PIE) $(BINARY_NO_PIE)

help:
	@echo "TSan ASLR Demonstration Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  all          - Build both PIE and non-PIE versions"
	@echo "  run-pie      - Run PIE version (likely to fail on high ASLR systems)"
	@echo "  run-nopie    - Run non-PIE version (may still fail)"
	@echo "  run-setarch  - Run with setarch -R workaround (should work)"
	@echo "  run          - Run all three scenarios"
	@echo "  check-env    - Show environment information"
	@echo "  clean        - Remove built binaries"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "Docker usage:"
	@echo "  docker run --rm -v \$$(pwd):/work -w /work <image> make run-pie"
	@echo "  docker run --rm --security-opt seccomp=unconfined -v \$$(pwd):/work -w /work <image> make run-setarch"
