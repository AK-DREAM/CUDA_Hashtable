#include <cstdio>
#include "data_loader.h"
#include <iostream>
#include <algorithm>
#include <cuda_runtime.h>
using namespace std;
typedef unsigned long long ull;
typedef vec<64> T;

#define LOOP(i, n) \
    for (size_t i = threadIdx.x+blockIdx.x*blockDim.x; i < n; i += blockDim.x*gridDim.x) 

#define CUDA_CHECK_ERROR() { \
    cudaError_t err = cudaGetLastError(); \
    if (err != cudaSuccess) { \
        std::cerr << "CUDA Error: " << cudaGetErrorString(err) << std::endl; \
        exit(-1); \
    } \
}

const int N = 1000005, K = 20;

__device__ ull Keys[1<<K]; 
__device__ ull Vals[1<<K];
ull Ans[N];

__device__ unsigned hash_val(ull key) {
    return key&((1<<K)-1);
}

__device__ void insert1(ull key, ull ptr) {
    unsigned hs = hash_val(key);
    while (1) {
        ull now = atomicCAS(&Keys[hs], 0, key);
        if (!now || now == key) {
            Vals[hs] = ptr;
            return;
        }
        hs = (hs+1)&((1<<K)-1);
    }
}

__global__ void insert_kernel(ull *d_keys, ull *d_ptr, int cnt) {
    LOOP(i, cnt) {
        insert1(d_keys[i], *d_ptr+i*sizeof(T));
    }
}

void insert(ull *h_keys, T *h_ptr, int cnt) {
    ull *d_keys; ull *d_ptr;
    ull num = (ull)h_ptr;
    cudaMalloc(&d_keys, sizeof(ull)*cnt);
    cudaMalloc(&d_ptr, sizeof(ull));
    cudaMemcpy(d_keys, h_keys, sizeof(ull)*cnt, cudaMemcpyHostToDevice);
    cudaMemcpy(d_ptr, &num, sizeof(ull), cudaMemcpyHostToDevice);  
    insert_kernel<<<64,64>>>(d_keys, d_ptr, cnt);
    cudaFree(d_keys); cudaFree(d_ptr);
}

__device__ ull query1(ull key) {
    unsigned hs = hash_val(key);
    while (1) {
        if (Keys[hs] == key) return Vals[hs];
        else if (!Keys[hs]) return NULL;
        hs = (hs+1)&((1<<K)-1);
    }
}
__global__ void query_kernel(ull *d_keys, ull *d_ans, int cnt) {
    LOOP(i, cnt) {
        d_ans[i] = query1(d_keys[i]);
    }
}
void query(ull *h_keys, ull *h_ans, int cnt) {
    reverse(h_keys, h_keys+cnt);
    ull *d_keys; ull *d_ans;
    cudaMalloc(&d_keys, sizeof(ull)*cnt);
    cudaMalloc(&d_ans, sizeof(ull)*cnt);
    cudaMemcpy(d_keys, h_keys, sizeof(ull)*cnt, cudaMemcpyHostToDevice);
    query_kernel<<<64,64>>>(d_keys, d_ans, cnt);
    cudaMemcpy(h_ans, d_ans, sizeof(ull)*cnt, cudaMemcpyDeviceToHost);
    cudaFree(d_keys); cudaFree(d_ans);
}

int main() {
    data_loader<ull> data_Keys("../part_0.keys");
    data_loader<T> data_Vals("../part_0.vals");

    insert(data_Keys.data(), data_Vals.data(), data_Keys.count());
    query(data_Keys.data(), Ans, data_Keys.count());
    int cnt = data_Keys.count();
    printf("%d\n", cnt);
    for (int i = 0; i < cnt; i++) if (Ans[i]) {
        for (int j = 0; j < 64; j++) printf("%f ", ((T*)Ans[i])->v[j]);
        puts("");
    }
    return 0;
}