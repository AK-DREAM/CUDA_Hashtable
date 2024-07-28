#ifndef VALUE_SAVER
#define VALUE_SAVER

#include "myvec.h"
#include <cstddef>

#define MAX_SIZ (20ull<<30)
#define MAX_CNT (MAX_SIZ>>8)
#define DEV_SIZ (20ull<<30)

class value_saver {
public:
    value_saver();
    void save(size_t siz, const vec *v, int typ);
    size_t qoffset();
    size_t onHost();
    vec *hostData();
    vec *deviceData();
private:
    vec *vals, *d_vals, *valptr, *d_valptr;
    size_t offset, flg;
};

#endif