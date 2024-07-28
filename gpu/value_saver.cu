#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <cuda_runtime.h>
#include "value_saver.h"
#include "mytools.h"
using namespace std;
typedef unsigned long long ull;

value_saver::value_saver() {
    cudaHostAlloc(&vals, MAX_SIZ, cudaHostAllocMapped);
    cudaSetDevice(1);
    cudaMalloc(&d_vals, DEV_SIZ);
    cudaSetDevice(0);
    valptr = vals; d_valptr = d_vals;
    offset = 0; flg = -1;
}

void value_saver::save(size_t siz, const vec *v, int typ) {
    size_t cnt = siz/sizeof(vec);
    if (!~flg && valptr+cnt > vals+MAX_CNT) {
        flg = offset;
    }
    if (!~flg) {
        if (typ == 0) {
            memcpy(valptr, v, siz);
        } else {
            cudaMemcpy(valptr, v, siz, cudaMemcpyDeviceToHost);
        }
        valptr += cnt;
    } else {
        if (typ == 0) {
            cudaMemcpy(d_valptr, v, siz, cudaMemcpyHostToDevice);
            d_valptr += cnt;
        } else {
            cudaMemcpyPeer(d_valptr, 1, v, 0, siz);
            d_valptr += cnt;
        }
    }
    offset += cnt;
}

size_t value_saver::qoffset() {
    return offset;
}

size_t value_saver::onHost() {
    return flg;
}

vec* value_saver::hostData() {
    return vals;
}

vec* value_saver::deviceData() {
    return d_vals;
}