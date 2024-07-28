#include <utility>
#include <cstdio>
#include <iostream>
#include <algorithm>
#include <cuda_runtime.h>
#include <assert.h>
#include <string>
#include "mytools.h"
#include "dinner123.h"
using namespace std;
typedef unsigned long long ull;

dinner123::dinner123() {
    cudaMalloc(&Keys, sizeof(ull)<<TSIZ);
    cudaMalloc(&Vals, sizeof(ull)<<TSIZ);
    cudaHostAlloc(&Exi, 1ull<<30, cudaHostAllocMapped);
    cudaHostAlloc(&Ans, 1ull<<30, cudaHostAllocMapped); 
    insTime = fndTime = 0;
}

#define mix(h) ({					\
			(h) ^= (h) >> 23;		\
			(h) *= 0x2127599bf4325c37ULL;	\
			(h) ^= (h) >> 47; })

__device__ ull hash_val(ull v, ull seed=114514) {
	const ull m = 0x880355f21e6d1965ULL;
	ull h = seed;
	h ^= mix(v);
	h *= m;
    return mix(h)&((1ull<<TSIZ)-1);
}

__device__ void insert1(ull *Keys, ull *Vals, ull key, ull ptr) {
    unsigned hs = hash_val(key);
    while (1) {
        ull now = atomicCAS(&Keys[hs], 0, key);
        if (!now || now == key) {
            atomicMax(&Vals[hs], ptr);
            return;
        }
        hs = (hs+1)&((1ull<<TSIZ)-1);
    }
}
__global__ void insert_kernel(ull *Keys, ull *Vals, const ull *d_keys, ull offset, size_t cnt) {
    LOOP(i, cnt) {
        insert1(Keys, Vals, d_keys[i], offset+i);
    }
}
void dinner123::insert(size_t cnt, const ull* keys, const vec* values, cudaStream_t stream = 0) {
    ull offset = saver.qoffset();
    saver.save(cnt*sizeof(vec), values, 1);
    insert_kernel<<<80,1024>>>(Keys, Vals, keys, offset, cnt);
    cudaDeviceSynchronize();
}
void dinner123::Insert(const char *keyfile, const char *valfile) {
    size_t cnt = loader.load_keyfile(keyfile); 
    ull offset = saver.qoffset();
    size_t siz = loader.load_valfile(valfile);

    auto exec = [&]() {
        saver.save(siz, loader.valdata(), 0);
        insert_kernel<<<80,1024>>>(Keys, Vals, loader.keydata(), offset, cnt);
    };
    PERF_GPU(insTime, exec(););
    cudaDeviceSynchronize();

    puts(~saver.onHost()?"Device":"Host");
}

__device__ ull query1(ull *Keys, ull *Vals, ull key) {
    unsigned hs = hash_val(key);
    while (1) {
        if (Keys[hs] == key) return Vals[hs];
        else if (!Keys[hs]) return (1ull<<63);
        hs = (hs+1)&((1u<<TSIZ)-1);
    }
}
__global__ void query_kernel(ull *Keys, ull *Vals, const ull *d_keys, ull *Ptr, bool *Exi, size_t cnt) {
    LOOP(i, cnt) {
        Ptr[i] = query1(Keys, Vals, d_keys[i]);
        Exi[i] = !(Ptr[i]>>63&1);
    }
}

__global__ void findVal_kernel0(vec *data, const ull *Ptr, vec *Ans, size_t cnt, size_t flg) {
    LOOP(i, cnt<<5) {
        int id = i>>5, j = i&31;
        if ((Ptr[id]>>63&1) || Ptr[id] >= flg) continue;
        float *pt1 = (float*)(Ans+id), *pt2 = (float*)(data+Ptr[id]);
        *(pt1+j) = *(pt2+j);
        *(pt1+j+32) = *(pt2+j+32);
    }
}

__global__ void findVal_kernel1(vec *data, ull *Ptr, vec *Ans, size_t cnt, size_t flg) {
    LOOP(i, cnt<<5) {
        int id = i>>5, j = i&31;
        if ((Ptr[id]>>63&1) || Ptr[id] < flg) continue;
        float *pt1 = (float*)(Ans+id), *pt2 = (float*)(data+Ptr[id]);
        *(pt1+j) = *(pt2+j);
        *(pt1+j+32) = *(pt2+j+32);
    }
}

void dinner123::find(size_t cnt, const ull* d_keys, vec* Ans, bool* Exi, cudaStream_t stream = 0) {
    ull *Ptr; cudaMalloc(&Ptr, cnt*sizeof(ull));
    query_kernel<<<80,1024>>>(Keys, Vals, d_keys, Ptr, Exi, cnt);
    cudaDeviceSynchronize();
    size_t flg = saver.onHost();
    findVal_kernel0<<<80,1024>>>(saver.hostData(), Ptr, Ans, cnt, flg);
    if (~flg) {
        cudaSetDevice(1);
        ull *Ptr1; cudaMalloc(&Ptr1, cnt*sizeof(ull));
        vec *Ans1; cudaMalloc(&Ans1, cnt*sizeof(vec));
        cudaMemcpyPeer(Ptr1, 1, Ptr, 0, cnt*sizeof(ull));
        findVal_kernel1<<<80,1024>>>(saver.deviceData(), Ptr1, Ans1, cnt, flg);
        cudaMemcpy(Ans, Ans1, cnt*sizeof(vec), cudaMemcpyDeviceToHost);
        cudaSetDevice(0);
    }
    cudaDeviceSynchronize();
}

string changeExtension(const char *file, string ext) {
    string str(file);
    size_t pos = str.rfind('.');
    str.replace(pos, std::string::npos, ext);
    return str.c_str();
}

void dinner123::Find(const char *keyfile) {
    size_t cnt = loader.load_keyfile(keyfile); 
    auto exec = [&]() {
        find(cnt, loader.keydata(), Ans, Exi);
    };
    PERF_GPU(fndTime, exec(););
    FILE *OUT0 = fopen(changeExtension(keyfile, ".myvals").c_str(), "wb");
    fwrite(Ans, 1, cnt*sizeof(vec), OUT0);
    fclose(OUT0); 

    FILE *OUT1 = fopen(changeExtension(keyfile, ".exists").c_str(), "wb");
    fwrite(Exi, 1, cnt*sizeof(bool), OUT1);
    fclose(OUT1);
}
