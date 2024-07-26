objects = data_loader.o dinner123.o main.o 

main : $(objects)
	g++ -o main $(objects)

data_loader.o : data_loader.cpp data_loader.h
	g++ -c data_loader.cpp

dinner123.o : dinner123.cu data_loader.h dinner123.h
	nvcc -c dinner123.cu

main.o : main.cpp data_loader.h	
	g++ -c main.cpp
