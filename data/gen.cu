#include <cuda_runtime.h>
#include <curand.h>
#include <cstdio>
using namespace std;
typedef unsigned long long ull;

const int N = 1000000;

curandGenerator_t gen;
ull keys[N+5];
float vals[N<<6|5];

void Init() {
    curandCreateGenerator(&gen, CURAND_RNG_PSEUDO_DEFAULT);
    curandSetPseudoRandomGeneratorSeed(gen, time(0));
    
}

int main() {
    Init();
    int n = 100000000;
    FILE *F1 = fopen("./my2.keys", "w");
    for (int i = 0; i < n; i += N) {
        curandGenerateLongLong(gen, keys, N);
        fwrite(keys, 1, N*sizeof(ull), F1);
    }
    fclose(F1);
    FILE *F2 = fopen("./my2.vals", "w");
    for (int i = 0; i < n; i += N) {
        curandGenerateUniform(gen, vals, N<<6);
        fwrite(vals, 1, (N<<6)*sizeof(float), F2);
    }
    return 0;
}