#include <cstdio>
#include "data_loader.h"
#include <iostream>
#include <algorithm>
#include <cuda_runtime.h>
using namespace std;
typedef unsigned long long ull;

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
__device__ vec<64> Vals[1<<K];
vec<64> Ans[N];

__device__ unsigned hash_val(ull key) {
    return key&((1<<K)-1);
}

__device__ void insert1(ull key, vec<64> val) {
    unsigned hs = hash_val(key);
    while (1) {
        ull now = atomicCAS(&Keys[hs], 0, key);
        if (!now || now == key) {
            Vals[hs] = val;
            return;
        }
        hs = (hs+1)&((1<<K)-1);
    }
}
__global__ void insert_kernel(ull *d_keys, vec<64> *d_vals, int cnt) {
    LOOP(i, cnt) {
        insert1(d_keys[i], d_vals[i]);
    }
}
__global__ void print_kernel() {
    printf("Hello");
}

void insert(ull *h_keys, vec<64> *h_vals, int cnt) {
    ull *d_keys; vec<64> *d_vals;
    cudaMalloc(&d_keys, sizeof(ull)*cnt);
    cudaMalloc(&d_vals, sizeof(vec<64>)*cnt);
    cudaMemcpy(d_keys, h_keys, sizeof(ull)*cnt, cudaMemcpyHostToDevice);
    cudaMemcpy(d_vals, h_vals, sizeof(vec<64>)*cnt, cudaMemcpyHostToDevice);
    insert_kernel<<<1,1>>>(d_keys, d_vals, cnt);
    cudaDeviceSynchronize();
    CUDA_CHECK_ERROR();
    cudaFree(d_keys); cudaFree(d_vals);
}

__device__ vec<64> query1(ull key) {
    unsigned hs = hash_val(key);
    while (1) {
        if (Keys[hs] == key) return Vals[hs];
        else if (!Keys[hs]) return Vals[0];
        hs = (hs+1)&((1<<K)-1);
    }
}
__global__ void query_kernel(ull *d_keys, vec<64> *d_ans, int cnt) {
    LOOP(i, cnt) {
        d_ans[i] = query1(d_keys[i]);
    }
}
void query(ull *h_keys, vec<64> *h_ans, int cnt) {
    reverse(h_keys, h_keys+cnt);
    ull *d_keys; vec<64> *d_ans;
    cudaMalloc(&d_keys, sizeof(ull)*cnt);
    cudaMalloc(&d_ans, sizeof(vec<64>)*cnt);
    cudaMemcpy(d_keys, h_keys, sizeof(ull)*cnt, cudaMemcpyHostToDevice);
    query_kernel<<<64,64>>>(d_keys, d_ans, cnt);
    cudaMemcpy(h_ans, d_ans, sizeof(vec<64>) *cnt, cudaMemcpyDeviceToHost);
    cudaFree(d_keys); cudaFree(d_ans);
}

int main() {
    data_loader<ull> data_Keys("../part_0.keys");
    data_loader<vec<64>> data_Vals("../part_0.vals");
    insert(data_Keys.data(), data_Vals.data(), data_Keys.count());
    query(data_Keys.data(), Ans, data_Keys.count());
    int cnt = data_Keys.count();
    printf("%d\n", cnt);
    for (int i = 0; i < cnt; i++) {
        for (int j = 0; j < 64; j++) printf("%f ", Ans[i].v[j]);
        puts("");
    }
    return 0;
}