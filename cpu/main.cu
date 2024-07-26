#include <cstdio>
#include "data_loader.h"
#include "dinner123.h
#include <cuda_runtime.h>
using namespace std;
typedef unsigned long long ull;

const int HASH_SIZE = (1<<20);
const int N = 1000005;

int head[HASH_SIZE+5];
ull keys[N]; float vals[N];



int main() {
    data_loader<ull> Keys("../part_0.keys");
    data_loader<vec<64>> Values("../part_0.vals");
    
    table.insert(Keys.data(), Values.data(), Keys.count());
    return 0;
}