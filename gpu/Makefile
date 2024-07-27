objects = data_loader.o main.o 
args = -arch=sm_70 

main : $(objects)
	nvcc -o main $(objects) $(args) 

data_loader.o : data_loader.cpp data_loader.h
	g++ -c data_loader.cpp -O3

main.o : main.cu data_loader.h	
	nvcc -c main.cu $(args) -O3
