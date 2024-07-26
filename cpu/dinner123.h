#include "data_loader.h"
#include <cstddef>
typedef unsigned long long ull;

template <typename T>
class dinner123 {
public:
    dinner123(int _K);
    unsigned hash_val(ull key);
    __device__ void insert1(ull key, T val);
    __global__ void insert_kernel(ull *keys, T *vals, int cnt);
    void insert(ull *keys, T *vals, int cnt);
private:
    int K; 
    ull Keys; T *Vals;
};