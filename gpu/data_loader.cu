#include <cstdio>
#include <cstdlib>
#include <assert.h>
#include <cuda_runtime.h>
#include "data_loader.h"
#include "mytools.h"
using namespace std;

template <typename T>
data_loader<T>::data_loader(const char *name) {
    FILE *IN = fopen(name, "rb");
    if (IN == nullptr) {
        puts("ERROR");
        assert(0);
    }
    fseek(IN, 0, SEEK_END);
    file_size = ftell(IN);
    rewind(IN);
    // buf = (T*)malloc(file_size);
    cudaHostAlloc(&buf, file_size, cudaHostAllocMapped);

    T* ptr = buf; long long res = file_size;
    while (res > 0) {
        size_t num = fread(ptr, 1, 1<<23, IN);
        ptr += num; res -= (1<<23);
        printf("%lld\n", res);
    }
    fclose(IN);
}

template <typename T>
data_loader<T>::~data_loader() {
    cudaFreeHost(buf);
}

template <typename T>
size_t data_loader<T>::count() {
    return file_size/sizeof(T);
}

template <typename T>
T* data_loader<T>::data() {
    return buf;
}

template class data_loader<unsigned long long>;
template class data_loader<vec>;