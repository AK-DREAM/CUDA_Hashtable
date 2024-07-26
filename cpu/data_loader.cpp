#include <cstdio>
#include <cstdlib>
#include "data_loader.h"
using namespace std;

template <typename T>
data_loader<T>::data_loader(const char *name) {
    FILE *IN = fopen("../part_0.keys", "rb");
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
template class data_loader<vec<64>>;