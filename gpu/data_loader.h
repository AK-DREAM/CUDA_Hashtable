#include <cstddef>

struct vec {
    float v[8];
};

template <typename T>
class data_loader {
public:
    data_loader(const char *name);
    ~data_loader();
    size_t count();
    T* data();

private:
    T *buf; 
    size_t file_size;
};
