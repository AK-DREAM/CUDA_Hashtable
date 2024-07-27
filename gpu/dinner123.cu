#include <utility>
#include <cstdio>
#include <iostream>
#include <algorithm>
#include <cuda_runtime.h>
#include "data_loader.h"
#include "mytools.h"
#include "dinner123.h"
using namespace std;
typedef unsigned long long ull;

#define mix(h) ({					\
			(h) ^= (h) >> 23;		\
			(h) *= 0x2127599bf4325c37ULL;	\
			(h) ^= (h) >> 47; })

__device__ ull hash_val(ull v, ull seed=114514) {
	const ull m = 0x880355f21e6d1965ULL;
	ull h = seed;
	h ^= mix(v);
	h *= m;
    return mix(h)&((1u<<TSIZ)-1);
}

__device__ void insert1(ull *Keys, ull *Vals, ull key, ull ptr) {
    unsigned hs = hash_val(key);
    while (1) {
        ull now = atomicCAS(&Keys[hs], 0, key);
        if (!now || now == key) {
            atomicMax(&Vals[hs], ptr);
            return;
        }
        hs = (hs+1)&((1u<<TSIZ)-1);
    }
}

__global__ void insert_kernel(ull *Keys, ull *Vals, ull *d_keys, ull d_ptr, int cnt) {
    LOOP(i, cnt) {
        insert1(Keys, Vals, d_keys[i], d_ptr+i*sizeof(vec));
    }
}

dinner123::dinner123() {
    cudaMalloc(&Keys, sizeof(ull)<<TSIZ);
    cudaMalloc(&Vals, sizeof(ull)<<TSIZ);
}

void dinner123::insert(size_t cnt, ull *h_keys, ull h_ptr) {
    ull *d_keys; 
    d_keys = h_keys;
    // cudaMalloc(&d_keys, sizeof(ull)*cnt);
    // cudaMemcpy(d_keys, h_keys, sizeof(ull)*cnt, cudaMemcpyHostToDevice);

    auto work = [&]() {
        insert_kernel<<<80,1024>>>(Keys, Vals, d_keys, h_ptr, cnt);
        cudaDeviceSynchronize();
    };
    work();
    // cudaFree(d_keys); 
}

__device__ ull query1(ull *Keys, ull *Vals, ull key) {
    unsigned hs = hash_val(key);
    while (1) {
        if (Keys[hs] == key) return Vals[hs];
        else if (!Keys[hs]) return NULL;
        hs = (hs+1)&((1u<<TSIZ)-1);
    }
}
__global__ void query_kernel(ull *Keys, ull *Vals, ull *d_keys, ull *d_ans, bool *d_ok, int cnt) {
    LOOP(i, cnt) {
        d_ans[i] = query1(Keys, Vals, d_keys[i]);
        d_ok[i] = !!d_ans[i];
    }
}
void dinner123::query(size_t cnt, ull *h_keys, ull *h_ans, bool *h_ok) {
    //reverse(h_keys, h_keys+cnt);
    ull *d_keys, *d_ans; bool *d_ok;
    d_keys = h_keys; d_ans = h_ans; d_ok = h_ok;
    // cudaHostGetDevicePointer(&d_keys, h_keys, 0);
    // cudaHostGetDevicePointer(&d_ans, h_ans, 0);
    // cudaHostGetDevicePointer(&d_ok, h_ok, 0);
    // cudaMalloc(&d_keys, sizeof(ull)*cnt);
    // cudaMalloc(&d_ans, sizeof(ull)*cnt);
    // cudaMalloc(&d_ok, sizeof(bool)*cnt);
    // cudaMemcpy(d_keys, h_keys, sizeof(ull)*cnt, cudaMemcpyHostToDevice);

    auto work = [&]() {
        query_kernel<<<80,1024>>>(Keys, Vals, d_keys, d_ans, d_ok, cnt);
        cudaDeviceSynchronize();
    };
    work();
    
    // cudaMemcpy(h_ans, d_ans, sizeof(ull)*cnt, cudaMemcpyDeviceToHost);
    // cudaMemcpy(h_ok, d_ok, sizeof(bool)*cnt, cudaMemcpyDeviceToHost);
    // cudaFree(d_keys); 
    // cudaFree(d_ans); 
    // cudaFree(d_ok);
}