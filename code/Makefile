objects = data_loader.o main.o 

main : $(objects)
	nvcc -o main $(objects) -arch=sm_70

data_loader.o : data_loader.cpp data_loader.h
	g++ -c data_loader.cpp

main.o : main.cu data_loader.h	
	nvcc -c main.cu -arch=sm_70
