#include <iostream>
#include <thread>
#include <atomic>

// Use regular int for actual data race that TSan can detect
int shared_counter = 0;

void increment_counter(int thread_id, int iterations) {
    for (int i = 0; i < iterations; ++i) {
        // Intentional data race for demonstration
        // Non-atomic read-modify-write on shared variable
        int old_value = shared_counter;
        shared_counter = old_value + 1;

        // Small delay to make race more likely
        for (volatile int j = 0; j < 100; ++j) {}
    }
    std::cout << "Thread " << thread_id << " finished" << std::endl;
}

int main() {
    std::cout << "Starting TSan ASLR demonstration..." << std::endl;

    const int num_threads = 4;
    const int iterations = 1000;

    std::thread threads[num_threads];

    // Start threads
    for (int i = 0; i < num_threads; ++i) {
        threads[i] = std::thread(increment_counter, i, iterations);
    }

    // Join threads
    for (int i = 0; i < num_threads; ++i) {
        threads[i].join();
    }

    std::cout << "Final counter value: " << shared_counter << std::endl;
    std::cout << "Expected value: " << (num_threads * iterations) << std::endl;

    return 0;
}
