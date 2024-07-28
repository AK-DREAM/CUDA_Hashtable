#ifndef DINNER123
#define DINNER123

#include <utility>
#include "mytools.h"
#include "myvec.h"
#include "data_loader.h"
using namespace std;
typedef unsigned long long ull;

#define TSIZ 30

class dinner123 {
public:
    dinner123();
    void insert(size_t cnt, const ull* keys, const vec* values, cudaStream_t stream);
    void Insert(const char *keyfile, const char *valfile);
    void find(size_t cnt, const ull* keys, vec* values, bool* exists, cudaStream_t stream);
    void Find(const char *keyfile);

    float insTime, fndTime;
private:
    ull *Keys, *Vals;
    bool *Exi; vec *Ans;
    data_loader loader;
    value_saver saver;
};

#endif