#include <cstdio>
#include <cstdlib>
#include <assert.h>
#include "data_loader.h"
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
    buf = (T*)malloc(file_size);
    fread(buf, 1, file_size, IN);
    fclose(IN);
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
template class data_loader<float>;
template class data_loader<vec<64>>;