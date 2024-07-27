#include <cstdio>
#include <iostream>
#include <algorithm>
#include <cuda_runtime.h>
#include "data_loader.h"
#include "mytools.h"
using namespace std;
typedef unsigned long long ull;

const int K = 30;

#define mix(h) ({					\
			(h) ^= (h) >> 23;		\
			(h) *= 0x2127599bf4325c37ULL;	\
			(h) ^= (h) >> 47; })

__device__ ull hash_val(ull v, ull seed=114514) {
	const ull m = 0x880355f21e6d1965ULL;
	ull h = seed;
	h ^= mix(v);
	h *= m;
    return mix(h)&((1u<<K)-1);
}

__device__ void insert1(ull *Keys, ull *Vals, ull key, ull ptr) {
    unsigned hs = hash_val(key);
    while (1) {
        ull now = atomicCAS(&Keys[hs], 0, key);
        if (!now || now == key) {
            Vals[hs] = ptr;
            return;
        }
        hs = (hs+1)&((1u<<K)-1);
    }
}

__global__ void insert_kernel(ull *Keys, ull *Vals, ull *d_keys, ull d_ptr, int cnt) {
    LOOP(i, cnt) {
        insert1(Keys, Vals, d_keys[i], d_ptr+i*sizeof(TP));
    }
}

void insert(ull *Keys, ull *Vals, ull *h_keys, TP *h_ptr, int cnt) {
    ull *d_keys; 
    cudaMalloc(&d_keys, sizeof(ull)*cnt);
    cudaMemcpy(d_keys, h_keys, sizeof(ull)*cnt, cudaMemcpyHostToDevice);

    auto work = [&]() {
        insert_kernel<<<80,64>>>(Keys, Vals, d_keys, (ull)h_ptr, cnt);
        cudaDeviceSynchronize();
    };
    work();
    cudaFree(d_keys); 
}

__device__ ull query1(ull *Keys, ull *Vals, ull key) {
    unsigned hs = hash_val(key);
    while (1) {
        if (Keys[hs] == key) return Vals[hs];
        else if (!Keys[hs]) return NULL;
        hs = (hs+1)&((1u<<K)-1);
    }
}
__global__ void query_kernel(ull *Keys, ull *Vals, ull *d_keys, ull *d_ans, int cnt) {
    LOOP(i, cnt) {
        d_ans[i] = query1(Keys, Vals, d_keys[i]);
    }
}
void query(ull *Keys, ull *Vals, ull *h_keys, ull *h_ans, int cnt) {
    // reverse(h_keys, h_keys+cnt);
    ull *d_keys; ull *d_ans;
    cudaMalloc(&d_keys, sizeof(ull)*cnt);
    cudaMalloc(&d_ans, sizeof(ull)*cnt);
    cudaMemcpy(d_keys, h_keys, sizeof(ull)*cnt, cudaMemcpyHostToDevice);

    auto work = [&]() {
        query_kernel<<<80,64>>>(Keys, Vals, d_keys, d_ans, cnt);
        cudaDeviceSynchronize();
    };
    work();
    
    cudaMemcpy(h_ans, d_ans, sizeof(ull)*cnt, cudaMemcpyDeviceToHost);
    cudaFree(d_keys); cudaFree(d_ans);
}

int main() {
    data_loader<ull> data_Keys("../data/part_0.keys");
    data_loader<TP> data_Vals("../data/part_0.vals");
    puts("OK");
    ull *Keys, *Vals;
    cudaMalloc(&Keys, sizeof(ull)<<K);
    cudaMalloc(&Vals, sizeof(ull)<<K);
    ull *Ans = (ull*)malloc(data_Keys.count()*sizeof(ull));

    PERF_GPU(
        insert(Keys, Vals, data_Keys.data(), data_Vals.data(), data_Keys.count());
    );
    PERF_GPU(
        query(Keys, Vals, data_Keys.data(), Ans, data_Keys.count());
    );
    
    int cnt = data_Keys.count();
    printf("%d\n", cnt);
    for (int i = 0; i < 100; i++) if (Ans[i]) {
        for (int j = 0; j < 64; j++) printf("%f ", ((TP*)Ans[i])->v[j]);
        puts("");
    }
    return 0;
}