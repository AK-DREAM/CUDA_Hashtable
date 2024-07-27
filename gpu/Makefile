objects = data_loader.o dinner123.o main.o 
args = -arch=sm_70 -O3

main : $(objects)
	nvcc -o main $(objects) $(args) 

data_loader.o : data_loader.cu
	nvcc -c data_loader.cu $(args)

dinner123.o : dinner123.cu
	nvcc -c dinner123.cu $(args)

main.o : main.cu data_loader.h	
	nvcc -c main.cu $(args)
