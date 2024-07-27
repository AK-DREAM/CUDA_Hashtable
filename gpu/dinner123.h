#include <utility>
#include "mytools.h"
using namespace std;
typedef unsigned long long ull;

#define TSIZ 30

class dinner123 {
public:
    dinner123();
    void insert(size_t cnt, ull *h_keys, ull h_ptr);
    void query(size_t cnt, ull *h_keys, ull *h_ans, bool *exists);
private:
    int K;
    ull *Keys, *Vals;
};
