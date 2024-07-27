#include <cstdio>
#include "data_loader.h"
#include "mytools.h"
#include <iostream>
#include <algorithm>
#include <cuda_runtime.h>
using namespace std;
typedef unsigned long long ull;
typedef vec<64> T;

const int K = 30;

__device__ unsigned hash_val(ull key) {
    return key&((1<<K)-1);
}

__device__ void insert1(ull *Keys, ull *Vals, ull key, ull ptr) {
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

__global__ void insert_kernel(ull *Keys, ull *Vals, ull *d_keys, ull *d_ptr, int cnt) {
    LOOP(i, cnt) {
        insert1(Keys, Vals, d_keys[i], *d_ptr+i*sizeof(T));
    }
}

void insert(ull *Keys, ull *Vals, ull *h_keys, T *h_ptr, int cnt) {
    ull *d_keys; ull *d_ptr;
    ull num = (ull)h_ptr;
    cudaMalloc(&d_keys, sizeof(ull)*cnt);
    cudaMalloc(&d_ptr, sizeof(ull));
    cudaMemcpy(d_keys, h_keys, sizeof(ull)*cnt, cudaMemcpyHostToDevice);
    cudaMemcpy(d_ptr, &num, sizeof(ull), cudaMemcpyHostToDevice);  

    auto work = [&]() {
        insert_kernel<<<64,64>>>(Keys, Vals, d_keys, d_ptr, cnt);
        cudaDeviceSynchronize();
    };
    work();
    
    cudaFree(d_keys); cudaFree(d_ptr);
}

__device__ ull query1(ull *Keys, ull *Vals, ull key) {
    unsigned hs = hash_val(key);
    while (1) {
        if (Keys[hs] == key) return Vals[hs];
        else if (!Keys[hs]) return NULL;
        hs = (hs+1)&((1<<K)-1);
    }
}
__global__ void query_kernel(ull *Keys, ull *Vals, ull *d_keys, ull *d_ans, int cnt) {
    LOOP(i, cnt) {
        d_ans[i] = query1(Keys, Vals, d_keys[i]);
    }
}
void query(ull *Keys, ull *Vals, ull *h_keys, ull *h_ans, int cnt) {
    reverse(h_keys, h_keys+cnt);
    ull *d_keys; ull *d_ans;
    cudaMalloc(&d_keys, sizeof(ull)*cnt);
    cudaMalloc(&d_ans, sizeof(ull)*cnt);
    cudaMemcpy(d_keys, h_keys, sizeof(ull)*cnt, cudaMemcpyHostToDevice);

    auto work = [&]() {
        query_kernel<<<64,64>>>(Keys, Vals, d_keys, d_ans, cnt);
        cudaDeviceSynchronize();
    };
    work();
    
    cudaMemcpy(h_ans, d_ans, sizeof(ull)*cnt, cudaMemcpyDeviceToHost);
    cudaFree(d_keys); cudaFree(d_ans);
}

int main() {
    data_loader<ull> data_Keys("../data/my2.keys");
    data_loader<T> data_Vals("../data/my2.vals");
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
    // for (int i = 0; i < cnt; i++) if (Ans[i]) {
    //     for (int j = 0; j < 64; j++) printf("%f ", ((T*)Ans[i])->v[j]);
    //     puts("");
    // }
    return 0;
}