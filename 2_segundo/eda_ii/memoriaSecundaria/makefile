pruebaDispersion: pruebaDispersion.c modificarReg.o dispersion.o
	gcc -g pruebaDispersion.c modificarReg.o dispersion.o -o pruebaDispersion

modificarReg.o:  modificarReg.c
	gcc -c -g modificarReg.c -o modificarReg.o

dispersion.o: dispersion.h dispersion.c
	gcc -c -g dispersion.c -o dispersion.o

clean:
	rm *.o
