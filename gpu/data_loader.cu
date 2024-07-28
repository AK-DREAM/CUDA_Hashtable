#include <cstdio>
#include <cstdlib>
#include <assert.h>
#include <iostream>
#include <cuda_runtime.h>
#include "data_loader.h"
#include "mytools.h"
#include "value_saver.h"
using namespace std;
typedef unsigned long long ull;

data_loader::data_loader() {
    cudaHostAlloc(&keybuf, 2ull<<30, cudaHostAllocMapped);
    cudaHostAlloc(&valbuf, 2ull<<30, cudaHostAllocMapped);
}

data_loader::~data_loader() {
    cudaFreeHost(keybuf);
    cudaFreeHost(valbuf);
}

size_t data_loader::load_keyfile(const char *name) {
    FILE *IN = fopen(name, "rb");
    fseek(IN, 0, SEEK_END);
    size_t file_size = ftell(IN);
    rewind(IN);

    ull *ptr = keybuf; ull res = 0;
    while (res < file_size) {
        size_t num = fread(ptr, 1, 1ull<<30, IN);
        ptr += num/sizeof(ull); res += num;
    }
    fclose(IN);
    return file_size/sizeof(ull);
}
size_t data_loader::load_valfile(const char *name) {
    FILE *IN = fopen(name, "rb");
    fseek(IN, 0, SEEK_END);
    size_t file_size = ftell(IN);
    rewind(IN);

    size_t siz = fread(valbuf, 1, 1<<30, IN);

    fclose(IN);
    return siz;
}

ull* data_loader::keydata() {
    return keybuf;
}

vec* data_loader::valdata() {
    return valbuf;
}