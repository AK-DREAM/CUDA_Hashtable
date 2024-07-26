#include <cstdio>
#include <cuda_runtime.h>
#include "dinner123.h"
using namespace std;
typedef unsigned long long ull;


#define LOOP(i, n) \
    for (size_t i = threadIdx.x+blockIdx.x*blockDim.x; i < n; i += blockDim.x*gridDim.x) 

template <typename T>
dinner123<T>::dinner123(int _K): K(_K) {
    cudaMalloc(&Keys, sizeof(ull)<<K);
    cudaMalloc(&Vals, sizeof(T)<<K);
}

template <typename T>
unsigned dinner123<T>::hash_val(ull key) {
    return key&((1<<K)-1);
}

template <typename T>
__device__ void dinner123<T>::insert1(ull key, T val) {
    unsigned hs = hash_val(key);
    while (1) {
        ull now = atomicCAS(&Keys[hs], 0, key);
        if (!now || now == key) {
            Vals[hs] = val;
            return;
        }
        now = (now+1)&((1<<K)-1);
    }
}

template <typename T>
__global__ void insert_kernel(ull *h_keys, T *h_vals, int cnt) {
    LOOP(i, cnt) {
        insert1(h_keys[i], h_vals[i]);
    }
}

template <typename T>
void dinner123<T>::insert(ull *h_keys, T *h_vals, int cnt) {
    ull *d_keys; T *d_vals;
    cudaMalloc(&d_keys, sizeof(ull)*cnt);
    cudaMalloc(&d_vals, sizeof(T)*cnt);
    cudaMemcpy(d_keys, h_keys, sizeof(ull)*cnt, cudaMemcpyHostToDevice);
    cudaMemcpy(d_vals, h_vals, sizeof(T)*cnt, cudaMemcpyHostToDevice);
    insert_kernel<<<64,1024>>><T>(d_keys, d_vals, cnt);
}