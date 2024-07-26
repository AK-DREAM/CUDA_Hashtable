#include <cstddef>

template <size_t dim>
struct vec {
    float v[dim];
};

template <typename T>
class data_loader {
public:
    data_loader(const char *name);
    size_t count();
    T* data();

private:
    T *buf; 
    size_t file_size;
};
