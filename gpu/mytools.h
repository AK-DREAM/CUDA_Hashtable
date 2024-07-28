#ifndef MYTOOLS
#define MYTOOLS

#define LOOP(i, n) \
    for (size_t i = threadIdx.x+blockIdx.x*blockDim.x; i < n; i += blockDim.x*gridDim.x) 

#define CUDA_CHECK_ERROR() { \
    cudaError_t err = cudaGetLastError(); \
    if (err != cudaSuccess) { \
        std::cerr << "CUDA Error: " << cudaGetErrorString(err) << std::endl; \
        exit(-1); \
    } else { \
        std::cerr << "OK!\n"; \
    } \
}

#define PERF_GPU(Sum, behavior)             \
    {                                       \
        cudaEvent_t start1;                 \
        cudaEventCreate(&start1);           \
        cudaEvent_t stop1;                  \
        cudaEventCreate(&stop1);            \
        cudaEventRecord(start1, NULL);      \
        behavior                            \
        cudaEventRecord(stop1, NULL);       \
        cudaEventSynchronize(stop1);        \
        float msecTotal1 = 0.0f;            \
        cudaEventElapsedTime(&msecTotal1, start1, stop1);   \
        Sum += msecTotal1; \
        printf("GPU time: %f\n", msecTotal1);  \
    } 

#endif