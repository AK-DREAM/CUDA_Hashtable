objects = data_loader.o dinner123.o value_saver.o main.o 
args = -arch=sm_70 -lineinfo -g -G

main : $(objects)
	nvcc -o main $(objects) $(args) 

data_loader.o : data_loader.cu data_loader.h
	nvcc -c data_loader.cu $(args)

value_saver.o : value_saver.cu value_saver.h
	nvcc -c value_saver.cu $(args)

dinner123.o : dinner123.cu 
	nvcc -c dinner123.cu $(args)

main.o : main.cu
	nvcc -c main.cu $(args)

clean :  
	rm -f $(objects) main