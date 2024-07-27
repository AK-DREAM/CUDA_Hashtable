#include <bits/stdc++.h>
using namespace std;
typedef unsigned long long ull;


#define CUDA_CHECK_ERROR() { \
    cudaError_t err = cudaGetLastError(); \
    if (err != cudaSuccess) { \
        std::cerr << "CUDA Error: " << cudaGetErrorString(err) << std::endl; \
        exit(-1); \
    } else { \
        std::cerr << "OK!\n"; \
    } \
}

const int N = 5000000;
mt19937_64 rng(time(0));
ull keys[N+5], qry[N<<4|5];
float vals[N<<6|5];

int main() {
    int n = 200000000, Q = 0;
    ull mask = 0;
    mask = ~mask;
    FILE *F1 = fopen("./my.keys", "w");
    for (int i = 0; i < n; i += N) {
        cerr << i << endl;
        int c = min(N,n-i);
        for (int j = 0; j < c; j++) {
            keys[j] = rng()&mask;
            if (!(rng()&63)) qry[Q++] = keys[j];
        }
        fwrite(keys, 1, c*sizeof(ull), F1);
    }
    fclose(F1);
    FILE *F2 = fopen("./my.vals", "w");
    for (int i = 0; i < n; i += N) {
        cerr << i << endl;
        int c = min(N,n-i);
        for (int j = 0; j < (c<<6); j++) vals[j] = rng()&63;
        fwrite(vals, 1, (c<<6)*sizeof(float), F2);
    }
    fclose(F2);
    return 0;
}