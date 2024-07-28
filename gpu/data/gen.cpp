#include <bits/stdc++.h>
using namespace std;
#define N 1000
typedef unsigned long long ull;
const int Ins = 80ull * 1024 * 1024 * 1024 / (256 + 8) / N;
const int Qry = 80ull * 1024 * 1024 * 1024 / (256 + 8) / N;
#define mix(h) ({					\
			(h) ^= (h) >> 23;		\
			(h) *= 0x2127599bf4325c37ULL;	\
			(h) ^= (h) >> 47; })

ull hash_val(ull v, ull seed=114514) {
	const ull m = 0x880355f21e6d1965ULL;
	ull h = seed;
	h ^= mix(v);
	h *= m;
    return mix(h);
}
double qqq[4] = {.1,.1,.3,.5};
ull *a;
float *b;
mt19937_64 rnd1(11514);
mt19937 rnd2(123321);
signed main(){
    a=(ull*)malloc(Ins*sizeof(ull));
    b=(float*)malloc(Ins*256*sizeof(float));
    int gennums = 0;
    for(int i = 0; i < 4; i++){
        int ins = N*qqq[i], qry = N*qqq[i];
        printf("%d %d\n",ins,qry);
        while(ins--){
            static int cnt=0;
            for(int i=0;i<Ins;i++) 
                if(rnd2()&1)a[i] = hash_val(gennums++);
                else a[i] = rnd1();
            for(int i=0;i<Ins*64;i++) b[i] = (rnd2()&0xffff) / 100;
            FILE*f1=fopen(("A/part_"+to_string(cnt)+".keys").c_str(),"wb");
            fwrite(a, sizeof(ull), Ins, f1);
            fclose(f1);
            FILE*f2=fopen(("A/part_"+to_string(cnt)+".vals").c_str(),"wb");
            fwrite(b, sizeof(float), Ins * 64, f2);
            fclose(f2);
            cnt++;
        }
        while(qry--){
            static int cnt=1;
            for(int i=0;i<Qry;i++) 
                if(rnd2()&1) a[i] = hash_val(rnd2()%gennums);
                else a[i] = rnd1();
            FILE*f1=fopen(("B/part_"+to_string(cnt)+".keys").c_str(),"wb");
            fwrite(a, sizeof(ull), Qry, f1);
            fclose(f1);
            cnt++;
        }
    }
}