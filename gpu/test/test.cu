#include <cstdio>
#include <iostream>
#include <cuda_runtime.h>
using namespace std;
#define CUDA_CHECK_ERROR() { \
    cudaError_t err = cudaGetLastError(); \
    if (err != cudaSuccess) { \
        std::cerr << "CUDA Error: " << cudaGetErrorString(err) << std::endl; \
        exit(-1); \
    } else { \
        std::cerr << "OK!\n"; \
    } \
}

__global__ void test_kernel(int cnt, int *a, int *b) {
    int i = threadIdx.x;
    if (i < 100) b[i] = *(a+i);
}

__global__ void print_kernel(int cnt, int *b) {
    int i = threadIdx.x;
    if (i < 100) printf("%d\n", b[i]);
}

int main() {
    int *a, *b;
    cudaHostAlloc(&a, 100*sizeof(int), cudaHostAllocMapped);
    cudaMalloc(&b, 100*sizeof(int));
    for (int i = 0; i < 100; i++) a[i] = i;
    test_kernel<<<1,100>>>(100, a, b);
    cudaDeviceSynchronize();
    CUDA_CHECK_ERROR();
    print_kernel<<<1,100>>>(100, b);
    cudaDeviceSynchronize();
    CUDA_CHECK_ERROR();
    return 0;
}