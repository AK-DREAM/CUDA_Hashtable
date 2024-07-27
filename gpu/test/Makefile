main : test_speed.o dinner123.o
	nvcc -o main test_speed.o dinner123.o -arch=sm_70 -O3

test_speed.o : test_speed.cu
	nvcc -c test_speed.cu -O3 -arch=sm_70 

dinner123.o : ../dinner123.cu
	nvcc -c ../dinner123.cu -arch=sm_70 -O3
