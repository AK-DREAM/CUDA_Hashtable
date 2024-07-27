#include <cstdio>
#include <iostream>
#include <algorithm>
#include <cuda_runtime.h>
#include "data_loader.h"
#include "mytools.h"
#include "dinner123.h"
using namespace std;
typedef unsigned long long ull;

int main() {
    data_loader<ull> data_Keys("../data/my2.keys");
    data_loader<vec> data_Vals("../data/my2.vals");

    dinner123 Hashtable;
    ull *Ans; // = (ull*)malloc(data_Keys.count()*sizeof(ull));
    // cudaMallocHost(&Ans, data_Keys.count()*sizeof(ull));
    cudaHostAlloc(&Ans, data_Keys.count()*sizeof(ull), cudaHostAllocMapped);
    bool *Ok; // = (bool*)malloc(data_Keys.count()*sizeof(bool));; 
    // cudaMallocHost(&Ok, data_Keys.count()*sizeof(bool));
    cudaHostAlloc(&Ok, data_Keys.count()*sizeof(bool), cudaHostAllocMapped);

    PERF_GPU(
        Hashtable.insert(data_Keys.count(), data_Keys.data(), (ull)data_Vals.data());
    );
    CUDA_CHECK_ERROR();
    PERF_GPU(
        Hashtable.query(data_Keys.count(), data_Keys.data(), Ans, Ok);
    );
    CUDA_CHECK_ERROR();
    
    int cnt = data_Keys.count();
    printf("%d\n", cnt);
    for (int i = 0; i < 1; i++) if (Ok[i]) {
        for (int j = 0; j < 64; j++) printf("%f ", ((vec*)Ans[i])->v[j]);
        puts("");
    }
    cudaFreeHost(Ans);
    cudaFreeHost(Ok);
    return 0;
}