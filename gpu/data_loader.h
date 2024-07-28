#ifndef DATA_LOADER 
#define DATA_LOADER

#include <cstddef>
#include "myvec.h"
#include "value_saver.h"
typedef unsigned long long ull;

class data_loader {
public:
    data_loader();
    ~data_loader();
    size_t load_keyfile(const char *name);
    size_t load_valfile(const char *name);
    ull* keydata();
    vec* valdata();
    bool onDevice();
private:
    ull *keybuf;
    vec *valbuf;
};

#endif